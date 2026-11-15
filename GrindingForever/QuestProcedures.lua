local _, ns = ...
local E = ns.Forever
local Procedures = {}
ns.QuestProcedures = Procedures

local function positiveInteger(value)
    return type(value) == 'number' and value > 0 and value < math.huge and value % 1 == 0
end

local function recordFor(quest)
    local record = ns.QuestProcedureData and ns.QuestProcedureData[quest]
    if type(record) == 'table' and type(record.slots) == 'table' then return record end
end

local function questState(quest, state)
    local observed = state and state.quests and state.quests[quest]
    return observed or E.QuestState(quest)
end

local function trueValue(value)
    return E.Public(value) and (value == true or value == 1)
end

local function observedBool(value)
    if not E.Public(value) then return end
    if value == true or value == 1 then return true end
    if value == false or value == 0 then return false end
end

local function observedCount(value)
    if E.Public(value) and type(value) == 'number' and value >= 0 and value < math.huge then return value end
end

local function objectiveEvidence(live, slot, required)
    local objectives = live and live.objectives
    local objective = type(objectives) == 'table' and objectives[slot]
    if type(objective) ~= 'table' then return end
    local have = observedCount(objective.numFulfilled)
    local total = observedCount(objective.numRequired)
    if required then
        if not positiveInteger(required) or not have then return end
        return have >= required, have, required
    end
    local finished = observedBool(objective.finished)
    if finished or (have and total and total > 0 and have >= total) then return true, have, total end
    if finished == false or (have and total and total > 0) then return false, have, total end
end

local function savedRoot(create)
    if type(E.db) ~= 'table' then return end
    if type(E.db.questProcedureProgress) ~= 'table' then
        if not create then return end
        E.db.questProcedureProgress = {}
    end
    return E.db.questProcedureProgress
end

local function progressFor(context, slot, create)
    local root = savedRoot(create)
    if not root then return end
    local version = context.record.version or 1
    local saved = root[context.quest]
    if type(saved) ~= 'table' or saved.version ~= version or type(saved.slots) ~= 'table' then
        if not create then return end
        saved = {version = version, slots = {}}
        root[context.quest] = saved
    end
    if type(saved.slots[slot]) ~= 'table' then
        if not create then return end
        saved.slots[slot] = {}
    end
    return saved.slots[slot]
end

local function sequenceFor(context, slot)
    if context.sequences[slot] == nil then
        local definition = context.record.slots[slot]
        local phases = type(definition) == 'table' and definition.phases
        local ids = {}
        local valid = type(phases) == 'table' and #phases > 0
        if valid then
            for index, phase in ipairs(phases) do
                if type(phase) ~= 'table' or type(phase.id) ~= 'string' or phase.id == ''
                    or ids[phase.id] or type(phase.title) ~= 'string' or phase.title == '' then
                    valid = false
                    break
                end
                ids[phase.id] = index
            end
        end
        context.sequences[slot] = valid and {phases = phases, ids = ids, statuses = {}, acknowledgements = {}} or false
    end
    return context.sequences[slot]
end

local function inventoryCount(context, item)
    if not positiveInteger(item) and (type(item) ~= 'string' or item == '') then return end
    if context.inventory[item] == nil then
        local count = E.Call(C_Item and C_Item.GetItemCount or GetItemCount, item, false)
        context.inventory[item] = observedCount(count) or false
    end
    return context.inventory[item] or nil
end

local phaseStatus
local function evaluate(condition, context, slot, phase, confirm, depth)
    if type(condition) ~= 'table' or depth > 32 then return end
    local kind = condition.kind
    if kind == 'all' or kind == 'any' then
        local entries = condition.conditions
        if type(entries) ~= 'table' or #entries == 0 then return end
        local unknown = false
        for _, entry in ipairs(entries) do
            local result = evaluate(entry, context, slot, phase, confirm, depth + 1)
            if result == nil then unknown = true end
            if kind == 'all' and result == false then return false end
            if kind == 'any' and result == true then return true end
        end
        if not unknown then return kind == 'all' end
    elseif kind == 'item' then
        local need = condition.count or 1
        local have = inventoryCount(context, condition.item)
        if positiveInteger(need) and have then return have >= need end
    elseif kind == 'objective' then
        local targetSlot = condition.slot or slot
        if positiveInteger(targetSlot) then return objectiveEvidence(context.live, targetSlot, condition.count) end
    elseif kind == 'quest' then
        local quest = condition.quest or context.quest
        if not positiveInteger(quest) then return end
        local live = quest == context.quest and context.live or questState(quest, context.state)
        local field = condition.state
        if field == 'rewarded' and context.state and context.state.completed and context.state.completed[quest] then
            return true
        end
        if live and live.status ~= 'unavailable' then
            if field == 'inLog' or field == 'rewarded' then return observedBool(live[field]) end
            if field == 'ready' then return observedBool(live.ready) end
        end
    elseif kind == 'phase' then
        local targetSlot = condition.slot or slot
        if targetSlot ~= 0 and not positiveInteger(targetSlot) then return end
        local sequence = sequenceFor(context, targetSlot)
        local index = sequence and sequence.ids[condition.id]
        if not index then return end
        if objectiveEvidence(context.live, targetSlot) then return true end
        local status = phaseStatus(context, targetSlot, sequence, index)
        if status ~= 'fallback' then return status == 'complete' end
    elseif kind == 'manual' then
        if confirm then return true end
        local saved = progressFor(context, slot, false)
        return saved ~= nil and saved[phase.id] == 'confirmed'
    end
end

phaseStatus = function(context, slot, sequence, index)
    local statuses = sequence.statuses
    if statuses[index] == 'checking' then return 'fallback' end
    if statuses[index] then return statuses[index], sequence.acknowledgements[index] end
    statuses[index] = 'checking'

    local phase = sequence.phases[index]
    local function resolve()
        if index > 1 then
            local previous = phaseStatus(context, slot, sequence, index - 1)
            if previous ~= 'complete' then return previous == 'fallback' and 'fallback' or 'blocked' end
        end

        local saved = progressFor(context, slot, false)
        if phase.remember and saved and saved[phase.id] == 'observed' then return 'complete' end
        if phase.requires ~= nil then
            local allowed = evaluate(phase.requires, context, slot, phase, false, 1)
            if allowed == false then return 'blocked' end
            if allowed == nil then return 'fallback' end
        end

        local done = evaluate(phase.complete, context, slot, phase, false, 1)
        if done == true then
            if phase.remember and not (saved and saved[phase.id]) then
                saved = progressFor(context, slot, true)
                if saved then saved[phase.id] = 'observed' end
            end
            return 'complete'
        end

        -- For a manual alternative, the player's affirmative confirmation can
        -- resolve a phase even if the game's alternative evidence is unavailable.
        local canAcknowledge = evaluate(phase.complete, context, slot, phase, true, 1) == true
        if done == false or canAcknowledge then return 'current', canAcknowledge end
        return 'fallback'
    end

    local status, canAcknowledge = resolve()
    statuses[index] = status
    sequence.acknowledgements[index] = canAcknowledge
    return status, canAcknowledge
end

local function destinationFor(location)
    if type(location) ~= 'table' or not positiveInteger(location.mapID) then return end
    local x, y = location.x, location.y
    if type(x) ~= 'number' or not (x >= 0 and x <= 100)
        or type(y) ~= 'number' or not (y >= 0 and y <= 100) then return end
    return {mapID = location.mapID, x = x, y = y, name = location.name,
        npcID = location.npcID, sourceName = location.sourceName, zone = location.zone}
end

local function countRules(rule, matches, depth)
    if type(rule) ~= 'table' or depth > 32 or #matches > 1 then return end
    if (rule.kind == 'item' or rule.kind == 'objective') and positiveInteger(rule.count) and rule.count > 1 then
        matches[#matches + 1] = rule
    elseif (rule.kind == 'all' or rule.kind == 'any') and type(rule.conditions) == 'table' then
        for _, condition in ipairs(rule.conditions) do
            countRules(condition, matches, depth + 1)
        end
    end
end

local function displayCount(context, slot, phase)
    if type(phase.count) == 'string' then return phase.count end
    local need, have
    local rule = phase.progress or phase.complete
    if type(rule) ~= 'table' then return end
    if rule.kind == 'all' or rule.kind == 'any' then
        local matches = {}
        countRules(rule, matches, 1)
        if #matches ~= 1 then return end
        rule = matches[1]
    end
    if rule.kind == 'item' then
        need = rule.count or 1
        have = inventoryCount(context, rule.item)
    elseif rule.kind == 'objective' then
        local _, observed, required = objectiveEvidence(context.live, rule.slot or slot, rule.count)
        have, need = observed, required
    end
    if have and positiveInteger(need) then return string.format('%d/%d', have, need) end
end

local function current(context, slot)
    if slot ~= 0 and not positiveInteger(slot) then return nil, 'fallback' end
    local live = context.live
    if not live or live.status == 'unavailable' then return nil, 'fallback' end
    if trueValue(live.rewarded) or trueValue(live.ready) or trueValue(live.complete) then return nil, 'complete' end
    if not trueValue(live.inLog) then return nil, 'inactive' end
    if slot > 0 and objectiveEvidence(live, slot) then return nil, 'complete' end

    local sequence = sequenceFor(context, slot)
    if not sequence then return nil, 'fallback' end
    for index, phase in ipairs(sequence.phases) do
        local status, canAcknowledge = phaseStatus(context, slot, sequence, index)
        if status == 'current' then
            local upcoming = {}
            for nextIndex = index + 1, math.min(index + 2, #sequence.phases) do
                local nextPhase = sequence.phases[nextIndex]
                if nextPhase.requires then break end
                upcoming[#upcoming + 1] = nextPhase.title
            end
            local destination = destinationFor(phase.destination)
            local alternates
            for _, candidate in ipairs(phase.alternateDestinations or {}) do
                local location = destinationFor(candidate)
                if location then
                    alternates = alternates or {}
                    alternates[#alternates + 1] = location
                end
            end
            return {
                id = phase.id, quest = context.quest, slot = slot,
                title = phase.title, body = phase.body, action = phase.action,
                label = phase.label or phase.title, source = phase.source,
                count = displayCount(context, slot, phase), destination = destination,
                alternateDestinations = alternates,
                groupable = phase.groupable == true and destination ~= nil,
                canAcknowledge = canAcknowledge == true,
                phaseNumber = index, phaseCount = #sequence.phases, upcoming = upcoming,
            }, status
        elseif status ~= 'complete' then
            return nil, status
        end
    end
    return nil, 'complete'
end

local function contextFor(quest, live, state)
    local record = recordFor(quest)
    if not record then return end
    return {quest = quest, record = record, live = live or questState(quest, state), state = state,
        inventory = {}, sequences = {}}
end

function Procedures.Has(quest, slot)
    local record = recordFor(quest)
    return record ~= nil and (slot == nil or record.slots[slot] ~= nil)
end

function Procedures.Slots(quest)
    local slots = {}
    local record = recordFor(quest)
    for slot in pairs(record and record.slots or {}) do
        if slot == 0 or positiveInteger(slot) then slots[#slots + 1] = slot end
    end
    table.sort(slots)
    return slots
end

function Procedures.Current(quest, slot, live, state)
    local context = contextFor(quest, live, state)
    if not context then return nil, 'fallback' end
    return current(context, slot)
end

function Procedures.Candidates(quest, live, state)
    local context = contextFor(quest, live, state)
    local candidates = {}
    if context then
        for _, slot in ipairs(Procedures.Slots(quest)) do
            local phase = current(context, slot)
            if phase then candidates[#candidates + 1] = phase end
        end
    end
    return candidates
end

function Procedures.Signature(quest, live, state)
    local context = contextFor(quest, live, state)
    if not context then return '' end
    local parts = {}
    for _, slot in ipairs(Procedures.Slots(quest)) do
        local phase, status = current(context, slot)
        parts[#parts + 1] = phase and (phase.id .. ':' .. (phase.count or '') .. ':' .. tostring(phase.canAcknowledge)) or status
    end
    return table.concat(parts, '|')
end

function Procedures.Acknowledge(quest, slot, phaseID, live, state)
    local context = contextFor(quest, live, state)
    if not context then return false end
    local phase = current(context, slot)
    if not (phase and phase.canAcknowledge and phase.id == phaseID) then return false end
    local saved = progressFor(context, slot, true)
    if not saved then return false end
    saved[phase.id] = 'confirmed'
    return true
end

function Procedures.ResetQuest(quest)
    local saved = savedRoot(false)
    if saved and quest ~= nil then saved[quest] = nil end
end

function Procedures.Sync(state)
    local saved = savedRoot(false)
    if not saved then return end
    for quest in pairs(saved) do
        local live = positiveInteger(quest) and questState(quest, state)
        if not recordFor(quest) or (state and state.completed and state.completed[quest])
            or (live and (trueValue(live.rewarded) or (live.status == 'available' and observedBool(live.inLog) == false))) then
            saved[quest] = nil
        end
    end
end
