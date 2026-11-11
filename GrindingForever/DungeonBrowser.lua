local _, ns = ...
local E, N = ns.Forever, ns.NormalUI
local window
local assets = "Interface\\AddOns\\GrindingForever\\Media\\DungeonMap"
local waypointIcon = "Interface\\AddOns\\GrindingForever\\Media\\RecipePin"
local bossFallback = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_8"
local portraitMask = "Interface\\CharacterFrame\\TempPortraitAlphaMask"

local raidNames = {
    ["ahnqiraj"] = true, ["temple of ahnqiraj"] = true, ["ruins of ahnqiraj"] = true,
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
    [4829] = 2837, [11517] = 11611, [11520] = 7970, [11518] = 11429, [11519] = 2007, [3914] = 524, [3864] = 1951, [3886] = 524,
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
        token.portrait = token:CreateTexture(nil, "ARTWORK")
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
            token.portrait:AddMaskTexture(innerMask)
        end
    end
    local journal = E.journal
    local display = bossDisplay[boss.npcID]
        or journal and journal.STATIC_DISPLAY_IDS and journal.STATIC_DISPLAY_IDS[boss.npcID]
    token.portrait:SetTexture(bossFallback)
    if display then E.Call(SetPortraitTextureFromCreatureDisplayID, token.portrait, display) end
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
    window:SetSize(680, 690)
    window:SetPoint("CENTER")
    window:SetFrameStrata("DIALOG")
    window:SetClampedToScreen(true)
    window:SetMovable(true)
    window:EnableMouse(true)
    local theme = ns.VisualPhaseB.Theme
    local components = ns.VisualPhaseB.Components
    local leather = window:CreateTexture(nil, "BACKGROUND")
    leather:SetPoint("TOPLEFT", 5, -5)
    leather:SetPoint("BOTTOMRIGHT", -5, 5)
    leather:SetTexture(theme.textures.leather)
    leather:SetTexCoord(unpack(theme.leather))
    leather:SetVertexColor(.45, .39, .32)
    components.LayoutBorder(window, 28)

    local header = CreateFrame("Frame", nil, window)
    header:SetPoint("TOPLEFT")
    header:SetPoint("TOPRIGHT", -35, 0)
    header:SetHeight(42)
    header:EnableMouse(true)
    header:RegisterForDrag("LeftButton")
    header:SetScript("OnDragStart", function() window:StartMoving() end)
    header:SetScript("OnDragStop", function() window:StopMovingOrSizing() end)
    local title = N.MakeText(header, 17)
    title:SetPoint("LEFT", 16, 0)
    components.Close(window, function() window:Hide() end)

    local search = CreateFrame("EditBox", nil, window, "InputBoxTemplate")
    search:SetSize(280, 26)
    search:SetPoint("TOPLEFT", 22, -45)
    search:SetAutoFocus(false)
    search:SetFont("Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf", 14, "")
    search:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    local status = N.MakeText(window, 12)
    status:SetTextColor(.76, .64, .45)
    status:SetPoint("BOTTOMLEFT", 18, 14)
    status:SetPoint("BOTTOMRIGHT", -18, 14)

    local map = CreateFrame("Frame", nil, window)
    map:SetPoint("TOP", 0, -82)
    local art = map:CreateTexture(nil, "BACKGROUND")
    art:SetAllPoints()
    local pins = {}
    local list = CreateFrame("ScrollFrame", nil, window, "UIPanelScrollFrameTemplate")
    local content = CreateFrame("Frame", nil, list)
    content:SetSize(620, 1)
    list:SetScrollChild(content)
    local rows, pendingItems = {}, {}
    local rowHeight = 38
    local selected, floor, tab = nil, 1, "bosses"
    local selectedBoss, selectedQuest, questLandmark
    local draw

    local function button(parent, label, width, action)
        local b = N.MakeButton(parent, label, width, action)
        b:SetSize(width, 28)
        return b
    end

    local back = button(window, "< Instances", 112, function() selected = nil; draw() end)
    back:SetPoint("TOPLEFT", 18, -45)
    local floorButton = button(window, "", 120, function()
        floor = floor % #selected.gfMaps + 1
        draw()
    end)
    floorButton:SetPoint("TOPRIGHT", -18, -45)

    local entrance = button(window, "Pin Entrance", 142, function()
        status:SetText(setWaypoint(ns.DungeonEntrance(selected)))
    end)
    entrance:SetPoint("LEFT", back, "RIGHT", 8, 0)

    local function makeTab(label, key, width)
        local control = CreateFrame("Button", nil, window)
        control:SetSize(width, 29)
        control.label = N.MakeText(control, 15, label)
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

    local bossTab = makeTab("Bosses & Loot", "bosses", 130)
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
    window:SetScript("OnEvent", function(self, _, itemID)
        if not E.Public(itemID) or type(itemID) ~= "number" or not pendingItems[itemID] then return end
        pendingItems[itemID] = false
        if not self:IsShown() then return end
        for index = 1, content.visibleRows do
            local row = rows[index]
            if row.itemID == itemID then paintItem(row) end
        end
    end)

    local function addRow(label, action, itemID, detail, actionLabel, boss, heading)
        local index = content.visibleRows + 1
        content.visibleRows = index
        local row = rows[index]
        if not row then
            row = CreateFrame("Button", nil, content)
            row:SetPoint("TOPLEFT", 0, -(index - 1) * rowHeight)
            row:SetPoint("TOPRIGHT", 0, -(index - 1) * rowHeight)
            row:SetHeight(rowHeight)
            local separator = row:CreateTexture(nil, "BACKGROUND")
            separator:SetPoint("BOTTOMLEFT", 6, 0)
            separator:SetPoint("BOTTOMRIGHT", -6, 0)
            separator:SetHeight(1)
            separator:SetColorTexture(.68, .48, .26, .20)
            local highlight = row:CreateTexture(nil, "BACKGROUND", nil, 1)
            highlight:SetAllPoints()
            highlight:SetColorTexture(.12, .44, .41, .27)
            row:SetHighlightTexture(highlight)
            row.icon = row:CreateTexture(nil, "ARTWORK")
            row.icon:SetSize(23, 23)
            row.icon:SetPoint("LEFT", 7, 0)
            row.label = N.MakeText(row, 14)
            row.label:SetWordWrap(false)
            row.detail = N.MakeText(row, 11)
            row.detail:SetWordWrap(false)
            row.detail:SetTextColor(.75, .65, .48)
            row.command = N.MakeText(row, 12)
            row.command:SetJustifyH("RIGHT")
            row.command:SetWordWrap(false)
            row.command:SetTextColor(.45, .85, .77)
            row.command:SetPoint("RIGHT", -8, 0)
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
        local right = actionLabel and -120 or -8
        local y = detail and -4 or -11
        row.label:SetPoint("TOPLEFT", left, y)
        row.label:SetPoint("TOPRIGHT", right, y)
        row.detail:SetPoint("TOPLEFT", left, -21)
        row.detail:SetPoint("TOPRIGHT", right, -21)
        row.detail:SetText(detail or "")
        row.command:SetText(actionLabel or "")
        if heading then row.label:SetTextColor(.78, .57, .31)
        else row.label:SetTextColor(.97, .82, .56) end
        if itemID then paintItem(row) else row.label:SetText(label) end
        row:SetScript("OnClick", action)
        row:EnableMouse(action ~= nil or itemID ~= nil)
        row:Show()
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

    local function drawMap(image, bosses, allowedNames)
        local height = math.min(340, 630 / image.aspect)
        map:SetSize(height * image.aspect, height)
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
        local journal = selected.journalMap
        for _, position in ipairs(journal and journal.bosses or {}) do
            local sourceFloor = journal.floors and journal.floors[position.floor or 1]
            if mapID and sourceFloor and sourceFloor.uiMapID == mapID then
                landmark(position.name, position.x, position.y, "boss")
            end
        end
        local points = recordFor(ns.DungeonLandmarks, selected.name)
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
                addRow(loot[2])
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
        table.sort(names)
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
            end, nil, nil, "View Loot", boss)
        end
        if #names == 0 then addRow("No encounters recorded for this instance") end
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
                    addRow(title, function() status:SetText(setWaypoint(point)) end, nil, location, "Pin")
                end
            end
            if #groups == 0 then addRow(label .. "  /  " .. (hint or "Location Unavailable")) end
        end
        local function details(q)
            local record = q.record
            addRow(q.name, function() selectedQuest = nil; draw() end, nil, nil, "Back To Quests")
            if record.objective then addRow(record.objective) end
            addEndpoint(q, true)
            addEndpoint(q, false)
            local seen = {}
            for _, p in ipairs(q.reference and q.reference.chain or {}) do
                local previous = ns.ForeverQuestData.quests[p[1]]
                local name = p[2] or (previous and previous.title) or ("Quest " .. p[1])
                local loc = ns.DungeonLocation(p[3], name)
                local action
                if localEndpoint(loc) then action = function() status:SetText(setWaypoint(loc)) end end
                if name ~= q.name then addRow(name, action, nil, "Prerequisite", action and "Pin") end
                seen[p[1]] = true
            end
            for _, p in ipairs(record.prerequisites or {}) do
                local previous = ns.ForeverQuestData.quests[p.pre]
                if previous and not seen[p.pre] then addRow(previous.title, nil, nil, "Prerequisite") end
            end
            if type(record.requires) == "string" then addRow(record.requires, nil, nil, "Requirement") end
            local item = q.reference and q.reference.startItem or record.startItem
            if item then
                local source = type(item[4]) == "string" and item[4] or "Starts Quest"
                addRow(item[2], nil, item[1], source)
            end
        end
        for _, q in ipairs(questRows) do
            if selectedQuest and selectedQuest == (q.id or q.name) then details(q); return end
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
        local matched
        for _, q in ipairs(questRows) do
            local side = q.reference and q.reference.faction or q.record.faction or q.record.side
            local classOnly = q.reference and q.reference.classOnly
            local title = ns.DungeonNameKey(q.name)
            if (not landmarkQuests or title == landmarkTitle or landmarkQuests[title])
                and (not classOnly or not class or classOnly == class)
                and ((side ~= "Alliance" and side ~= "Horde") or not faction or side == faction) then
                local key = q.id or q.name
                addRow(q.name, function() selectedQuest = key; draw() end, nil, q.source, "Details")
                matched = true
            end
        end
        if not matched then
            addRow(questLandmark and "No available quests linked to this pin" or "No dungeon quests recorded for this character")
        end
    end

    draw = function()
        for _, row in ipairs(rows) do row:Hide() end
        for _, pin in ipairs(pins) do pin:Hide() end
        content.visibleRows = 0
        list:SetVerticalScroll(0)
        search:SetShown(not selected)
        back:SetShown(selected ~= nil)
        bossTab:SetShown(selected ~= nil)
        questTab:SetShown(selected ~= nil)
        local loc = selected and ns.DungeonEntrance(selected)
        entrance:SetShown(loc ~= nil)
        local floors = selected and selected.gfMaps
        local image = floors and floors[floor]
        floorButton:SetShown(floors and #floors > 1 or false)
        if image then floorButton.label:SetText("Floor " .. floor .. " / " .. #floors) end
        map:SetShown(image ~= nil)
        list:ClearAllPoints()
        list:SetPoint("TOPLEFT", 18, selected and (image and -466 or -119) or -82)
        list:SetPoint("BOTTOMRIGHT", -34, 42)
        if selected then
            title:SetText(selected.name)
            bossTab:ClearAllPoints()
            bossTab:SetPoint("TOPLEFT", 18, image and -432 or -85)
            questTab:ClearAllPoints()
            questTab:SetPoint("LEFT", bossTab, "RIGHT", 8, 0)
            bossTab.line:SetShown(tab == "bosses")
            questTab.line:SetShown(tab == "quests")
            bossTab.label:SetAlpha(tab == "bosses" and 1 or .66)
            questTab.label:SetAlpha(tab == "quests" and 1 or .66)
            local questRows = ns.DungeonQuestRows(selected, selected.name)
            local questsByID = {}
            local faction = UnitFactionGroup("player")
            local policy = ns.ForeverQuestPlanner
            local rejected = {}
            for _, quest in ipairs(questRows) do
                if quest.id then questsByID[quest.id] = quest end
            end
            local bosses, fallback = {}, recordFor(ns.DungeonLoot, selected.name)
            for _, boss in ipairs(selected.bosses or {}) do
                bosses[ns.DungeonNameKey(boss.name)] = {name = boss.name, loot = boss.loot, npcID = boss.npcID}
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
                for _, fact in ipairs(reference.quests or {}) do
                    local row = questsByID[fact.id]
                    if policy and not policy.AllowsQuest(fact.id, faction, fact) then
                        rejected[fact.id] = true
                    elseif not row then
                        local source = "Dungeon Quest"
                        if fact.min_level and fact.min_level > 0 then source = source .. "  /  Level " .. fact.min_level end
                        row = {id = fact.id, name = fact.name, source = source, record = ns.ForeverQuestData.quests[fact.id] or {}}
                        questsByID[fact.id] = row
                        table.insert(questRows, row)
                    end
                    if row and not rejected[fact.id] and not row.reference then row.reference = fact end
                end
            end
            local allowedNames = {}
            for i = #questRows, 1, -1 do
                local quest = questRows[i]
                if rejected[quest.id] then
                    table.remove(questRows, i)
                else
                    allowedNames[ns.DungeonNameKey(quest.name)] = quest.name
                end
            end
            table.sort(questRows, function(a, b) return a.name < b.name end)
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
            local journal = selected.journalMap
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
            title:SetText("Dungeons & Raids")
            local query, entries = (search:GetText() or ""):lower(), {}
            local catalog = {}
            for name, instance in pairs(E.dungeons) do
                if ns.IsForeverDungeon(name) then catalog[name] = instance end
            end
            for name, reference in pairs(ns.DungeonReference or {}) do
                local title = reference.art or name
                if ns.IsForeverDungeon(name) and not catalog[title] then
                    catalog[title] = {name = title, gfMaps = recordFor(ns.BundledDungeonMaps, title)}
                end
            end
            for name, instance in pairs(catalog) do
                if name:lower():find(query, 1, true) then
                    local key = ns.DungeonNameKey(name)
                    local range = levelRanges[key] or {}
                    entries[#entries + 1] = {name = name, instance = instance, raid = raidNames[key] == true,
                        minimum = instance.minimum or range[1], maximum = instance.maximum or range[2]}
                end
            end
            table.sort(entries, function(a, b)
                if a.raid ~= b.raid then return not a.raid end
                local minA, minB = a.minimum or math.huge, b.minimum or math.huge
                if not a.raid and minA ~= minB then return minA < minB end
                return a.name < b.name
            end)
            local raid
            for _, entry in ipairs(entries) do
                if raid ~= entry.raid then
                    raid = entry.raid
                    addRow(raid and "Raids" or "Dungeons By Level", nil, nil, nil, nil, nil, true)
                end
                local instance = entry.instance
                local levels = entry.minimum and entry.maximum
                    and string.format("Levels %d-%d", entry.minimum, entry.maximum)
                addRow(entry.name, function()
                    search:ClearFocus()
                    selected, floor, tab = instance, 1, "bosses"
                    selectedBoss, selectedQuest, questLandmark = nil, nil, nil
                    draw()
                end, nil, levels, instance.gfMaps and "View Map" or "Details")
            end
            status:SetText(#entries == 0 and "No matching instances" or "")
        end
        content:SetHeight(math.max(1, content.visibleRows * rowHeight))
        list:UpdateScrollChildRect()
    end

    search:SetScript("OnTextChanged", draw)
    window:SetScript("OnShow", draw)
    draw()
end
