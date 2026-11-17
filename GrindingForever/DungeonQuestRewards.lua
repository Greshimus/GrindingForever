local _, ns = ...
local E = ns.Forever
local R = {}
ns.DungeonQuestRewards = R

local function number(value)
    if E.Public(value) and type(value) == "number" then return value end
end

local function text(value)
    if E.Public(value) and type(value) == "string" and value:find("%S") then return value end
end

local function positive(value)
    local actual = number(value)
    if actual and actual > 0 then return actual end
end

local function list(value)
    if E.Public(value) and type(value) == "table" then return value end
    return {}
end

function R.IsCached(id)
    local value = E.Call(C_QuestLog and C_QuestLog.IsQuestDataCached, id)
    return E.Public(value) and value == true
end

local function mergeItems(static, legacy, additional)
    local rows, seen = {}, {}
    local function add(items, isLegacy)
        for _, item in ipairs(items or {}) do
            local id = positive(item[1])
            local name = text(item[2])
            local key = id or name
            if key and not seen[key] then
                seen[key] = true
                local count = isLegacy and positive(item[4]) or not isLegacy and positive(item[3]) or nil
                rows[#rows + 1] = {id = id, name = name, count = count}
            end
        end
    end
    add(static, false)
    add(legacy, true)
    add(additional, true)
    return rows
end

local function withLiveItems(id, countFn, itemFn, offline, rewardKind)
    if not id or not itemFn then return offline end
    local total = number(E.Call(countFn, id))
    if not total or total <= 0 then return offline end
    local rows, offlineByID = {}, {}
    for _, item in ipairs(offline) do
        if item.id then offlineByID[item.id] = item end
    end
    local seen = {}
    -- The quest-log link API uses the selected quest on some clients.
    local selected = number(E.Call(C_QuestLog and C_QuestLog.GetSelectedQuest)) == id
    for slot = 1, total do
        local name, _, count, _, _, itemID = E.Call(itemFn, slot, id)
        itemID = positive(itemID)
        if itemID and not seen[itemID] then
            local prior = offlineByID[itemID]
            local link = selected and text(E.Call(GetQuestLogItemLink, rewardKind, slot))
            if link and tonumber(link:match("|Hitem:(%d+)[:|]")) ~= itemID then link = nil end
            rows[#rows + 1] = {
                id = itemID,
                name = text(name) or prior and prior.name,
                count = positive(count) or prior and prior.count,
                link = link or nil,
            }
            seen[itemID] = true
        end
    end
    -- The live quest log can return only the choices visible to this character.
    -- The Journal also lists documented choices for quests outside the active log.
    for _, item in ipairs(offline) do
        if not item.id or not seen[item.id] then rows[#rows + 1] = item end
    end
    return rows
end

local function amount(id, cached, getter, fallback)
    local live = id and number(E.Call(getter, id))
    if live and (live > 0 or live == 0 and cached) then return live, true end
    return positive(fallback), false
end

local function moneyText(copper)
    local denominations = {}
    local function append(value, symbol)
        if value > 0 then denominations[#denominations + 1] = value .. symbol end
    end
    append(math.floor(copper / 10000), "g")
    append(math.floor(copper / 100) % 100, "s")
    append(copper % 100, "c")
    return table.concat(denominations, " ")
end

local function localizedNumber(value)
    return text(E.Call(BreakUpLargeNumbers, value)) or tostring(value)
end

local function factionName(id, fallback)
    local data = E.Call(C_Reputation and C_Reputation.GetFactionDataByID, id)
    return text(list(data).name) or text(E.Call(GetFactionInfoByID, id)) or fallback or ("Faction #" .. id)
end

local function addCurrency(info, lines, seen)
    info = list(info)
    local id = positive(info.currencyID)
    local name = text(info.name)
    local count = positive(info.totalRewardAmount) or positive(info.baseRewardAmount)
    if id and not name then name = text(list(E.Call(C_CurrencyInfo and C_CurrencyInfo.GetCurrencyInfo, id)).name) end
    local key = id or name
    if key and count and not seen[key] then
        seen[key] = true
        lines[#lines + 1] = localizedNumber(count) .. " " .. (name or "Currency #" .. id)
    end
end

local function addCurrencies(id, summary, choices)
    local info = C_QuestInfoSystem or {}
    local currencies = list(E.Call(info.GetQuestRewardCurrencies, id))
    local seen = {}
    for _, currency in ipairs(currencies) do addCurrency(currency, summary, seen) end
    if #currencies == 0 then
        for slot = 1, number(E.Call(GetNumQuestLogRewardCurrencies, id)) or 0 do
            local name, _, count, currencyID = E.Call(GetQuestLogRewardCurrencyInfo, slot, id)
            addCurrency({name = name, currencyID = currencyID, totalRewardAmount = count}, summary, seen)
        end
    end
    local ordinary = number(E.Call(GetNumQuestLogChoices, id)) or 0
    local combined = number(E.Call(GetNumQuestLogChoices, id, true)) or 0
    if combined > ordinary then
        seen = {}
        for slot = 1, combined do
            addCurrency(E.Call(C_QuestLog and C_QuestLog.GetQuestRewardCurrencyInfo, id, slot, true), choices, seen)
        end
    end
end

local function addSpells(id, append)
    local info = C_QuestInfoSystem or {}
    for _, reward in ipairs(list(E.Call(info.GetQuestRewardSpells, id))) do
        local spellID = positive(reward)
        if spellID then
            local spell = list(E.Call(info.GetQuestRewardSpellInfo, id, spellID))
            local name = text(spell.name) or text(E.Call(C_Spell and C_Spell.GetSpellName, spellID))
                or text(E.Call(GetSpellInfo, spellID)) or ("Spell #" .. spellID)
            append("Spell or unlock: " .. name)
        end
    end
end

local function addSelectedQuestRewards(id, append)
    local selected = positive(E.Call(C_QuestLog and C_QuestLog.GetSelectedQuest))
    if selected ~= id then return end
    local title = text(E.Call(GetQuestLogRewardTitle))
    if title then append("Title: " .. title) end
    local skill, _, points = E.Call(GetQuestLogRewardSkillPoints)
    skill, points = text(skill), positive(points)
    if skill and points then append(skill .. " +" .. points) end
    local reputation = {}
    for index = 1, number(E.Call(GetNumQuestLogRewardFactions)) or 0 do
        local faction, hundredths = E.Call(GetQuestLogRewardFactionInfo, index)
        faction, hundredths = positive(faction), number(hundredths)
        if faction and hundredths and hundredths ~= 0 then
            reputation[#reputation + 1] = {faction, hundredths / 100}
        end
    end
    if #reputation > 0 then return reputation end
end

function R.ForQuest(id, record, supplemental, loaded)
    local offline = ns.DungeonRewardData and ns.DungeonRewardData[id] or {}
    local fixed = mergeItems(offline.fixed, not record.rewardChoice and record.rewardItems or nil,
        record.additionalRewardItems)
    local choices = mergeItems(offline.choices, record.rewardChoice and record.rewardItems or nil)
    local cached = id and (loaded or R.IsCached(id))
    fixed = withLiveItems(id, GetNumQuestLogRewards, GetQuestLogRewardInfo, fixed, "reward")
    choices = withLiveItems(id, GetNumQuestLogChoices, GetQuestLogChoiceInfo, choices, "choice")
    local selectable = {}
    for _, item in ipairs(choices) do
        if item.id then selectable[item.id] = true end
    end
    for index = #fixed, 1, -1 do
        if selectable[fixed[index].id] then table.remove(fixed, index) end
    end

    local summary, choiceCurrencies, seen = {}, {}, {}
    local function append(value)
        local line = text(value)
        if not line then return end
        local key = line:lower()
        if not seen[key] then seen[key] = true; summary[#summary + 1] = line end
    end
    local xp, liveXP = amount(id, cached, GetQuestLogRewardXP,
        offline.xp or record.liveXPFallback or record.xp or supplemental.xp)
    if xp and xp > 0 then append(localizedNumber(xp) .. (liveXP and " XP" or " base XP")) end
    local money, liveMoney = amount(id, cached, GetQuestLogRewardMoney,
        offline.money or record.money_copper or supplemental.money_copper)
    if money and money > 0 then
        append(moneyText(money) .. (liveMoney and "" or " (recorded reward)"))
    end
    local currentRep = id and addSelectedQuestRewards(id, append)
    local reputation = currentRep or ns.DungeonRewardReputation and ns.DungeonRewardReputation[id]
    local fallbackNames = ns.DungeonRewardFactionNames or {}
    local repNames = {}
    for _, entry in ipairs(reputation or {}) do
        local value = entry[2]
        if value ~= 0 then
            local fallback = fallbackNames[entry[1]]
            local name = factionName(entry[1], fallback)
            repNames[name:lower()] = true
            if fallback then repNames[fallback:lower()] = true end
            append(("%s %+g reputation"):format(name, value))
        end
    end
    for _, extra in ipairs(offline.extras or {}) do
        local faction = extra:match("^(.-)%s+[+-]%d[%d%.]*$")
        if not faction or not repNames[faction:lower()] then append(extra) end
    end
    if id then
        local currencies = {}
        addCurrencies(id, currencies, choiceCurrencies)
        for _, line in ipairs(currencies) do append(line) end
        addSpells(id, append)
        local honor = positive(E.Call(GetQuestLogRewardHonor, id))
        if honor then append(localizedNumber(honor) .. " Honor") end
        local favor = positive(E.Call(C_QuestInfoSystem and C_QuestInfoSystem.GetQuestLogRewardFavor, id, true))
        if favor then append(localizedNumber(favor) .. " Favor") end
    end
    return summary, fixed, choices, choiceCurrencies
end
