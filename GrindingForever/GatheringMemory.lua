local _, ns = ...
local E, F, G = ns.Forever, ns.FarmingPlanner, ns.GatheringObserver
local V, M = ns.MapControls99, ns.KnownNodePins
if not E or not F or not G then return end

local function read(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, value = pcall(fn, ...)
    if ok and E.Public(value) then return value end
end

local spellKinds = {[2575] = "Mining", [2366] = "Herbalism"}
local names, byItem = {}, {}
for id, meta in pairs(F.meta) do
    if meta.kind == "Mining" or meta.kind == "Herbalism" then
        names[meta.name:lower()] = id
        if meta.item then byItem[meta.item] = byItem[meta.item] == nil and id or false end
    end
end

local function nodeID(name)
    if E.Public(name) and type(name) == "string" then return names[name:lower()] end
end

local function tooltipNode()
    if not GameTooltip or not GameTooltip:IsShown() then return end
    local owner = GameTooltip:GetOwner()
    if owner and owner ~= UIParent and owner ~= WorldFrame then return end
    local title = GameTooltipTextLeft1
    return title and nodeID(read(title.GetText, title))
end

function G.Initialize()
    if not E.db then return false end
    E.db.nodeMemory = E.db.nodeMemory or {nodes = {}, nextNode = 1}
    G.data = E.db.nodeMemory
    G.data.nodes = G.data.nodes or {}
    G.data.nextNode = G.data.nextNode or 1
    return true
end

local function remember(id, position, harvest)
    local meta = F.meta[id]
    if not meta or not position or not G.Initialize() then return end
    local found
    for _, node in pairs(G.data.nodes) do
        local saved = node.position
        if node.sourceNodeID == id and saved and saved.mapID == position.mapID
            and math.abs(saved.x - position.x) < 0.12 and math.abs(saved.y - position.y) < 0.12 then
            found = node
            break
        end
    end
    local now = read(GetServerTime)
    local newPin = not found
    if newPin then
        found = {profession = meta.kind, name = meta.name, sourceNodeID = id,
            position = position, firstSeen = now, items = {}, harvests = 0, sourceMatchedHarvests = 0}
        local slot = G.data.nextNode
        G.data.nodes[slot] = found
        G.data.nextNode = slot % 500 + 1
    end
    found.lastSeen = now
    if harvest then
        found.harvests = (found.harvests or 0) + 1
        found.sourceMatchedHarvests = (found.sourceMatchedHarvests or 0) + 1
    else
        found.observedClicks = (found.observedClicks or 0) + 1
    end
    if newPin then
        if V then V.map = nil end
        if M then M.age = 5 end
        local runtime = ns.QuestGathering and ns.QuestGathering.Runtime
        if runtime then runtime.nodeAt = nil end
    end
end

local function outdoorPosition()
    if not read(IsInInstance) then return read(E.CurrentPosition) end
end

local spellName = C_Spell and C_Spell.GetSpellName or GetSpellInfo
local toolName = C_Item and C_Item.GetItemNameByID or GetItemInfo
local function contains(message, term)
    return type(term) == "string" and term ~= "" and message:find(term:lower(), 1, true) ~= nil
end

local function isGatherRequirement(message, kind)
    if not E.Public(message) or type(message) ~= "string" then return false end
    local lower = message:lower()
    -- The client includes the required skill or tool name in these interaction errors.
    if kind == "Mining" then
        return contains(lower, read(spellName, 2575)) or contains(lower, "mining")
            or contains(lower, read(toolName, 2901)) or contains(lower, "mining pick")
    end
    return contains(lower, read(spellName, 2366)) or contains(lower, read(spellName, 170691))
        or contains(lower, "herbalism")
end

local pending, clicked, loot
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("GLOBAL_MOUSE_DOWN")
frame:RegisterEvent("UI_ERROR_MESSAGE")
frame:RegisterEvent("CHAT_MSG_LOOT")
for _, event in ipairs({"UNIT_SPELLCAST_SENT", "UNIT_SPELLCAST_START", "UNIT_SPELLCAST_SUCCEEDED",
        "UNIT_SPELLCAST_FAILED", "UNIT_SPELLCAST_INTERRUPTED"}) do
    frame:RegisterUnitEvent(event, "player")
end

local function handle(_, event, a, b, c, d)
    if event == "PLAYER_LOGIN" then G.Initialize(); return end
    if event == "GLOBAL_MOUSE_DOWN" then
        if a == "RightButton" then
            local id = tooltipNode()
            clicked = id and {id = id, at = GetTime()}
        end
        return
    end
    if event == "UI_ERROR_MESSAGE" then
        local now = GetTime()
        local recentAttempt = pending and now - pending.at < 2
        local recentClick = clicked and now - clicked.at < 1
        local id = (recentAttempt and pending.id) or (recentClick and clicked.id) or tooltipNode()
        if not id or not isGatherRequirement(b, F.meta[id].kind) then return end
        -- A visible matching node also covers clients that dispatch the error before the click event.
        if (recentClick and clicked.id == id) or tooltipNode() == id
            or (recentAttempt and pending.id == id) then
            remember(id, outdoorPosition(), false)
            pending, clicked = nil, nil
        end
        return
    end
    if event == "CHAT_MSG_LOOT" then
        if not loot or GetTime() - loot.at > 3 or not E.Public(a) or type(a) ~= "string" then return end
        local selfLoot = LOOT_ITEM_SELF and LOOT_ITEM_SELF:match("^(.-)%%")
        if not selfLoot or selfLoot == "" or a:sub(1, #selfLoot) ~= selfLoot then return end
        local item = E.ItemID(a)
        local id = item and byItem[item]
        if id and F.meta[id].kind == loot.kind then
            remember(id, loot.position, true)
            loot = nil
        end
        return
    end
    if not E.Public(a) or a ~= "player" then return end
    local spell, guid = c, b
    if event == "UNIT_SPELLCAST_SENT" then spell, guid = d, c end
    if not E.Public(spell) or not E.Public(guid) or type(spell) ~= "number" or type(guid) ~= "string" then return end
    local kind = spellKinds[spell]
    if not kind then
        local label = read(spellName, spell)
        if label and label == read(spellName, 2575) then kind = "Mining"
        elseif label and label == read(spellName, 2366) then kind = "Herbalism" end
    end
    if not kind then return end
    if event == "UNIT_SPELLCAST_SENT" or event == "UNIT_SPELLCAST_START" then
        local started = event == "UNIT_SPELLCAST_START"
        if pending and pending.guid == guid and pending.id then
            if started then pending.started = true end
            return
        end
        local id = event == "UNIT_SPELLCAST_SENT" and nodeID(b) or tooltipNode()
        if not id and clicked and GetTime() - clicked.at < 1 then id = clicked.id end
        if id and F.meta[id].kind ~= kind then id = nil end
        pending = {guid = guid, id = id, position = outdoorPosition(), at = GetTime(), started = started}
        loot = nil
        return
    end
    if pending and pending.guid ~= guid then return end
    local attempt = pending
    pending, clicked = nil, nil
    if event ~= "UNIT_SPELLCAST_SUCCEEDED" then
        if attempt and attempt.started and attempt.id then remember(attempt.id, attempt.position, false) end
        return
    end
    local position = attempt and attempt.position or outdoorPosition()
    local id = attempt and attempt.id or tooltipNode()
    if id and F.meta[id].kind == kind then remember(id, position, true)
    elseif position then loot = {kind = kind, position = position, at = GetTime()} end
end
frame:SetScript("OnEvent", handle)
G.Initialize()
