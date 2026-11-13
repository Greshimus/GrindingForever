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
    N.ApplyWindowLayer(panel,"recipes")
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
    label:SetText("All Professions")
    label:SetTextColor(.18, .11, .06)
    local continent, chosenZone
    local function mapContinent(mapID)
        for _ = 1, 8 do
            local info = mapID and E.Call(C_Map and C_Map.GetMapInfo, mapID)
            if not info then return end
            if info.mapType == (Enum and Enum.UIMapType and Enum.UIMapType.Continent or 2) then return info.name end
            if not info.parentMapID or info.parentMapID <= 0 or info.parentMapID == mapID then return end
            mapID = info.parentMapID
        end
    end
    local locationContinents, availableZones = {}, {}
    local collapsed = {}
    local sourceRank = {Vendor=1, Quest=2, ["Quest Reward"]=2, Drop=3, Trainer=5}
    local sourceLabels = {"Vendors","Quests","Drops","Other Sources","Trainers"}
    local raidZones = {["onyxias lair"]=true,["barrow deeps"]=true,["hyjal summit"]=true,
        ["molten core"]=true,["blackwing lair"]=true,["zulgurub"]=true,["ahnqiraj"]=true,
        ["temple of ahnqiraj"]=true,["ruins of ahnqiraj"]=true,naxxramas=true}
    local function locationGroup(loc)
        local name=loc.zone or loc.dungeon
        if loc.raid or (name and raidZones[ns.DungeonNameKey(name)]) then return "Raids" end
        if loc.dungeon then return "Dungeons" end
        if loc.zone=="Zephras Isle" then return loc.zone end
        local map=loc.mapID or loc.zone
        if map and locationContinents[map]==nil then locationContinents[map]=mapContinent(loc.mapID) or false end
        return map and locationContinents[map]
    end
    local gathering = {Mining=true,Herbalism=true,Skinning=true,Fishing=true}
    local function rankSource(loc)
        if not loc then return 4 end
        return loc.vendor and 1 or sourceRank[loc.source] or 4
    end
    local function priceText(loc)
        if loc.source ~= "Vendor" then return "" end
        if type(loc.price) ~= "number" then return " / Price unrecorded" end
        local price = GetCoinTextureString and GetCoinTextureString(loc.price)
        return " / " .. (price or (loc.price .. "c"))
    end
    local function recipeBound(recipe)
        local id = recipe.learnableItemID
        local getter = GetItemInfo
        if not id then return false end
        local _,_,_,_,_,_,_,_,_,_,_,_,_,binding = E.Call(getter,id)
        return binding == 1
    end
    local catalog = ns.RecipeCatalog
    local continentButton = N.MakeButton(panel, "Search by Zone", 190)
    continentButton.label:SetFont(continentButton.label:GetFont(), 16); N.ButtonArrow(continentButton,"down","RIGHT")
    continentButton:SetPoint("TOPLEFT", 18, -76)
    local menu = CreateFrame("Frame", nil, panel, "BackdropTemplate")
    menu:SetPoint("TOPLEFT", continentButton, "BOTTOMLEFT", 0, -2)
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
                    button.disclosure:Show()
                    button.disclosure:SetRotation(collapsed[row.collapseKey or row.heading] and 0 or -math.pi / 2)
                elseif loc then
                    button.disclosure:Hide()
                    button.icon:SetTexture(loc.source == "Vendor" and "Interface\\Icons\\INV_Misc_Coin_01"
                        or loc.source == "Trainer" and ns.WindowWorkflow.TrainerIcon(recipe)
                        or loc.source == "Drop" and "Interface\\Icons\\Ability_Creature_Cursed_02"
                        or "Interface\\Icons\\INV_Misc_Map_01")
                    button.label:SetText(loc.name or "Unknown source")
                    button.detail:SetText((row.trainer and recipe.profession or loc.source or "Source") .. " / " .. (loc.zone or "Unknown zone")
                        .. priceText(loc) .. (catalog.HasWaypoint(loc) and "" or " / No waypoint"))
                else
                    button.disclosure:SetShown(row.count > 0)
                    button.disclosure:SetRotation(expanded == recipe.key and -math.pi / 2 or 0)
                    button.icon:SetTexture(recipeIcon(recipe))
                    local bound = recipeBound(recipe)
                    button.label:SetText(recipe.name .. (bound and " |cffa42a13(Bind on Pickup)|r" or ""))
                    button.detail:SetText((row.learning or recipe.profession or "Recipe") .. (recipe.skill and recipe.skill > 0 and (" " .. recipe.skill) or "")
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
        local currentZone = info and info.name or E.Call(GetRealZoneText)
        local zone = chosenZone
        if not zone and not continent and not query then zone = currentZone end
        if zone == "All Zones" then zone = nil end
        scope:SetText(zone and ("Browsing " .. zone) or (continent and ("Browsing " .. continent) or "Browsing All Zones"))
        if not recipes or revision ~= catalog.revision then
            recipes = catalog.Browse()
            revision = catalog.revision
            known, locationContinents, availableZones = {}, {}, {}
        end
        rows = {}
        local groups, listed, trainers, trainerKeys = {}, {}, {}, {}
        local trainerZone=zone or (not continent and currentZone)
        local localProfessions, fallbacks={},{}
        local capitals={Orgrimmar=true,Undercity=true,["Thunder Bluff"]=true,["Stormwind City"]=true,
            Stormwind=true,Ironforge=true,Darnassus=true}
        local zoneFacts=trainerZone and ns.ForeverData.zones[trainerZone]
        local position=E.CurrentPosition()
        local origin=trainerZone==currentZone and position or zoneFacts and zoneFacts.mapID
            and {mapID=zoneFacts.mapID,x=50,y=50} or position
        local function matches(recipe)
            if not query or recipe.name:lower():find(query,1,true) then return true end
            local id=recipe.productID or recipe.learnableItemID
            local name=id and E.Call(GetItemInfo,id)
            return type(name)=="string" and name:lower():find(query,1,true)~=nil
        end
        local allProfessions = mine:GetChecked()
        for _, recipe in ipairs(recipes) do
            if recipe.profession ~= "Jewelcrafting" and E.Eligible(recipe, state)
                and (allProfessions or state.skills[recipe.profession])
                then
                local sources = {}
                for _, loc in ipairs(recipe.locations or {}) do
                    local locContinent
                    if continent then
                        locContinent = locationGroup(loc)
                    end
                    if loc.source=="Trainer" then
                        local key=(recipe.profession or "").."/"..catalog.SourceKey(loc)
                        local profession=recipe.profession
                        local inScope=trainerZone and (loc.zone==trainerZone or (trainerZone==currentZone and mapID and loc.mapID==mapID))
                            or not trainerZone and continent and locContinent==continent
                        if not query and E.Eligible(loc,state) then
                            if inScope and not trainerKeys[key] then
                                trainerKeys[key]=true
                                localProfessions[profession]=true
                                trainers[#trainers+1]={recipe=recipe,location=loc}
                            elseif state.skills[profession] and capitals[loc.zone] and catalog.HasWaypoint(loc) then
                                local distance=origin and E.Distance(origin,loc)
                                local previous=fallbacks[profession]
                                if distance and (not previous or distance<previous.distance) then
                                    fallbacks[profession]={recipe=recipe,location=loc,distance=distance}
                                end
                            end
                        end
                    elseif matches(recipe) and E.Eligible(loc, state) and (not continent or locContinent == continent)
                        and (not zone or loc.zone == zone or (zone == currentZone and loc.mapID == mapID))
                        then
                        sources[#sources + 1] = loc
                    end
                end
                local key = recipe.key
                known[key] = state.skills[recipe.profession] and E.Known(recipe) or nil
                if #sources > 0 then
                    table.sort(sources,function(a,b)
                        local ar,br=rankSource(a),rankSource(b)
                        if ar~=br then return ar<br end
                        return (a.zone or "") .. (a.name or "") < (b.zone or "") .. (b.name or "")
                    end)
                    groups[recipe] = sources
                    listed[#listed + 1] = recipe
                end
            end
        end
        table.sort(listed,function(a,b)
            local ap,bp=a.profession or "",b.profession or ""
            if gathering[ap]~=gathering[bp] then return not gathering[ap] end
            if ap~=bp then return ap<bp end
            local ar,br=rankSource(groups[a][1]),rankSource(groups[b][1])
            if ar~=br then return ar<br end
            return a.name<b.name
        end)
        if #listed == 1 and expanded == nil then expanded=listed[1].key end
        local profession, previousRank
        for _,recipe in ipairs(listed) do
            local name=recipe.profession or "Other"
            if name~=profession then
                profession=name;previousRank=nil
                rows[#rows+1]={heading=name}
            end
            if not collapsed[name] then
                local sources=groups[recipe]
                local rank=rankSource(sources[1])
                local key=name.."/"..rank
                if rank~=previousRank then
                    rows[#rows+1]={heading=sourceLabels[rank],collapseKey=key}
                    previousRank=rank
                end
                if not collapsed[key] then
                    local skill=state.skills[recipe.profession]
                    local learning
                    if known[recipe.key]==true then learning="Already known"
                    elseif skill and type(skill.rank)=="number" and type(recipe.skill)=="number" and recipe.skill>0 then
                        learning=skill.rank>=recipe.skill and "Meets skill" or "Requires skill"
                    end
                    rows[#rows+1]={recipe=recipe,count=#sources,trained=known[recipe.key],preferred=sources[1],learning=learning}
                    if expanded==recipe.key then
                        for _,loc in ipairs(sources) do rows[#rows+1]={recipe=recipe,location=loc} end
                    end
                end
            end
        end
        for profession,row in pairs(fallbacks)do
            if not localProfessions[profession] then trainers[#trainers+1]=row end
        end
        if #trainers>0 then
            rows[#rows+1]={heading="Trainers · "..(trainerZone or continent or "Nearby Capitals"),collapseKey="zone-trainers"}
            if not collapsed["zone-trainers"] then
                table.sort(trainers,function(a,b)
                    if a.recipe.profession~=b.recipe.profession then return a.recipe.profession<b.recipe.profession end
                    return (a.location.name or "")<(b.location.name or "")
                end)
                for _,row in ipairs(trainers)do row.trainer=true;rows[#rows+1]=row end
            end
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
            local itemID = not self.record.trainer and (r.learnableItemID or r.productID)
            if itemID then
                E.Call(GameTooltip.SetHyperlink, GameTooltip, "item:" .. itemID)
            elseif r.spellID and not self.record.trainer then
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
                local heading=self.record.collapseKey or self.record.heading
                collapsed[heading]=not collapsed[heading]
                refresh(true)
                return
            end
            local r = self.record.recipe
            local isTrainer = self.record.trainer
            local loc = self.record.location
            if not loc then
                if self.record.count == 0 then
                    if self.record.trained then return end
                    feedback:SetText("No acquisition source is recorded for " .. r.name .. ".")
                    return
                end
                feedback:SetText("")
                if expanded == r.key then expanded = false else expanded = r.key end
                loc = self.record.preferred
                refresh(true)
            end
            if not loc or not catalog.HasWaypoint(loc) then
                feedback:SetText((loc and loc.name or r.name) .. " has no recorded waypoint.")
                return
            end
            local compass = ns.NavigationCompass
            local key = "recipe-browser"
            compass.pins[key] = { key = key, name = loc.name or r.name, zone = loc.zone, location = loc,
                icon = isTrainer and ns.WindowWorkflow.TrainerIcon(r) or assets .. "UI-MicroButton-Professions-Up",
                professionButton = not isTrainer, customIcon = true }
            compass.age = 1
            local pinned = catalog.PinWorldMap(loc)
            selected = tostring(r.key) .. "/" .. catalog.SourceKey(loc)
            local result = pinned and "World Map" or "World Map pin unavailable"
            result = result .. (compass.Enabled() and " / Compass" or " / Compass Off")
            feedback:SetText((loc.name or loc.zone or r.name) .. "  ·  " .. result)
            draw()
        end)
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
        option.label:SetFont(option.label:GetFont(), 15); option:SetHeight(22)
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
                local area = locationGroup(loc)
                if loc.zone then availableZones[loc.zone] = area or availableZones[loc.zone] or false end
            end
        end
    end
    continentButton:SetScript("OnClick", function(self)
        geography()
        openMenu(self, {"Current Zone","Eastern Kingdoms","Kalimdor","Zephras Isle","Dungeons","Raids"}, function(value)
            if value=="Current Zone" then continent=nil;chosenZone=nil;resetFilters();return end
            local values={"All Zones"}
            for name,area in pairs(availableZones) do
                if area==value or name==value then values[#values+1]=name end
            end
            table.sort(values,function(a,b)
                if a=="All Zones" then return b~="All Zones" end
                if b=="All Zones" then return false end
                return a<b
            end)
            openMenu(self,values,function(zone)
                continent=value
                chosenZone=zone
                resetFilters()
            end)
        end)
    end)
    local function resizeRows()
        pageSize = math.max(1, math.min(#buttons, math.floor((panel:GetHeight() - 204) / 37)))
        draw()
    end
    syncScroll = N.PanelScroll(panel, viewport, function() return rowOffset end,
        function(value) rowOffset = math.floor(value + .5); draw() end,
        function() return math.max(0, #rows - pageSize) end, 3)
    N.PanelChrome(panel, {"Recipe","List"}, 500, 430, resizeRows)
    N.LiveLayout(panel, resizeRows)
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
        if not (C_Timer and C_Timer.NewTimer) then refresh();return end
        pendingSearch = C_Timer.NewTimer(.2, function()
            pendingSearch = nil
            if panel:IsShown() then refresh() end
        end)
    end)
    mine:SetScript("OnClick", function()
        menu:Hide()
        resetFilters()
    end)
    refresh()
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
    local active = ns.FarmingPlanner.route ~= nil
    if farmButton.selected ~= active then
        farmButton.selected = active
        farmButton:SetEnamelTint()
        farmButton.activeGlow:SetShown(active)
    end
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
        recipeButton = N.MakeButton(r.panels[1], "Recipe List", 165, showRecipes)
        farmButton = N.MakeButton(r.panels[1], "Farming", 90, function()
            local button = N.farmButton
            local click = button and button:GetScript("OnClick")
            if click then click(button, "LeftButton") end
        end)
        farmButton.activeGlow = CreateFrame("Frame", nil, farmButton)
        farmButton.activeGlow:SetAllPoints(farmButton)
        farmButton.activeGlow:EnableMouse(false)
        for _, side in ipairs({"TOP", "BOTTOM", "LEFT", "RIGHT"}) do
            local edge = farmButton.activeGlow:CreateTexture(nil, "OVERLAY")
            if side == "TOP" or side == "BOTTOM" then
                edge:SetPoint(side .. "LEFT", 2, 0)
                edge:SetPoint(side .. "RIGHT", -2, 0)
                edge:SetHeight(2)
            else
                edge:SetPoint("TOP" .. side, 0, -2)
                edge:SetPoint("BOTTOM" .. side, 0, 2)
                edge:SetWidth(2)
            end
            edge:SetColorTexture(1, .77, .29, 1)
        end
        farmButton.activeGlow:Hide()
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

ns.ProfessionKnowledge.InitializeAuction(E)
