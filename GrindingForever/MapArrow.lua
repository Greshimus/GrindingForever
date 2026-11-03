--[[ Grinding Forever MapArrow — facing-aware navigation arrow + waypoints (original) ]]
local ADDON, ns = ...
ns = ns or {}
ns.Map = ns.Map or {}

local arrowFrame, arrowTex, titleFS, objectiveFS, distFS
local destX, destY, destMap, destLabel, destObjective
local loopStep, loopOwner, loopPoints, loopIndex
-- Presentation observations only; no additional position or bearing reads.
local observedStatus, observedYards = "pending", nil
local function ObserveNavigation(status, yards, force)
  local changed = force or status ~= observedStatus
    or (yards and math.floor(yards + .5)) ~= (observedYards and math.floor(observedYards + .5))
  observedStatus, observedYards = status, yards
  if changed and ns.SendMessage then pcall(ns.SendMessage, "GF_NAVIGATION_CHANGED") end
end

-- Positioning only: offsets and frame bounds are UI units, not physical pixels.
local viewportWidth, viewportHeight, viewportScale
local positionPending, savedPointPending
local function KeepArrowOnScreen()
  if not arrowFrame then return end
  local width, height = UIParent:GetWidth(), UIParent:GetHeight()
  local rootScale = UIParent:GetEffectiveScale()
  arrowFrame._gfPositionRevision = "gps-layout-retry.20261022"
  positionPending = true
  arrowFrame._gfPositionStatus = "waiting for viewport"
  if not (type(width)=="number" and width>0 and type(height)=="number" and height>0
      and type(rootScale)=="number" and rootScale>0) then return end
  if savedPointPending then
    local p = savedPointPending
    arrowFrame:ClearAllPoints()
    arrowFrame:SetPoint(p[1] or "CENTER", UIParent, p[4] or p[1] or "CENTER", p[2] or 0, p[3] or 80)
    savedPointPending = nil
  end
  local left, bottom, right, top = arrowFrame:GetLeft(), arrowFrame:GetBottom(), arrowFrame:GetRight(), arrowFrame:GetTop()
  local scale = arrowFrame:GetEffectiveScale()
  arrowFrame._gfPositionStatus = "waiting for frame bounds"
  if not (left and bottom and right and top and scale and scale>0) then return end
  local ratio = scale/rootScale
  if left*ratio < 0 or bottom*ratio < 0 or right*ratio > width or top*ratio > height then
    arrowFrame:ClearAllPoints()
    arrowFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
    arrowFrame._gfPositionStatus = "reset; awaiting layout validation"
    return
  end
  viewportWidth, viewportHeight, viewportScale = width, height, rootScale
  positionPending = false
  arrowFrame._gfPositionStatus = "validated"
end

local function CleanDestination(label)
  local t = tostring(label or 'Destination')
  if ns.Loader and ns.Loader.CleanMarkup then t = ns.Loader.CleanMarkup(t) end
  t = t:gsub('::%d+', ''):gsub('^%s*Look for:%s*', '')
  return (t:gsub('%s+', ' '):gsub('^%s+', ''):gsub('%s+$', ''))
end

local function EnsureArrow()
  if arrowFrame then return end
  arrowFrame = CreateFrame("Frame", "GrindingForeverArrowFrame", UIParent)
  arrowFrame:SetSize(96, 96)
  arrowFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
  arrowFrame:SetMovable(true)
  arrowFrame:EnableMouse(true)
  arrowFrame:RegisterForDrag("LeftButton")
  arrowFrame:SetScript("OnDragStart", function(self) self:StartMoving() end)
  arrowFrame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p,_,relativePoint,x,y = self:GetPoint(1)
    if ns.db then ns.db.arrowPoint = {p, x, y, relativePoint} end
  end)
  arrowFrame:Hide()

  arrowTex = arrowFrame:CreateTexture(nil, "ARTWORK")
  arrowTex:SetAllPoints()
  local ok = pcall(function()
    arrowTex:SetTexture("Interface\\AddOns\\GrindingForever\\Assets\\GrindingForeverArrow")
  end)
  if not ok then
    arrowTex:SetTexture("Interface\\Minimap\\MiniMap-QuestArrow")
  end

  titleFS = arrowFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  titleFS:SetPoint("TOP", arrowFrame, "BOTTOM", 0, -2)
  titleFS:SetTextColor(0.9, 0.8, 0.55)
  titleFS:SetWidth(200)

  objectiveFS = arrowFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  objectiveFS:SetPoint("TOP", titleFS, "BOTTOM", 0, -2)
  objectiveFS:SetWidth(200)
  objectiveFS:SetTextColor(0.9, 0.8, 0.55)

  distFS = arrowFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
  distFS:SetPoint("TOP", objectiveFS, "BOTTOM", 0, -2)
  distFS:SetTextColor(0.85, 0.85, 0.85)
end

function ns.Map.SetDestination(mapID, x, y, label, objective)
  local client=ns.Retail.Client
  mapID=client.Number(mapID,1,2147483647);x=client.Number(x,0,100);y=client.Number(y,0,100)
  if not mapID or mapID%1~=0 or not x or not y then ns.Map.ClearDestination();return false end
  label=client.Text(label);objective=client.Text(objective)
  destMap, destX, destY, destLabel = mapID, x, y, label
  destObjective = objective
  ObserveNavigation("pending", nil, true)
end

function ns.Map.ClearDestination()
  destMap, destX, destY, destLabel = nil, nil, nil, nil
  destObjective = nil
  loopStep, loopOwner, loopPoints, loopIndex = nil, nil, nil, nil
  ObserveNavigation("no-destination", nil, true)
end

function ns.Map.HasVisibleDestination()
  return arrowFrame and arrowFrame:IsShown() and destMap and destX and destY
end

function ns.Map.GetNavigationSnapshot()
  local hasDestination = destMap ~= nil and destX ~= nil and destY ~= nil
  local shown = arrowFrame ~= nil and arrowFrame:IsShown() or false
  local status = not hasDestination and "no-destination" or not shown and "hidden" or observedStatus
  return {status=status, hasDestination=hasDestination, arrowShown=shown,
    mapID=type(destMap)=="number" and destMap or nil,
    xPercent=type(destX)=="number" and destX or nil,
    yPercent=type(destY)=="number" and destY or nil,
    description=destLabel and CleanDestination(destLabel) or nil,
    objective=destObjective and CleanDestination(destObjective) or nil,
    distanceYards=hasDestination and shown and observedYards or nil}
end

-- All distances and bearings are computed in world space, not map percentages.
local function WorldPosition(mapID, x, y)
  return ns.Retail.Client.WorldPosition(mapID,x,y)
end

local function Update()
  if arrowTex then arrowTex:Hide() end -- Never retain a stale restricted heading.
  if not arrowFrame or not arrowFrame:IsShown() then return end
  if positionPending or UIParent:GetWidth() ~= viewportWidth or UIParent:GetHeight() ~= viewportHeight
      or UIParent:GetEffectiveScale() ~= viewportScale then KeepArrowOnScreen() end
  if titleFS then titleFS:SetText(CleanDestination(destLabel)) end
  if objectiveFS then
    local objective = CleanDestination(destObjective or "")
    objectiveFS:SetText(objective ~= CleanDestination(destLabel) and objective or "")
  end
  if not (destMap and destX and destY) then
    if distFS then distFS:SetText("No destination") end
    ObserveNavigation("no-destination")
    return
  end
  local pm, px, py = ns.PlayerPosition()
  if not (pm and px and py) then
    if distFS then distFS:SetText("Position unavailable") end
    ObserveNavigation("position-unavailable")
    return
  end
  local playerInstance, playerX, playerY = WorldPosition(pm, px, py)
  local targetInstance, targetX, targetY = WorldPosition(destMap, destX, destY)
  if not (playerInstance and targetInstance) then
    if distFS then distFS:SetText("World coordinates unavailable") end
    ObserveNavigation("world-unavailable")
    return
  end
  if playerInstance ~= targetInstance then
    if distFS then distFS:SetText("Destination on another continent") end
    ObserveNavigation("another-continent")
    return
  end
  local dx, dy = targetX-playerX, targetY-playerY
  local yards = math.sqrt(dx*dx+dy*dy)
  if distFS then
    distFS:SetText(yards <= 5 and "|cff66ff66Arrived|r" or string.format("%.0f yd", yards))
  end
  local facing = ns.Retail.Client.Facing()
  if facing and arrowTex then
    arrowTex:Show()
    -- WoW world X increases toward north, world Y toward west;
    -- GetPlayerFacing is counterclockwise from north.
    local bearing = math.atan2(dy, dx)
    arrowTex:SetRotation(bearing-facing)
  end
  ObserveNavigation(yards <= 5 and "arrived" or "active", yards)
  -- Source waypoint radius controls route traversal, independently of the
  -- unchanged five-yard green arrival indicator above. Advance once per tick.
  if loopStep and yards <= (loopPoints[loopIndex].radius or 5) then
    loopIndex = loopIndex % #loopPoints + 1
    local point = loopPoints[loopIndex]
    ns.Map.SetDestination(point.mapID, point.x, point.y, destLabel, destObjective)
  end
end

function ns.Map.ShowArrow()
  EnsureArrow()
  savedPointPending = ns.db and ns.db.arrowPoint
  arrowFrame:Show()
  KeepArrowOnScreen()
  arrowFrame:SetClampedToScreen(true)
  if ns.Targeting then ns.Targeting.Refresh() end
  arrowFrame:SetScript("OnUpdate", function(_, elapsed)
    arrowFrame._t = (arrowFrame._t or 0) + elapsed
    if arrowFrame._t > 0.05 then arrowFrame._t = 0; Update() end
  end)
  if ns.db then ns.db.arrow = true end
  ObserveNavigation("pending", nil, true)
end

function ns.Map.HideArrow()
  if arrowFrame then
    arrowFrame:SetScript("OnUpdate", nil)
    arrowFrame:Hide()
  end
  if ns.db then ns.db.arrow = false end
  ObserveNavigation("hidden", nil, true)
  if ns.Targeting then ns.Targeting.Refresh() end
end

function ns.Map.ToggleArrow()
  EnsureArrow()
  if arrowFrame:IsShown() then ns.Map.HideArrow() else ns.Map.ShowArrow() end
end

function ns.Map.SetWaypoint(mapID, x, y, label)
  label = CleanDestination(label or "Grinding Forever")
  if not mapID or not x or not y then
    ns.Print("No coordinates for waypoint.")
    return
  end
  if C_Map and C_Map.SetUserWaypoint and UiMapPoint then
    local ok = pcall(function()
      C_Map.SetUserWaypoint(UiMapPoint.CreateFromCoordinates(mapID, x/100, y/100))
      if C_SuperTrack and C_SuperTrack.SetSuperTrackedUserWaypoint then
        C_SuperTrack.SetSuperTrackedUserWaypoint(true)
      end
    end)
    if ok then
      ns.Print("Waypoint set: " .. (label or "destination"))
      return
    end
  end
  if TomTom and TomTom.AddWaypoint then
    TomTom:AddWaypoint(mapID, x/100, y/100, {title = label or "Grinding Forever"})
    ns.Print("TomTom waypoint set.")
    return
  end
  ns.Print("No waypoint API available.")
end

function ns.Map.SetCurrentWaypoint()
  if not (destX and destY) then ns.Print("Current step has no coordinates."); return end
  ns.Map.SetWaypoint(destMap or select(1, ns.PlayerPosition()), destX, destY, destLabel)
end

function ns.Map.UpdateFromStep(step, navigation)
  navigation = navigation or step
  if navigation and ns.Coords and ns.Coords.Normalize then
    if navigation.x or navigation.worldX then ns.Coords.Normalize(navigation) end
    for _, el in ipairs(navigation.elements or {}) do
      if el.tag == "goto" then ns.Coords.Normalize(el) end
    end
  end
  if not step then ns.Map.ClearDestination(); return end
  local objective = ns.Loader.StepDisplayText(step) or "Travel to the marked location"
  local heading = step.target or step.mob
  if not heading then
    for _, el in ipairs(step.elements or {}) do
      if (el.tag == "target" or el.tag == "mob") and el.unit
          and (not el.filters or not ns.Loader or ns.Loader.PlayerMatchesFilter(el.filters)) then
        heading = el.unit; break
      end
    end
  end
  if navigation.loop then
    local points = {}
    for _, el in ipairs(navigation.elements or {}) do
      if el.tag == "goto" and el.mapID and el.x and el.y
          and (not el.radius or el.radius > 0)
          and ns.Loader.PlayerMatchesFilter(el.filters or {}) then
        points[#points + 1] = el
      end
    end
    if #points > 0 then
      if loopStep ~= navigation or loopOwner ~= ns.activeGuide then loopIndex = 1 end
      loopStep, loopOwner, loopPoints = navigation, ns.activeGuide, points
      loopIndex = math.min(loopIndex, #points)
      local point = points[loopIndex]
      ns.Map.SetDestination(point.mapID, point.x, point.y, heading or objective, objective)
      return
    end
  end
  loopStep, loopOwner, loopPoints, loopIndex = nil, nil, nil, nil
  if navigation.x and navigation.y then
    ns.Map.SetDestination(navigation.mapID, navigation.x, navigation.y, heading or objective, objective)
    -- also pull from elements
  else
    for _, el in ipairs(navigation.elements or {}) do
      if el.tag == "goto" and el.x and el.y then
        ns.Map.SetDestination(el.mapID, el.x, el.y, heading or objective, objective)
        return
      end
    end
    ns.Map.ClearDestination()
  end
end
