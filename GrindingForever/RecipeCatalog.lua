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
local purchaseRecipes
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
    purchaseRecipes = nil
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
        if previous.requirement and not loc.requirement then
            local merged = {}
            for field, value in pairs(loc) do merged[field] = value end
            merged.requirement = previous.requirement
            loc = merged
        end
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

local function hasText(value)
    return type(value) == "string" and value:find("%S") ~= nil
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
        for _, key in ipairs({"spellID", "productID", "profession", "faction", "skill", "requiredSkill", "knowledgeVerified", "learned",
            "minLevel", "maxLevel", "requiredQuest", "reputationID", "reputationStanding", "specializationSpell"}) do
            if recipe[key] ~= nil and (key ~= "profession" or hasText(recipe[key])) then row[key] = recipe[key] end
        end
        if itemID then row.learnableItemID = itemID; byItem[itemID] = row end
        if row.spellID then bySpell[row.spellID] = row end
        if hasText(recipe.name) and not recipe.name:match("^Spell %d+$") then row.name = recipe.name end
        for _, loc in ipairs(recipe.locations or {}) do addLocation(row, loc) end
    end
    for _, recipe in ipairs(buildFacts()) do merge(recipe) end
    for _, recipe in pairs(E.recipes) do merge(recipe) end
    for _, recipe in ipairs(rows) do
        if not hasText(recipe.name) then
            local spellName = recipe.spellID and E.SpellName(recipe.spellID)
            recipe.name = hasText(spellName) and spellName or "Unnamed Recipe"
        end
        recipe.key = recipe.spellID or recipe.learnableItemID or recipe.name
        recipe.sourceIndexes = nil
    end
    return rows
end

function Catalog.PurchaseRecipes()
    if purchaseRecipes then return purchaseRecipes end
    local rows = {}
    local sources = ns.ForeverCatalog and ns.ForeverCatalog.byItem or {}
    for _, recipe in ipairs(Catalog.Browse()) do
        local itemID = recipe.learnableItemID
        local vendors = {}
        for _, loc in ipairs(recipe.locations) do
            if loc.source == "Vendor" then vendors[#vendors + 1] = loc end
        end
        for _, loc in ipairs(sources[itemID] or {}) do
            if loc.kind == "Vendor" or loc.source == "Vendor" then vendors[#vendors + 1] = loc end
        end
        recipe.requiredSkill = recipe.skill or recipe.requiredSkill
        if itemID and recipe.spellID and recipe.requiredSkill and #vendors > 0 then
            recipe.vendors = vendors
            rows[#rows + 1] = recipe
        end
    end
    table.sort(rows, function(a, b) return a.spellID < b.spellID end)
    purchaseRecipes = rows
    return rows
end

local recipeItemPrefixes = {
    Recipe = true, Pattern = true, Plans = true, Formula = true,
    Schematic = true, Manual = true, Design = true, Technique = true,
}

local function vendorRecipeName(name)
    local prefix, title = name:match("^(%a+):%s*(.+)$")
    return recipeItemPrefixes[prefix] and title or name
end

local function vendorTooltipLines(id)
    local rows, byItem, bySpell = {}, {}, {}
    local function add(itemID, spellID, name, profession, skill)
        if not hasText(name) then return end
        local label = vendorRecipeName(name)
        local hasSkill = hasText(profession) and type(skill) == "number" and skill > 0
        if hasSkill then label = label .. (" (%s %d)"):format(profession, skill) end
        local row = byItem[itemID] or bySpell[spellID]
        if not row then
            row = { label = label, hasSkill = hasSkill }
            rows[#rows + 1] = row
        elseif hasSkill and not row.hasSkill then
            row.label, row.hasSkill = label, true
        end
        if itemID then byItem[itemID] = row end
        if spellID then bySpell[spellID] = row end
    end
    local function addFact(fact, fallback)
        if not E.SeasonalAvailable({spellID = fact[2], learnableItemID = fact[5]}) then return end
        local name = fact[3] or E.SpellName(fact[2])
        local skill = fact[4] and fact[4] > 0 and fact[4] or fallback
        add(fact[5], fact[2], name, facts.professions[fact[1]], skill)
    end

    for _, index in ipairs(facts.byVendor[id] or {}) do
        addFact(facts.recipes[index])
    end
    for _, recipe in pairs(observedByVendor[id] or {}) do
        if E.SeasonalAvailable(recipe) then
            local itemID = recipe.learnableItemID
            local fact
            for _, index in ipairs(facts.byItem[itemID] or {}) do
                local candidate = facts.recipes[index]
                -- This index also contains finished products, including items that teach another recipe.
                if candidate[5] == itemID then
                    fact = candidate
                    break
                end
            end
            if fact then
                addFact(fact, recipe.requiredSkill or recipe.skill)
            else
                add(itemID, recipe.spellID, recipe.name, recipe.profession, recipe.requiredSkill or recipe.skill)
            end
        end
    end

    local lines = {}
    for _, row in ipairs(rows) do lines[#lines + 1] = row.label end
    return lines
end

local function recipeItemSourceLines(id)
    local indexes, observed = facts.byItem[id], observedByItem[id]
    if not indexes and not observed then return {} end
    local faction = E.state and E.state.faction or E.Call(UnitFactionGroup, "player")
    local player = E.CurrentPosition()
    local merchant = E.activeRecipeMerchant
    local trading = merchant and MerchantFrame and E.Call(MerchantFrame.IsShown, MerchantFrame) == true
    local function factionAllows(side)
        return not side or side == "Neutral" or side == "Both"
            or E.Public(faction) and faction == side
    end
    local function nearby(vendor, npcID)
        if not vendor or not factionAllows(vendor.faction) then return false end
        if trading and merchant.npcID == npcID then return true end
        local yards = player and exact(vendor) and E.Distance(player, vendor)
        return yards and yards <= E.RecipeVendorRadius
    end
    local sources, seen = {}, {}
    local function addSource(key, description, zone)
        local source = seen[key]
        if source then
            source.zone = source.zone or zone
        else
            source = {description = description, zone = zone}
            seen[key] = source
            sources[#sources + 1] = source
        end
    end
    for _, index in ipairs(indexes or {}) do
        local fact = facts.recipes[index]
        if E.SeasonalAvailable({spellID = fact[2], learnableItemID = fact[5]}) then
            for _, source in ipairs(fact[7]) do
                local kind, sourceID = source[1], source[2]
                local entity = facts.entities[kind] and facts.entities[kind][sourceID]
                if kind == "Vendor" then
                    local vendor = E.vendors[sourceID]
                    if not nearby(vendor, sourceID) then vendor = entity and locate(kind, sourceID) end
                    if nearby(vendor, sourceID) then
                        local crafted = fact[6] == id and fact[5] ~= id
                        local verb = crafted and "Recipe sold by " or "Sold by "
                        local key = "Vendor:" .. sourceID .. (crafted and ":recipe" or "")
                        addSource(key, verb .. (vendor.name or "Vendor #" .. sourceID), vendor.zone)
                    end
                elseif entity and factionAllows(entity[6]) then
                    local verb = kind == "Drop" and "Drops from " or kind == "Trainer" and "Taught by " or "Reward from "
                    local name = entity[1] or (kind .. " #" .. sourceID)
                    addSource(kind .. ":" .. sourceID, verb .. name, entity[2])
                elseif kind == "World Drop" then
                    addSource(kind .. ":" .. (sourceID or ""), "World drop", sourceID)
                end
            end
        end
    end
    if observed and E.SeasonalAvailable(observed) then
        for _, loc in ipairs(observed.locations) do
            if loc.source == "Vendor" and loc.npcID and loc.name and nearby(loc, loc.npcID) then
                addSource("Vendor:" .. loc.npcID, "Sold by " .. loc.name, loc.zone)
            end
        end
    end
    local lines = {}
    for _, source in ipairs(sources) do
        local label = source.description .. (source.zone and (" (" .. source.zone .. ")") or "")
        lines[#lines + 1] = label
    end
    return lines
end

function E.RecipeTooltipLines(id, isUnit)
    ensureObserved()
    local lines = isUnit and vendorTooltipLines(id) or recipeItemSourceLines(id)
    if #lines == 0 then return nil end
    local out, seen = {}, {}
    for _, label in ipairs(lines) do
        if not seen[label] then
            seen[label] = true
            out[#out + 1] = label
        end
    end
    table.sort(out)
    if #out > 10 then
        local count = #out
        for i = count, 11, -1 do out[i] = nil end
        out[11] = "+" .. (count - 10) .. " more in Recipe Sources"
    end
    if isUnit then table.insert(out, 1, "Recipes for sale") end
    return out
end
