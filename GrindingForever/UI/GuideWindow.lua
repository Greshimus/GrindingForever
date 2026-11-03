--[[ Grinding Forever — polished guide window ]]
local ADDON, ns = ...
ns = ns or {}
ns.UI = ns.UI or {}

local frame, titleFS, activeFS, statusFS, headerTex, parchmentTex, watermark, guideHeadingFS, stepCountFS, nextHeadingFS
local stepButtons = {}
local objectiveBG, objectiveScroll, objectiveContent
local LayoutContent
local guideMenu, guideMenuRows = nil, {}
local guideSelectButton
local ASSETS = "Interface\\AddOns\\GrindingForever\\Assets\\"

local function DisplayText(value)
  if ns.Loader and ns.Loader.CleanMarkup then return ns.Loader.CleanMarkup(value) end
  value = tostring(value or "")
  value = value:gsub("|cGF_[%u%d_]+_", ""):gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
  value = value:gsub("|T.-|t", ""):gsub("|H.-|h(.-)|h", "%1")
  return value
end

local function Plain(value)
  local t = DisplayText(value)
  t = t:gsub('::%d+', ''):gsub('^%s*>>%s*', '')
  return (t:gsub('%s+', ' '):gsub('^%s+', ''):gsub('%s+$', ''))
end

local function StepSummary(step)
  if not step then return 'No active step' end
  return ns.Loader.StepDisplayText(step) or 'Continue to the next objective'
end

local function GuideDisplayName(g)
  if not g then return "Select Guide" end
  local faction = ns.Faction and tostring(ns.Faction() or ""):lower() or ""
  return DisplayText((g.displayNames and g.displayNames[faction]) or g.displayName or g.name or "Guide")
end

local function SetTextSize(fs, size)
  local font, _, flags = fs:GetFont()
  fs:SetFont(font, size, flags)
end

-- Preview filtering only: never alter the controller's step list or indices.
local function PreviewSummary(step)
  return ns.Loader.StepDisplayText(step)
end

local function PreviewButton(i)
  if stepButtons[i] then return stepButtons[i] end
  local b = CreateFrame("Button", nil, frame)
  b:Hide()
  b.bg = b:CreateTexture(nil, "BACKGROUND")
  b.bg:SetAllPoints()
  b.bg:SetTexture(ASSETS .. "GrindingForeverActiveStep")
  b.bg:SetVertexColor(1, 1, 1, 0)
  b.fs = b:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  SetTextSize(b.fs, 14)
  b.fs:SetPoint("TOPLEFT", 0, -3)
  b.fs:SetJustifyH("LEFT")
  b.fs:SetJustifyV("TOP")
  b.fs:SetWordWrap(true)
  b.fs:SetTextColor(0.30, 0.22, 0.12)
  b:SetScript("OnClick", function(self)
    if self.stepIndex then ns.Guide.SetActive(ns.activeGuide, self.stepIndex) end
  end)
  b:SetScript("OnEnter", function(self) self.bg:SetVertexColor(1, 1, 1, 0.35) end)
  b:SetScript("OnLeave", function(self) self.bg:SetVertexColor(1, 1, 1, 0) end)
  stepButtons[i] = b
  return b
end

LayoutContent = function(steps)
  local width, height = frame:GetWidth() - 64, frame:GetHeight()
  guideHeadingFS:SetWidth(math.max(1, width - stepCountFS:GetStringWidth() - 16))
  activeFS:SetWidth(width)
  activeFS:SetHeight(0)
  local textHeight = math.max(20, activeFS:GetStringHeight())
  -- Reserve room for roughly three two-line previews at the minimum size.
  local objectiveHeight = math.min(math.max(80, textHeight), math.max(80, math.min(height * 0.30, height - 376)))
  objectiveScroll:SetHeight(objectiveHeight)
  objectiveContent:SetSize(width, textHeight)
  activeFS:SetHeight(textHeight)
  objectiveScroll:SetVerticalScroll(math.min(objectiveScroll:GetVerticalScroll(), math.max(0, textHeight - objectiveHeight)))
  objectiveBG:SetHeight(objectiveHeight + 20)
  local nextTop = 111 + objectiveHeight + 24
  nextHeadingFS:ClearAllPoints()
  nextHeadingFS:SetPoint("TOPLEFT", frame, "TOPLEFT", 28, -nextTop)
  local y, count = nextTop + 25, 0
  for _, b in ipairs(stepButtons) do b:Hide(); b.stepIndex = nil end
  for idx = (ns.activeStepIndex or 1) + 1, #(steps or {}) do
    local summary = PreviewSummary(steps[idx])
    if summary then
      local b = PreviewButton(count + 1)
      b.fs:SetWidth(width)
      b.fs:SetHeight(0)
      b.fs:SetText(idx .. ". " .. summary)
      local rowHeight = math.max(28, b.fs:GetStringHeight() + 8)
      if y + rowHeight > height - 80 then break end
      b:ClearAllPoints()
      b:SetPoint("TOPLEFT", frame, "TOPLEFT", 32, -y)
      b:SetSize(width, rowHeight)
      b.stepIndex = idx
      b.bg:SetVertexColor(1, 1, 1, 0)
      b:Show()
      count = count + 1
      y = y + rowHeight + 4
    end
  end
end

local function EnsureGuideMenu()
  if guideMenu then return end
  guideMenu = CreateFrame("Frame", "GrindingForeverGuideSelector", UIParent, "BackdropTemplate")
  guideMenu:SetSize(340, 360)
  guideMenu:SetFrameStrata("DIALOG")
  guideMenu:SetClampedToScreen(true)
  guideMenu:SetBackdrop({ bgFile = ASSETS .. "GrindingForeverSidebar", edgeFile = ASSETS .. "GrindingForeverBorder", tile = false, edgeSize = 16, insets = {left=5,right=5,top=5,bottom=5} })
  guideMenu:SetBackdropColor(0.12, 0.07, 0.025, 1)
  local title = guideMenu:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  title:SetPoint("TOPLEFT", 12, -10); title:SetText("SELECT A GUIDE"); title:SetTextColor(1,0.78,0.35)
  local scroll = CreateFrame("ScrollFrame", nil, guideMenu, "UIPanelScrollFrameTemplate")
  scroll:SetPoint("TOPLEFT", 8, -32); scroll:SetPoint("BOTTOMRIGHT", -26, 8)
  local content = CreateFrame("Frame", nil, scroll); content:SetSize(290, 1); scroll:SetScrollChild(content)
  guideMenu.content, guideMenu.scroll = content, scroll
  guideMenu:SetScript("OnShow", function()
    for _, row in ipairs(guideMenuRows) do row:Hide() end
    local eligible = ns.Guide.Eligible()
    local y = -2
    for i, g in ipairs(eligible) do
      local row = guideMenuRows[i]
      if not row then
        row = CreateFrame("Button", nil, content, "BackdropTemplate")
        row:SetSize(286, 24)
        row.bg = row:CreateTexture(nil, "BACKGROUND"); row.bg:SetAllPoints(); row.bg:SetColorTexture(0.55,0.32,0.08,0.0)
        row.label = row:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall"); row.label:SetPoint("LEFT", 7, 0); row.label:SetPoint("RIGHT", -5, 0); row.label:SetJustifyH("LEFT")
        row:SetScript("OnEnter", function(self) self.bg:SetColorTexture(0.65,0.42,0.10,0.55) end)
        row:SetScript("OnLeave", function(self) self.bg:SetColorTexture(0.55,0.32,0.08, self.guide == ns.activeGuide and 0.45 or 0) end)
        row:SetScript("OnClick", function(self) ns.Guide.SetActive(self.guide, 1); guideMenu:Hide(); ns.UI.Refresh() end)
        guideMenuRows[i] = row
      end
      row:ClearAllPoints(); row:SetPoint("TOPLEFT", content, "TOPLEFT", 0, y)
      row.label:SetText(GuideDisplayName(g)); row.label:SetTextColor(0.98,0.88,0.67)
      row.guide = g; row.bg:SetColorTexture(0.55,0.32,0.08, g == ns.activeGuide and 0.45 or 0); row:Show()
      y = y - 25
    end
    content:SetHeight(math.max(1, -y + 4))
  end)
  guideMenu:Hide()
end


local function MakeBtn(parent, text, w, h, onClick)
  local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
  b:SetSize(w, h)
  if b.SetBackdrop then
    b:SetBackdrop({
      bgFile = ASSETS .. "GrindingForeverButtonNormal",
      edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
      tile = false, edgeSize = 8,
      insets = { left = 2, right = 2, top = 2, bottom = 2 },
    })
    b:SetBackdropColor(0.85, 0.68, 0.40, 0.95)
  end
  local fs = b:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
  fs:SetAllPoints()
  fs:SetText(text)
  fs:SetTextColor(1, 0.92, 0.75)
  b.fs = fs
  b:SetScript("OnClick", onClick)
  b:SetScript("OnEnter", function(self)
    if self.SetBackdropColor then self:SetBackdropColor(0.95, 0.82, 0.55, 1) end
  end)
  b:SetScript("OnLeave", function(self)
    if self.SetBackdropColor then self:SetBackdropColor(0.85, 0.68, 0.40, 0.95) end
  end)
  return b
end

local function Ensure()
  if frame then return end
  frame = CreateFrame("Frame", "GrindingForeverGuideFrame", UIParent, "BackdropTemplate")
  frame:SetSize(480, 460)
  frame:SetResizable(true)
  if frame.SetResizeBounds then frame:SetResizeBounds(480, 460, 850, 720) end
  frame:SetPoint("CENTER", UIParent, "CENTER", 0, 80)
  frame:SetMovable(true)
  frame:EnableMouse(true)
  -- Dragging is restricted to the title bar below.
  -- The title bar has its own drag handler.
  frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p,_,_,x,y = self:GetPoint(1)
    if ns.db then ns.db.framePoint = { p, x, y } end
  end)
  if frame.SetBackdrop then
    frame:SetBackdrop({
      bgFile = ASSETS .. "GrindingForeverSidebar",
      edgeFile = ASSETS .. "GrindingForeverBorder",
      tile = false, edgeSize = 24,
      insets = { left = 8, right = 8, top = 8, bottom = 8 },
    })
    frame:SetBackdropColor(1, 1, 1, 1)
  end

  parchmentTex = frame:CreateTexture(nil, "BACKGROUND")
  parchmentTex:SetTexture(ASSETS .. "GrindingForeverParchment")
  parchmentTex:SetPoint("TOPLEFT", 12, -49)
  parchmentTex:SetPoint("BOTTOMRIGHT", -12, 52)
  parchmentTex:SetVertexColor(1, 1, 1, 1)

  headerTex = frame:CreateTexture(nil, "ARTWORK")
  headerTex:SetTexture(ASSETS .. "GrindingForeverHeader")
  headerTex:SetPoint("TOPLEFT", 8, -8)
  headerTex:SetPoint("TOPRIGHT", -8, -8)
  headerTex:SetHeight(36)

  watermark = frame:CreateTexture(nil, "BACKGROUND")
  watermark:SetTexture(ASSETS .. "GrindingForeverWatermark")
  watermark:SetSize(160, 160)
  watermark:SetPoint("BOTTOMRIGHT", -24, 40)
  watermark:SetVertexColor(0.35, 0.20, 0.08, 0.28)

  titleFS = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  titleFS:SetPoint("TOP", 0, -15)
  titleFS:SetText("|cffc49a58GRINDING FOREVER|r")

  local close = CreateFrame("Button", nil, frame)
  close:SetSize(24, 24)
  close:SetPoint("TOPRIGHT", -14, -14)
  local ct = close:CreateTexture(nil, "ARTWORK")
  ct:SetAllPoints()
  ct:SetTexture(ASSETS .. "GrindingForeverClose")
  close:SetScript("OnClick", function()
    -- This button belongs to the original window, independent of active presentation.
    frame:Hide()
    if guideMenu then guideMenu:Hide() end
    if ns.db then ns.db.showWindow = false end
  end)

  guideHeadingFS = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  guideHeadingFS:SetPoint("TOPLEFT", 28, -65)
  guideHeadingFS:SetTextColor(0.33, 0.20, 0.08)
  stepCountFS = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  stepCountFS:SetPoint("TOPRIGHT", -28, -67)
  stepCountFS:SetTextColor(0.40, 0.27, 0.12)
  nextHeadingFS = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  nextHeadingFS:SetPoint("TOPLEFT", 28, -230)
  nextHeadingFS:SetText("UP NEXT")
  nextHeadingFS:SetTextColor(0.42, 0.27, 0.12)

  objectiveBG = frame:CreateTexture(nil, "ARTWORK")
  objectiveBG:SetTexture("Interface\\\\Buttons\\\\WHITE8X8")
  objectiveBG:SetVertexColor(0.96, 0.84, 0.63, 0.30)
  objectiveBG:SetPoint("TOPLEFT", 25, -100)
  objectiveBG:SetPoint("TOPRIGHT", -25, -100)
  objectiveBG:SetHeight(118)
  objectiveScroll = CreateFrame("ScrollFrame", nil, frame)
  objectiveScroll:SetPoint("TOPLEFT", 32, -111)
  objectiveScroll:SetPoint("RIGHT", frame, "RIGHT", -32, 0)
  objectiveContent = CreateFrame("Frame", nil, objectiveScroll)
  objectiveScroll:SetScrollChild(objectiveContent)
  objectiveScroll:EnableMouseWheel(true)
  objectiveScroll:SetScript("OnMouseWheel", function(self, delta)
    self:SetVerticalScroll(math.max(0, math.min(self:GetVerticalScroll() - delta * 24,
      math.max(0, objectiveContent:GetHeight() - self:GetHeight()))))
  end)
  activeFS = objectiveContent:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
  SetTextSize(activeFS, 17)
  activeFS:SetPoint("TOPLEFT")
  activeFS:SetJustifyH("LEFT")
  activeFS:SetWordWrap(true)
  activeFS:SetHeight(105)
  activeFS:SetJustifyV("TOP")
  activeFS:SetTextColor(0.25, 0.18, 0.10)


  statusFS = frame:CreateFontString(nil, "OVERLAY", "GameFontDisableSmall")
  statusFS:SetPoint("BOTTOMRIGHT", -24, 57)
  statusFS:SetTextColor(0.45, 0.35, 0.22)

  local footer = CreateFrame("Frame", nil, frame)
  footer:SetPoint("BOTTOMLEFT", 15, 13)
  footer:SetPoint("BOTTOMRIGHT", -15, 13)
  footer:SetHeight(26)
  local controls = {
    {"< Guide", 54, function() ns.Guide.Prev() end},
    {"Guide >", 54, function() ns.Guide.Next() end},
    {"< Step", 49, function() ns.Guide.StepPrev() end},
    {"Step >", 49, function() ns.Guide.StepNext() end},
    {"Arrow", 45, function() ns.Map.ToggleArrow() end},
    {"WP", 31, function()
      ns.Map.SetCurrentWaypoint()
    end},
    {"Tgt", 31, function()
      if ns.Targeting then ns.Targeting.Refresh() end
      ns.Print("Target information is unavailable in this alpha.")
    end},
  }
  local previous
  for _, item in ipairs(controls) do
    local b = MakeBtn(footer, item[1], item[2], 24, item[3])
    if previous then b:SetPoint("LEFT", previous, "RIGHT", 3, 0)
    else b:SetPoint("LEFT", footer, "LEFT", 0, 0) end
    previous = b
  end
  guideSelectButton = MakeBtn(footer, "Guides", 58, 24, function()
    EnsureGuideMenu()
    guideMenu:ClearAllPoints()
    guideMenu:SetPoint("BOTTOMLEFT", guideSelectButton, "TOPLEFT", 0, 6)
    if guideMenu:IsShown() then guideMenu:Hide() else guideMenu:Show(); guideMenu:Raise() end
  end)
  guideSelectButton:SetPoint("LEFT", previous, "RIGHT", 3, 0)

  local titleDrag = CreateFrame("Frame", nil, frame)
  titleDrag:SetPoint("TOPLEFT", 14, -9)
  titleDrag:SetPoint("TOPRIGHT", -43, -9)
  titleDrag:SetHeight(31)
  titleDrag:EnableMouse(true)
  titleDrag:RegisterForDrag("LeftButton")
  titleDrag:SetScript("OnDragStart", function() frame:StartMoving() end)
  titleDrag:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
    local p, _, _, x, y = frame:GetPoint(1)
    if ns.db then ns.db.framePoint = {p, x, y} end
  end)

  -- Explicit bottom-right diagonal resize handle.
  local grip = CreateFrame("Button", nil, frame)
  grip:SetSize(24, 24)
  grip:SetPoint("BOTTOMRIGHT", -3, 3)
  grip:SetFrameLevel(frame:GetFrameLevel() + 5)
  local gripText = grip:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
  gripText:SetAllPoints()
  gripText:SetText("◢")
  gripText:SetTextColor(1, 0.79, 0.38)
  grip:RegisterForDrag("LeftButton")
  grip:SetScript("OnDragStart", function() frame:StartSizing("BOTTOMRIGHT") end)
  grip:SetScript("OnDragStop", function()
    frame:StopMovingOrSizing()
    if ns.db then ns.db.frameSize = {frame:GetWidth(), frame:GetHeight()} end
  end)
  grip:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Drag to resize Grinding Forever")
    GameTooltip:Show()
  end)
  grip:SetScript("OnLeave", function() GameTooltip:Hide() end)
  if ns.db and ns.db.frameSize then
    frame:SetSize(math.min(850, math.max(480, ns.db.frameSize[1] or 480)), math.min(720, math.max(460, ns.db.frameSize[2] or 460)))
  end
  frame:SetScript("OnSizeChanged", function()
    local _, steps = ns.Guide.CurrentStep()
    LayoutContent(steps)
  end)
end

function ns.UI.Refresh()
  if ns.UI.Preview and ns.UI.Preview.enabled and ns.UI.Preview.Refresh() then return end
  Ensure()
  local g = ns.activeGuide
  local st, steps = ns.Guide.CurrentStep()
  if not g then
    guideHeadingFS:SetText("No guide selected")
    stepCountFS:SetText("")
    activeFS:SetText("Retail catalog is empty. No guides are enabled.")
    statusFS:SetText("0 guides")
    for _, b in ipairs(stepButtons) do
      b.fs:SetText(""); b.stepIndex = nil; b.bg:SetVertexColor(1,1,1,0)
    end
    LayoutContent({})
    ns.UI.RenderedSelection = { title = "No guide selected" }
    return
  end
  guideHeadingFS:SetText(GuideDisplayName(g))
  stepCountFS:SetText(string.format("Step %d / %d", ns.activeStepIndex or 1, #(steps or {})))
  local lines = { StepSummary(st) }
  if st then
    for _, helper in ipairs(ns.Guide.ActiveHelpers(g, st)) do
      if not helper.hidewindow then
        local summary = ns.Loader.StepDisplayText(helper)
        if summary then lines[#lines + 1] = summary end
      end
    end
    for _, el in ipairs(st.elements or {}) do
      if el.tag == 'accept' or el.tag == 'turnin' then
        local detail = Plain(el.text or '')
        if detail ~= '' then
          local prefix = el.tag == 'accept' and 'Accept: ' or 'Turn in: '
          if not StepSummary(st):find(detail, 1, true) then lines[#lines + 1] = prefix .. detail end
        end
      end
    end
    if st.x and st.y then
      lines[#lines + 1] = string.format("Location: %.2f, %.2f", st.x, st.y)
    end
  end
  activeFS:SetText(table.concat(lines, "\n"))
  objectiveScroll:SetVerticalScroll(0)
  LayoutContent(steps)
  local elig = ns.Guide.Eligible()
  statusFS:SetText(string.format("%d available  ·  %s  ·  L%d", #elig, ns.Faction(), ns.Level()))
  if guideSelectButton then guideSelectButton.fs:SetText("Guides") end
  -- Record only a completed render, so diagnostics can identify a stale window.
  ns.UI.RenderedSelection = { guide = g, index = ns.activeStepIndex, title = StepSummary(st) }
end

function ns.UI.Show()
  if ns.UI.Showcase and ns.UI.Showcase.active then ns.UI.Showcase.Show(); return end
  if ns.UI.Preview and ns.UI.Preview.enabled then ns.UI.Preview.Show(); return end
  Ensure()
  if ns.db and ns.db.framePoint then
    local p = ns.db.framePoint
    frame:ClearAllPoints()
    frame:SetPoint(p[1] or "CENTER", UIParent, p[1] or "CENTER", p[2] or 0, p[3] or 80)
  end
  frame:Show()
  ns.UI.Refresh()
  if ns.db then ns.db.showWindow = true end
end

function ns.UI.Hide()
  if ns.UI.Showcase and ns.UI.Showcase.active then ns.UI.Showcase.Hide(); return end
  if ns.UI.Preview and ns.UI.Preview.enabled then ns.UI.Preview.Hide(); return end
  if frame then frame:Hide() end
  if ns.db then ns.db.showWindow = false end
end

function ns.UI.Toggle()
  if ns.UI.Showcase then ns.UI.Showcase.Toggle(); return end
  if ns.UI.Preview and ns.UI.Preview.enabled then ns.UI.Preview.ToggleVisibility(); return end
  Ensure()
  if frame:IsShown() then ns.UI.Hide() else ns.UI.Show() end
end

-- Presentation switching must not call Show/Hide's saved visibility setters.
function ns.UI.SetCompactPresentationVisible(visible)
  if visible then Ensure(); frame:Show(); ns.UI.Refresh()
  else
    if frame then frame:Hide() end
    if guideMenu then guideMenu:Hide() end
  end
end

ns.RegisterMessage("GF_STEP_CHANGED", function() ns.UI.Refresh() end)
ns.RegisterMessage("GF_LOGIN", function()
  if ns.UI.Showcase and ns.UI.Showcase.Login and ns.UI.Showcase.Login() then return end
  if ns.db and ns.db.showWindow ~= false then ns.UI.Show() end
end)

local mini
local function EnsureMini()
  if mini then return end
  local ldb = LibStub and LibStub("LibDataBroker-1.1", true)
  local dbicon = LibStub and LibStub("LibDBIcon-1.0", true)
  if ldb and dbicon then
    ns.db = ns.db or {}
    ns.db.minimap = ns.db.minimap or { hide = false }
    local launcher = ldb:NewDataObject("GrindingForever", {
      type = "launcher",
      text = "Grinding Forever",
      icon = "Interface\\AddOns\\GrindingForever\\Assets\\GrindingForeverDragonCrest",
      iconCoords = {0, .5, 0, 1}, -- Square dragon-head region of the 2:1 cutout.
      OnClick = function(_, button)
        if button == "RightButton" then
          ns.UI.Show()
        else
          ns.UI.Toggle()
        end
      end,
      OnTooltipShow = function(tooltip)
        tooltip:AddLine("Grinding Forever", 0.77, 0.60, 0.35)
        tooltip:AddLine("Left-click: toggle guide", 0.9, 0.9, 0.9)
        tooltip:AddLine("Drag: move button around minimap", 0.9, 0.9, 0.9)
      end,
    })
    dbicon:Register("GrindingForever", launcher, ns.db.minimap)
    mini = true -- LibDBIcon owns the one ringed, draggable minimap button.
    return
  end

  -- Fallback for clients without LibDBIcon: keep one ringed, draggable button.
  if not Minimap then return end
  mini = CreateFrame("Button", "GrindingForeverMinimapButton", Minimap)
  mini:SetSize(32, 32)
  mini:SetFrameStrata("MEDIUM")
  mini:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -8, 0)
  mini:SetMovable(true)
  mini:RegisterForDrag("LeftButton")
  mini:SetScript("OnDragStart", function(self) self:StartMoving() end)
  mini:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p, _, rp, x, y = self:GetPoint(1)
    ns.db = ns.db or {}
    ns.db.minimap = ns.db.minimap or {}
    ns.db.minimap.point = { p, rp, x, y }
  end)
  local t = mini:CreateTexture(nil, "BACKGROUND")
  t:SetAllPoints(); t:SetTexture(ASSETS .. "GrindingForeverDragonCrest"); t:SetTexCoord(0,.5,0,1)
  local ring = mini:CreateTexture(nil, "OVERLAY")
  ring:SetAllPoints(); ring:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
  mini:SetScript("OnClick", function() ns.UI.Toggle() end)
  mini:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    GameTooltip:AddLine("Grinding Forever", 0.77, 0.60, 0.35)
    GameTooltip:AddLine("Left-click: toggle guide", 0.9, 0.9, 0.9)
    GameTooltip:AddLine("Drag: move button", 0.9, 0.9, 0.9)
    GameTooltip:Show()
  end)
  mini:SetScript("OnLeave", function() GameTooltip:Hide() end)
end
ns.RegisterMessage("GF_LOADED", EnsureMini)
