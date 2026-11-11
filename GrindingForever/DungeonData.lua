local _, ns = ...

local excluded = {}
for name in ([=[
hellfire ramparts|blood furnace|shattered halls|slave pens|underbog|steamvault|mana tombs|auchenai crypts|sethekk halls|shadow labyrinth|old hillsbrad foothills|old hillsbrad|escape from durnholde|black morass|opening of the dark portal|mechanar|botanica|arcatraz|magisters terrace|karazhan|gruuls lair|magtheridons lair|serpentshrine cavern|tempest keep|eye|black temple|sunwell plateau|zulaman|battle for mount hyjal|mount hyjal|hyjal past
]=]):gmatch("[^|\n]+") do
    excluded[name] = true
end

function ns.DungeonNameKey(name)
    return name:lower():gsub("’", ""):gsub("'", ""):gsub("%-", " "):gsub("^the ", "")
end

function ns.IsForeverDungeon(name)
    local title = name:match(":%s*(.+)") or name
    return not excluded[ns.DungeonNameKey(title)]
end

-- Exterior waypoints use zone coordinates in percent. Interior landmarks are separate.
ns.DungeonEntrances = {
    ["Ragefire Chasm"] = {1454, 52.6, 49.0},
    ["Wailing Caverns"] = {1413, 46.0, 36.3},
    ["The Deadmines"] = {1436, 42.5, 71.7},
    ["Shadowfang Keep"] = {1421, 44.8, 67.8},
    ["The Stockade"] = {1453, 52.4, 70.0},
    ["Gnomeregan"] = {1426, 24.3, 39.8},
    ["Razorfen Kraul"] = {1413, 42.9, 90.2},
    ["Razorfen Downs"] = {1413, 50.0, 92.0},
    ["Scarlet Monastery"] = {1420, 82.6, 33.8},
    ["Blackrock Depths"] = {1427, 34.8, 84.0},
    ["Lower Blackrock Spire"] = {1427, 34.8, 84.0},
    ["Upper Blackrock Spire"] = {1427, 34.8, 84.0},
    ["Dire Maul"] = {1444, 59.0, 45.0},
    ["Scholomance"] = {1422, 69.7, 73.2},
    ["The Temple of Atal'Hakkar"] = {1435, 69.5, 53.5},
    ["Maraudon"] = {1443, 29.1, 62.5},
    ["Uldaman"] = {1418, 44.3, 12.0},
    ["City of Dalaran"] = {1416, 8.5, 59.3},
    ["The Drowned City"] = {1434, 21.4, 27.9},
}

-- Fallback encounter drops where the client does not expose journal loot.
-- Item names, quality and tooltips are resolved from the client by ID.
ns.DungeonLoot = {
    ["Ragefire Chasm"] = {
        ["Taragaman the Hungerer"] = {14148, 14149, 14145, {14540, "Quest Item"}},
        ["Jergosh the Invoker"] = {14150, 14147, 14151},
    },
    ["Wailing Caverns"] = {
        ["Lady Anacondra"] = {5404, 10412, 10413},
        ["Kresh"] = {13245, 6447},
        ["Lord Cobrahn"] = {6465, 6460, 10410},
        ["Verdan the Everliving"] = {6629, 6630, 6631},
        ["Lord Serpentis"] = {6469, 5970, 10411},
        ["Lord Pythas"] = {6472, 6473},
        ["Skum"] = {6449, 6448},
        ["Mutanus the Devourer"] = {6461, 6627, 6463, {10441, "Starts a Quest"}},
    },
    ["The Deadmines"] = {
        ["Rhahk'Zor"] = {5187},
        ["Miner Johnson"] = {5444},
        ["Sneed"] = {5195, 5194},
        ["Gilnid"] = {5199, 1156},
        ["Mr. Smite"] = {5196, 5192, 7230},
        ["Captain Greenskin"] = {5200, 10403, 5201},
        ["Edwin VanCleef"] = {5202, 5191, 10399, 5193, {2874, "Starts a Quest"}},
        ["Cookie"] = {5197, 5198, 8490},
    },
}

local function mapName(mapID)
    local info = ns.Forever.Call(C_Map and C_Map.GetMapInfo, mapID)
    return info and info.name
end

local referenceByName = {}
local referencesByMap = {}
for name, reference in pairs(ns.DungeonReference or {}) do
    referenceByName[ns.DungeonNameKey(name)] = reference
    if reference.art then
        local key = ns.DungeonNameKey(reference.art)
        referencesByMap[key] = referencesByMap[key] or {}
        table.insert(referencesByMap[key], reference)
    end
end

function ns.DungeonReferencesFor(name)
    local key = ns.DungeonNameKey(name)
    local exact = referenceByName[key]
    return referencesByMap[key] or (exact and {exact}) or {}
end

function ns.DungeonLocation(point, fallback)
    if type(point) ~= "table" or type(point[1]) ~= "number"
        or type(point[2]) ~= "number" or type(point[3]) ~= "number" then return end
    return {mapID = point[1], x = point[2], y = point[3], zone = mapName(point[1]), name = point[4] or fallback}
end

function ns.DungeonEntrance(instance)
    if instance.entrance then return instance.entrance end
    local label = instance.name .. " entrance"
    for _, reference in ipairs(ns.DungeonReferencesFor(instance.name)) do
        if reference.entrance then return ns.DungeonLocation(reference.entrance, label) end
    end
    local key = ns.DungeonNameKey(instance.name)
    local base = ns.DungeonNameKey(instance.name:match("^([^:]+):") or instance.name)
    for name, point in pairs(ns.DungeonEntrances) do
        local candidate = ns.DungeonNameKey(name)
        if candidate == key or candidate == base then return ns.DungeonLocation(point, label) end
    end
end

function ns.DungeonQuestLocations(quest, start)
    local data = ns.ForeverQuestData
    local record = data and data.quests and data.quests[quest.id] or quest.record or {}
    local endpoints = {}
    local hint = start and record.pickup or not start and record.turnin
    local kind = start and "accept" or "turnin"
    local planner = ns.ForeverQuestPlanner
    local seen = {}
    local function add(mapID, x, y, name)
        if not mapID or type(x) ~= "number" or type(y) ~= "number" then return end
        local key = string.format("%d:%.1f:%.1f", mapID, x, y)
        if seen[key] then return end
        seen[key] = true
        endpoints[#endpoints + 1] = {mapID = mapID, x = x, y = y, name = name, zone = mapName(mapID)}
    end
    local reference = quest.reference
    if reference then
        local point = start and reference.startPoint or not start and reference.endPoint
        if point then add(point[1], point[2], point[3], point[4] or quest.name) end
        if not hint and start and reference.startsInDungeon then hint = "Inside the dungeon" end
    end
    for _, source in ipairs((start and record.starts or not start and record.ends) or {}) do
        local key = source.kind .. ":" .. source.id
        local name = data and data.names and data.names[key] or source.kind .. " #" .. source.id
        for _, point in ipairs(data and data.spawns and data.spawns[key] or {}) do
            add(point.mapID, point.x, point.y, name)
        end
        if not hint then hint = name end
    end
    for _, action in pairs(planner and planner.actionIndex and planner.actionIndex[quest.id] or {}) do
        local point = action.kind == kind and action.map
        if point then
            local target = type(action.target) == "table" and action.target.name or action.target
            add(point.ui_map, point.x, point.y, type(target) == "string" and target or quest.name)
        end
    end
    table.sort(endpoints, function(a, b)
        if a.mapID ~= b.mapID then return a.mapID < b.mapID end
        if a.x ~= b.x then return a.x < b.x end
        return a.y < b.y
    end)
    return hint, endpoints
end
