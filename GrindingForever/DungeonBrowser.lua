local _, ns = ...
local E, N = ns.Forever, ns.NormalUI
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

local visibleRaids = {
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
    gnomeregan = {"Grubbis", "Viscous Fallout", "Electrocutioner 6000", "Crowd Pummeler 9-60",
        "Dark Iron Ambassador", "Mekgineer Thermaplugg"},
    ["ragefire chasm"] = {"Oggleflint", "Taragaman the Hungerer", "Jergosh the Invoker", "Bazzalan"},
}

local bundledBossIcons = {
    ["magmatus"] = "Interface\\Icons\\Spell_Fire_Elemental_Totem",
}

local function paintBossToken(frame, boss, anchor, offset, size)
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
        edge:SetColorTexture(.78, .58, .31, 1)
        local interior = token:CreateTexture(nil, "BORDER")
        interior:SetPoint("TOPLEFT", 2, -2)
        interior:SetPoint("BOTTOMRIGHT", -2, 2)
        interior:SetColorTexture(.075, .057, .035, 1)
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
    local journal = E.journal
    local static = journal and journal.STATIC_DISPLAY_IDS
    local npcID = boss.npcID or boss.portraitNpcID
    local display = boss.displayID or (npcID and (bossDisplay[npcID] or static and static[npcID]))
    local key = ns.DungeonNameKey(boss.name)
    local category = lootCategoryIcons[key]
    local icon = category and ("Interface\\AddOns\\GrindingForever\\Media\\" .. category)
        or boss.customIcon or bundledBossIcons[key]
    token.fallback:SetShown(not icon)
    local portrait = token.portrait
    portrait:SetTexture(nil)
    portrait:SetTexCoord(0, 1, 0, 1)
    if icon then
        portrait:SetTexture(icon)
    elseif display and type(SetPortraitTextureFromCreatureDisplayID) == "function" then
        local ok, result = pcall(SetPortraitTextureFromCreatureDisplayID, portrait, display)
        if not ok or result == false then portrait:SetTexture(nil) end
    end
    token:Show()
end

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
    local title, header
    local media = "Interface\\AddOns\\GrindingForever\\Media\\"
    local function ink(label)
        label:SetTextColor(44/255,34/255,30/255)
        if label.SetShadowColor then
            label:SetShadowColor(.92,.76,.49,.35)
            label:SetShadowOffset(1,-1)
        end
    end
    local function paper(parent, layer, sublevel, fullSheet)
        local texture=parent:CreateTexture(nil,layer or "BACKGROUND",nil,sublevel or 0)
        texture:SetTexture(media.."BaseParchment")
        if fullSheet then texture:SetTexCoord(0,1254/2048,0,1254/2048)
        else texture:SetTexCoord(.13,.49,.13,.49) end
        return texture
    end
    local base=paper(window,"BACKGROUND",4,true)
    base:SetTexCoord(.018,.595,.018,.595)
    base:SetPoint("TOPLEFT",1,-39)
    base:SetPoint("BOTTOMRIGHT",-1,1)
    local status = N.MakeText(window, 12)
    status:SetTextColor(.26, .14, .07)
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
    local rows, cards, pendingItems = {}, {}, {}
    local rowHeight = 38
    local selected, floor, tab = nil, 1, "bosses"
    local selectedBoss, selectedQuest, questLandmark
    local draw
    title, header = N.PanelChrome(window, "", 600, 490, function() draw(true) end)
    title:SetJustifyH("CENTER")
    title:SetTextColor(.93,.73,.37)
    title:ClearAllPoints()
    title:SetPoint("LEFT",header,"LEFT",92,0)
    title:SetPoint("RIGHT",header,"RIGHT",-92,0)
    local emblem = header:CreateTexture(nil,"OVERLAY")
    emblem:SetTexture("Interface\\AddOns\\GrindingForever\\Media\\ControlForeverEmblem")
    emblem:SetSize(32,32)
    emblem:SetPoint("CENTER",header,"CENTER")
    local dungeonTitle = N.MakeText(header,20,"Dungeons")
    dungeonTitle:SetTextColor(.93,.73,.37)
    dungeonTitle:SetPoint("RIGHT",emblem,"LEFT",-8,0)
    local raidTitle = N.MakeText(header,20,"Raids")
    raidTitle:SetTextColor(.93,.73,.37)
    raidTitle:SetPoint("LEFT",emblem,"RIGHT",8,0)

    local function button(parent, label, width, action)
        local b = N.MakeButton(parent, label, width, action)
        b:SetSize(width, 28)
        return b
    end

    local back = button(window, "Instances", 128, function() selected = nil; draw() end)
    N.ButtonArrow(back,"left","LEFT")
    back:SetPoint("TOPLEFT", 18, -45)
    local floorButton
    floorButton = button(window, "", 120, function()
        if floorButton.floorCount < 2 then return end
        floor = floor % floorButton.floorCount + 1
        draw()
    end)
    floorButton:SetPoint("TOPRIGHT", -18, -45)

    local entrance = button(window, "Pin Entrance", 142, function()
        status:SetText(setWaypoint(ns.DungeonEntrance(selected)))
    end)
    entrance:SetPoint("LEFT", back, "RIGHT", 8, 0)
    local clearQuest = button(window, "Clear Quest Pin", 134, function()
        if ns.NavigationCompass.ClearQuestPin() then
            draw()
            status:SetText("Quest pin cleared")
        end
    end)
    clearQuest:SetPoint("LEFT", entrance, "RIGHT", 8, 0)

    local function makeTab(label, key, width)
        local control = CreateFrame("Button", nil, window)
        control:SetSize(width, 29)
        local fill=paper(control)
        fill:SetAllPoints()
        fill:SetVertexColor(.86,.71,.49)
        control.paper=fill
        local hover=paper(control,"BACKGROUND",1)
        hover:SetAllPoints();hover:SetVertexColor(.99,.89,.65)
        control:SetHighlightTexture(hover)
        N.BronzeRectangle(control)
        control.label = N.MakeText(control, 15, label, true)
        ink(control.label)
        control.label:SetPoint("LEFT", 8, 0)
        control.line = control:CreateTexture(nil, "ARTWORK")
        control.line:SetColorTexture(.77, .54, .27, 1)
        control.line:SetPoint("BOTTOMLEFT", 8, 0)
        control.line:SetPoint("BOTTOMRIGHT", -8, 0)
        control.line:SetHeight(2)
        control:SetScript("OnClick", function()
            if tab ~= key then tab = key; draw() end
        end)
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

    window:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    for _, event in ipairs({"QUEST_ACCEPTED", "QUEST_REMOVED", "QUEST_TURNED_IN"}) do
        E.Call(window.RegisterEvent, window, event)
    end
    window:SetScript("OnEvent", function(self, event, itemID)
        if event ~= "GET_ITEM_INFO_RECEIVED" then
            if self:IsShown() and selected and tab == "quests" then draw(true) end
            return
        end
        if not E.Public(itemID) or type(itemID) ~= "number" or not pendingItems[itemID] then return end
        pendingItems[itemID] = false
        if not self:IsShown() then return end
        for index = 1, content.visibleRows do
            local row = rows[index]
            if row.itemID == itemID then paintItem(row) end
        end
    end)

    local function addRow(label, action, itemID, detail, actionLabel, boss, heading, completed, underway, framed)
        local index = content.visibleRows + 1
        content.visibleRows = index
        local row = rows[index]
        if not row then
            row = CreateFrame("Button", nil, content)
            row:SetPoint("TOPLEFT", 0, -(index - 1) * rowHeight)
            row:SetPoint("TOPRIGHT", 0, -(index - 1) * rowHeight)
            row:SetHeight(rowHeight)
            row.selectorTrim=N.BronzeRectangle(row)
            local separator = row:CreateTexture(nil, "BACKGROUND")
            separator:SetPoint("BOTTOMLEFT", 6, 0)
            separator:SetPoint("BOTTOMRIGHT", -6, 0)
            separator:SetHeight(1)
            separator:SetColorTexture(.68, .48, .26, .20)
            local fill=paper(row,"BACKGROUND",-2)
            fill:SetAllPoints();fill:SetVertexColor(.96,.87,.70,.18)
            local highlight=paper(row,"BACKGROUND",1)
            highlight:SetAllPoints()
            highlight:SetVertexColor(.95,.78,.51,.78)
            row:SetHighlightTexture(highlight)
            row.icon = row:CreateTexture(nil, "ARTWORK")
            row.icon:SetSize(23, 23)
            row.icon:SetPoint("LEFT", 7, 0)
            row.label = N.MakeText(row, 14)
            row.label:SetWordWrap(true)
            row.detail = N.MakeText(row, 11)
            row.detail:SetWordWrap(true)
            row.detail:SetTextColor(.28, .16, .065)
            row.command = N.MakeText(row, 12)
            row.command:SetJustifyH("RIGHT")
            row.command:SetWordWrap(false)
            row.command:SetTextColor(.34,.20,.085)
            row.command:SetPoint("RIGHT", -8, 0)
            row.disclosure=N.ControlArrow(row,"right","RIGHT")
            row.disclosure:SetVertexColor(.49,.31,.12)
            row.stamp = row:CreateTexture(nil, "OVERLAY", nil, 5)
            row.stamp:SetTexture("Interface\\AddOns\\GrindingForever\\Media\\DungeonQuestCompleteStamp")
            row.stamp:SetSize(86,43)
            row.underway=row:CreateTexture(nil,"OVERLAY",nil,5)
            row.underway:SetSize(26,26)
            row.underway:SetPoint("RIGHT",-28,0)
            row:SetScript("OnEnter", function(self)
                if not self.itemID or not GameTooltip then return end
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                if GameTooltip.SetItemByID then
                    GameTooltip:SetItemByID(self.itemID)
                else
                    GameTooltip:SetHyperlink("item:" .. self.itemID)
                end
                GameTooltip:Show()
            end)
            local function hideTooltip(self)
                if self.itemID and GameTooltip and GameTooltip:IsOwned(self) then GameTooltip:Hide() end
            end
            row:SetScript("OnLeave", hideTooltip)
            row:SetScript("OnHide", hideTooltip)
            rows[index] = row
        end
        row.itemID, row.itemName = itemID, label
        row.icon:SetShown(itemID ~= nil)
        paintBossToken(row, boss, "LEFT", 7, 26)
        row.label:ClearAllPoints()
        row.detail:ClearAllPoints()
        local left = (itemID or boss) and 40 or 8
        local disclosure = actionLabel=="Expand" or actionLabel=="Collapse"
        local showUnderway = type(underway) == "string"
        local right = showUnderway and (completed and -88 or -58) or disclosure and -28 or actionLabel and -math.max(55, #actionLabel * 7 + 13) or -8
        local y = detail and -4 or -11
        row.label:SetPoint("TOPLEFT", left, y)
        local textWidth=math.max(45, content:GetWidth()-left+right)
        row.label:SetWidth(textWidth)
        row.detail:SetWidth(textWidth)
        row.detail:SetText(detail or "")
        row.command:SetText(not disclosure and actionLabel or "")
        row.disclosure:SetShown(disclosure)
        if disclosure then row.disclosure:SetRotation(actionLabel=="Collapse" and -math.pi/2 or 0) end
        row.stamp:SetShown(showUnderway and completed == true)
        if showUnderway then
            row.underway:SetTexture(media.."JournalQuest"..underway)
            row.stamp:SetTexture(media.."JournalQuestChain")
            row.stamp:SetSize(27,27)
        end
        row.underway:SetShown(showUnderway)
        row.disclosure:ClearAllPoints()
        row.disclosure:SetPoint((showUnderway or completed) and "TOPRIGHT" or "RIGHT", row, (showUnderway or completed) and "TOPRIGHT" or "RIGHT", -10, (showUnderway or completed) and -7 or 0)
        if heading then row.label:SetTextColor(.37, .19, .06)
        else row.label:SetTextColor(.16, .09, .03) end
        if itemID then paintItem(row) else row.label:SetText(label) end
        local selector=framed or itemID~=nil or (action~=nil and not heading)
        row.selectorTrim:SetShown(selector)
        local labelHeight=math.max(18,row.label:GetStringHeight())
        local detailHeight=detail and math.max(14,row.detail:GetStringHeight()) or 0
        local height=math.max((showUnderway or completed) and 48 or rowHeight,selector and 36 or 0,labelHeight+detailHeight+13)
        row.label:ClearAllPoints()
        row.label:SetPoint("TOPLEFT",left,detail and -4 or -(height-labelHeight)/2)
        row.detail:SetPoint("TOPLEFT",left,-labelHeight-5)
        row.stamp:ClearAllPoints()
        row.stamp:SetPoint("RIGHT",row,"RIGHT",-57,0)
        row:ClearAllPoints()
        row:SetPoint("TOPLEFT",content,"TOPLEFT",0,-content.rowY)
        row:SetPoint("TOPRIGHT",content,"TOPRIGHT",0,-content.rowY)
        row:SetHeight(height)
        content.rowY=content.rowY+height+(selector and 5 or 0)
        row:SetScript("OnClick", action)
        row:EnableMouse(action ~= nil or itemID ~= nil)
        row:Show()
        return row
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
        local focused = selectedBoss and position.kind=="boss" and ns.DungeonNameKey(position.name)==ns.DungeonNameKey(selectedBoss)
        pin:SetScale(focused and 1.22 or 1)
        pin.icon:SetShown(not position.boss)
        if not position.boss then
            pin.icon:SetTexture(position.kind == "quest" and "Interface\\GossipFrame\\AvailableQuestIcon"
                or "Interface\\MINIMAP\\TRACKING\\Dungeon")
        end
        paintBossToken(pin, position.boss, "CENTER", 0, 23)
        pin:ClearAllPoints()
        pin:SetPoint("CENTER", map, "TOPLEFT", position.x * map:GetWidth(), -position.y * map:GetHeight())
        pin:Show()
    end

    local currentMapAspect
    local function fitMap()
        if not currentMapAspect or not map:IsShown() then return end
        local width = window:GetWidth()
        local leftWidth = math.max(250, math.floor(width * .36))
        mapPane:ClearAllPoints()
        mapPane:SetPoint("TOPLEFT", window, "TOPLEFT", leftWidth + 22, -76)
        mapPane:SetPoint("BOTTOMRIGHT", window, "BOTTOMRIGHT", -18, 42)
        local height = math.max(1, math.min(window:GetHeight() - 126, (width - leftWidth - 48) / currentMapAspect))
        local mapWidth = height * currentMapAspect
        map:SetSize(mapWidth, height)
        for _, pin in ipairs(pins) do
            if pin:IsShown() and pin.landmark then
                pin:ClearAllPoints()
                pin:SetPoint("CENTER", map, "TOPLEFT", pin.landmark.x * mapWidth, -pin.landmark.y * height)
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
        local count, seen = 0, {}
        local function landmark(name, x, y, kind, detail)
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
            addPin({name = name, x = x, y = y, kind = kind, detail = detail, boss = boss}, count)
        end
        for _, point in ipairs(ns.DungeonReferencePins[image.file] or {}) do
            if point[4] ~= "floor" then landmark(point[1], point[2], point[3], point[4], point[5]) end
        end
        local mapID = tonumber(image.file:match("^(%d+)%.blp$"))
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
            local facts = boss.npcID and ns.DungeonEncounterFacts and ns.DungeonEncounterFacts[boss.npcID]
            addRow("Mechanics", nil, nil, nil, nil, nil, true)
            if facts and type(facts.mechanics) == "table" and #facts.mechanics > 0 then
                for _, mechanic in ipairs(facts.mechanics) do
                    addRow(mechanic.name, nil, nil, mechanic.description)
                end
            else
                addRow("No verified Forever mechanics recorded.")
            end
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
            addRow(name, nil, id, detail)
        end
        for _, loot in ipairs(boss.referenceLoot or {}) do
            if loot[1] > 0 then
                add(loot[1], loot[2], loot[3])
            elseif loot[2] then
                hasLoot = true
                addRow(loot[2], nil, nil, nil, nil, nil, nil, nil, nil, true)
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
        local function addEndpoint(q, start)
            local label = start and "Start" or "Turn In"
            local hint, points = ns.DungeonQuestLocations(q, start)
            local reference = q.reference
            local primary = reference and ns.DungeonLocation(start and reference.startPoint or not start and reference.endPoint, hint or q.name)
            local known = primary and primary.name
            if not known or known == q.name or known:match("^%a+ #%d+$") then known = hint or known end
            local groups, byName = {}, {}
            local function collect(point, preferred)
                if not localEndpoint(point) then return end
                local name = point.name or known or q.name
                if name == q.name or name:match("^%a+ #%d+$") then name = known or name end
                local key = ns.DungeonNameKey(name)
                local group = byName[key]
                if not group then
                    group = {name = name, point = point, preferred = preferred}
                    byName[key], groups[#groups + 1] = group, group
                elseif not group.preferred then
                    local first = group.point
                    if first.mapID ~= point.mapID or math.abs(first.x - point.x) >= 1
                        or math.abs(first.y - point.y) >= 1 then group.conflict = true end
                end
            end
            collect(primary, true)
            for _, point in ipairs(points) do collect(point) end
            for _, group in ipairs(groups) do
                local point = group.point
                local title = label .. "  /  " .. group.name
                if group.conflict then
                    addRow(title, nil, nil, "Conflicting Coordinates")
                else
                    local location = string.format("%s (%.1f, %.1f)", point.zone or "Zone Map", point.x, point.y)
                    addRow(title, function() local result=questWaypoint(point); draw(true); status:SetText(result) end, nil, location, questPinLabel(point))
                end
            end
            if #groups == 0 then addRow(label .. "  /  " .. (hint or "Location Unavailable")) end
        end
        local data = ns.ForeverQuestData.quests
        local known, previous, nextSteps = {}, {}, {}
        local function link(before, after)
            if not before or not after or before == after then return end
            previous[after] = previous[after] or {}
            nextSteps[before] = nextSteps[before] or {}
            for _, id in ipairs(previous[after]) do if id == before then return end end
            table.insert(previous[after], before)
            table.insert(nextSteps[before], after)
        end
        for _, row in ipairs(questRows) do
            if row.id then known[row.id] = row end
            local last
            for _, step in ipairs(row.reference and row.reference.chain or {}) do
                local id = step[1]
                if id ~= row.id then
                    local loc = step[3]
                    local record = data[id] or {}
                    known[id] = known[id] or {id = id, name = record.title or step[2] or ("Quest " .. id), record = record}
                    if loc and not known[id].reference then known[id].reference = {startPoint = loc} end
                    link(last,id)
                    last = id
                end
            end
            link(last,row.id)
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
        local function chainFor(q)
            if not q.id then return {q} end
            local chain, visited = {}, {}
            local function visit(id)
                if not id or visited[id] then return end
                visited[id] = true
                local record = data[id] or {}
                local step = known[id] or {id = id, name = record.title, record = record}
                local policy = ns.ForeverQuestPlanner
                if not step.name or (policy and not policy.AllowsQuest(id,faction,step.reference or step.record)) then return end
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
            while tail and nextSteps[tail] and #nextSteps[tail] == 1 and not visited[nextSteps[tail][1]] do
                tail = nextSteps[tail][1]
                visit(tail)
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
        local function details(chain)
            local nextStep
            for _, step in ipairs(chain) do
                if underway(step) then nextStep=step; break end
                if not nextStep and not questComplete(step) then nextStep=step end
            end
            for index, step in ipairs(chain) do
                local record = step.record
                local supplemental = ns.ForeverQuestData.quests[step.id] or {}
                local title = #chain > 1 and (index .. ". " .. step.name) or step.name
                addRow(title, nil, nil, questLevel(step), nil, nil, true, false,
                    badge(step), true)
                if #chain>1 and step==nextStep then
                    addRow(underway(step) and "Current step" or "Next step", nil, nil, nil, nil, nil, true)
                end
                addRow("Objective", nil, nil,
                    record.objective or supplemental.objective or questObjectiveFallbacks[step.id] or "Objective unavailable", nil, nil, true)
                addEndpoint(step,true)
                addEndpoint(step,false)
                local reward = record.rewards or record.rewardSummary
                local xp = record.xp or supplemental.xp or record.liveXPFallback
                local items = record.rewardItems or {}
                addRow(record.rewardChoice and "Rewards · Choose one" or "Rewards", nil, nil,
                    reward or (xp and (xp .. " XP")) or (#items == 0 and "Reward information unavailable" or nil))
                for _, item in ipairs(items) do
                    addRow(item[2] or ("Item " .. item[1]), nil, item[1])
                end
                if type(record.requires) == "string" then addRow(record.requires,nil,nil,"Requirement") end
                local item = step.reference and step.reference.startItem or record.startItem
                if item then addRow(item[2],nil,item[1],type(item[4]) == "string" and item[4] or "Starts Quest") end
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
            local group = byKey[key]
            if not group then
                group = {quest=terminal, chain=chain, members={}}
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
                local key = q.id or q.name
                local expanded = selectedQuest == key
                local level = questLevel(chain[1]) or questLevel(q)
                local detail = (#chain > 1 and ("Quest Chain · " .. #chain .. " Steps") or "Dungeon Quest")
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
            card.image:SetPoint("TOPLEFT", 1, -1);card.image:SetPoint("BOTTOMRIGHT", -1, 1)
            card.base=paper(card)
            card.base:SetAllPoints()
            card.base:SetVertexColor(.89,.75,.53)
            N.BronzeRectangle(card)
            local hover=paper(card,"OVERLAY",-2)
            hover:SetAllPoints();hover:SetVertexColor(1,.87,.63,.25)
            card:SetHighlightTexture(hover)
            local band=card:CreateTexture(nil,"OVERLAY",nil,-1)
            card.band = band
            band:SetPoint("BOTTOMLEFT", card, "BOTTOMLEFT",1,1)
            band:SetPoint("BOTTOMRIGHT", card, "BOTTOMRIGHT",-1,1)
            band:SetColorTexture(0,0,0,.5)
            card.name = N.MakeText(card, 15, "", true)
            card.name:SetTextColor(.98,.77,.48)
            card.name:SetPoint("BOTTOMLEFT", card.band, "LEFT", 5, 0)

            card.name:SetWordWrap(false)
            card.level = N.MakeText(card, 11, "", true)
            card.level:SetPoint("RIGHT",card.band,"RIGHT",-5,0)
            card.level:SetTextColor(.95,.72,.43)
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
        local family = ns.DungeonNameKey(entry.name):match("^([^:]+):")
        local wing = family and wingFamilies[family]
        local font, _, flags = card.name:GetFont()
        card.name:SetFont(font, 13, flags)
        card.name:SetWordWrap(false)
        local quests = dungeonQuests(entry.instance)
        local complete = #quests > 0
        for _, quest in ipairs(quests) do
            if not questComplete(quest) then complete = false; break end
        end
        card.complete:SetShown(complete)
        card.name:SetText(entry.name)
        card.band:SetHeight(height*.175)
        local levels = entry.minimum and entry.maximum and string.format("%d–%d",entry.minimum,entry.maximum)
        card.level:SetText(levels or (entry.raid and "Raid" or ""))
        card.name:SetWidth(0)
        local available=math.max(20,width-card.level:GetStringWidth()-18)
        for size=13,8,-1 do
            card.name:SetFont(font,size,flags)
            if card.name:GetStringWidth()<=available then break end
        end
        card.name:SetWidth(available)
        card:SetScript("OnClick",function()
            selected, floor, tab = entry.instance, 1, "bosses"
            selectedBoss, selectedQuest, questLandmark = nil, nil, nil
            draw()
        end)
        card:Show()
    end

    draw = function(keepScroll)
        local previousScroll = keepScroll == true and list:GetVerticalScroll() or 0
        local width = window:GetWidth()
        title:SetShown(selected ~= nil)
        emblem:SetShown(not selected)
        dungeonTitle:SetShown(not selected)
        raidTitle:SetShown(not selected)
        local leftWidth = math.max(250,math.floor(width * .36))
        for _, row in ipairs(rows) do row:Hide() end
        for _, card in ipairs(cards) do card:Hide() end
        for _, pin in ipairs(pins) do pin:Hide() end
        content.visibleRows = 0
        content.rowY=0
        list:SetVerticalScroll(0)
        back:SetShown(selected ~= nil)
        bossTab:SetShown(selected ~= nil)
        questTab:SetShown(selected ~= nil)
        local loc = selected and ns.DungeonEntrance(selected)
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
        if image then floorButton.label:SetText("Floor " .. floor .. " / " .. #floors) end
        currentMapAspect = image and image.aspect
        mapPane:SetShown(image ~= nil)
        map:SetShown(image ~= nil)
        list:ClearAllPoints()
        local rightInset = image and (width - leftWidth) or 34
        list:SetPoint("TOPLEFT", 18, selected and -119 or -47)
        list:SetPoint("BOTTOMRIGHT", -rightInset, 42)
        content:SetWidth(width - rightInset - 18)
        local cardHeight
        if selected then
            title:SetText(selected.name)
            bossTab:ClearAllPoints()
            bossTab:SetPoint("TOPLEFT", 18, -85)
            questTab:ClearAllPoints()
            questTab:SetPoint("LEFT", bossTab, "RIGHT", 8, 0)
            bossTab.line:SetShown(tab == "bosses")
            questTab.line:SetShown(tab == "quests")
            bossTab.paper:SetVertexColor(.9,.74,.50,tab=="bosses" and 1 or .48)
            questTab.paper:SetVertexColor(.9,.74,.50,tab=="quests" and 1 or .48)
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
                    entry.referenceLoot = entry.referenceLoot or {}
                    for _, item in ipairs(boss.loot) do table.insert(entry.referenceLoot, item) end
                    bosses[key] = entry
                end
            end
            local floorByMapID = {}
            for index, mapFloor in ipairs(floors or {}) do
                local mapID = tonumber(mapFloor.file:match("^(%d+)%.blp$"))
                if mapID then floorByMapID[mapID] = index end
                for _, point in ipairs(ns.DungeonReferencePins[mapFloor.file] or {}) do
                    if point[4] == "boss" then
                        local key = ns.DungeonNameKey(point[1])
                        local boss = bosses[key] or {name = point[1]}
                        boss.floor = boss.floor or index
                        bosses[key] = boss
                    end
                end
            end
            for name in pairs(fallback or {}) do
                local key = ns.DungeonNameKey(name)
                bosses[key] = bosses[key] or {name = name}
            end
            for _, landmark in ipairs(recordFor(ns.DungeonLandmarks, selected.name) or {}) do
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
                    y = y + 34
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

    window:SetScript("OnShow", draw)
    draw()
end
