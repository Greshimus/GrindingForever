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

local wingFamilies = {
    ["scarlet monastery"] = {name="Scarlet Monastery", wings={
        graveyard="Graveyard", library="Library", armory="Armory", cathedral="Cathedral"}},
    ["dire maul"] = {name="Dire Maul", wings={east="East", west="West", north="North"}},
    stratholme = {name="Stratholme", wings={living="Living", undead="Undead"}},
    ["blackrock spire"] = {name="Blackrock Spire", wings={
        lower="Lower Blackrock Spire", upper="Upper Blackrock Spire"}},
}

function ns.DungeonWingContext(instance)
    local family, wing, name
    if type(instance) == "table" then
        family, wing, name = instance.family, instance.wing, instance.name
    else name = instance end
    if type(name) == "string" then
        local key = ns.DungeonNameKey(name):gsub("%s+", " "):match("^ *(.-) *$")
        if key == "lower blackrock spire" then family, wing = "blackrock spire", "lower"
        elseif key == "upper blackrock spire" then family, wing = "blackrock spire", "upper"
        else family, wing = key:match("^([^:]+): *(.-) *$") end
    end
    local definition = wingFamilies[family]
    local label = definition and definition.wings[wing]
    if not label then return end
    return {family=family, wing=wing, label=label, familyLabel=definition.name}
end

local function wingMembership(context, wings)
    local definition = wingFamilies[context.family]
    if type(wings) ~= "table" or #wings == 0 then return end
    local included = false
    for _, wing in ipairs(wings) do
        if not definition.wings[wing] then return end
        if wing == context.wing then included = true end
    end
    return included
end

function ns.DungeonQuestWingMembership(instance, questID)
    local context = ns.DungeonWingContext(instance)
    if not context then return nil, nil, nil end
    local family = ns.DungeonQuestWingFacts and ns.DungeonQuestWingFacts[context.family]
    local fact = family and family.quests and family.quests[questID]
    if type(fact) ~= "table" then return nil, nil, context end
    return wingMembership(context, fact.wings), fact, context
end

function ns.DungeonQuestWingObjectives(instance, questID)
    local membership, fact, context = ns.DungeonQuestWingMembership(instance, questID)
    local targets = {}
    if membership ~= true or type(fact.objectives) ~= "table" then return targets, fact, context end
    for target, wings in pairs(fact.objectives) do
        if type(target) == "string" and wingMembership(context, wings) == true then targets[#targets+1] = target end
    end
    table.sort(targets)
    return targets, fact, context
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

-- A reviewed navigation estimate never replaces raw spawn or observation facts.
local function contactNumber(value, low, high)
    return type(value) == "number" and value == value and value >= low and value <= high
end

local function contactArrayCount(values)
    if type(values) ~= "table" then return end
    local count, last = 0, 0
    for key in pairs(values) do
        if not contactNumber(key, 1, 256) or key % 1 ~= 0 then return end
        count, last = count + 1, math.max(last, key)
    end
    if count > 0 and count == last then return count end
end

local contactFields = {"entityKind", "entityID", "mapID", "frameID", "siteID"}

function ns.MeanQuestContact(points, context)
    if type(context) ~= "table" or (context.entityKind ~= "npc" and context.entityKind ~= "object")
        or not contactNumber(context.entityID, 1, 1e9) or context.entityID % 1 ~= 0
        or not contactNumber(context.mapID, 1, 1e9) or context.mapID % 1 ~= 0
        or type(context.frameID) ~= "string" or context.frameID == ""
        or type(context.siteID) ~= "string" or context.siteID == "" then return nil, "Invalid contact context" end
    local count = contactArrayCount(points)
    if not count then return nil, "Invalid contact points" end
    local unique, seen, sumX, sumY = {}, {}, 0, 0
    for _, point in ipairs(points) do
        if type(point) ~= "table" then return nil, "Invalid contact point" end
        for _, field in ipairs(contactFields) do
            if point[field] ~= context[field] then return nil, "Contact identity or frame differs" end
        end
        if not contactNumber(point.x, 0, 100) or not contactNumber(point.y, 0, 100) then
            return nil, "Invalid contact coordinate"
        end
        local sourceCount = contactArrayCount(point.provenance)
        if not sourceCount then return nil, "Missing contact provenance" end
        local x, y = point.x == 0 and 0 or point.x, point.y == 0 and 0 or point.y
        local key = string.format("%.17g:%.17g", x, y)
        local contributor = seen[key]
        if not contributor then
            contributor = {x=x, y=y, provenance={}}
            seen[key], unique[#unique+1] = contributor, contributor
            sumX, sumY = sumX + x, sumY + y
        end
        for _, source in ipairs(point.provenance) do
            if type(source) ~= "string" or source == "" then return nil, "Invalid contact provenance" end
            local present = false
            for _, prior in ipairs(contributor.provenance) do if prior == source then present = true; break end end
            if not present then contributor.provenance[#contributor.provenance+1] = source end
        end
    end
    local x, y, dx, dy = sumX / #unique, sumY / #unique, 0, 0
    for _, point in ipairs(unique) do
        dx, dy = math.max(dx, math.abs(point.x-x)), math.max(dy, math.abs(point.y-y))
    end
    if dx > 2 or dy > 2 then return nil, "Contact coordinates exceed two-axis limit" end
    return {mapID=context.mapID, x=x, y=y, name=context.name, zone=context.zone,
        npcID=context.entityKind == "npc" and context.entityID or nil,
        objectID=context.entityKind == "object" and context.entityID or nil,
        source="Grinding Forever reviewed contact mean", evidence="derived-navigation-mean",
        contactResolution={id=context.resolutionID, inputCount=count, distinctCount=#unique,
            maxDeltaX=dx, maxDeltaY=dy, contributors=unique}}
end

local bashanaContext = {entityKind="npc", entityID=9087, mapID=1456,
    frameID="Forever:uiMap1456:percent", siteID="npc:9087:Thunder Bluff",
    name="Bashana Runetotem", zone="Thunder Bluff", resolutionID="bashana-20261119"}
local function bashanaPoint(x, y, source)
    return {entityKind="npc", entityID=9087, mapID=1456, frameID=bashanaContext.frameID,
        siteID=bashanaContext.siteID, x=x, y=y, provenance={source}}
end
ns.QuestContactResolutionFacts = {
    ["npc:9087"] = {context=bashanaContext,
        -- These world positions identify preserved projection aliases, not a new mean world position.
        worldSites={{worldMap=1,worldX=-1088,worldY=-225},{worldMap=1,worldX=-1088,worldY=-223}},
        points={
            bashanaPoint(71.058,34.204,"Bundled QuestData NPC9087; world1/-1088/-225; legacy spawn reference"),
            bashanaPoint(70.866,34.204,"Bundled QuestData NPC9087; world1/-1088/-223; legacy spawn reference"),
            bashanaPoint(71.06,34.19,"QuestLocationEvidence QuestieDB Forever v1.1.0; shared contact coordinate"),
            bashanaPoint(70.95539569854736,33.86580944061279,
                "Imported target NPC9087 and linked quest6561 turn-in; live player approach, not exact NPC position"),
            bashanaPoint(70.8,33.4,
                "DungeonReference Earthen Echo98823 Bashana pickup; legacy curated reference, exact spawn/build unverified"),
        }},
}

function ns.ResolveQuestContact(quest, start, context)
    local data = ns.ForeverQuestData
    local id = type(quest) == "table" and quest.id or quest
    local record = data and data.quests and data.quests[id]
    local sources = record and (start and record.starts or not start and record.ends)
    if contactArrayCount(sources) ~= 1 then return end
    local source = sources[1]
    if type(source) ~= "table" or (source.kind ~= "npc" and source.kind ~= "object")
        or not contactNumber(source.id, 1, 1e9) or source.id % 1 ~= 0 then return end
    local fact = ns.QuestContactResolutionFacts[source.kind..":"..source.id]
    if not fact then return end
    if context then
        if type(context) ~= "table" then return end
        for _, field in ipairs(contactFields) do
            if context[field] ~= nil and context[field] ~= fact.context[field] then return end
        end
    end
    local function knownPoint(point)
        if type(point) ~= "table" or point.mapID ~= fact.context.mapID then return false end
        if point.npcID ~= nil and (source.kind ~= "npc" or point.npcID ~= source.id)
            or point.objectID ~= nil and (source.kind ~= "object" or point.objectID ~= source.id) then return false end
        for _, approved in ipairs(fact.points) do
            if point.x == approved.x and point.y == approved.y then return true end
        end
        return false
    end
    -- A later source update adding another site must be reviewed, not hidden by this one-site record.
    for _, point in ipairs(data.spawns[source.kind..":"..source.id] or {}) do
        local alias = false
        for _, site in ipairs(fact.worldSites) do
            if point.worldMap == site.worldMap and point.worldX == site.worldX and point.worldY == site.worldY then
                alias = true; break
            end
        end
        if (point.worldMap ~= nil or point.worldX ~= nil or point.worldY ~= nil) and not alias then return end
        if point.mapID == fact.context.mapID then
            if not knownPoint(point) then return end
        elseif not alias then return end
    end
    local evidence = ns.QuestLocationEvidence and ns.QuestLocationEvidence[id]
    for _, point in ipairs(evidence and (start and evidence.startPoints or not start and evidence.endPoints) or {}) do
        if not knownPoint(point) then return end
    end
    local reference = type(quest) == "table" and quest.reference
    local preferred = reference and (start and reference.startPoint or not start and reference.endPoint)
    if preferred and not knownPoint({mapID=preferred[1],x=preferred[2],y=preferred[3]}) then return end
    return ns.MeanQuestContact(fact.points, fact.context)
end

function ns.DungeonQuestLocations(quest, start)
    local data = ns.ForeverQuestData
    local record = data and data.quests and data.quests[quest.id] or quest.record or {}
    local endpoints = {}
    local hint = start and record.pickup or not start and record.turnin
    local resolved = ns.ResolveQuestContact(quest, start)
    if resolved then return hint or resolved.name, {resolved}, resolved end
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
    local evidence = ns.QuestLocationEvidence and ns.QuestLocationEvidence[quest.id]
    local points = evidence and (start and evidence.startPoints or not start and evidence.endPoints)
    for _, point in ipairs(points or {}) do
        add(point.mapID, point.x, point.y, point.name or quest.name)
    end
    table.sort(endpoints, function(a, b)
        if a.mapID ~= b.mapID then return a.mapID < b.mapID end
        if a.x ~= b.x then return a.x < b.x end
        return a.y < b.y
    end)
    return hint, endpoints
end
