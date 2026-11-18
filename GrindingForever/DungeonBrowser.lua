local _, ns = ...
local E, N = ns.Forever, ns.NormalUI
local questRewards = ns.DungeonQuestRewards
local window
local assets = "Interface\\AddOns\\GrindingForever\\Media\\DungeonMap"
local waypointIcon = "Interface\\AddOns\\GrindingForever\\Media\\RecipePin"
local bossFallback = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8"
local portraitMask = "Interface\\CharacterFrame\\TempPortraitAlphaMask"

-- WoW Forever client 1.60.1.70888: Map.LoadingScreenID joined to LoadingScreens.
local loadingArt = {
    ["hall of thanes"]=7963781, ["ruins of lordaeron"]=7963782,
    ["ragefire chasm"]=131862, ["wailing caverns"]=131882, deadmines=131833,
    ["shadowfang keep"]=131869, ["blackfathom deeps"]=131823, stockade=131870,
    ["stormwind stockade"]=131870, gnomeregan=131841, ["razorfen kraul"]=131865,
    ["excavation site: wetlands"]=7963777, ["city of dalaran"]=7963775,
    ["scarlet monastery"]=131852, ["razorfen downs"]=131864, uldaman=131876,
    zulfarrak=131885, maraudon=131850, ["sunken temple"]=131872,
    ["temple of atalhakkar"]=131872, ["blackrock depths"]=131824,
    ["lower blackrock spire"]=131825, ["upper blackrock spire"]=131825, ["blackrock spire"]=131825,
    ["dire maul"]=131835, scholomance=131868, stratholme=131871, zulgurub=131886,
    ["onyxias lair"]=131863, ["molten core"]=131851, ["blackwing lair"]=131827,
    ["ruins of ahnqiraj"]=131818, ["ahnqiraj"]=131819, ["temple of ahnqiraj"]=131819,
    ["ahnqiraj temple"]=131819, naxxramas=131854, ["drowned city"]=7963741,
    ["blackmaw hold"]=7963784, ["alcaz prison"]=7963734, ["shapers terrace"]=7963783,
    ["kroldok stronghold"]=7963780, ["demon fall canyon"]=6213069,
}
local function loadingScreen(name)
    local key = ns.DungeonNameKey(name)
    return loadingArt[key] or loadingArt[key:match("^([^:]+):")]
end

local wingFamilies = {
    ["scarlet monastery"] = true, ["dire maul"] = true, stratholme = true,
}
-- Forever Dungeon Journal floor order and client UiMap IDs for each wing.
local wingFloors = {
    ["scarlet monastery: graveyard"] = {"Scarlet Monastery", 1},
    ["scarlet monastery: library"] = {"Scarlet Monastery", 2},
    ["scarlet monastery: armory"] = {"Scarlet Monastery", 3},
    ["scarlet monastery: cathedral"] = {"Scarlet Monastery", 4},
    ["dire maul: north"] = {"Dire Maul", 2},
    ["dire maul: west"] = {"Dire Maul", 3, 4, 5},
    ["dire maul: east"] = {"Dire Maul", 7, 6},
    ["stratholme: living"] = {"Stratholme", 1},
    ["stratholme: undead"] = {"Stratholme", 2},
}
local landingAliases = {
    ["sunken temple"] = "The Temple of Atal'Hakkar",
    ["temple of atalhakkar"] = "The Temple of Atal'Hakkar",
    ["shapers terrace"] = "Shaper's Terrace",
}

local archivedRaidMaps = {
    ["molten core"] = true,
    ["blackwing lair"] = true,
}
local visibleRaids = {
    ["molten core"] = "Molten Core",
    ["blackwing lair"] = "Blackwing Lair",
    ["onyxias lair"] = "Onyxia's Lair",
    ["barrow deeps"] = "Barrow Deeps",
    ["hyjal summit"] = "Hyjal Summit",
}
local hiddenCards = {
    ["cozy sleeping bag"] = true,
    ["mallet of zulfarrak"] = true,
}
local raidNames = {
    ["ahnqiraj"] = true, ["temple of ahnqiraj"] = true, ["ahnqiraj temple"] = true, ["ruins of ahnqiraj"] = true,
    ["blackwing lair"] = true, ["molten core"] = true, ["naxxramas"] = true,
    ["onyxias lair"] = true, ["zulgurub"] = true, ["hyjal summit"] = true, ["barrow deeps"] = true,
}
local levelRanges = {
    ["ragefire chasm"] = {13, 18}, ["hall of thanes"] = {13, 20},
    ["ruins of lordaeron"] = {15, 22}, ["wailing caverns"] = {15, 24}, ["deadmines"] = {17, 26},
    ["shadowfang keep"] = {20, 30}, ["blackfathom deeps"] = {24, 32}, ["stockade"] = {24, 32},
    ["excavation site: wetlands"] = {26, 33}, ["city of dalaran"] = {28, 33},
    ["gnomeregan"] = {29, 38}, ["razorfen kraul"] = {29, 38}, ["scarlet monastery"] = {30, 45},
    ["scarlet monastery: graveyard"] = {30, 38}, ["scarlet monastery: library"] = {33, 41},
    ["scarlet monastery: armory"] = {34, 42}, ["scarlet monastery: cathedral"] = {36, 45},
    ["drowned city"] = {35, 40}, ["razorfen downs"] = {37, 46}, ["uldaman"] = {38, 48},
    ["kroldok stronghold"] = {40, 45}, ["zulfarrak"] = {43, 50}, ["maraudon"] = {45, 52},
    ["alcaz prison"] = {48, 53}, ["sunken temple"] = {49, 56}, ["temple of atalhakkar"] = {49, 56},
    ["blackrock depths"] = {52, 60}, ["blackmaw hold"] = {55, 60},
    ["lower blackrock spire"] = {55, 60}, ["upper blackrock spire"] = {55, 60},
    ["dire maul"] = {55, 60}, ["dire maul: east"] = {55, 60},
    ["dire maul: west"] = {57, 60}, ["dire maul: north"] = {57, 60},
    ["scholomance"] = {58, 60}, ["stratholme"] = {58, 60}, ["shapers terrace"] = {58, 60},
}

local bossDisplay = {
    [3669] = 4213, [3671] = 4313, [3653] = 5126, [3670] = 4214, [3674] = 4203, [3673] = 4215, [5775] = 4256, [3654] = 4088,
    [5912] = 1267, [644] = 14403, [3586] = 556, [642] = 1269, [643] = 7125, [1763] = 7124, [646] = 2026, [647] = 7113,
    [639] = 2029, [645] = 1305, [4887] = 5027, [4831] = 4979, [6243] = 1773, [12902] = 12822, [4830] = 1816, [4832] = 4939,
    [12876] = 110, [4829] = 2837, [11517] = 11611, [11520] = 7970, [11518] = 11429, [11519] = 2007, [3914] = 524, [3864] = 1951, [3886] = 524,
    [3887] = 3222, [4278] = 3223, [4279] = 522, [3872] = 3224, [4627] = 1131, [4274] = 2352, [3927] = 11179, [4275] = 2353,
    [261306] = 142826, [261311] = 142840, [261319] = 142837, [250660] = 144188, [250483] = 144189, [250631] = 138667, [256097] = 144170, [250657] = 144175,
    [256035] = 139455, [1696] = 517, [1666] = 825, [1717] = 3250, [1663] = 2149, [1716] = 1621, [1720] = 2142, [260322] = 144209,
    [260325] = 144210, [260326] = 144224, [247126] = 145787, [245999] = 129891, [246003] = 129894, [246017] = 129954, [246008] = 129895, [246016] = 129900,
    [247032] = 130235, [246020] = 130061, [7361] = 144378, [7079] = 5497, [6235] = 6915, [6229] = 6774, [7800] = 6980, [6228] = 6669,
    [6168] = 6110, [4424] = 6097, [4428] = 4644, [4420] = 4652, [4422] = 2450, [4421] = 4642, [4425] = 4735, [4842] = 6102,
    [3983] = 2044, [6490] = 5534, [6488] = 5230, [6489] = 5231, [4543] = 11396, [3974] = 2040, [6487] = 5266, [3975] = 2041,
    [4542] = 2605, [3976] = 2042, [3977] = 2043, [7355] = 7845, [7357] = 8055, [8567] = 7864, [7354] = 11382, [7356] = 6124,
    [7358] = 7971, [9219] = 11574, [9218] = 11576, [9217] = 11578, [9196] = 11565, [9236] = 9732, [9237] = 9733, [10596] = 9929,
    [10376] = 9755, [10584] = 11583, [9596] = 9668, [9736] = 9738, [10220] = 9567, [10268] = 9564, [9718] = 11809, [9568] = 8711,
    [9816] = 2172, [10264] = 9581, [10509] = 9686, [10899] = 10222, [10339] = 9806, [10429] = 9778, [10430] = 10193, [16042] = 14308,
    [10363] = 10115, [9018] = 8761, [9025] = 5781, [9319] = 9212, [9027] = 8760, [9028] = 7873, [9029] = 523, [9030] = 11538,
    [9031] = 3004, [9032] = 8271, [9024] = 8762, [9056] = 8704, [9041] = 9089, [9017] = 1204, [9016] = 12162, [9033] = 8756,
    [8983] = 8759, [9537] = 8658, [9502] = 8177, [9543] = 8667, [9499] = 8652, [9156] = 8329, [8923] = 8270, [9039] = 8687,
    [9938] = 12162, [8929] = 8705, [9019] = 8807, [11490] = 11335, [13280] = 5489, [14327] = 14378, [11492] = 14416, [11489] = 14383,
    [11488] = 11270, [11467] = 11250, [11487] = 14384, [11496] = 14173, [14506] = 14556, [11486] = 11256, [14326] = 11561, [14322] = 11545,
    [14321] = 11561, [14323] = 11561, [14325] = 11564, [14324] = 11537, [11501] = 11583, [10393] = 2606, [10558] = 10482, [10516] = 10771,
    [10808] = 571, [11143] = 10669, [10997] = 10674, [10811] = 10544, [10813] = 10691, [10809] = 7856, [10435] = 10433, [10437] = 9793,
    [10436] = 10698, [10438] = 10546, [10439] = 12818, [10440] = 10729, [8580] = 7873, [5721] = 7553, [5720] = 6375, [8443] = 8053,
    [5710] = 6708, [5711] = 6709, [5719] = 7975, [5722] = 9584, [5709] = 7806, [10506] = 143673, [10503] = 11073, [11622] = 12073,
    [10433] = 10248, [10432] = 2606, [10508] = 7919, [10505] = 11069, [11261] = 10901, [10901] = 11492, [10507] = 10433, [10504] = 11072,
    [10502] = 11835, [1853] = 11070, [13282] = 11172, [12258] = 12389, [12236] = 12334, [12237] = 9014, [12225] = 12350, [12203] = 12293,
    [13601] = 7125, [13596] = 13589, [12201] = 12292, [6910] = 5945, [6906] = 5710, [7228] = 6089, [7206] = 10798, [7291] = 6059,
    [4854] = 11165, [2748] = 5988, [8127] = 7353, [7271] = 6434, [7275] = 6441, [7273] = 7271, [10082] = 9293, [10080] = 9291,
    [10081] = 9292, [7797] = 6687, [7267] = 6439, [258905] = 144475, [258924] = 144487, [260042] = 142144, [264177] = 144023, [260274] = 142322,
    [258966] = 141217, [258972] = 141219, [259281] = 141443, [258964] = 141215, [264773] = 14424, [258968] = 141218, [255997] = 4973, [257016] = 2317,
    [256236] = 140092, [255702] = 6374, [247195] = 140708, [247206] = 130432, [247209] = 130440, [247198] = 130427, [247234] = 130447, [247207] = 130436,
    [247231] = 131644, [269104] = 12235,
    -- Native PlayerModel display observations from the installed Forever client.
    [250034] = 2424, [16059] = 15981, [261974] = 143035, [262297] = 143122, [7023] = 5285,
    -- Verified display mappings formerly available only through the optional Journal catalog.
    [5712] = 6699, [5713] = 6698, [5714] = 6700, [5715] = 6702, [5716] = 6701, [5717] = 6707,
    [7272] = 6696, [7604] = 6433, [7795] = 6685, [7796] = 6690, [11032] = 10458, [11058] = 10475,
    [14354] = 7552, [14516] = 14591, [16118] = 16020, [253201] = 142989, [253218] = 143040, [255391] = 7914,
    [260468] = 142457, [261809] = 143832, [261812] = 144514, [261813] = 144511, [262081] = 143063,
    [262127] = 144515, [262716] = 17273, [264172] = 144022, [269111] = 145808, [272561] = 147098,
    -- WoWBocho's Forever NPC display table, checked against local CreatureDisplayInfo.
    [255699] = 139050, [261316] = 1070,
    -- Classic display IDs for the archived Molten Core and Blackwing Lair reference maps.
    [11502] = 11121, [11982] = 10193, [11988] = 11986, [12018] = 12029, [12056] = 12129,
    [12057] = 12110, [12098] = 13030, [12118] = 13031, [12259] = 13030, [12264] = 13032,
    [11583] = 11380, [11981] = 6377, [11983] = 6377, [12017] = 14308,
    [12435] = 10115, [13020] = 13992, [14020] = 14367, [14601] = 6377,
}

local function localEndpoint(point)
    if not point or type(point.mapID) ~= "number" or type(point.x) ~= "number" or type(point.y) ~= "number"
        or point.x <= 0 or point.x > 100 or point.y <= 0 or point.y > 100 then return false end
    local info = E.Call(C_Map and C_Map.GetMapInfo, point.mapID)
    return (not info or not info.mapType or info.mapType > 2)
        and point.mapID ~= 12 and point.mapID ~= 13 and point.mapID ~= 1414 and point.mapID ~= 1415
        and point.zone ~= "Kalimdor" and point.zone ~= "Eastern Kingdoms"
end

local lootCategoryIcons = {
    ["recipes & patterns"] = "DungeonRecipePortrait",
    ["trash drops"] = "DungeonTrashPortrait",
    ["trash/object"] = "DungeonTrashPortrait",
}

local encounterRoutes = {
    ["city of dalaran"] = {"Atrexis the Grave Knight", "Lyn the Ignored", "Arcane Anomaly", "Mana Devourer", "Fel Ancient", "Unstable Sentinel", "Arcanic Enigma", "Shade of the Archmage"},
    ["hall of thanes"] = {"Faldrim Anvilmar", "Magmatus", "Plunder", "Durgen Dirgehammer"},
    ["molten core"] = {"Lucifron", "Magmadar", "Gehennas", "Garr", "Shazzrah", "Baron Geddon", "Sulfuron Harbinger", "Golemagg the Incinerator", "Majordomo Executus", "Ragnaros"},
    ["blackwing lair"] = {"Razorgore the Untamed", "Vaelastrasz the Corrupt", "Broodlord Lashlayer", "Firemaw", "Ebonroc", "Flamegor", "Chromaggus", "Nefarian"},
    gnomeregan = {"Grubbis", "Viscous Fallout", "Electrocutioner 6000", "Crowd Pummeler 9-60",
        "Dark Iron Ambassador", "Mekgineer Thermaplugg"},
    ["ragefire chasm"] = {"Oggleflint", "Taragaman the Hungerer", "Jergosh the Invoker", "Bazzalan"},
}

local bundledBossIcons = {
    ["magmatus"] = "Interface\\Icons\\Spell_Fire_Elemental_Totem",
    ["lordaeron captain"] = "Interface\\Icons\\INV_Helmet_03",
    ["secret safe"] = "Interface\\Icons\\INV_Misc_TreasureChest_01",
    ["gordok tribute chest"] = "Interface\\Icons\\INV_Misc_TreasureChest_01",
    ["knot thimblejacks cache"] = "Interface\\Icons\\INV_Misc_TreasureChest_01",
}

-- These documented boss rows can also originate solely from a named floor pin.
local pinnedBossNPCs = {
    ["overseer wrex"] = 255391,
    ["lordaeron captain"] = 255699, ["magmatus"] = 261316,
    ["titanosaur"] = 253201, ["venomridge"] = 261813, ["thunderhoof"] = 261812,
    ["direhorn matriarch"] = 262127, ["cinder"] = 261974, ["bolt"] = 262081,
    ["snowtalon"] = 262297, ["vitrix"] = 272561, ["izharel and torrel"] = 253218,
    ["nanaya"] = 261809,
}

-- Documented portrait models for these two encounters use their staging NPCs.
local pinnedBossDisplays = {
    ["deathless marrow"] = 142245,
    ["primeval elemental"] = 129945,
}

local function paintBossToken(frame, boss, anchor, offset, size, mapPin)
    if not boss then
        if frame.bossToken then frame.bossToken:Hide() end
        return
    end
    local token = frame.bossToken
    if not token then
        token = CreateFrame("Frame", nil, frame)
        frame.bossToken = token
        token:SetSize(size, size)
        token:SetPoint(anchor, offset, 0)
        local edge = token:CreateTexture(nil, "BACKGROUND")
        edge:SetAllPoints()
        N.BronzeRail(edge,"TOP")
        local interior = token:CreateTexture(nil, "BORDER")
        interior:SetPoint("TOPLEFT", 2, -2)
        interior:SetPoint("BOTTOMRIGHT", -2, 2)
        interior:SetColorTexture(.075, .057, .035, 1)
        token.edge, token.interior = edge, interior
        local fallback = token:CreateTexture(nil, "ARTWORK", nil, 0)
        fallback:SetAllPoints(interior)
        fallback:SetTexture(bossFallback)
        token.fallback = fallback
        token.portrait = token:CreateTexture(nil, "ARTWORK", nil, 1)
        token.portrait:SetAllPoints(interior)
        if token.CreateMaskTexture then
            local outerMask = token:CreateMaskTexture()
            outerMask:SetAllPoints()
            outerMask:SetTexture(portraitMask, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            edge:AddMaskTexture(outerMask)
            local innerMask = token:CreateMaskTexture()
            innerMask:SetAllPoints(interior)
            innerMask:SetTexture(portraitMask, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            interior:AddMaskTexture(innerMask)
            fallback:AddMaskTexture(innerMask)
            token.portrait:AddMaskTexture(innerMask)
        end
    end
    if boss.marker ~= nil and not mapPin then
        if not token.badge then
            token.badge = token:CreateTexture(nil, "ARTWORK")
            token.badge:SetTexture("Interface\\AddOns\\GrindingForever\\Media\\DungeonRouteBadges")
            token.glyph = N.MakeText(token, 12, "", false)
            token.glyph:SetPoint("CENTER", token.badge, "CENTER", 0, 0)
            token.glyph:SetJustifyH("CENTER")
            token.glyph:SetTextColor(.98, .91, .72)
        end
        local diameter = N.PixelSize(token, 21)
        token.badge:ClearAllPoints()
        token.badge:SetPoint("LEFT", token, "RIGHT", N.PixelSize(token, 4), 0)
        token.badge:SetSize(diameter, diameter)
        local diamond = not tonumber(boss.marker)
        token.badge:SetTexCoord(diamond and .5 or 0, diamond and 1 or .5, 0, 1)
        local font, _, flags = token.glyph:GetFont()
        token.glyph:SetFont(font, N.PixelSize(token, 12), flags)
        token.glyph:SetText(boss.marker)
        token.glyph:Show()
        token.badge:Show()
    elseif token.badge then
        token.badge:Hide()
        token.glyph:Hide()
    end
    local journal = E.journal
    local static = journal and journal.STATIC_DISPLAY_IDS
    local key = ns.DungeonNameKey(boss.name)
    local npcID = boss.portraitNpcID or boss.npcID or pinnedBossNPCs[key]
    local display = boss.displayID
        or (npcID and (bossDisplay[npcID] or static and static[npcID]))
        or pinnedBossDisplays[key]
    local category = lootCategoryIcons[key]
    local icon = category and ("Interface\\AddOns\\GrindingForever\\Media\\" .. category)
        or boss.customIcon
    local portrait = token.portrait
    portrait:SetTexture(nil)
    portrait:SetTexCoord(0, 1, 0, 1)
    local requested
    if display and (mapPin or not icon) and type(SetPortraitTextureFromCreatureDisplayID) == "function" then
        local ok, result = pcall(SetPortraitTextureFromCreatureDisplayID, portrait, display)
        requested = ok and result ~= false
        if not requested then portrait:SetTexture(nil) end
    end
    if not requested and not portrait:GetTexture() then
        portrait:SetTexture(icon or bundledBossIcons[key])
    end
    -- A successful portrait request can return nil while the client loads it.
    token.fallback:SetShown(not portrait:GetTexture())
    token:Show()
end
ns.PaintDungeonBossToken = paintBossToken

local function setWaypoint(loc)
    if not loc then return "No coordinates recorded" end
    local name = loc.name or loc.zone or "Dungeon Waypoint"
    local catalog = ns.RecipeCatalog
    local marked = catalog and catalog.PinWorldMap and catalog.PinWorldMap(loc)
    local compass = ns.NavigationCompass
    if compass and compass.Enabled() then
        local previous = compass.dungeonPin
        if previous then compass.pins[previous] = nil end
        -- Use a recipe-style key so GF recognizes this as an explicit tracking target.
        local key = compass.FlagKey({name = "Dungeon: " .. name}, loc)
        compass.dungeonPin = key
        compass.pins[key] = {key = key, name = name, zone = loc.zone, location = loc, icon = waypointIcon, pin = true}
        compass.age = 1
        return (marked and "Pinned on Map & Compass: " or "Pinned on Compass: ") .. name
    end
    return marked and ("Pinned on Map: " .. name) or "This location could not be pinned"
end

local function questWaypoint(loc)
    local compass = ns.NavigationCompass
    if not compass or not loc then return "No coordinates recorded" end
    local name = loc.name or loc.zone or "Quest"
    local key = compass.FlagKey({name = "Quest: " .. name}, loc)
    if compass.questPin == key then
        compass.ClearQuestPin()
        return "Quest pin cleared"
    end
    if not compass.Enabled() then return "Enable GPS to pin quests" end
    compass.ClearQuestPin()
    compass.questPin = key
    compass.pins[key] = {key = key, name = name, zone = loc.zone, location = loc, icon = compass.questIcon}
    compass.age = 1
    return "Pinned on Compass: " .. name
end

local function questPinLabel(loc)
    local compass = ns.NavigationCompass
    if not compass or not loc then return "Pin" end
    local name = loc.name or loc.zone or "Quest"
    local key = compass.FlagKey({name = "Quest: " .. name}, loc)
    return compass.questPin == key and "Unpin" or "Pin"
end

local function recordFor(instance, name)
    if not instance then return end
    local key = ns.DungeonNameKey(name)
    for title, record in pairs(instance) do
        if ns.DungeonNameKey(title) == key then return record end
    end
end

function ns.ToggleDungeonBrowser()
    if window then
        window:SetShown(not window:IsShown())
        return
    end

    window = CreateFrame("Frame", nil, UIParent)
    window:SetSize(780, 640)
    window:SetPoint("CENTER")
    N.ApplyWindowLayer(window,"dungeons")
    window:SetClampedToScreen(true)
    window:SetMovable(true)
    window:EnableMouse(true)
    local media = "Interface\\AddOns\\GrindingForever\\Media\\"
    local detailActive = false
    local textScale = 1
    local function sizeText(label, parent, size, minimumPixels, compactPixels)
        local font, _, flags = label:GetFont()
        local regular = math.max(size, N.PixelSize(parent, minimumPixels))
        local compact = math.min(regular, N.PixelSize(parent, compactPixels))
        label:SetFont(font, compact + (regular - compact) * textScale, flags)
    end
    local function warmLight(label, pixel)
        label:SetTextColor(.99, .91, .73)
        label:SetShadowColor(.06, .035, .02, .95)
        label:SetShadowOffset(0, -pixel)
    end
    local function darkInk(label, secondary)
        if secondary then label:SetTextColor(.27, .16, .085)
        else label:SetTextColor(.15, .085, .045) end
        label:SetShadowOffset(0, 0)
    end
    local function wood(parent, layer, sublevel)
        local texture = parent:CreateTexture(nil, layer, nil, sublevel or 0)
        texture:SetTexture(media .. "BaseWood")
        texture:SetTexCoord(.10, .56, .11, .37)
        texture:SetVertexColor(.64, .58, .50)
        return texture
    end
    local function paper(parent, layer, sublevel, fullSheet)
        local texture=parent:CreateTexture(nil,layer or "BACKGROUND",nil,sublevel or 0)
        texture:SetTexture(media.."BaseParchment")
        if fullSheet then texture:SetTexCoord(0,1254/2048,0,1254/2048)
        else texture:SetTexCoord(.13,.49,.13,.49) end
        return texture
    end
    local status = N.MakeText(window, 12)
    darkInk(status, true)
    status:SetPoint("BOTTOMLEFT", 18, 14)
    status:SetPoint("BOTTOMRIGHT", -18, 14)

    local mapPane = CreateFrame("Frame", nil, window)
    local mapBacking=paper(mapPane)
    mapBacking:SetAllPoints();mapBacking:SetVertexColor(.96,.89,.77,.32)
    mapBacking:Hide()
    local map = CreateFrame("Frame", nil, mapPane)
    map:SetPoint("TOP",mapPane,"TOP",0,-4)
    local art = map:CreateTexture(nil, "BACKGROUND"); N.BronzeRectangle(map)
    art:SetAllPoints()
    local pins = {}
    local list = CreateFrame("ScrollFrame", nil, window)
    local listPaper=paper(window,"BACKGROUND",5)
    listPaper:SetAllPoints(list)
    listPaper:SetVertexColor(.96,.89,.77,.35)
    listPaper:Hide()
    local content = CreateFrame("Frame", nil, list)
    content:SetSize(window:GetWidth() - 52, 1)
    list:SetScrollChild(content)
    local syncScroll = N.PanelScroll(window, list, function() return list:GetVerticalScroll() end,
        function(value) list:SetVerticalScroll(value) end,
        function() return math.max(0, content:GetHeight() - list:GetHeight()) end, 114)
    local rows, cards, pendingItems, detailBlocks = {}, {}, {}, {}
    local rowHeight = 38
    local selected, floor, tab = nil, 1, "bosses"
    local selectedBoss, selectedQuest, questLandmark
    local draw
    N.PanelChrome(window, {"Dungeon","Journal"}, 600, 490, function() draw(true) end)
    local headerExtra = N.HeaderSize(window) - N.PixelSize(window, 40)

    local function button(parent, label, width, action)
        local b = N.WoodButton(parent, label, width, action)
        b:SetSize(math.max(width,b:GetWidth(),N.PixelSize(b,24)),math.max(28,b.label:GetStringHeight()+N.PixelSize(b,8),N.PixelSize(b,24)))
        return b
    end

    local back = button(window, "Instances", 128, function() selected = nil; draw() end)
    N.ButtonArrow(back,"left","LEFT")
    back:SetPoint("TOPLEFT", 18, -45 - headerExtra)
    local floorButton
    floorButton = button(window, "", 120, function()
        if floorButton.floorCount < 2 then return end
        floor = floor % floorButton.floorCount + 1
        draw()
    end)
    floorButton:SetPoint("TOPRIGHT", -18, -45 - headerExtra)
    floorButton:HookScript("OnEnter", function(self)
        if not self.floorLabel then return end
        GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT")
        GameTooltip:AddLine(self.floorLabel)
        GameTooltip:AddLine("Click for the next floor.", 1, 1, 1)
        GameTooltip:Show()
    end)
    floorButton:HookScript("OnLeave", function() GameTooltip:Hide() end)

    local entrance = button(window, "Pin Entrance", 142, function()
        if selected then status:SetText(setWaypoint(ns.DungeonEntrance(selected))) end
    end)
    entrance:SetPoint("LEFT", back, "RIGHT", 8, 0)
    local clearQuest = button(window, "Clear Quest Pin", 134, function()
        if ns.NavigationCompass.ClearQuestPin() then
            draw()
            status:SetText("Quest pin cleared")
        end
    end)
    clearQuest:SetPoint("LEFT", entrance, "RIGHT", 8, 0)

    local function layoutFloorButton()
        if not floorButton.floorCount or floorButton.floorCount < 2 then return end
        local short = "Floor " .. floor .. " / " .. floorButton.floorCount
        local label = floorButton.floorLabel
        local text = label and (floor .. "/" .. floorButton.floorCount .. "  " .. label) or short
        floorButton.label:SetText(text)
        local padding = N.PixelSize(floorButton, 18)
        local needed = math.max(120, floorButton.label:GetStringWidth() + padding)
        local leftWidth = back:GetWidth()
        if entrance:IsShown() then leftWidth = leftWidth + 8 + entrance:GetWidth() end
        if clearQuest:IsShown() then leftWidth = leftWidth + 8 + clearQuest:GetWidth() end
        local room = window:GetWidth() - 44 - leftWidth
        if needed > room then floorButton.label:SetText(short); needed = 120 end
        floorButton:SetWidth(needed)
    end
    window:HookScript("OnSizeChanged", layoutFloorButton)

    local function makeTab(label, key, width)
        local control = N.WoodButton(window, label, width, function()
            if tab ~= key then tab = key; draw() end
        end)
        control:SetSize(width, 29)
        N.UnderlineControl(control, true)
        control.selectionLine:SetColorTexture(.92, .73, .44, .95)
        control.selectionLine:SetHeight(N.PixelSize(control, 3))
        return control
    end

    local bossTab = makeTab("Bosses", "bosses", 85)
    local questTab = makeTab("Quests", "quests", 72)

    local function itemLabel(name)
        if E.Public(name) and type(name) == "string" and name ~= "" and not name:match("^Item%s+%d+$") then
            return name
        end
    end

    local function paintItem(row)
        local id = row.itemID
        local name = itemLabel(row.itemName) or E.ItemLabel(id)
        if not name and pendingItems[id] == nil then
            pendingItems[id] = C_Item and type(C_Item.RequestLoadItemDataByID) == "function" or false
            if pendingItems[id] then E.Call(C_Item.RequestLoadItemDataByID, id) end
        end
        row.label:SetText(name or (pendingItems[id] and "Loading Item Name..." or "Unknown Item"))
        local icon = E.Call(C_Item and C_Item.GetItemIconByID, id) or E.Call(GetItemIcon, id)
        row.icon:SetTexture(E.Public(icon) and icon or "Interface\\Icons\\INV_Misc_QuestionMark")
    end

    local openRewardQuests, rewardRequests = {}, {}
    window:SetScript("OnEvent", function(self, event, itemID, success)
        if event == "QUEST_DATA_LOAD_RESULT" then
            if not E.Public(itemID) or type(itemID) ~= "number" or not rewardRequests[itemID] then return end
            rewardRequests[itemID] = E.Public(success) and success == true and "loaded" or "unavailable"
            if self:IsShown() and openRewardQuests[itemID] then draw(true) end
            return
        end
        if event ~= "GET_ITEM_INFO_RECEIVED" then
            if self:IsShown() and selected and tab == "quests" then draw(true) end
            return
        end
        if not E.Public(itemID) or type(itemID) ~= "number" then return end
        if not pendingItems[itemID] then return end
        pendingItems[itemID] = false
        if not self:IsShown() then return end
        for index = 1, content.visibleRows do
            local row = rows[index]
            if row.itemID == itemID then paintItem(row) end
        end
    end)
    window:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    E.Call(window.RegisterEvent, window, "QUEST_DATA_LOAD_RESULT")
    for _, event in ipairs({"QUEST_ACCEPTED", "QUEST_REMOVED", "QUEST_TURNED_IN"}) do
        E.Call(window.RegisterEvent, window, event)
    end

    local function detailFill(frame, sublevel)
        local fill = frame:CreateTexture(nil, "BACKGROUND", nil, sublevel or 0)
        fill:SetAllPoints()
        fill:SetColorTexture(.98, .90, .73, .72)
        return fill
    end

    local function activateRow(row, mouseButton)
        if row.itemID and mouseButton == "LeftButton" and ns.HandleItemChatClick(row.itemLink or row.itemID) then return end
        if row.action then row.action(row, mouseButton) end
    end

    local function addRow(label, action, itemID, detail, actionLabel, boss, heading, completed, underway, framed, inDetailBlock, itemLink)
        local index = content.visibleRows + 1
        content.visibleRows = index
        local row = rows[index]
        if not row then
            row = CreateFrame("Button", nil, content)
            row:SetPoint("TOPLEFT", 0, -(index - 1) * rowHeight)
            row:SetPoint("TOPRIGHT", 0, -(index - 1) * rowHeight)
            row:SetHeight(rowHeight)
            row.selectorTrim=N.BronzeRectangle(row, 2)
            local separator = row:CreateTexture(nil, "BACKGROUND")
            separator:SetPoint("BOTTOMLEFT", 6, 0)
            separator:SetPoint("BOTTOMRIGHT", -6, 0)
            separator:SetHeight(1)
            N.BronzeRail(separator,"TOP");separator:SetAlpha(.26)
            local fill=paper(row,"BACKGROUND",-2)
            fill:SetAllPoints();fill:SetVertexColor(.96,.87,.70,.18)
            row.separator, row.paperFill = separator, fill
            row.detailFill = detailFill(row, -2)
            row.woodFill = wood(row, "BACKGROUND")
            row.woodFill:SetAllPoints()
            row.hover = row:CreateTexture(nil, "HIGHLIGHT")
            row.hover:SetAllPoints()
            row.hover:SetColorTexture(.95, .78, .51, .20)
            row:SetHighlightTexture(row.hover)
            row.icon = row:CreateTexture(nil, "ARTWORK")
            row.icon:SetSize(23, 23)
            row.icon:SetPoint("LEFT", 7, 0)
            row.label = N.MakeText(row, 14)
            row.label:SetWordWrap(true)
            row.detail = N.MakeText(row, 11)
            row.detail:SetWordWrap(true)
            row.command = N.MakeText(row, 12)
            row.command:SetJustifyH("RIGHT")
            row.command:SetWordWrap(false)
            row.command:SetPoint("RIGHT", -8, 0)
            row.disclosure=N.ControlArrow(row,"right","RIGHT")
            row.disclosure:SetVertexColor(.49,.31,.12)
            row.stamp = row:CreateTexture(nil, "OVERLAY", nil, 5)
            row.stamp:SetTexture(media .. "QuestBootTrail")
            row.stamp:SetTexCoord(0, 88 / 128, 0, 68 / 128)
            row.stamp:SetBlendMode("BLEND")
            row.stampGold = row:CreateTexture(nil, "OVERLAY", nil, 6)
            row.stampGold:SetTexture(media .. "QuestBootTrail")
            row.stampGold:SetTexCoord(0, 88 / 128, 0, 68 / 128)
            row.stampGold:SetAllPoints(row.stamp)
            row.stampGold:SetBlendMode("ADD")
            row.stampGold:SetVertexColor(.98, .83, .52, .25)
            row.underway=row:CreateTexture(nil,"OVERLAY",nil,5)
            row.underway:SetSize(26,26)
            row.underway:SetPoint("RIGHT",-28,0)
            local function showTooltip(self)
                if not self.itemID or not GameTooltip then return end
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if not ns.SetNativeItemTooltip(GameTooltip, self.itemLink or self.itemID) then
                    GameTooltip:AddLine(self.label:GetText())
                end
                GameTooltip:Show()
            end
            local function hideTooltip(self)
                if self.itemID and GameTooltip and GameTooltip:IsOwned(self) then GameTooltip:Hide() end
            end
            row:SetScript("OnEnter", showTooltip)
            row:SetScript("OnLeave", hideTooltip)
            row:SetScript("OnHide", hideTooltip)
            row:SetScript("OnClick", activateRow)
            row.itemButton = CreateFrame("Button", nil, row)
            row.itemButton:SetAllPoints(row.icon)
            row.itemButton:RegisterForClicks("LeftButtonUp")
            row.itemButton:SetScript("OnEnter", function() showTooltip(row) end)
            row.itemButton:SetScript("OnLeave", function() hideTooltip(row) end)
            row.itemButton:SetScript("OnClick", function(_, mouseButton)
                if row.itemID then activateRow(row, mouseButton) end
            end)
            rows[index] = row
        end
        row.itemID, row.itemName, row.itemLink, row.action = itemID, label, itemLink, action
        local showUnderway = type(underway) == "string"
        local chainMarker = showUnderway and completed == true
        local woodenRow = boss ~= nil or showUnderway
        local pixel = N.PixelSize(row, 1)
        local pad = math.max(8, 9 * pixel)
        local verticalPad = inDetailBlock and 5 * pixel or pad
        local bossSize = math.max(26, 28 * pixel)
        local detailCard = framed == "detail"
        row.paperFill:SetShown(not inDetailBlock and not woodenRow and not detailCard)
        row.detailFill:SetShown(detailCard)
        row.separator:SetShown(not inDetailBlock)
        row.woodFill:SetShown(woodenRow)
        local titleSize = (boss or showUnderway) and 16 or heading and 15 or 14
        sizeText(row.label, row, titleSize, (boss or showUnderway) and 17 or 15, woodenRow and 15.5 or 14)
        sizeText(row.detail, row, 13, 14, woodenRow and 11.5 or 12.5)
        sizeText(row.command, row, 13, 14, 12.5)
        if woodenRow then
            warmLight(row.label, pixel)
            warmLight(row.command, pixel)
            warmLight(row.detail, pixel)
            row.disclosure:SetVertexColor(.98, .83, .52)
        else
            darkInk(row.label, false)
            darkInk(row.command, true)
            darkInk(row.detail, true)
            row.disclosure:SetVertexColor(.42, .24, .11)
        end
        row.icon:SetShown(itemID ~= nil)
        row.itemButton:SetShown(itemID ~= nil)
        paintBossToken(row, boss, "LEFT", pad, bossSize)
        if boss then
            row.bossToken:SetSize(bossSize, bossSize)
            row.bossToken:ClearAllPoints()
            row.bossToken:SetPoint("LEFT", row, "LEFT", pad, 0)
        end
        row.label:ClearAllPoints()
        row.detail:ClearAllPoints()
        local markerWidth = boss and boss.marker ~= nil and N.PixelSize(row, 25) or 0
        local left = boss and (bossSize + 2 * pad + markerWidth) or itemID and 40 or pad
        local disclosure = actionLabel=="Expand" or actionLabel=="Collapse"
        row.command:SetText(not disclosure and actionLabel or "")
        local glyphWidth = math.max(12, 12 * pixel)
        local badgeWidth = math.max(24, 25 * pixel)
        local badgeInset = disclosure and (pad + glyphWidth + 4 * pixel) or pad
        local stampWidth = 29 * pixel * 88 / 68
        local stampInset = badgeInset + badgeWidth + 5 * pixel
        local right = chainMarker and (stampInset + stampWidth + 6 * pixel)
            or showUnderway and (badgeInset + badgeWidth + 6 * pixel)
            or disclosure and (pad + glyphWidth + 7 * pixel)
            or actionLabel and (row.command:GetStringWidth() + 2 * pad) or pad
        local textWidth=math.max(32, content:GetWidth()-left-right)
        row.label:SetWidth(textWidth)
        row.detail:SetWidth(textWidth)
        row.detail:SetText(detail or "")
        row.command:ClearAllPoints()
        row.command:SetPoint("RIGHT", row, "RIGHT", -pad, 0)
        row.disclosure:SetSize(glyphWidth, glyphWidth)
        row.disclosure:SetShown(disclosure)
        if disclosure then row.disclosure:SetRotation(actionLabel=="Collapse" and -math.pi/2 or 0) end
        row.stamp:SetSize(stampWidth, 29 * pixel)
        row.stamp:SetShown(chainMarker)
        row.stampGold:SetShown(chainMarker)
        if showUnderway then
            row.underway:SetTexture(media.."JournalQuest"..underway)
        end
        row.underway:SetSize(badgeWidth, badgeWidth)
        row.underway:ClearAllPoints()
        row.underway:SetPoint("RIGHT",row,"RIGHT",-badgeInset,0)
        row.underway:SetShown(showUnderway)
        row.disclosure:ClearAllPoints()
        row.disclosure:SetPoint("RIGHT", row, "RIGHT", -pad, 0)
        if itemID then paintItem(row) else row.label:SetText(label) end
        local selector=not inDetailBlock and (framed or itemID~=nil or (action~=nil and not heading))
        row.selectorTrim:SetShown(selector)
        local labelHeight=math.max(18 * pixel,row.label:GetStringHeight())
        local detailHeight=detail and row.detail:GetStringHeight() + 2 * pixel or 0
        local minimumHeight=boss and math.max(41,42*pixel) or showUnderway and math.max(48,50*pixel) or rowHeight
        if inDetailBlock then minimumHeight=itemID and 30 * pixel or 27 * pixel end
        local height=math.max(minimumHeight,labelHeight+detailHeight+2*verticalPad)
        row.label:SetPoint("TOPLEFT",left,detail and -verticalPad or -(height-labelHeight)/2)
        row.detail:SetPoint("TOPLEFT",left,-labelHeight-verticalPad-2*pixel)
        row.stamp:ClearAllPoints()
        row.stamp:SetPoint("RIGHT",row,"RIGHT",-stampInset,0)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT",content,"TOPLEFT",0,-content.rowY)
        row:SetPoint("TOPRIGHT",content,"TOPRIGHT",0,-content.rowY)
        row:SetHeight(height)
        content.rowY=content.rowY+height+(selector and 5 or 0)
        row:EnableMouse(action ~= nil or itemID ~= nil)
        row:Show()
        return row
    end

    local function drawDetailBlock(top)
        local index = content.visibleDetailBlocks + 1
        content.visibleDetailBlocks = index
        local block = detailBlocks[index]
        if not block then
            block = CreateFrame("Frame", nil, content)
            block:SetFrameLevel(content:GetFrameLevel())
            block:EnableMouse(false)
            detailFill(block)
            N.BronzeRectangle(block, 2)
            detailBlocks[index] = block
        end
        local pixel = N.PixelSize(block, 1)
        block:ClearAllPoints()
        block:SetPoint("TOPLEFT",content,"TOPLEFT",0,-top)
        block:SetPoint("TOPRIGHT",content,"TOPRIGHT",0,-top)
        block:SetHeight(content.rowY - top + 3 * pixel)
        block:Show()
        content.rowY = content.rowY + 8 * pixel
    end

    local function positionPin(pin, mapWidth, mapHeight)
        local point = pin.landmark
        local dx = point.markerX and N.PixelSize(map, point.markerX) or 0
        local dy = point.markerY and N.PixelSize(map, point.markerY) or 0
        local scale = pin:GetScale()
        pin:ClearAllPoints()
        pin:SetPoint("CENTER", map, "TOPLEFT", (point.x * mapWidth + dx) / scale,
            (-point.y * mapHeight + dy) / scale)
        if (dx ~= 0 or dy ~= 0) and pin.CreateLine then
            if not pin.leader then
                pin.leader = pin:CreateLine(nil, "BACKGROUND")
                pin.leader:SetColorTexture(.98, .84, .54, 1)
            end
            pin.leader:SetThickness(N.PixelSize(map, 1))
            pin.leader:SetStartPoint("CENTER", pin, -dx / scale, -dy / scale)
            pin.leader:SetEndPoint("CENTER", pin, 0, 0)
            pin.leader:Show()
        elseif pin.leader then
            pin.leader:Hide()
        end
    end

    local function addPin(position, count)
        local pin = pins[count]
        if not pin then
            pin = CreateFrame("Button", nil, map)
            pin:SetSize(19, 19)
            pin.icon = pin:CreateTexture(nil, "ARTWORK")
            pin.icon:SetAllPoints()
            pin:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:AddLine(self.landmark.name)
                if self.landmark.detail then GameTooltip:AddLine(self.landmark.detail, 1, 1, 1, true) end
                GameTooltip:Show()
            end)
            pin:SetScript("OnLeave", function() GameTooltip:Hide() end)
            pin:SetScript("OnClick", function(self)
                if self.landmark.kind == "boss" then
                    selectedBoss, tab = self.landmark.name, "bosses"
                    GameTooltip:Hide()
                    draw()
                elseif self.landmark.kind == "floor" then
                    local target = self.landmark.targetFloor
                    if target and target >= 1 and target <= floorButton.floorCount then
                        floor, selectedBoss = target, nil
                        GameTooltip:Hide()
                        draw()
                    end
                elseif self.landmark.kind == "entrance" then
                    local loc = ns.DungeonEntrance(selected)
                    if loc then status:SetText(setWaypoint(loc)) end
                elseif self.landmark.kind == "quest" then
                    selectedQuest, questLandmark, tab = nil, self.landmark, "quests"
                    GameTooltip:Hide()
                    draw()
                end
            end)
            pins[count] = pin
        end
        pin.landmark = position
        local focused = selectedBoss and position.kind == "boss" and
            ns.DungeonNameKey(position.name) == ns.DungeonNameKey(position.focusAlias or selectedBoss)
        pin:SetScale(focused and 1.22 or 1)
        local isStair = type(position.stairLabel) == "string"
        if isStair and not pin.stairBadge then
            local badge = CreateFrame("Frame", nil, pin)
            badge:SetAllPoints()
            local border = badge:CreateTexture(nil, "BACKGROUND")
            border:SetAllPoints()
            border:SetColorTexture(.87, .67, .37)
            local plate = badge:CreateTexture(nil, "BACKGROUND", nil, 1)
            local pixel = N.PixelSize(badge, 1)
            plate:SetPoint("TOPLEFT", pixel, -pixel)
            plate:SetPoint("BOTTOMRIGHT", -pixel, pixel)
            plate:SetColorTexture(.15, .08, .04)
            badge.label = N.MakeText(badge, 13, "", true)
            badge.label:SetPoint("CENTER")
            badge.label:SetTextColor(1, .89, .64)
            pin.stairBadge = badge
        end
        if pin.stairBadge then
            pin.stairBadge:SetShown(isStair)
            if isStair then pin.stairBadge.label:SetText(position.stairLabel) end
        end
        pin.icon:SetShown(not position.boss and not isStair)
        if not position.boss then
            pin.icon:SetTexture(position.kind == "quest" and "Interface\\GossipFrame\\AvailableQuestIcon"
                or "Interface\\MINIMAP\\TRACKING\\Dungeon")
        end
        paintBossToken(pin, position.boss, "CENTER", 0, 23, true)
        positionPin(pin, map:GetWidth(), map:GetHeight())
        pin:Show()
    end

    local currentMapAspect
    local function fitMap()
        if not currentMapAspect or not map:IsShown() then return end
        local width = window:GetWidth()
        local leftWidth = math.max(250, math.floor(width * .36))
        mapPane:ClearAllPoints()
        mapPane:SetPoint("TOPLEFT", window, "TOPLEFT", leftWidth + 22, -76 - headerExtra)
        mapPane:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -18, 42)
        local height = math.max(1, math.min(window:GetHeight() - 126 - headerExtra, (width - leftWidth - 48) / currentMapAspect))
        local mapWidth = height * currentMapAspect
        map:SetSize(mapWidth, height)
        for _, pin in ipairs(pins) do
            if pin:IsShown() and pin.landmark then
                positionPin(pin, mapWidth, height)
            end
        end
    end
    window:HookScript("OnSizeChanged", fitMap)
    N.LiveLayout(window, function() draw(true) end)

    local function drawMap(image, bosses, allowedNames)
        currentMapAspect = image.aspect
        fitMap()
        art:SetTexture(assets .. image.file)
        art:SetTexCoord(image.u0, image.u1, image.v0, image.v1)
        local count, seen, positionAlias = 0, {}, {}
        local referencePins = ns.DungeonReferencePins[image.pinKey or image.file] or {}
        for _, point in ipairs(referencePins) do
            if point.sharedWith then positionAlias[point[1]] = point.sharedWith end
        end
        local function landmark(name, x, y, kind, detail, options)
            if type(name) ~= "string" or type(x) ~= "number" or type(y) ~= "number" then return end
            if x < 0 or y < 0 or x > 1 or y > 1 then return end
            if kind == "quest" then
                local matches = {}
                for key, title in pairs(allowedNames) do
                    if key == ns.DungeonNameKey(name) or (detail or ""):find(title, 1, true) then
                        matches[#matches + 1] = title
                    end
                end
                if #matches == 0 then return end
                table.sort(matches)
                detail = table.concat(matches, ", ")
            end
            local key = kind .. ":" .. ns.DungeonNameKey(name)
            local positions = seen[key] or {}
            for _, position in ipairs(positions) do
                if kind == "boss" or (math.abs(position.x - x) < .006 and math.abs(position.y - y) < .006) then
                    return
                end
            end
            positions[#positions + 1] = {x = x, y = y}
            seen[key] = positions
            local boss
            if kind == "boss" then
                local bossKey = ns.DungeonNameKey(name)
                boss = bosses[bossKey] or {name = name}
                boss.floor = boss.floor or floor
                bosses[bossKey] = boss
            end
            count = count + 1
            addPin({name = name, x = x, y = y, kind = kind, detail = detail, boss = boss,
                markerX = options and options.markerX, markerY = options and options.markerY,
                targetFloor = options and options.targetFloor,
                stairLabel = options and kind == "floor" and (options.stairLabel or options.marker),
                focusAlias = selectedBoss and positionAlias[selectedBoss]}, count)
        end
        for _, point in ipairs(referencePins) do
            if not point.sharedWith and (point[4] ~= "floor" or point.targetFloor) then
                landmark(point[1], point[2], point[3], point[4], point[5], point)
            end
        end
        local mapID = not image.curatedPins and tonumber(image.file:match("^(%d+)%.blp$"))
        local journal = selected.journalMap or (selected.sourceData and selected.map)
        for _, position in ipairs(journal and journal.bosses or {}) do
            local sourceFloor = journal.floors and journal.floors[position.floor or 1]
            if mapID and sourceFloor and sourceFloor.uiMapID == mapID then
                landmark(position.name, position.x, position.y, "boss")
            end
        end
        local points = image.legacyLandmarks ~= false and recordFor(ns.DungeonLandmarks, selected.name)
        for _, point in ipairs(points or {}) do
            if (point[6] or 1) == floor then landmark(point[1], point[2], point[3], point[4] or "boss", point[5]) end
        end
        if mapID and EJ_GetMapEncounter then
            for index = 1, 40 do
                local x, y, _, name = E.Call(EJ_GetMapEncounter, mapID, index)
                if not name then break end
                landmark(name, x, y, "boss")
            end
        end
        return count
    end

    local function showLoot(boss, questRows, fallback)
        if not boss.lootCategory then
            local top = content.rowY
            local function mechanicRow(label, description, heading)
                addRow(label, nil, nil, description, nil, nil, heading, nil, nil, nil, true)
            end
            local bossID = boss.npcID or pinnedBossNPCs[ns.DungeonNameKey(boss.name)]
            local facts = bossID and ns.DungeonEncounterFacts and ns.DungeonEncounterFacts[bossID]
            local creatureID = E.NPCID(E.Call(UnitGUID, "target"))
            local hp, levelText
            if creatureID and creatureID == bossID then
                local targetLevel = E.Call(UnitLevel, "target")
                if E.Public(targetLevel) and type(targetLevel) == "number" and targetLevel > 0 then
                    levelText = tostring(targetLevel)
                end
                local maxHealth = E.Call(UnitHealthMax, "target")
                if E.Public(maxHealth) and type(maxHealth) == "number" and maxHealth > 100 then hp = maxHealth end
            end
            if not levelText and facts and facts.minLevel then
                local minimum, maximum = facts.minLevel, facts.maxLevel
                levelText = minimum == maximum and tostring(minimum) or (minimum .. "–" .. maximum)
                if facts.alternateLevel then levelText = levelText .. " / " .. facts.alternateLevel end
                levelText = levelText .. " (reference)"
            end
            local healthSource = not hp and facts and facts.referenceHealth
            hp = hp or healthSource
            local healthText
            if hp then
                healthText = tostring(hp):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "") .. " HP"
                if healthSource then healthText = healthText .. " (reference)" end
            end
            mechanicRow("Level " .. (levelText or "unverified") .. "  ·  " .. (healthText or "HP unverified"))
            mechanicRow("Abilities", nil, true)
            local lookup = ns.GetDungeonEncounterVerifiedFacts
            local verified = lookup and lookup(selected.name, boss.name, bossID)
            local mechanics = verified and verified.mechanics or facts and facts.mechanics
            if mechanics and #mechanics > 0 then
                for _, mechanic in ipairs(mechanics) do
                    mechanicRow(mechanic.name, mechanic.description)
                end
            else
                mechanicRow("No documented Forever abilities yet.")
            end
            drawDetailBlock(top)
        end
        local found = {}
        local hasLoot = false
        local notes = {}
        for _, item in ipairs(fallback or {}) do
            if type(item) == "table" then notes[item[1]] = item[2] end
        end
        for _, q in ipairs(questRows) do
            local item = q.reference and q.reference.startItem or q.record.startItem
            if item and type(item[4]) == "string" and item[4]:lower():find(boss.name:lower(), 1, true) then
                notes[item[1]] = "Starts " .. q.name
            end
        end
        local function add(id, name, detail)
            if not id or found[id] then return end
            found[id] = true
            hasLoot = true
            detail = notes[id] or detail
            addRow(name, nil, id, detail, nil, nil, nil, nil, nil, "detail")
        end
        for _, loot in ipairs(boss.referenceLoot or {}) do
            if loot[1] > 0 then
                add(loot[1], loot[2], loot[3])
            elseif loot[2] then
                hasLoot = true
                addRow(loot[2], nil, nil, nil, nil, nil, nil, nil, nil, "detail")
            end
        end
        for _, loot in ipairs(boss.loot or {}) do add(loot[1], loot[2], loot[3]) end
        for _, item in ipairs(fallback or {}) do
            if type(item) == "table" then add(item[1], nil, item[2]) else add(item) end
        end
        for _, q in ipairs(questRows) do
            local item = q.reference and q.reference.startItem or q.record.startItem
            if item and notes[item[1]] == "Starts " .. q.name then
                add(item[1], item[2])
            end
        end
        if not hasLoot then addRow("No loot records for this source") end
    end

    local function showBosses(bosses, questRows, fallback)
        local names = {}
        for _, boss in pairs(bosses) do names[#names + 1] = boss.name end
        local order, count = {}, 0
        local function rank(name)
            local key = ns.DungeonNameKey(name)
            if not order[key] and not lootCategoryIcons[key] then
                count = count + 1
                order[key] = count
            end
        end
        for _, name in ipairs(encounterRoutes[ns.DungeonNameKey(selected.name)] or {}) do rank(name) end
        for _, boss in ipairs(selected.bosses or {}) do rank(boss.name) end
        for _, reference in ipairs(ns.DungeonReferencesFor(selected.name)) do
            for _, boss in ipairs(reference.encounters) do rank(boss.name) end
        end
        table.sort(names, function(a, b)
            local keyA, keyB = ns.DungeonNameKey(a), ns.DungeonNameKey(b)
            local categoryA, categoryB = lootCategoryIcons[keyA] ~= nil, lootCategoryIcons[keyB] ~= nil
            if categoryA ~= categoryB then return not categoryA end
            local rankA, rankB = order[keyA] or math.huge, order[keyB] or math.huge
            if rankA ~= rankB then return rankA < rankB end
            local floorA, floorB = bosses[keyA].floor or math.huge, bosses[keyB].floor or math.huge
            if floorA ~= floorB then return floorA < floorB end
            return a < b
        end)
        if selectedBoss then
            local boss = bosses[ns.DungeonNameKey(selectedBoss)]
            if boss then
                addRow(boss.name, function() selectedBoss = nil; draw() end, nil, nil, "Back To Bosses", boss)
                showLoot(boss, questRows, recordFor(fallback, boss.name))
                return
            end
            selectedBoss = nil
        end
        for _, name in ipairs(names) do
            local boss = bosses[ns.DungeonNameKey(name)]
            addRow(name, function()
                selectedBoss = name
                if boss.floor then floor = boss.floor end
                draw()
            end, nil, nil, "Expand", boss)
        end
        if #names == 0 then addRow("No encounters recorded for this instance") end
    end

    local function questComplete(q)
        if not q.id then return false end
        local state = E.QuestState(q.id)
        if state.inLog then return false end
        local completed = E.state and E.state.completed
        return completed and completed[q.id] == true or state.rewarded == true
    end

    local function dungeonQuests(instance)
        local rows = ns.DungeonQuestRows(instance, instance.name)
        local faction = E.Call(UnitFactionGroup, "player")
        local _, class = E.Call(UnitClass, "player")
        local policy = ns.ForeverQuestPlanner
        local byID = {}
        for _, quest in ipairs(rows) do
            if quest.id then byID[quest.id] = quest end
        end
        for _, reference in ipairs(ns.DungeonReferencesFor(instance.name)) do
            for _, fact in ipairs(reference.quests or {}) do
                local row = byID[fact.id]
                if not row then
                    row = {id = fact.id, name = fact.name, source = "Dungeon Quest",
                        record = ns.ForeverQuestData.quests[fact.id] or {}}
                    byID[fact.id] = row
                    rows[#rows + 1] = row
                end
                row.reference = row.reference or fact
            end
        end
        for i = #rows, 1, -1 do
            local quest = rows[i]
            local fact = quest.reference or quest.record
            local side = fact.faction or quest.record.side
            if (policy and not policy.AllowsQuest(quest.id, faction, fact))
                or (fact.classOnly and class and fact.classOnly ~= class)
                or ((side == "Alliance" or side == "Horde") and faction and side ~= faction) then
                table.remove(rows, i)
            end
        end
        table.sort(rows, function(a,b) return a.name < b.name end)
        return rows
    end

    local function showQuests(questRows)
        local faction = E.Call(UnitFactionGroup, "player")
        local _, class = E.Call(UnitClass, "player")
        local questData = ns.ForeverQuestData
        local data = questData.quests
        local function blockRow(title, detail, itemID, action, command, heading, itemLink)
            return addRow(title, action, itemID, detail, command, nil, heading, nil, nil, nil, true, itemLink)
        end
        local function nameKey(name, questName)
            if type(name) ~= "string" or name == questName or name == "Inside the dungeon"
                or name:match("^%a+ #%d+$") then return end
            return ns.DungeonNameKey(name:match("^(.-)%s+—%s+") or name)
        end
        local function samePlace(a, b)
            return a.location == b.location
                or not (a.preferred and b.preferred) and a.world and b.world and a.world == b.world
        end
        local function endpoints(q, start)
            local hint, points = ns.DungeonQuestLocations(q, start)
            local reference = q.reference
            local primary = reference and ns.DungeonLocation(start and reference.startPoint or not start and reference.endPoint, hint or q.name)
            local record = data[q.id] or q.record or {}
            local sources = (start and record.starts or not start and record.ends) or {}
            local source = #sources == 1 and sources[1]
            local npc = source and source.kind == "npc" and source.id or nil
            local npcKey = npc and ("npc:"..npc)
            local npcName = npcKey and questData.names and questData.names[npcKey]
            local aliases = npcKey and questData.spawns and questData.spawns[npcKey] or {}
            local known = npcName or (primary and nameKey(primary.name, q.name) and primary.name) or hint
            local function worldPosition(point, preferred)
                local result
                for _, alias in ipairs(aliases) do
                    local distance = preferred and 1 or .05
                    if alias.mapID == point.mapID and type(alias.x) == "number" and type(alias.y) == "number"
                        and math.abs(alias.x - point.x) < distance and math.abs(alias.y - point.y) < distance
                        and type(alias.worldMap) == "number" and type(alias.worldX) == "number" and type(alias.worldY) == "number" then
                        local value = string.format("%d:%.2f:%.2f", alias.worldMap, alias.worldX, alias.worldY)
                        if result and result ~= value then return end
                        result = value
                    end
                end
                return result
            end
            local groups, byName = {}, {}
            local function collect(point, preferred)
                if not localEndpoint(point) then return end
                local name = nameKey(point.name, q.name) and point.name or known or q.name
                local key = nameKey(name, q.name) or name
                local matchesNPC = npc and (not npcName or key == nameKey(npcName, q.name))
                local candidate = {name = matchesNPC and npcName or name, point = point, preferred = preferred,
                    nameKey = nameKey(name, q.name), npc = matchesNPC and npc or nil,
                    location = string.format("%d:%.1f:%.1f", point.mapID, point.x, point.y),
                    world = matchesNPC and worldPosition(point, preferred) or nil}
                local group = byName[key]
                if not group then
                    byName[key], groups[#groups + 1] = candidate, candidate
                elseif not samePlace(group, candidate) then
                    group.conflict = true
                end
            end
            collect(primary, true)
            for _, point in ipairs(points or {}) do collect(point) end
            if #groups == 0 then
                local name = npcName or hint or "Location Unavailable"
                groups[1] = {name = name, nameKey = nameKey(name, q.name), npc = npc}
            end
            return groups, #sources > 0 and not npc
        end
        local function endpointRow(label, group)
            local title = label .. " / " .. group.name
            local point = group.point
            if group.conflict and not group.preferred then
                blockRow(title, "Conflicting Coordinates")
            elseif not point then
                blockRow(title)
            else
                local location = string.format("%s (%.1f, %.1f)", point.zone or "Zone Map", point.x, point.y)
                blockRow(title, location, nil,
                    function() local result=questWaypoint(point); draw(true); status:SetText(result) end, questPinLabel(point))
            end
        end
        local function addEndpoints(q)
            local ends, endAmbiguous = endpoints(q, false)
            local item = q.reference and q.reference.startItem or q.record.startItem
            if item then
                blockRow("Start / " .. (item[2] or ("Item " .. item[1])),
                    type(item[4]) == "string" and item[4] or "Use this item to start the quest", item[1])
            else
                local starts, startAmbiguous = endpoints(q, true)
                local first, last = starts[1], ends[1]
                local sameNPC = first.npc and last.npc and first.npc == last.npc
                    or (not first.npc or not last.npc) and first.nameKey and first.nameKey == last.nameKey
                -- Identical verified contacts outrank inconsistent fallback spawn coordinates.
                local samePoint = first.point and last.point and samePlace(first, last)
                    and ((first.preferred and last.preferred) or (not first.conflict and not last.conflict))
                local sameUnlocatedNPC = not first.point and not last.point and first.npc and first.npc == last.npc
                if #starts == 1 and #ends == 1 and not startAmbiguous and not endAmbiguous and sameNPC
                    and (samePoint or sameUnlocatedNPC) then
                    endpointRow("Start / Turn In", last.preferred and not first.preferred and last or first)
                    return
                end
                for _, group in ipairs(starts) do endpointRow("Start", group) end
            end
            for _, group in ipairs(ends) do endpointRow("Turn In", group) end
        end
        local known, previous, nextSteps, followups, registeredRows = {}, {}, {}, {}, {}
        local function link(before, after)
            if type(before) ~= "number" or type(after) ~= "number"
                or before <= 0 or after <= 0 or before == after then return end
            previous[after] = previous[after] or {}
            nextSteps[before] = nextSteps[before] or {}
            for _, id in ipairs(previous[after]) do if id == before then return end end
            table.insert(previous[after], before)
            table.insert(nextSteps[before], after)
        end
        for _, row in ipairs(questRows) do
            if row.id then
                known[row.id], registeredRows[row.id] = row, row
            end
        end
        for _, row in ipairs(questRows) do
            local last
            for _, step in ipairs(row.reference and row.reference.chain or {}) do
                local id = step[1]
                if id ~= row.id then
                    local loc = step[3]
                    local record = data[id] or {}
                    known[id] = known[id] or {id = id, name = record.title or step[2] or ("Quest " .. id), record = record}
                    if loc and not known[id].reference then known[id].reference = {startPoint = loc} end
                    if step.prerequisite then known[id].prerequisite = true end
                    link(last,id)
                    last = id
                end
            end
            link(last,row.id)
            for _, step in ipairs(row.reference and row.reference.followups or {}) do
                local record = data[step.id] or {}
                known[step.id] = {id=step.id, name=step.name or record.title, record=record, reference=step}
                followups[step.id] = true
                link(step.after or row.id, step.id)
            end
        end
        for _, row in ipairs(questRows) do
            local record = data[row.id] or row.record
            if row.record.leadsToQuestLink then link(row.id,row.record.leadsToQuestLink.id) end
            if not previous[row.id] then
                for _, req in ipairs(record.prerequisites or {}) do
                    if not req.breadcrumb then link(req.pre,row.id) end
                end
            end
        end
        local function availableStep(id)
            local record = data[id] or {}
            local step = known[id] or {id=id, name=record.title, record=record}
            local policy = ns.ForeverQuestPlanner
            local reference = step.reference
            if not step.name or (reference and reference.classOnly and reference.classOnly ~= class)
                or (policy and not policy.AllowsQuest(id, faction, reference or step.record)) then return end
            return step
        end
        local function chainFor(q)
            if not q.id then return {q} end
            local chain, visited = {}, {}
            local function visit(id)
                if not id or id <= 0 or visited[id] then return end
                visited[id] = true
                local step = availableStep(id)
                if not step then return end
                local record = step.record
                local parents = previous[id]
                if parents then
                    for _, parent in ipairs(parents) do visit(parent) end
                else
                    for _, req in ipairs(record.prerequisites or {}) do
                        if not req.breadcrumb then visit(req.pre) end
                    end
                end
                chain[#chain+1] = step
            end
            visit(q.id)
            if #chain == 0 then chain[1] = q end
            local tail = q.id
            while tail do
                local nextID
                for _, candidate in ipairs(nextSteps[tail] or {}) do
                    if not visited[candidate] and availableStep(candidate) then
                        if nextID then nextID = nil; break end
                        nextID = candidate
                    end
                end
                if not nextID then break end
                visit(nextID)
                tail = nextID
            end
            return chain
        end
        local questObjectiveFallbacks = {
            [5726] = "Recover a Lieutenant's Insignia from the Burning Blade and bring it to Thrall in Orgrimmar.",
            [5727] = "Show the Lieutenant's Insignia to Neeru Fireblade in the Cleft of Shadow, then report back to Thrall.",
            [5728] = "Defeat Bazzalan and Jergosh the Invoker in Ragefire Chasm, then return to Thrall.",
            [870]="Investigate the fissure beneath the Forgotten Pools, then return to Tonga Runetotem.",
            [877]="Test the Dried Seeds at the Stagnant Oasis fissure and return to Tonga Runetotem.",
            [880]="Collect 8 Altered Snapjaw Shells and bring them to Tonga Runetotem.",
            [1489]="Speak with Arch Druid Hamuul Runetotem on Elder Rise in Thunder Bluff.",
            [1490]="Speak with Nara Wildmane in Thunder Bluff.",
            [914]="Collect the gems from Lord Cobrahn, Lady Anacondra, Lord Pythas and Lord Serpentis.",
        }
        local function questLevel(q)
            local data = ns.ForeverQuestData.quests[q.id] or {}
            local level = q.reference and q.reference.min_level or q.record.min_level or data.min_level
            return type(level) == "number" and level > 0 and ("Requires Level " .. level) or nil
        end
        local function badge(q)
            if questComplete(q) then return "Complete" end
            local state=q.id and E.QuestState(q.id)
            if state and state.inLog==true then
                if state.ready==true or state.ready==1 or state.complete==true or state.complete==1 then return "Ready" end
                return "Active"
            end
            return "Available"
        end
        local function underway(q)
            return q.id and E.QuestState(q.id).inLog == true and not questComplete(q)
        end
        local function objectiveText(step, supplemental)
            local walkthrough = step.reference and step.reference.objective
            if type(walkthrough) == "string" and walkthrough:find("%S") then return walkthrough end
            local state=step.id and E.QuestState(step.id)
            local live={}
            for _,goal in ipairs(state and state.objectives or {}) do
                if E.Public(goal.text) and type(goal.text)=="string" and goal.text:find("%S") then
                    live[#live+1]=goal.text
                end
            end
            if #live>0 then return table.concat(live,"\n") end
            for _,text in ipairs({step.record.objective or false, supplemental.objective or false,
                questObjectiveFallbacks[step.id] or false, ns.DungeonObjectiveText and ns.DungeonObjectiveText[step.id] or false}) do
                if type(text)=="string" and text:find("%S") then return text end
            end
            local goals={}
            for _,goal in ipairs(supplemental.objectives or step.record.objectives or {}) do
                if goal.kind=="item" and goal.target then
                    local name=E.Call(GetItemInfo,goal.target)
                    if not E.Public(name) or type(name)~="string" then name="item #"..goal.target end
                    goals[#goals+1]=("Collect %d × %s"):format(goal.count or 1,name)
                end
            end
            if #goals>0 then return table.concat(goals,"\n") end
            local hint=ns.DungeonQuestLocations(step,false)
            if hint and hint~=step.name and not hint:match("^%a+ #%d+$") then return "Speak with "..hint.." to turn in this step." end
        end

        local function details(chain)
            local nextStep
            for _, step in ipairs(chain) do
                if underway(step) then nextStep=step; break end
                if not nextStep and not questComplete(step) then nextStep=step end
            end
            local stepNumber = 0
            for _, step in ipairs(chain) do
                local record = step.record
                local supplemental = ns.ForeverQuestData.quests[step.id] or {}
                if #chain > 1 then
                    local summary = questLevel(step)
                    if step == nextStep then
                        local progress = underway(step) and "Current step" or "Next step"
                        summary = summary and (summary .. " · " .. progress) or progress
                    end
                    local title
                    if step.prerequisite then
                        title = "Prerequisite · " .. step.name
                    else
                        stepNumber = stepNumber + 1
                        title = stepNumber .. ". " .. step.name
                    end
                    addRow(title, nil, nil, summary, nil, nil, true, false, badge(step), true)
                end
                local top = content.rowY
                local objective=objectiveText(step,supplemental)
                if objective then blockRow("Objective", objective, nil, nil, nil, true) end
                local objectivePoint = step.reference and ns.DungeonLocation(step.reference.objectivePoint)
                if localEndpoint(objectivePoint) then
                    endpointRow("Objective Location", {name=objectivePoint.name, point=objectivePoint})
                end
                addEndpoints(step)
                if questRewards then
                    local id = step.id
                    if id then
                        openRewardQuests[id] = true
                        local request = C_QuestLog and C_QuestLog.RequestLoadQuestByID
                        if request and not rewardRequests[id] and not questRewards.IsCached(id) then
                            rewardRequests[id] = "requested"
                            E.Call(request, id)
                        end
                    end
                    local summary, fixed, choices, currencies = questRewards.ForQuest(id, record, supplemental,
                        rewardRequests[id] == "loaded")
                    local options = #choices + #currencies
                    local detail = #summary > 0 and table.concat(summary, "\n")
                        or #fixed == 0 and options == 0 and "Reward details unavailable" or nil
                    blockRow("Rewards", detail, nil, nil, nil, true)
                    local function rewardItem(item)
                        local name = item.name or ("Item " .. item.id)
                        blockRow(name, item.count and item.count > 1 and ("Quantity: " .. item.count) or nil,
                            item.id, nil, nil, nil, item.link)
                    end
                    for _, item in ipairs(fixed) do rewardItem(item) end
                    if options > 0 then
                        blockRow(options > 1 and "Choose one" or "Reward option", nil, nil, nil, nil, true)
                        for _, item in ipairs(choices) do rewardItem(item) end
                        for _, currency in ipairs(currencies) do blockRow(currency) end
                    end
                else
                    local reward = record.rewards or record.rewardSummary
                    local xp = record.xp or supplemental.xp or record.liveXPFallback
                    local items = record.rewardItems or {}
                    blockRow(record.rewardChoice and "Rewards · Choose one" or "Rewards",
                        reward or (xp and (xp .. " XP")) or (#items == 0 and "Reward information unavailable" or nil),
                        nil, nil, nil, true)
                    for _, item in ipairs(items) do
                        blockRow(item[2] or ("Item " .. item[1]), nil, item[1])
                    end
                end
                if type(record.requires) == "string" then blockRow(record.requires, "Requirement") end
                drawDetailBlock(top)
            end
        end
        local landmarkTitle, landmarkQuests
        if questLandmark then
            landmarkTitle = ns.DungeonNameKey(questLandmark.name)
            landmarkQuests = {}
            for name in (questLandmark.detail or ""):gmatch("[^,]+") do
                landmarkQuests[ns.DungeonNameKey(name:match("^%s*(.-)%s*$"))] = true
            end
            addRow(questLandmark.name, function() questLandmark = nil; draw() end, nil, "Quest Location", "All Quests")
        end
        local groups, byKey = {}, {}
        for _, q in ipairs(questRows) do
            local chain = chainFor(q)
            local terminal = chain[#chain]
            local key = terminal.id or terminal.name
            local display = terminal
            if followups[terminal.id] then
                for index = #chain, 1, -1 do
                    local id = chain[index].id
                    if id and registeredRows[id] and not followups[id] then
                        display = registeredRows[id]
                        break
                    end
                end
            end
            local group = byKey[key]
            if not group then
                group = {key=key, quest=display, chain=chain, members={}}
                byKey[key] = group
                groups[#groups+1] = group
            elseif #chain > #group.chain then group.chain = chain end
            group.members[#group.members+1] = q
        end
        table.sort(groups, function(a,b) return a.quest.name < b.quest.name end)
        local matched
        for _, group in ipairs(groups) do
            local q, chain = group.quest, group.chain
            local atLandmark = not landmarkQuests
            if landmarkQuests then
                for _, member in ipairs(group.members) do
                    local title = ns.DungeonNameKey(member.name)
                    if title == landmarkTitle or landmarkQuests[title] then atLandmark = true; break end
                end
            end
            local side = q.reference and q.reference.faction or q.record.faction or q.record.side
            local classOnly = q.reference and q.reference.classOnly
            if atLandmark
                and (not classOnly or not class or classOnly == class)
                and ((side ~= "Alliance" and side ~= "Horde") or not faction or side == faction) then
                local key = group.key
                local expanded = selectedQuest == key
                local level = questLevel(chain[1]) or questLevel(q)
                local stepCount = 0
                for _, step in ipairs(chain) do
                    if not step.prerequisite then stepCount = stepCount + 1 end
                end
                local detail = (#chain > 1 and ("Quest Chain · " .. stepCount .. (stepCount == 1 and " Step" or " Steps")) or "Dungeon Quest")
                    .. (level and ("\n" .. level) or "")
                local status = "Complete"
                for _, step in ipairs(chain) do
                    local stepStatus=badge(step)
                    if stepStatus=="Ready" then status="Ready"; break end
                    if stepStatus=="Active" or status=="Complete" then status=stepStatus end
                end
                addRow(q.name, function() selectedQuest = not expanded and key or nil; draw(true) end,
                    nil, detail, expanded and "Collapse" or "Expand", nil, nil, #chain > 1,
                    status)
                if expanded then details(chain) end
                matched = true
            end
        end
        if not matched then
            addRow(questLandmark and "No available quests linked to this pin" or "No dungeon quests recorded for this character")
        end
    end

    local function showCard(index, entry, x, y, width, height)
        local card = cards[index]
        if not card then
            card = CreateFrame("Button", nil, content)
            card.image = card:CreateTexture(nil, "ARTWORK")
            card.image:SetPoint("TOPLEFT", 4, -4)
            card.base=paper(card)
            card.base:SetAllPoints()
            card.base:SetVertexColor(.89,.75,.53)
            N.BronzeRectangle(card)
            local hover=paper(card,"OVERLAY",-2)
            hover:SetAllPoints();hover:SetVertexColor(1,.87,.63,.25)
            card:SetHighlightTexture(hover)
            local band = wood(card, "OVERLAY", -1)
            card.band = band
            band:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT",4,4)
            band:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT",-4,4)
            card.image:SetPoint("BOTTOMRIGHT",band,"TOPRIGHT")
            local bandEdge = card:CreateTexture(nil, "OVERLAY")
            bandEdge:SetPoint("TOPLEFT", band, "TOPLEFT")
            bandEdge:SetPoint("TOPRIGHT", band, "TOPRIGHT")
            bandEdge:SetHeight(N.PixelSize(card, 1))
            N.BronzeRail(bandEdge, "TOP")
            bandEdge:SetAlpha(.60)
            card.name = N.MakeText(card, 15, "", true)
            card.name:SetPoint("LEFT", card.band, "LEFT", 5, 0)
            if card.name.SetMaxLines then card.name:SetMaxLines(2) end
            card.level = N.MakeText(card, 11, "", true)
            card.level:SetPoint("RIGHT",card.band,"RIGHT",-5,0)
            card.level:SetWordWrap(false)
            card.complete = card:CreateTexture(nil, "OVERLAY", nil, 5)
            card.complete:SetTexture("Interface\\AddOns\\GrindingForever\\Media\\DungeonQuestCompleteStamp")
            card.complete:SetSize(54,27)
            card.complete:SetPoint("BOTTOMRIGHT",card.band,"TOPRIGHT",-3,-3)
            cards[index] = card
        end
        local id = loadingScreen(entry.name)
        card.image:SetTexture(id)
        card.image:SetTexCoord(.025,.975,id and id >= 7000000 and .26 or .34,.76)
        card.image:SetShown(id ~= nil)
        card:SetSize(width,height)
        card:ClearAllPoints();card:SetPoint("TOPLEFT",content,"TOPLEFT",x,-y)
        local pixel = N.PixelSize(card, 1)
        sizeText(card.name, card, 14, 15, 14.5)
        sizeText(card.level, card, 12, 13, 12)
        warmLight(card.name, pixel)
        warmLight(card.level, pixel)
        card.level:SetTextColor(.97, .80, .53)
        local quests = dungeonQuests(entry.instance)
        local complete = #quests > 0
        for _, quest in ipairs(quests) do
            if not questComplete(quest) then complete = false; break end
        end
        card.complete:SetShown(complete)
        local levels = entry.minimum and entry.maximum and string.format("%d–%d",entry.minimum,entry.maximum)
        card.level:SetText(entry.archivedMap and "Reference" or levels or (entry.raid and "Raid" or ""))
        card.name:SetWidth(math.max(38, width - card.level:GetStringWidth() - 24 * pixel))
        card.name:SetText(entry.name)
        card.band:SetHeight(math.max(24 * pixel, math.min(44 * pixel, card.name:GetStringHeight() + 8 * pixel)))
        card:SetScript("OnClick",function()
            local maps = entry.instance.gfMaps
            selected, floor, tab = entry.instance, maps and maps.startFloor or 1, "bosses"
            selectedBoss, selectedQuest, questLandmark = nil, nil, nil
            draw()
        end)
        card:Show()
    end

    local function drawContents(keepScroll)
        openRewardQuests = {}
        local previousScroll = keepScroll == true and list:GetVerticalScroll() or 0
        local width = window:GetWidth()
        local leftWidth = math.max(250,math.floor(width * .36))
        for _, row in ipairs(rows) do row:Hide() end
        for _, block in ipairs(detailBlocks) do block:Hide() end
        for _, card in ipairs(cards) do card:Hide() end
        for _, pin in ipairs(pins) do pin:Hide() end
        content.visibleRows, content.visibleDetailBlocks = 0, 0
        content.rowY=0
        list:SetVerticalScroll(0)
        back:SetShown(selected ~= nil)
        bossTab:SetShown(selected ~= nil)
        questTab:SetShown(selected ~= nil)
        local loc = selected and not archivedRaidMaps[ns.DungeonNameKey(selected.name)]
            and ns.DungeonEntrance(selected)
        entrance:SetShown(loc ~= nil)
        clearQuest:SetShown(ns.NavigationCompass and ns.NavigationCompass.questPin ~= nil)
        local floors = selected and selected.gfMaps
        local wing = selected and wingFloors[ns.DungeonNameKey(selected.name)]
        local parentFloors = wing and recordFor(ns.BundledDungeonMaps,wing[1])
        if parentFloors then
            floors = {}
            for index = 2,#wing do floors[#floors+1] = parentFloors[wing[index]] end
        end
        local image = floors and floors[floor]
        floorButton.floorCount = floors and #floors or 0
        floorButton:SetShown(floors and #floors > 1 or false)
        floorButton.floorLabel = image and image.label
        local previousMapAspect=currentMapAspect
        currentMapAspect = image and image.aspect
        if (image ~= nil) ~= detailActive or (image and previousMapAspect ~= image.aspect) then
            detailActive = image ~= nil
            local unit,p,minW,minH,maxW,maxH=N.ApplySizeProfile(window,detailActive and "detail" or "")
            local width=math.max(minW,math.min(p[3],maxW))
            local leftWidth=math.max(250,math.floor(width*unit*.36))
            local height=detailActive and math.floor(((width*unit-leftWidth-48)/image.aspect+126+headerExtra)/unit+.5) or p[4]
            window:SetSize(width*unit,math.max(minH,math.min(height,maxH))*unit)
        end
        mapPane:SetShown(image ~= nil)
        map:SetShown(image ~= nil)
        list:ClearAllPoints()
        width=window:GetWidth()
        -- Match Steps at compact widths, then blend into the existing roomy type.
        local widthPixels = width / N.PixelSize(window, 1)
        local compactWidth = detailActive and 820 or 730
        textScale = math.max(0, math.min(1, (widthPixels - compactWidth) / 180))
        sizeText(status, window, 13, 14, 12)
        for _, control in ipairs({back, entrance, clearQuest, floorButton, bossTab, questTab}) do
            sizeText(control.label, control, 14, 0, 13)
        end
        layoutFloorButton()
        leftWidth=math.max(250,math.floor(width*.36))
        local rightInset = image and (width - leftWidth) or 34
        list:SetPoint("TOPLEFT", 18, (selected and -119 or -47) - headerExtra)
        list:SetPoint("BOTTOMRIGHT", -rightInset, 42)
        content:SetWidth(width - rightInset - 18)
        local cardHeight
        if selected then
            bossTab:ClearAllPoints()
            bossTab:SetPoint("TOPLEFT", 18, -85 - headerExtra)
            questTab:ClearAllPoints()
            questTab:SetPoint("LEFT", bossTab, "RIGHT", 8, 0)
            bossTab:SetSelected(tab == "bosses")
            questTab:SetSelected(tab == "quests")
            local questRows = dungeonQuests(selected)
            local allowedNames = {}
            for _, quest in ipairs(questRows) do
                allowedNames[ns.DungeonNameKey(quest.name)] = quest.name
            end
            local bosses, fallback = {}, recordFor(ns.DungeonLoot, selected.name)
            for _, boss in ipairs(selected.bosses or {}) do
                bosses[ns.DungeonNameKey(boss.name)] = {
                    name = boss.name, loot = boss.loot, npcID = boss.npcID,
                    customIcon = boss.customIcon, displayID = boss.displayID, portraitNpcID = boss.portraitNpcID,
                }
            end
            for _, reference in ipairs(ns.DungeonReferencesFor(selected.name)) do
                for _, boss in ipairs(reference.encounters) do
                    local key = ns.DungeonNameKey(boss.name)
                    local entry = bosses[key] or {name = boss.name}
                    entry.npcID = entry.npcID or boss.npcID
                    entry.portraitNpcID = entry.portraitNpcID or boss.portraitNpcID
                    entry.displayID = entry.displayID or boss.displayID
                    entry.customIcon = entry.customIcon or boss.customIcon
                    entry.referenceLoot = entry.referenceLoot or {}
                    for _, item in ipairs(boss.loot) do table.insert(entry.referenceLoot, item) end
                    bosses[key] = entry
                end
            end
            local floorByMapID, curated = {}, false
            for index, mapFloor in ipairs(floors or {}) do
                curated = curated or mapFloor.curatedPins == true
                local mapID = not mapFloor.curatedPins and tonumber(mapFloor.file:match("^(%d+)%.blp$"))
                if mapID then floorByMapID[mapID] = index end
                for _, point in ipairs(ns.DungeonReferencePins[mapFloor.pinKey or mapFloor.file] or {}) do
                    if point[4] == "boss" then
                        local key = ns.DungeonNameKey(point[1])
                        local boss = bosses[key] or {name = point[1]}
                        boss.floor = boss.floor or index
                        boss.marker = point.marker or boss.marker
                        boss.npcID = boss.npcID or point.npcID
                        boss.displayID = boss.displayID or point.displayID
                        bosses[key] = boss
                    end
                end
            end
            for name in pairs(fallback or {}) do
                local key = ns.DungeonNameKey(name)
                bosses[key] = bosses[key] or {name = name}
            end
            for _, landmark in ipairs(not curated and recordFor(ns.DungeonLandmarks, selected.name) or {}) do
                if not landmark[4] or landmark[4] == "boss" then
                    local key = ns.DungeonNameKey(landmark[1])
                    bosses[key] = bosses[key] or {name = landmark[1]}
                    bosses[key].floor = bosses[key].floor or landmark[6] or 1
                end
            end
            local journal = selected.journalMap or (selected.sourceData and selected.map)
            for _, position in ipairs(journal and journal.bosses or {}) do
                local sourceFloor = journal.floors and journal.floors[position.floor or 1]
                local index = sourceFloor and floorByMapID[sourceFloor.uiMapID]
                if index and type(position.name) == "string" then
                    local key = ns.DungeonNameKey(position.name)
                    local boss = bosses[key] or {name = position.name}
                    boss.floor = boss.floor or index
                    bosses[key] = boss
                end
            end
            if selected.otherLoot then bosses["trash/object"] = {name = "Trash/Object", loot = selected.otherLoot} end
            local pinCount = image and drawMap(image, bosses, allowedNames)
            status:SetText(not image and "Map artwork unavailable for this instance"
                or archivedRaidMaps[ns.DungeonNameKey(selected.name)] and "Reference map · Live raid access unconfirmed"
                or pinCount == 0 and "No landmarks recorded for this floor" or "")
            if tab == "bosses" then showBosses(bosses, questRows, fallback) else showQuests(questRows) end
        else
            local entries = {}
            local catalog = {}
            local function addInstance(name, instance)
                local key = ns.DungeonNameKey(name)
                if wingFamilies[key] or hiddenCards[key] or (raidNames[key] and not visibleRaids[key])
                    or not ns.IsForeverDungeon(name) then return end
                local title = visibleRaids[key] or landingAliases[key] or name
                local current = catalog[title]
                if not current or (instance.sourceData and not current.sourceData) then
                    catalog[title] = instance
                end
            end
            for name, instance in pairs(E.dungeons) do addInstance(name, instance) end
            for name, reference in pairs(ns.DungeonReference or {}) do
                local family = ns.DungeonNameKey(name):match("^([^:]+):")
                local title = family and wingFamilies[family] and name or reference.art or name
                addInstance(title, {name = title, gfMaps = recordFor(ns.BundledDungeonMaps, title)})
            end
            for _, title in pairs(visibleRaids) do
                if not catalog[title] then
                    addInstance(title, {name = title, gfMaps = recordFor(ns.BundledDungeonMaps, title)})
                end
            end
            for name, instance in pairs(catalog) do
                if instance.name ~= name then
                    local canonical = {}
                    for field, value in pairs(instance) do canonical[field] = value end
                    canonical.name = name
                    canonical.gfMaps = recordFor(ns.BundledDungeonMaps, name) or instance.gfMaps
                    instance = canonical
                end
                local key = ns.DungeonNameKey(name)
                local range = levelRanges[key] or {}
                entries[#entries + 1] = {name = name, instance = instance, raid = raidNames[key] == true,
                    archivedMap = archivedRaidMaps[key],
                    minimum = instance.minimum or range[1], maximum = instance.maximum or range[2]}
            end
            table.sort(entries, function(a, b)
                if a.raid ~= b.raid then return not a.raid end
                local minA, minB = a.minimum or math.huge, b.minimum or math.huge
                if not a.raid and minA ~= minB then return minA < minB end
                return a.name < b.name
            end)
            local raid, x, y = false, 0, 0
            local gap = 10
            local columns=math.max(2,math.min(5,math.floor((content:GetWidth()+gap)/178)))
            local cardWidth=(content:GetWidth()-gap*(columns-1))/columns
            local cardSize=math.max(85,math.min(112,cardWidth*.57))
            local stride=cardSize+8
            for index, entry in ipairs(entries) do
                if entry.raid and not raid then
                    if x ~= 0 then x = 0;y = y + stride end
                    raid = true
                    local heading = addRow("Raids", nil, nil, nil, nil, nil, true)
                    heading:ClearAllPoints();heading:SetPoint("TOPLEFT",content,"TOPLEFT",0,-y)
                    heading:SetPoint("TOPRIGHT",content,"TOPRIGHT",0,-y)
                    y = y + heading:GetHeight()
                end
                showCard(index,entry,x*(cardWidth+gap),y,cardWidth,cardSize)
                x=x+1
                if x==columns then x=0;y=y+stride end
            end
            cardHeight = y + (x ~= 0 and stride or 0)
            status:SetText(#entries == 0 and "No instances available" or "")
        end
        content:SetHeight(math.max(1, cardHeight or content.rowY))
        list:UpdateScrollChildRect()
        if previousScroll > 0 then list:SetVerticalScroll(math.min(previousScroll, math.max(0, content:GetHeight() - list:GetHeight()))) end
        syncScroll()
    end

    local drawing, redrawPending
    draw = function(keepScroll)
        -- Cached quest data and size changes can notify us before the current draw finishes.
        if drawing then redrawPending = true; return end
        drawing = true
        repeat
            redrawPending = false
            local ok, detail = pcall(drawContents, keepScroll)
            if not ok then
                drawing, redrawPending = false, false
                error(detail, 0)
            end
            keepScroll = true
        until not redrawPending
        drawing = false
    end
    local targetWatcher = CreateFrame("Frame")
    targetWatcher:RegisterEvent("PLAYER_TARGET_CHANGED")
    targetWatcher:SetScript("OnEvent", function()
        if window:IsShown() and selectedBoss and tab == "bosses" then draw(true) end
    end)
    window:SetScript("OnShow", draw)
    draw()
end
