local _, ns = ...
local N, W, E = ns.NormalUI, ns.WindowWorkflow, ns.Forever
N.fieldGuideMinimumHeight = 560
local Showcase = ns.UI.Showcase
local panel, recipeButton, farmButton, dungeonButton
local hidden = false


local function showRecipes()
    if panel then
        panel:SetShown(not panel:IsShown())
        return
    end
    panel = CreateFrame("Frame", nil, UIParent)
    panel:SetSize(510, 528)
    panel:SetPoint("CENTER")
    panel:SetFrameStrata("DIALOG")
    panel:EnableMouse(true)
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)
    local assets = "Interface\\AddOns\\GrindingForever\\Media\\"
    local search = CreateFrame("EditBox", nil, panel, "InputBoxTemplate")
    search:SetSize(145, 28)
    search:SetPoint("TOPLEFT", 22, -44)
    search:SetAutoFocus(false)
    local mine = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
    mine:SetPoint("LEFT", search, "RIGHT", 10, 0)
    local label = N.MakeText(panel, 12, "", true)
    label:SetPoint("LEFT", mine, "RIGHT", 1, 0)
    label:SetText("My Professions")
    label:SetTextColor(.18, .11, .06)
    local profession, continent, chosenZone
    local function mapContinent(mapID)
        for _ = 1, 8 do
            local info = mapID and E.Call(C_Map and C_Map.GetMapInfo, mapID)
            if not info then return end
            if info.mapType == (Enum and Enum.UIMapType and Enum.UIMapType.Continent or 2) then return info.name end
            if not info.parentMapID or info.parentMapID <= 0 or info.parentMapID == mapID then return end
            mapID = info.parentMapID
        end
    end
    local locationContinents, availableContinents, availableZones = {}, {}, {}
    local trainedExpanded = true
    local catalog = ns.RecipeCatalog
    local professionButton = N.MakeButton(panel, "All Professions", 155)
    professionButton:SetPoint("TOPRIGHT", -18, -45)
    local continentButton = N.MakeButton(panel, "All Continents", 156)
    continentButton:SetPoint("TOPLEFT", 18, -76)
    local zoneButton = N.MakeButton(panel, "Current Zone", 156)
    zoneButton:SetPoint("LEFT", continentButton, "RIGHT", 7, 0)
    local menu = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    menu:SetPoint("TOPRIGHT", professionButton, "BOTTOMRIGHT", 0, -2)
    menu:SetWidth(155)
    menu:SetFrameLevel(panel:GetFrameLevel() + 12)
    menu:EnableMouse(true)
    menu:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", edgeSize = 14 })
    menu:SetBackdropColor(.10, .06, .035, 1)
    menu:SetBackdropBorderColor(.75, .51, .26)
    menu:Hide()
    local scope = N.MakeText(panel, 12, "", true)
    scope:SetPoint("TOPLEFT", 18, -118)
    scope:SetTextColor(.24, .16, .10)
    local viewport = CreateFrame("Frame", nil, panel)
    viewport:SetPoint("TOPLEFT", 18, -145)
    viewport:SetPoint("BOTTOMRIGHT", -37, 59)
    local rows, buttons, rowOffset = {}, {}, 0
    local pageSize, syncScroll = 8
    local expanded, selected
    local recipes, revision
    local known = {}
    local status = panel:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    status:SetPoint("BOTTOM", 0, 22)
    status:SetTextColor(.24, .16, .10)
    local feedback = panel:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    feedback:SetPoint("BOTTOMLEFT", 18, 45)
    feedback:SetPoint("BOTTOMRIGHT", -18, 45)
    feedback:SetJustifyH("LEFT")
    feedback:SetTextColor(.24, .16, .10)
    local function recipeIcon(recipe)
        local itemID = recipe.productID or recipe.learnableItemID
        local icon = itemID and E.Call(C_Item and C_Item.GetItemIconByID or GetItemIcon, itemID)
        if not E.Public(icon) then icon = nil end
        if not icon and recipe.spellID then
            icon = E.Call(C_Spell and C_Spell.GetSpellTexture or GetSpellTexture, recipe.spellID)
        end
        return E.Public(icon) and icon or "Interface\\Icons\\INV_Scroll_03"
    end
    local function draw()
        rowOffset = math.min(rowOffset, math.max(0, #rows - pageSize))
        for i, button in ipairs(buttons) do
            local row = i <= pageSize and rows[rowOffset + i]
            button.record = row
            if row then
                local loc, recipe = row.location, row.recipe
                button.selected = loc and selected == tostring(recipe.key) .. "/" .. catalog.SourceKey(loc)
                button.fill:SetColorTexture(.30, .56, .45, button.selected and .34 or 0)
                button.icon:SetShown(recipe ~= nil)
                button.detail:SetShown(recipe ~= nil)
                if row.heading then
                    button.label:SetText(row.heading)
                    button.disclosure:SetShown(row.trained == true)
                    button.disclosure:SetRotation(trainedExpanded and math.pi / 2 or 0)
                elseif loc then
                    button.disclosure:Hide()
                    button.icon:SetTexture(loc.source == "Vendor" and "Interface\\Icons\\INV_Misc_Coin_01"
                        or loc.source == "Trainer" and "Interface\\Icons\\INV_Misc_Book_09"
                        or loc.source == "Drop" and "Interface\\Icons\\Ability_Creature_Cursed_02"
                        or "Interface\\Icons\\INV_Misc_Map_01")
                    button.label:SetText(loc.name or "Unknown source")
                    button.detail:SetText((loc.source or "Source") .. " / " .. (loc.zone or "Unknown zone")
                        .. (catalog.HasWaypoint(loc) and "" or " / No waypoint"))
                else
                    button.disclosure:SetShown(row.count > 0)
                    button.disclosure:SetRotation(expanded == recipe.key and math.pi / 2 or 0)
                    button.icon:SetTexture(recipeIcon(recipe))
                    button.label:SetText(recipe.name)
                    button.detail:SetText((recipe.profession or "Recipe") .. (recipe.skill and recipe.skill > 0 and (" " .. recipe.skill) or "")
                        .. (row.count > 0 and (" / " .. row.count .. " sources") or (row.trained and "" or " / Source unrecorded")))
                end
                button.label:ClearAllPoints()
                local indent = row.heading and 25 or loc and 61 or 45
                button.label:SetPoint("TOPLEFT", indent, row.heading and -8 or -2)
                button.label:SetPoint("TOPRIGHT", -9, row.heading and -8 or -2)
                button.icon:ClearAllPoints()
                button.icon:SetPoint("LEFT", loc and 32 or 16, 0)
                button.detail:ClearAllPoints()
                button.detail:SetPoint("BOTTOMLEFT", indent, 4)
                button.detail:SetPoint("BOTTOMRIGHT", -9, 4)
                button:Show()
            else
                button:Hide()
            end
        end
        status:SetText(#rows == 0 and "No matching sources in this scope" or
            string.format("%d–%d / %d", rowOffset + 1, math.min(#rows, rowOffset + pageSize), #rows))
        if syncScroll then syncScroll() end
    end
    local function refresh(keepPage)
        local query = search:GetText():match("^%s*(.-)%s*$"):lower()
        if query == "" then query = nil end
        local state = E.state or E.Snapshot()
        local mapID = E.Position().mapID
        local info = mapID and E.Call(C_Map and C_Map.GetMapInfo, mapID)
        local currentZone = info and info.name
        local global = query or profession or mine:GetChecked() or continent
        local zone = chosenZone
        if zone == "Current Zone" or (not zone and not global) then zone = currentZone end
        if zone == "All Zones" then zone = nil end
        scope:SetText(zone and ("Browsing " .. zone) or (continent and ("Browsing " .. continent) or "Browsing All Zones"))
        if not recipes or revision ~= catalog.revision then
            recipes = catalog.Browse()
            revision = catalog.revision
            known, locationContinents, availableContinents, availableZones = {}, {}, {}, {}
        end
        rows = {}
        local groups, listed, trained = {}, {}, {}
        local onlyMine = mine:GetChecked()
        for _, recipe in ipairs(recipes) do
            if recipe.profession ~= "Jewelcrafting" and E.Eligible(recipe, state)
                and ((onlyMine and state.skills[recipe.profession]) or (not onlyMine and (not profession or recipe.profession == profession)))
                and (not query or recipe.name:lower():find(query, 1, true)) then
                local sources = {}
                for _, loc in ipairs(recipe.locations or {}) do
                    local locContinent
                    if continent then
                        local map = loc.mapID or loc.zone
                        if map and locationContinents[map] == nil then locationContinents[map] = mapContinent(loc.mapID) or false end
                        locContinent = map and locationContinents[map]
                    end
                    if E.Eligible(loc, state) and (not continent or locContinent == continent)
                        and (not zone or loc.zone == zone or (zone == currentZone and loc.mapID == mapID))
                        and (global or loc.source ~= "Trainer") then
                        sources[#sources + 1] = loc
                    end
                end
                local key = recipe.key
                if known[key] == nil then known[key] = state.skills[recipe.profession] and E.Known(recipe) == true or false end
                if known[key] or #sources > 0 or (global and not zone and not continent) then
                    groups[recipe] = sources
                    local list = known[key] and trained or listed
                    list[#list + 1] = recipe
                end
            end
        end
        local function append(list)
            table.sort(list, function(a, b) return a.name < b.name end)
            for _, recipe in ipairs(list) do
                local sources = groups[recipe]
                rows[#rows + 1] = { recipe = recipe, count = #sources, trained = known[recipe.key] }
                if expanded == recipe.key then
                    table.sort(sources, function(a, b)
                        return (a.zone or "") .. (a.name or "") < (b.zone or "") .. (b.name or "")
                    end)
                    for _, loc in ipairs(sources) do
                        rows[#rows + 1] = { recipe = recipe, location = loc }
                    end
                end
            end
        end
        if #listed + #trained == 1 and expanded == nil then
            expanded = (listed[1] or trained[1]).key
        end
        append(listed)
        if #trained > 0 then
            rows[#rows + 1] = { heading = "Trained Recipes (" .. #trained .. ")", trained = true }
            if trainedExpanded then append(trained) end
        end
        if keepPage ~= true then rowOffset = 0 end
        draw()
    end
    for i = 1, 22 do
        local b = CreateFrame("Button", nil, viewport)
        b:SetHeight(36)
        b.fill = b:CreateTexture(nil, "BACKGROUND")
        b.fill:SetAllPoints()
        b:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
        b:GetHighlightTexture():SetVertexColor(.8, .6, .3, .16)
        b.label = N.MakeText(b, 14, "", true)
        b.label:ClearAllPoints()
        b.label:SetPoint("TOPLEFT", 12, -2)
        b.label:SetPoint("TOPRIGHT", -12, -2)
        b.label:SetJustifyH("LEFT")
        b.label:SetTextColor(.17, .10, .06)
        b.label:SetWordWrap(false)
        b.icon = b:CreateTexture(nil, "ARTWORK")
        b.icon:SetSize(24, 24)
        b.disclosure = b:CreateTexture(nil, "ARTWORK")
        b.disclosure:SetSize(10, 10)
        b.disclosure:SetPoint("LEFT", 4, 0)
        b.disclosure:SetTexture(assets .. "ControlTriangleRight")
        b.detail = N.MakeText(b, 11, "", true)
        b.detail:SetTextColor(.34, .22, .12)
        b.detail:SetJustifyH("LEFT")
        b.detail:SetWordWrap(false)
        b:SetPoint("TOPLEFT", 0, -(i - 1) * 37)
        b:SetPoint("TOPRIGHT", 0, -(i - 1) * 37)
        buttons[i] = b
        b:SetScript("OnEnter", function(self)
            local r = self.record and self.record.recipe
            if not r then return end
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            local itemID = r.learnableItemID or r.productID
            if itemID then
                E.Call(GameTooltip.SetHyperlink, GameTooltip, "item:" .. itemID)
            elseif r.spellID then
                E.Call(GameTooltip.SetSpellByID, GameTooltip, r.spellID)
            end
            local loc = self.record.location
            if loc then
                GameTooltip:AddLine(loc.name or "Acquisition Source", .92, .77, .46)
                if loc.requirement then GameTooltip:AddLine(loc.requirement, .92, .77, .46, true) end
                if catalog.HasWaypoint(loc) then
                    GameTooltip:AddLine(("%s %.1f, %.1f"):format(loc.zone or "Map", loc.x, loc.y), .92, .77, .46)
                end
                if type(loc.price) == "number" and GetCoinTextureString then
                    GameTooltip:AddLine(GetCoinTextureString(loc.price), .92, .77, .46)
                end
            end
            GameTooltip:Show()
        end)
        b:SetScript("OnLeave", function() GameTooltip:Hide() end)
        b:SetScript("OnClick", function(self)
            if not self.record then return end
            if self.record.heading then
                trainedExpanded = not trainedExpanded
                refresh(true)
                return
            end
            local r = self.record.recipe
            local loc = self.record.location
            if not loc then
                if self.record.count == 0 then
                    if self.record.trained then return end
                    feedback:SetText("No acquisition source is recorded for " .. r.name .. ".")
                    return
                end
                feedback:SetText("")
                if expanded == r.key then expanded = false else expanded = r.key end
                refresh(true)
                return
            end
            if not catalog.HasWaypoint(loc) then
                feedback:SetText((loc.name or "Source") .. " has no recorded waypoint.")
                return
            end
            local compass = ns.NavigationCompass
            local key = "recipe-browser"
            compass.pins[key] = { key = key, name = loc.name or r.name, zone = loc.zone, location = loc,
                icon = "Interface\\AddOns\\GrindingForever\\Media\\RecipePin", pin = true }
            compass.age = 1
            local pinned = catalog.PinWorldMap(loc)
            selected = tostring(r.key) .. "/" .. catalog.SourceKey(loc)
            local result = pinned and "World Map" or "World Map pin unavailable"
            result = result .. (compass.Enabled() and " / Compass" or " / Compass Off")
            feedback:SetText((loc.name or loc.zone or r.name) .. "  ·  " .. result)
            draw()
        end)
    end
    local professions = { "All Professions" }
    local professionNames = { ["All Professions"] = true }
    for _, name in ipairs(ns.Forever.professions or catalog.professions) do
        if name ~= "Jewelcrafting" and not professionNames[name] then
            professions[#professions + 1] = name
            professionNames[name] = true
        end
    end
    local options, selectOption, offset, menuOwner = {}, nil, 0, nil
    local optionRows = {}
    local function drawMenu()
        local count = math.min(12, #options)
        menu:SetHeight(count * 22 + 8)
        for i, option in ipairs(optionRows) do
            local value = i <= count and options[i + offset]
            option.value = value
            option:SetShown(value ~= false and value ~= nil)
            if value then option.label:SetText(value) end
        end
    end
    for i = 1, 12 do
        local option = N.PlainOption(N.MakeButton(menu, "", 147))
        option:SetHeight(22)
        option:SetPoint("TOPLEFT", 4, -4 - (i - 1) * 22)
        option:SetScript("OnClick", function(self)
            menu:Hide()
            selectOption(self.value)
        end)
        optionRows[i] = option
    end
    menu:EnableMouseWheel(true)
    menu:SetScript("OnMouseWheel", function(_, delta)
        offset = math.max(0, math.min(math.max(0, #options - 12), offset - delta))
        drawMenu()
    end)
    local function openMenu(owner, values, callback)
        if menu:IsShown() and menuOwner == owner then menu:Hide(); return end
        options, selectOption, offset, menuOwner = values, callback, 0, owner
        menu:ClearAllPoints()
        menu:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, -2)
        drawMenu()
        menu:Show()
    end
    local function resetFilters()
        expanded = nil
        feedback:SetText("")
        refresh()
    end
    local function geography()
        if next(availableZones) then return end
        for _, recipe in ipairs(recipes) do
            for _, loc in ipairs(recipe.locations or {}) do
                local map = loc.mapID or loc.zone
                if map and locationContinents[map] == nil then locationContinents[map] = mapContinent(loc.mapID) or false end
                local area = map and locationContinents[map]
                if area then availableContinents[area] = true end
                if loc.zone then availableZones[loc.zone] = area or availableZones[loc.zone] or false end
            end
        end
    end
    continentButton:SetScript("OnClick", function(self)
        geography()
        local values = {}
        for name in pairs(availableContinents) do values[#values + 1] = name end
        table.sort(values)
        table.insert(values, 1, "All Continents")
        openMenu(self, values, function(value)
            continent = value ~= "All Continents" and value or nil
            chosenZone = continent and "All Zones" or nil
            continentButton.label:SetText(value)
            zoneButton.label:SetText(chosenZone or "Current Zone")
            resetFilters()
        end)
    end)
    zoneButton:SetScript("OnClick", function(self)
        geography()
        local values = {}
        for name, area in pairs(availableZones) do
            if not continent or continent == area then values[#values + 1] = name end
        end
        table.sort(values)
        table.insert(values, 1, "All Zones")
        if not continent then table.insert(values, 1, "Current Zone") end
        openMenu(self, values, function(value)
            chosenZone = value
            zoneButton.label:SetText(value)
            resetFilters()
        end)
    end)
    professionButton:SetScript("OnClick", function(self)
        if mine:GetChecked() then return end
        openMenu(self, professions, function(value)
            profession = value ~= "All Professions" and value or nil
            professionButton.label:SetText(value)
            resetFilters()
        end)
    end)
    local function resizeRows()
        pageSize = math.max(1, math.min(#buttons, math.floor((panel:GetHeight() - 204) / 37)))
        draw()
    end
    syncScroll = N.PanelScroll(panel, viewport, function() return rowOffset end,
        function(value) rowOffset = math.floor(value + .5); draw() end,
        function() return math.max(0, #rows - pageSize) end, 3)
    N.PanelChrome(panel, "Recipes & Vendors", 500, 430, resizeRows)
    panel:SetScript("OnShow", refresh)
    panel:SetScript("OnHide", function()
        recipes, rows, known = nil, {}, {}
        menu:Hide()
        local owner = GameTooltip:GetOwner()
        if owner and owner.GetParent and owner:GetParent() == viewport then GameTooltip:Hide() end
    end)
    search:SetScript("OnEnterPressed", function(self) self:ClearFocus(); refresh() end)
    local pendingSearch
    search:SetScript("OnTextChanged", function()
        if pendingSearch then pendingSearch:Cancel() end
        pendingSearch = C_Timer.NewTimer(.2, function()
            pendingSearch = nil
            if panel:IsShown() then refresh() end
        end)
    end)
    mine:SetScript("OnClick", function()
        menu:Hide()
        local onlyMine = mine:GetChecked()
        professionButton.label:SetText(onlyMine and "My Professions" or profession or "All Professions")
        professionButton:SetAlpha(onlyMine and .55 or 1)
        resetFilters()
    end)
    refresh()
end

local compass = ns.NavigationCompass
local collect = compass.Collect
function compass.Collect(...)
    collect(...)
    if ns.FarmingPlanner.route and compass.targets[1] and compass.targets[1].active then
        table.remove(compass.targets, 1)
    end
end

local layout, legacySetView = W.Layout, W.SetView
local applyMode

-- Field Preview has a separate browser and uses the client's world map.
W.FitMap = function() end
N.UpdateMapView = function() end
N.RefreshRecipes = function() end

function W.Layout(...)
    local result = layout(...)
    local r = N.root
    if not r or not recipeButton then return result end
    if r.journeySwitch then r.journeySwitch:Hide() end
    if r.paceSwitch then r.paceSwitch:Hide() end
    r.workflowGrip:Hide()
    if r.recipeCompactGrip then r.recipeCompactGrip:Hide() end
    if r.compactSwap31 then r.compactSwap31:Hide() end
    r.panels[2]:Hide()
    r.panels[3]:Hide()
    local steps = r.panels[1]
    local width = steps:GetWidth() - 68

    recipeButton:SetSize((width - 12) * .48, 36)
    farmButton:SetSize((width - 12) * .25, 36)
    dungeonButton:SetSize((width - 12) * .27, 36)
    return result
end
N.WorkflowLayout = W.Layout

function W.SetView()
    applyMode()
    return true
end

applyMode = function()
    if hidden then
        if panel then panel:Hide() end
        Showcase.Hide()
        return
    end

    local r = N.root
    if not r then Showcase.Show(); r = N.root end
    if not recipeButton then
        recipeButton = N.MakeButton(r.panels[1], "Recipes & Vendors", 165, showRecipes)
        farmButton = N.MakeButton(r.panels[1], "Farming", 90, function()
            local button = N.farmButton
            local click = button and button:GetScript("OnClick")
            if click then click(button, "LeftButton") end
        end)
        dungeonButton = N.MakeButton(r.panels[1], "Dungeons", 90, ns.ToggleDungeonBrowser)
        dungeonButton:SetPoint("LEFT", farmButton, "RIGHT", 6, 0)
        farmButton:SetPoint("LEFT", recipeButton, "RIGHT", 6, 0)
        recipeButton:SetPoint("TOPLEFT", r.panels[1], "TOPLEFT", 28, -48)
    end
    if N.mode ~= "compact" or W.view ~= "steps" or W.recipeCompact then
        legacySetView("steps")
    end
    Showcase.Show()
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function()
    C_Timer.After(0, function()
        applyMode()
        local button = _G.GrindingForeverMinimapButton
        if button then
            local click = button:GetScript("OnClick")
            button:SetScript("OnClick", function(self, mouseButton)
                if mouseButton == "LeftButton" then
                    hidden = not hidden
                    applyMode()
                elseif click then click(self, mouseButton) end
            end)
        end
    end)
end)
