local _, ns = ...
local call = ns.Forever.Call
local nameKey = ns.DungeonNameKey
local texturePrefix = "Interface\\AddOns\\GrindingForever\\Media\\DungeonMap"
local woodTexture = "Interface\\AddOns\\GrindingForever\\Media\\BaseWood"
local sunken = "temple of atalhakkar"
local aliases = {
    ["sunken temple"] = sunken,
    ["stormwind stockade"] = "stockade",
    ["temple of ahnqiraj"] = "ahnqiraj",
    ["ahnqiraj temple"] = "ahnqiraj",
    ["the temple of atalhakkar"] = sunken,
}
local pane = {scale = 1, dx = 0, dy = 0, pins = {}}
local spireFloors

local function clamp(value, low, high)
    return math.max(low, math.min(high, value))
end

local function publicNumber(value)
    if (not ns.Forever.Public or ns.Forever.Public(value)) and type(value) == "number" then return value end
end

local function instanceMap()
    local inside, instanceType = call(IsInInstance)
    if inside ~= true or (instanceType ~= "party" and instanceType ~= "raid") then return end
    local name, _, _, _, _, _, _, instanceID = call(GetInstanceInfo)
    if type(name) ~= "string" then return end
    local key = nameKey(name)
    key = aliases[key] or key
    local bestMap = publicNumber(call(C_Map and C_Map.GetBestMapForUnit, "player"))
    if key == "blackrock spire" then
        local upper = bestMap == 254 or bestMap == 255 or bestMap == 1002295
            or bestMap == 1002296 or bestMap == 1002297
        local lower = bestMap == 250 or bestMap == 251 or bestMap == 252 or bestMap == 253
        if upper or lower then
            key = upper and "upper blackrock spire" or "lower blackrock spire"
        else
            -- With no usable floor ID, expose both parts of the shared instance
            -- for manual browsing rather than asserting the player is in Lower.
            if not spireFloors then
                spireFloors = {startFloor=1}
                local seen = {}
                for _,part in ipairs({"Lower Blackrock Spire","Upper Blackrock Spire"}) do
                    for _,image in ipairs((ns.BundledDungeonMaps or {})[part] or {}) do
                        if not seen[image.file] then
                            seen[image.file]=true;spireFloors[#spireFloors+1]=image
                        end
                    end
                end
            end
            if #spireFloors > 0 then return key,spireFloors,bestMap,instanceID,"Blackrock Spire" end
        end
    end
    if instanceID == 109 then key = sunken end
    for mapName, floors in pairs(ns.BundledDungeonMaps or {}) do
        if nameKey(mapName) == key then return key, floors, bestMap, instanceID, mapName end
    end
end

local function nativeFloorID(floor)
    return floor.uiMapID or tonumber((floor.pinKey or ""):match(":(%d+)$"))
        or tonumber(floor.file:match("^(%d+)%.blp$"))
end

local function nativeIndex(floors, mapID)
    if not mapID then return end
    for i, floor in ipairs(floors) do
        if nativeFloorID(floor) == mapID then return i end
    end
end

-- A visible native minimap is not evidence that add-ons receive coordinates.
-- Authored maps need an explicit, independently verified projection before a
-- moving player marker can be drawn. Never assume their crop matches C_Map.
local function currentPosition(key, floors, bestMap)
    local floor = nativeIndex(floors, bestMap)
    local image = floor and floors[floor]
    local projection = image and image.playerProjection
    if type(projection) ~= "table" or projection.verified ~= true
        or projection.mapID ~= bestMap then
        return floor or floors.startFloor or 1, nil, nil, floor ~= nil
    end
    local point = call(C_Map and C_Map.GetPlayerMapPosition, bestMap, "player")
    local x, y
    if point and point.GetXY then x,y=call(point.GetXY,point)
    elseif point then x,y=point.x,point.y end
    x,y=publicNumber(x),publicNumber(y)
    if not x or not y or (x == 0 and y == 0) then return floor,nil,nil,true end
    local u0,u1=projection.u0 or 0,projection.u1 or 1
    local v0,v1=projection.v0 or 0,projection.v1 or 1
    if u1<=u0 or v1<=v0 then return floor,nil,nil,true end
    return floor,(x-u0)/(u1-u0),(y-v0)/(v1-v0),true
end

local function pointInImage(x, y)
    return type(x) == "number" and type(y) == "number" and x >= 0 and x <= 1 and y >= 0 and y <= 1
end

local function makeButton(parent, label, width, callback)
    local button = (ns.NormalUI.WoodButton or ns.NormalUI.MakeButton)(parent, label, width, callback)
    button:SetSize(width, 24)
    return button
end

local function setFloor(floor, follow)
    if pane.floors and pane.floors[floor] then
        if pane.floor ~= floor then pane.dirty = true end
        pane.floor, pane.follow = floor, follow
    end
end

local function addPin(point, used)
    local kind, target = point[4] or "boss", point.targetFloor
    if not pointInImage(point[2], point[3]) or (kind ~= "boss" and kind ~= "quest" and (kind ~= "floor" or not target)) then return used end
    local number = used + 1
    local button = pane.pins[number]
    if not button then
        button = CreateFrame("Button", nil, pane.viewport)
        button:SetSize(23, 23)
        button:SetScript("OnClick", function(self)
            if self.targetFloor then
                GameTooltip:Hide()
                setFloor(self.targetFloor, false)
            end
        end)
        button:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(self.pointName)
            local point=self.landmark
            if point and point.possible then
                GameTooltip:AddLine("Possible spawn location",.95,.86,.68,true)
                if point.evidence=="inherited-reference" or point.nativeVerified==false then
                    GameTooltip:AddLine("Inherited Classic reference; Forever position unverified.",1,1,1,true)
                else
                    GameTooltip:AddLine("Recorded possible site; current presence is unconfirmed.",1,1,1,true)
                end
                if point.source then GameTooltip:AddLine(point.source,.7,.7,.7,true)end
            end
            local rarity=self.bossToken and self.bossToken.rareClassification
            if rarity and not (self.description or ""):lower():find("rare",1,true)then
                GameTooltip:AddLine(rarity=="rareelite" and "Rare elite encounter" or "Rare encounter",1,1,1,true)
            end
            if self.description then GameTooltip:AddLine(self.description, .95, .86, .68, true) end
            GameTooltip:Show()
        end)
        button:SetScript("OnLeave", function() GameTooltip:Hide() end)
        button:SetScript("OnHide",function(self)
            if GameTooltip.IsOwned and GameTooltip:IsOwned(self)then GameTooltip:Hide()end
        end)
        pane.pins[number] = button
    end
    -- The shared renderer/layout writes only to this fresh display record.
    -- Authored points remain immutable when a pooled button changes purpose.
    button.landmark={name=point[1],x=point[2],y=point[3],kind=kind,detail=point[5],
        markerX=point.markerX,markerY=point.markerY,possible=kind=="boss" and point.possible==true,
        pointID=point.pointID,candidateIndex=point.candidateIndex,candidateCount=point.candidateCount,
        npcID=point.npcID,source=point.source,sourceUrl=point.sourceUrl,evidence=point.evidence,
        nativeVerified=point.nativeVerified,displayCluster=point.displayCluster,targetFloor=target}
    button.x, button.y, button.offsetX, button.offsetY = point[2], point[3], point.markerX or 0, point.markerY or 0
    button.pointName, button.description, button.targetFloor = point[1], point[5], target
    button:SetScale(1)
    button.portraitSize=button.landmark.possible and 23*.7 or 23
    if kind == "floor" then
        if button.questIcon then button.questIcon:Hide() end
        if not button.stairs then
            local stairs = CreateFrame("Frame", nil, button)
            stairs:SetAllPoints()
            local rim = stairs:CreateTexture(nil, "BACKGROUND")
            rim:SetAllPoints()
            rim:SetColorTexture(.87, .67, .37, 1)
            local fill = stairs:CreateTexture(nil, "BACKGROUND", nil, 1)
            fill:SetPoint("TOPLEFT", 1, -1)
            fill:SetPoint("BOTTOMRIGHT", -1, 1)
            fill:SetColorTexture(.15, .08, .04, 1)
            stairs.label = ns.NormalUI.MakeText(stairs, 13, "", false)
            stairs.label:SetPoint("CENTER")
            button.stairs = stairs
        end
        button.stairs.label:SetText(point.stairLabel or point.marker or "↕")
        button.stairs:Show()
        ns.PaintDungeonBossToken(button, nil, "CENTER", 0, 23, true)
    elseif kind == "quest" then
        if button.stairs then button.stairs:Hide() end
        ns.PaintDungeonBossToken(button, nil, "CENTER", 0, 23, true)
        if not button.questIcon then button.questIcon=button:CreateTexture(nil,"ARTWORK"); button.questIcon:SetAllPoints() end
        button.questIcon:SetTexture("Interface\\GossipFrame\\AvailableQuestIcon"); button.questIcon:Show()
    else
        if button.questIcon then button.questIcon:Hide() end
        if button.stairs then button.stairs:Hide() end
        local entry = ns.DungeonPortraitSubject and ns.DungeonPortraitSubject(point[1], point.npcID, pane.name)
            or {name = point[1], npcID = point.npcID}
        local boss={
            name = entry.name, npcID = entry.npcID, portraitNpcID = entry.portraitNpcID,
            displayID = point.displayID or entry.displayID, customIcon = entry.customIcon,
        }
        button.landmark.boss=boss
        ns.PaintDungeonBossToken(button,boss,"CENTER",0,button.portraitSize,true)
    end
    button:Show()
    return number
end

local function drawPins(image)
    local used, seen = 0, {}
    local function add(point)
        local key = nameKey(point[1])
        local boss = not point[4] or point[4] == "boss"
        if point.sharedWith then return end
        local positions=boss and seen[key]
        if positions then
            if point.possible~=true then return end
            for _,position in ipairs(positions)do
                if type(point[2])=="number" and type(point[3])=="number"
                    and math.abs(position.x-point[2])<.000001 and math.abs(position.y-point[3])<.000001 then return end
            end
        end
        local previous = used
        used = addPin(point, used)
        if boss and used > previous then
            positions=positions or{};positions[#positions+1]={x=point[2],y=point[3]};seen[key]=positions
        end
    end
    for _, point in ipairs((ns.DungeonReferencePins or {})[image.pinKey or image.file] or {}) do add(point) end
    if image.legacyLandmarks ~= false then
        for _, point in ipairs((ns.DungeonLandmarks or {})[pane.name] or {}) do
            if (point[6] or 1) == pane.floor then add(point) end
        end
    end
    local mapID = not image.curatedPins and nativeFloorID(image)
    local instance = (ns.Forever.dungeons or {})[pane.name]
    local journal = instance and (instance.journalMap or (instance.sourceData and instance.map))
    for _, point in ipairs(journal and journal.bosses or {}) do
        local floor = journal.floors and journal.floors[point.floor or 1]
        if mapID and floor and mapID == floor.uiMapID then add({point.name, point.x, point.y, "boss"}) end
    end
    if not image.curatedPins and EJ_GetMapEncounter then
        if mapID then
            for index = 1, 40 do
                local x, y, _, boss = call(EJ_GetMapEncounter, mapID, index)
                if not boss then break end
                add({boss, x, y, "boss"})
            end
        end
    end
    for i = used + 1, #pane.pins do pane.pins[i]:Hide() end
    pane.visiblePins = used
    pane.pinLayoutDirty=true
end

local function positionPin(frame, x, y, ox, oy)
    frame:ClearAllPoints()
    frame:SetPoint("CENTER", pane.art, "TOPLEFT", x * pane.width + (ox or 0), -y * pane.height + (oy or 0))
end

local function layout()
    local width, height = pane.viewport:GetSize()
    if width <= 0 or height <= 0 then pane.width, pane.height = nil, nil; return end
    local floor = pane.floors[pane.floor]
    local availableHeight = math.max(1, height)
    local fitHeight = math.min(availableHeight, width / floor.aspect)
    pane.width, pane.height = fitHeight * floor.aspect * pane.scale, fitHeight * pane.scale
    local maxX = math.max(0, (pane.width - width) / 2)
    local maxY = math.max(0, (pane.height - availableHeight) / 2)
    pane.dx, pane.dy = clamp(pane.dx, -maxX, maxX), clamp(pane.dy, -maxY, maxY)
    pane.art:ClearAllPoints()
    pane.art:SetPoint("CENTER", pane.viewport, "CENTER", pane.dx, pane.dy)
    pane.art:SetSize(pane.width, pane.height)
    local pixel=ns.NormalUI.PixelSize(pane.viewport,1)
    if pane.pinLayoutDirty or pane.pinLayoutWidth~=pane.width or pane.pinLayoutHeight~=pane.height
        or pane.pinLayoutPixel~=pixel then
        -- World Map's pre-existing marker offsets are already in UI units.
        ns.LayoutDungeonMapPins(pane.pins,pane.art,pane.width,pane.height,pane.viewport,1)
        pane.pinLayoutWidth,pane.pinLayoutHeight,pane.pinLayoutPixel=pane.width,pane.height,pixel
        pane.pinLayoutDirty=nil
    end
    for i = 1, pane.visiblePins or 0 do
        local button = pane.pins[i]
        ns.PositionDungeonMapPin(button,pane.art,pane.width,pane.height,pane.viewport,1)
    end
    pane.lastWidth, pane.lastHeight = width, height
end

local function refresh(view)
    if pane.dirty then
        local floor = pane.floors[pane.floor]
        pane.art:SetTexture(texturePrefix .. floor.file)
        pane.art:SetTexCoord(floor.u0, floor.u1, floor.v0, floor.v1)
        pane.back:SetShown(pane.floor > 1)
        pane.next:SetShown(pane.floor < #pane.floors)
        pane.home:SetShown(#pane.floors > 1)
        drawPins(floor)
        pane.scale, pane.dx, pane.dy, pane.dirty = 1, 0, 0, nil
        layout()
    elseif pane.lastWidth ~= view:GetWidth() or pane.lastHeight ~= view:GetHeight()
        or pane.pinLayoutPixel~=ns.NormalUI.PixelSize(view,1) then
        layout()
    end
end

local function ensureViewport(frame, container)
    if pane.viewport then return end
    local view = CreateFrame("Frame", nil, frame)
    pane.viewport = view
    view:SetAllPoints(container)
    view:SetFrameLevel(container:GetFrameLevel() + 150)
    view:SetClipsChildren(true)
    view:EnableMouse(true)
    view:EnableMouseWheel(true)
    view:Hide()
    local backdrop = view:CreateTexture(nil, "BACKGROUND")
    backdrop:SetAllPoints()
    backdrop:SetTexture(woodTexture)
    backdrop:SetTexCoord(0, 1254 / 2048, 0, 1254 / 2048)
    backdrop:SetVertexColor(.28, .25, .22)
    pane.art = view:CreateTexture(nil, "ARTWORK")
    pane.player = view:CreateTexture(nil, "OVERLAY", nil, 7)
    pane.player:SetSize(24, 24)
    pane.player:SetTexture("Interface\\Minimap\\MinimapArrow")
    pane.back = makeButton(view, "<", 26, function() setFloor(pane.floor - 1, false) end)
    pane.back:SetPoint("TOPLEFT", 8, -8)
    pane.next = makeButton(view, ">", 26, function() setFloor(pane.floor + 1, false) end)
    pane.next:SetPoint("TOPLEFT", 38, -8)
    pane.home = makeButton(view, "Current Floor", 112, function() setFloor(pane.currentFloor or 1, true) end)
    pane.home:SetPoint("TOPLEFT", 70, -8)
    local world = makeButton(view, "World Map", 89, function()
        pane.optOut = true
        view:Hide()
        pane.switch:Show()
    end)
    world:SetPoint("TOPRIGHT", -8, -8)
    for _,control in ipairs({pane.back,pane.next,pane.home,world})do
        control:SetFrameLevel(view:GetFrameLevel()+15)
    end
    pane.switch = makeButton(frame, "Dungeon Map", 95, function()
        pane.optOut = nil
        pane.initialMap = call(frame.GetMapID, frame)
        pane.follow = true
        pane.dirty = true
    end)
    pane.switch:SetFrameLevel(view:GetFrameLevel() + 20)
    pane.switch:SetPoint("BOTTOMRIGHT", container, "BOTTOMRIGHT", -12, 28)
    pane.switch:Hide()
    view:SetScript("OnMouseWheel", function(_, delta)
        pane.scale = clamp(pane.scale * (delta > 0 and 1.25 or .8), 1, 4)
        layout()
    end)
    view:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then pane.dragX, pane.dragY = GetCursorPosition() end
    end)
    view:SetScript("OnMouseUp", function() pane.dragX, pane.dragY = nil, nil end)
    view:SetScript("OnHide", function() pane.dragX, pane.dragY = nil, nil end)
    view:SetScript("OnUpdate", function()
        if not pane.dragX then return end
        if not IsMouseButtonDown("LeftButton") then pane.dragX, pane.dragY = nil, nil; return end
        local x, y = GetCursorPosition()
        local scale = view:GetEffectiveScale()
        pane.dx = pane.dx + (x - pane.dragX) / scale
        pane.dy = pane.dy + (y - pane.dragY) / scale
        pane.dragX, pane.dragY = x, y
        layout()
    end)
end

local function hide()
    if pane.viewport then pane.viewport:Hide(); pane.switch:Hide() end
end

local function update()
    local frame = WorldMapFrame
    if not frame or not frame:IsShown() then
        hide()
        pane.initialMap, pane.wasShown = nil, nil
        return
    end
    local key, floors, bestMap, instanceID, name = instanceMap()
    local container = key and call(frame.GetCanvasContainer, frame)
    if not container or not floors or not floors[1] then
        hide()
        pane.key, pane.wasShown = nil, nil
        return
    end
    local mapID = call(frame.GetMapID, frame)
    local liveFloor, x, y, floorKnown = currentPosition(key, floors, bestMap)
    if pane.key ~= key or pane.instanceID ~= instanceID or not pane.wasShown then
        pane.key, pane.name, pane.floors, pane.instanceID = key, name, floors, instanceID
        pane.wasShown, pane.initialMap = true, mapID
        pane.floor, pane.follow, pane.dirty = liveFloor, true, true
        pane.optOut = nil
    end
    pane.currentFloor = liveFloor
    ensureViewport(frame, container)
    if pane.optOut or (mapID ~= pane.initialMap and not nativeIndex(floors, mapID)) then
        pane.viewport:Hide()
        pane.switch:Show()
        return
    end
    local homeText = floorKnown and "Current Floor" or (key == sunken and "Entrance Floor" or "First Floor")
    if pane.homeText ~= homeText then
        pane.home.label:SetText(homeText)
        pane.homeText = homeText
    end
    pane.switch:Hide()
    if pane.follow and (floorKnown or key ~= sunken) then setFloor(liveFloor, true) end
    pane.viewport:Show()
    refresh(pane.viewport)
    local facing = publicNumber(call(GetPlayerFacing))
    local showPlayer = liveFloor == pane.floor and pane.width and pointInImage(x, y) and facing ~= nil
    pane.player:SetShown(not not showPlayer)
    if showPlayer then
        positionPin(pane.player, x, y)
        pane.player:SetRotation(facing)
    end
end

local worker = CreateFrame("Frame")
local age = 0
worker:SetScript("OnUpdate", function(_, delta)
    if not WorldMapFrame or not WorldMapFrame:IsShown() then
        if pane.wasShown then update() end
        return
    end
    age = age + delta
    if age >= .15 then age = 0; update() end
end)
if EventRegistry and EventRegistry.RegisterCallback then
    EventRegistry:RegisterCallback("WorldMapOnShow", function() update() end, worker)
    EventRegistry:RegisterCallback("WorldMapOnHide", function() update() end, worker)
end

ns.DungeonWorldMap = { Refresh=update, State=pane }
