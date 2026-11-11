local _, ns = ...
local E, facts = ns.Forever, ns.RecipeSourceFacts
local Catalog = { professions = facts.professions, revision = 0 }
ns.RecipeCatalog = Catalog

local vendorReagents = {
    [2320]=true, [2321]=true, [4291]=true, [8343]=true, [14341]=true,
    [4289]=true, [2678]=true, [3371]=true, [3372]=true, [4470]=true,
    [2324]=true, [2604]=true, [6260]=true, [2605]=true, [4341]=true,
    [4340]=true, [6261]=true, [2325]=true, [4342]=true,
    [2880]=true, [3466]=true, [3857]=true, [4399]=true, [4400]=true,
}
local stockRead
local observedByVendor, observedByItem
function E.NoteVendorStock(id)
    vendorReagents[id] = true
end

function E.IsVendorReagent(id)
    if vendorReagents[id] then return true end
    if not stockRead then
        stockRead = true
        for _, vendor in pairs(E.vendors) do
            for itemID in pairs(vendor.stockItems or {}) do
                E.NoteVendorStock(itemID)
            end
        end
    end
    return vendorReagents[id] == true
end

function E.SupplementalDrops(npcID)
    return facts.mobMaterials[npcID]
end

local function indexObserved(recipe, npcID)
    if not npcID then return end
    local key = recipe.spellID or recipe.learnableItemID
    local vendorRecipes = observedByVendor[npcID]
    if not vendorRecipes then
        vendorRecipes = {}
        observedByVendor[npcID] = vendorRecipes
    end
    vendorRecipes[key] = recipe
    if recipe.learnableItemID then observedByItem[recipe.learnableItemID] = recipe end
end

local function ensureObserved()
    if observedByVendor then return end
    observedByVendor, observedByItem = {}, {}
    for _, recipe in pairs(E.recipes) do
        if recipe.observed then
            for _, loc in ipairs(recipe.locations) do
                if loc.source == "Vendor" then indexObserved(recipe, loc.npcID) end
            end
        end
    end
end

function E.NoteRecipeSource(recipe, npcID)
    ensureObserved()
    local key = recipe.spellID or recipe.learnableItemID
    local previous = observedByVendor[npcID]
    if not previous or not previous[key] then
        indexObserved(recipe, npcID)
        Catalog.revision = Catalog.revision + 1
    end
end

local function exact(loc)
    return type(loc) == "table" and E.Public(loc.mapID) and E.Public(loc.x) and E.Public(loc.y)
        and type(loc.mapID) == "number" and type(loc.x) == "number" and type(loc.y) == "number"
        and loc.mapID > 0 and loc.x > 0 and loc.x <= 100 and loc.y > 0 and loc.y <= 100
end
Catalog.HasWaypoint = exact

local sourcePin, sourcePinCanvas, sourceLocationOnMap, mapHooked
local function clearSourcePin()
    sourceLocationOnMap = nil
    if sourcePin then sourcePin:Hide() end
end

local function nativeWaypoint()
    return C_Map and E.Call(C_Map.GetUserWaypoint)
end

local function nativeWaypointChanged()
    if sourceLocationOnMap and (nativeWaypoint() or C_Map and E.Call(C_Map.HasUserWaypoint)) then
        clearSourcePin()
    end
end

local function renderSourcePin()
    nativeWaypointChanged()
    local map = WorldMapFrame
    local loc = sourceLocationOnMap
    if not loc or not map or map:GetMapID() ~= loc.mapID then
        if sourcePin then sourcePin:Hide() end
        return
    end
    local scroll = map.ScrollContainer
    local canvas = E.Call(map.GetCanvas, map) or (scroll and (E.Call(scroll.GetScrollChild, scroll) or scroll.Child))
    if not canvas then
        if sourcePin then sourcePin:Hide() end
        return
    end
    if canvas ~= sourcePinCanvas then
        if sourcePin then sourcePin:Hide() end
        sourcePinCanvas = canvas
        sourcePin = canvas:CreateTexture(nil, "OVERLAY")
        sourcePin:SetTexture("Interface\\AddOns\\GrindingForever\\Media\\RecipePin")
        sourcePin:SetSize(22, 30)
        canvas:HookScript("OnSizeChanged", renderSourcePin)
    end
    sourcePin:ClearAllPoints()
    sourcePin:SetPoint("BOTTOM", canvas, "TOPLEFT", loc.x * canvas:GetWidth() / 100, -loc.y * canvas:GetHeight() / 100)
    sourcePin:Show()
end

function Catalog.PinWorldMap(loc)
    if not exact(loc) then return false end
    clearSourcePin()
    local map = WorldMapFrame
    if not map then
        E.Call(C_AddOns and C_AddOns.LoadAddOn or LoadAddOn, "Blizzard_WorldMap")
        map = WorldMapFrame
    end
    if map then
        if not mapHooked then
            mapHooked = true
            E.Call(map.RegisterCallback, map, "MapChanged", renderSourcePin, Catalog)
            map:HookScript("OnShow", renderSourcePin)
            local events = CreateFrame("Frame")
            E.Call(events.RegisterEvent, events, "USER_WAYPOINT_UPDATED")
            events:SetScript("OnEvent", nativeWaypointChanged)
        end
        map:Show()
        E.Call(map.SetMapID, map, loc.mapID)
    end
    local pinned = false
    local canPin = C_Map and (not C_Map.CanSetUserWaypointOnMap or E.Call(C_Map.CanSetUserWaypointOnMap, loc.mapID))
    if canPin and C_Map.SetUserWaypoint and UiMapPoint then
        local point = E.Call(UiMapPoint.CreateFromCoordinates, loc.mapID, loc.x / 100, loc.y / 100)
        if point then
            local ok, result = pcall(C_Map.SetUserWaypoint, point)
            pinned = ok and E.Public(result) and result ~= false
            if pinned and C_Map.GetUserWaypoint then
                local current = nativeWaypoint()
                local x, y
                if current and current.position then x, y = E.Call(current.position.GetXY, current.position) end
                pinned = current and E.Public(current.uiMapID) and current.uiMapID == loc.mapID and E.Public(x) and E.Public(y)
                    and type(x) == "number" and type(y) == "number"
                    and math.abs(x - loc.x / 100) < .0001 and math.abs(y - loc.y / 100) < .0001
            end
        end
    end
    if pinned then return true end
    local mapInfo = C_Map and E.Call(C_Map.GetMapInfo, loc.mapID)
    local zoneType = Enum and Enum.UIMapType and Enum.UIMapType.Zone or 3
    local mapType = mapInfo and mapInfo.mapType
    if not map or not E.Public(mapType) or type(mapType) ~= "number" or mapType < zoneType then return false end
    sourceLocationOnMap = loc
    renderSourcePin()
    return pinned == true or (sourcePin and sourcePin:IsShown() and map:GetMapID() == loc.mapID) == true
end

local function locate(kind, id)
    local entity = facts.entities[kind] and facts.entities[kind][id]
    if not entity then return {name = kind .. " #" .. id, source = kind, sourceID = id} end
    local name, zone, mapID, x, y, faction = unpack(entity, 1, 6)
    local data = ns.ForeverQuestData
    if kind == "Quest" then
        local title = E.Call(C_QuestLog and C_QuestLog.GetTitleForQuestID, id)
        if E.Public(title) and type(title) == "string" and title ~= "" then name = title end
    end
    if not mapID then
        local zoneInfo = zone and ns.ForeverData.zones[zone]
        mapID = zoneInfo and zoneInfo.mapID
    end
    if kind ~= "Quest" and not x and mapID and data and data.spawns then
        for _, spawn in ipairs(data.spawns["npc:" .. id] or {}) do
            if spawn.mapID == mapID and spawn.x and spawn.y then
                x, y = spawn.x, spawn.y
                break
            end
        end
    end
    return { name = name or kind .. " #" .. id, zone = zone, mapID = mapID, x = x, y = y,
        faction = faction, source = kind, sourceID = id, npcID = kind ~= "Quest" and id or nil,
        questID = kind == "Quest" and id or nil }
end

local function sourceLocation(raw)
    local kind, id = raw[1], raw[2]
    local loc
    if facts.entities[kind] then
        loc = locate(kind, id)
    elseif kind == "World Drop" then
        loc = { name = id or kind, source = kind }
    else
        loc = { name = type(id) == "string" and id or kind, source = kind }
    end
    loc.stock = raw[3]
    loc.requirement = raw[4]
    return loc
end

local function identity(loc)
    local kind = loc.source or ""
    local id = loc.sourceID or loc.npcID or loc.questID
    if id then return kind .. ":" .. id .. ":" .. (loc.mapID or "") end
    return kind .. ":" .. (loc.name or "") .. ":" .. (loc.zone or "")
end

Catalog.SourceKey = identity

local function addLocation(recipe, loc)
    local key = identity(loc)
    local at = recipe.sourceIndexes[key]
    if not at then
        at = #recipe.locations + 1
        recipe.sourceIndexes[key] = at
    else
        local previous = recipe.locations[at]
        if exact(previous) and not exact(loc) then return end
    end
    recipe.locations[at] = loc
end

local function buildFacts()
    local recipes = {}
    for _, fact in ipairs(facts.recipes) do
        local profession, spellID, name, skill, itemID, productID, sources = unpack(fact, 1, 7)
        local recipe = {
            profession = facts.professions[profession], spellID = spellID, name = name,
            skill = skill, itemID = itemID, learnableItemID = itemID, productID = productID,
            locations = {}, sourceIndexes = {},
        }
        recipes[#recipes + 1] = recipe
        for _, raw in ipairs(sources) do addLocation(recipe, sourceLocation(raw)) end
    end
    return recipes
end

function Catalog.Browse()
    local rows, bySpell, byItem = {}, {}, {}
    local function merge(recipe)
        local itemID = recipe.learnableItemID or recipe.itemID
        local row = recipe.spellID and bySpell[recipe.spellID] or nil
        local itemMatch = itemID and byItem[itemID]
        if not row and itemMatch and (not itemMatch.spellID or not recipe.spellID) then row = itemMatch end
        if not row then
            row = {locations = {}, sourceIndexes = {}}
            rows[#rows + 1] = row
        end
        for _, key in ipairs({"spellID", "productID", "profession", "faction", "skill", "knowledgeVerified", "learned"}) do
            if recipe[key] ~= nil then row[key] = recipe[key] end
        end
        if itemID then row.learnableItemID = itemID; byItem[itemID] = row end
        if row.spellID then bySpell[row.spellID] = row end
        if recipe.name and not recipe.name:match("^Spell %d+$") then row.name = recipe.name end
        for _, loc in ipairs(recipe.locations or {}) do addLocation(row, loc) end
    end
    for _, recipe in ipairs(buildFacts()) do merge(recipe) end
    for _, recipe in pairs(E.recipes) do merge(recipe) end
    for _, recipe in ipairs(rows) do
        recipe.name = recipe.name or (recipe.spellID and E.SpellName(recipe.spellID)) or "Unnamed Recipe"
        recipe.key = recipe.spellID or recipe.learnableItemID or recipe.name
        recipe.sourceIndexes = nil
    end
    return rows
end

local function tooltipName(fact)
    return fact[3] or E.SpellName(fact[2])
end

function E.RecipeTooltipLines(id, isUnit)
    ensureObserved()
    local indexes = isUnit and facts.byVendor[id] or not isUnit and facts.byItem[id]
    local observed = isUnit and observedByVendor[id] or not isUnit and observedByItem[id]
    if not indexes and not observed then return nil end
    local state = E.state
    local out, seen = {}, {}
    local function add(key, label)
        if not seen[key] then
            out[#out + 1] = label
            seen[key] = true
        end
    end
    local function addSource(kind, sourceID, name, zone)
        local verb = kind == "Vendor" and "Sold by " or kind == "Drop" and "Drops from "
            or kind == "Trainer" and "Taught by " or "Reward from "
        add(kind .. ":" .. sourceID, verb .. name .. (zone and (" (" .. zone .. ")") or ""))
    end
    for _, index in ipairs(indexes or {}) do
        local fact = facts.recipes[index]
        local allowed = E.SeasonalAvailable({spellID = fact[2], learnableItemID = fact[5]})
        if allowed and isUnit then
            local skill = fact[4] and fact[4] > 0 and (" (" .. facts.professions[fact[1]] .. " " .. fact[4] .. ")") or ""
            add(fact[2], tooltipName(fact) .. skill)
        elseif allowed then
            for _, source in ipairs(fact[7]) do
                local kind, sourceID = source[1], source[2]
                local entity = facts.entities[kind] and facts.entities[kind][sourceID]
                if entity and (not state or not entity[6] or entity[6] == "Neutral" or entity[6] == "Both" or entity[6] == state.faction) then
                    local name = entity[1] or (kind .. " #" .. sourceID)
                    addSource(kind, sourceID, name, entity[2])
                elseif kind == "World Drop" then
                    add(kind .. ":" .. (sourceID or ""), "World drop" .. (sourceID and (" (" .. sourceID .. ")") or ""))
                end
            end
        end
    end
    if observed and isUnit then
        for key, recipe in pairs(observed) do
            if E.SeasonalAvailable(recipe) then add(key, recipe.name) end
        end
    elseif observed and E.SeasonalAvailable(observed) then
        for _, loc in ipairs(observed.locations) do
            if loc.source == "Vendor" and loc.npcID and loc.name then
                addSource(loc.source, loc.npcID, loc.name, loc.zone)
            end
        end
    end
    if #out == 0 then return nil end
    table.sort(out)
    if #out > 10 then
        local count = #out
        for i = count, 11, -1 do out[i] = nil end
        out[11] = "+" .. (count - 10) .. " more in Recipes & Vendors"
    end
    if isUnit then table.insert(out, 1, "Recipes for sale") end
    return out
end
