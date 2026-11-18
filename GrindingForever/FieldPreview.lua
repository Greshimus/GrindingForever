local _, ns = ...
local N, W, E = ns.NormalUI, ns.WindowWorkflow, ns.Forever
N.fieldGuideMinimumHeight = 560
local Showcase = ns.UI.Showcase
local panel, recipeButton, farmButton, dungeonButton
local hidden = false

local professionRank = {Cooking=2, ["First Aid"]=2, Mining=3, Herbalism=3, Skinning=3, Fishing=4}
local sourceTabs = {"All", "Vendors", "Quests", "Drops"}
local scopes = {"Local", "Trainers", "Merchant's Favor"}
local raidZones = {["onyxias lair"]=true, ["barrow deeps"]=true, ["hyjal summit"]=true,
    ["molten core"]=true, ["blackwing lair"]=true, ["zulgurub"]=true, ["ahnqiraj"]=true,
    ["temple of ahnqiraj"]=true, ["ruins of ahnqiraj"]=true, naxxramas=true}

local function favorRequirement(text)
    local value = type(text)=="string" and text:lower() or ""
    return value:find("merchant's favor",1,true) or value:find("durotar supply and logistics",1,true)
        or value:find("azeroth commerce authority",1,true)
end

local favorVendors = {}
for _, fact in ipairs(ns.RecipeSourceFacts.recipes or {}) do
    for _, source in ipairs(fact[7] or {}) do
        if source[1]=="Vendor" and favorRequirement(source[4]) then favorVendors[source[2]]=true end
    end
end

local function merchantFavor(loc)
    return loc.source=="Vendor" and (loc.merchantFavor or favorVendors[loc.npcID]
        or favorRequirement(loc.name) or favorRequirement(loc.requirement) or favorRequirement(loc.currency))
end
E.IsMerchantFavorVendor = merchantFavor

local function sourceTab(loc)
    if loc.source == "Vendor" then return "Vendors" end
    if loc.source == "Quest" or loc.source == "Quest Reward" then return "Quests" end
    if loc.source == "Drop" or loc.source == "World Drop" then return "Drops" end
    return "All"
end

local function sourceScope(loc)
    if loc.source == "Trainer" then return "Trainers" end
    return merchantFavor(loc) and "Merchant's Favor" or "Local"
end

local dungeonZones = {}
for name in pairs(ns.DungeonReference or {}) do dungeonZones[ns.DungeonNameKey(name)] = true end
for name in pairs(ns.DungeonEntrances or {}) do dungeonZones[ns.DungeonNameKey(name)] = true end

local function sortedKeys(values)
    local keys = {}
    for key in pairs(values) do keys[#keys+1] = key end
    table.sort(keys, function(a,b) return a:lower() < b:lower() end)
    return keys
end

local function showRecipes()
    if panel then panel:SetShown(not panel:IsShown()); return end
    local assets = "Interface\\AddOns\\GrindingForever\\Media\\"
    local face = assets.."Naowh.ttf"
    local catalog = ns.RecipeCatalog
    panel = CreateFrame("Frame", nil, UIParent)
    panel:SetSize(510, 528)
    panel:SetPoint("CENTER")
    N.ApplyWindowLayer(panel, "recipes")
    panel:EnableMouse(true)
    panel:SetMovable(true)
    panel:SetClampedToScreen(true)

    local onboarding = ns.ProfessionOnboarding
    local planButton = onboarding and N.WoodButton(panel, 'Profession plan', 126, onboarding.Open)

    local search = CreateFrame("EditBox", nil, panel)
    local searchFill=search:CreateTexture(nil,"BACKGROUND")
    searchFill:SetAllPoints();searchFill:SetColorTexture(.45,.27,.12,.24)
    N.BronzeRectangle(search,1)
    search:SetFont(face,N.PixelSize(search,14),"")
    search:SetTextColor(.18,.105,.045)
    search:SetTextInsets(6,6,0,0)
    search:SetAutoFocus(false)
    search:SetText("")
    local placeholder=N.MakeText(search,13,"Search recipes or sources",true)
    placeholder:SetPoint("LEFT",search,"LEFT",6,0)
    placeholder:SetAlpha(.62)
    local zoneButton = N.WoodButton(panel, "Current Zone", 190)
    N.ButtonArrow(zoneButton, "down", "RIGHT")
    local professionButton = N.WoodButton(panel, "All Professions", 150)
    N.ButtonArrow(professionButton, "down", "RIGHT")
    local scopeButtons, sourceButtons = {}, {}
    local location = N.MakeText(panel, 13, "", true)
    local status = N.MakeText(panel, 12, "", true)
    local feedback = N.MakeText(panel, 12, "", true)
    feedback:SetJustifyH("LEFT")
    feedback:SetWordWrap(false)
    local viewport = CreateFrame("Frame", nil, panel)
    local rows, buttons, rowOffset = {}, {}, 0
    local pageSize, syncScroll = 8
    local expanded, selected
    local recipes, revision
    local pendingItemNames = {}
    local mergedScope
    local scope, source, profession = "Local", "All", nil
    local chosenContinent, chosenZone
    local mapGroups = {}
    local refresh

    local function mapContinent(mapID)
        if not mapID then return end
        if mapGroups[mapID] ~= nil then return mapGroups[mapID] or nil end
        local export = ns.ForeverCatalog and ns.ForeverCatalog.zones
        local exported = export and export[mapID]
        local map, visited = mapID, {}
        while map and map > 0 and not visited[map] do
            visited[map] = true
            local info = E.Call(C_Map and C_Map.GetMapInfo, map)
            if not info then break end
            if info.mapType == (Enum and Enum.UIMapType and Enum.UIMapType.Continent or 2) then
                mapGroups[mapID] = info.name
                return info.name
            end
            map = info.parentMapID
        end
        mapGroups[mapID] = exported and exported.continent or false
        return mapGroups[mapID] or nil
    end

    local function locationGroup(loc)
        local name = loc.zone or loc.dungeon
        if loc.raid or (name and raidZones[ns.DungeonNameKey(name)]) then return "Raids" end
        if loc.dungeon or (name and dungeonZones[ns.DungeonNameKey(name)]) then return "Dungeons" end
        if name == "Zephras Isle" then return name end
        local entry = name and ns.ForeverData.zones[name]
        return mapContinent(loc.mapID or (entry and entry.mapID))
    end

    local sourceKinds = {vendor="Vendor", trainer="Trainer", drop="Drop", open="Container", quest="Quest", ["quest reward"]="Quest Reward"}
    local function mergeSources(recipe, zone, mapID)
        local data = ns.ForeverCatalog
        if not data then return end
        local indexes = {}
        local function matchKey(loc)
            local id = loc.npcID or loc.questID or loc.sourceID or loc.name or ""
            return (loc.source or "") .. ":" .. tostring(id) .. ":" .. (loc.zone or loc.mapID or "")
        end
        for index, loc in ipairs(recipe.locations) do indexes[matchKey(loc)] = index end
        local function add(sources)
            for _, row in ipairs(sources or {}) do
                local src = row.source or (row.kind and sourceKinds[row.kind:lower()])
                if src and (not zone or row.zone==zone or row.dungeon==zone or mapID and row.mapID==mapID) then
                    local loc = {}
                    for k, value in pairs(row) do loc[k] = value end
                    loc.source = src
                    loc.fromCatalog = true
                    -- NPC levels describe the source, not a player eligibility requirement.
                    loc.mobMinLevel, loc.mobMaxLevel = loc.minLevel, loc.maxLevel
                    loc.minLevel, loc.maxLevel = nil, nil
                    local key = matchKey(loc)
                    local index = indexes[key]
                    if index then
                        local previous = recipe.locations[index]
                        local merged = {}
                        for k,value in pairs(previous) do merged[k] = value end
                        for k,value in pairs(loc) do
                            if k ~= "fromCatalog" and (merged[k] == nil or k == "rate" or k == "sampleSize" or k == "provenance") then merged[k] = value end
                        end
                        recipe.locations[index] = merged
                    else
                        recipe.locations[#recipe.locations+1] = loc
                        indexes[key] = #recipe.locations
                    end
                end
            end
        end
        add(data.byItem and data.byItem[recipe.learnableItemID])
        add(data.recipes and data.recipes[recipe.spellID])
    end

    local function selectedZone()
        if chosenZone == "All Zones" then return nil end
        if chosenZone then return chosenZone end
        local mapID = E.Position().mapID
        local info = mapID and E.Call(C_Map and C_Map.GetMapInfo, mapID)
        return info and info.name or E.Call(GetRealZoneText), mapID
    end

    local function browseZones()
        local groups = {["Eastern Kingdoms"]={}, Kalimdor={}, ["Zephras Isle"]={}, Dungeons={}, Raids={}}
        local function add(group, name)
            if group and name then groups[group]=groups[group] or {}; groups[group][name]=true end
        end
        local maps = E.Call(C_Map and C_Map.GetMapChildrenInfo, 947, 2, true) or {}
        if #maps == 0 then maps = {{mapID=1415, name="Eastern Kingdoms"}, {mapID=1414, name="Kalimdor"}} end
        for _, map in ipairs(maps) do
            for _, child in ipairs(E.Call(C_Map and C_Map.GetMapChildrenInfo, map.mapID, 3, true) or {}) do
                add(map.name, child.name)
            end
        end
        for name, info in pairs(ns.ForeverData.zones) do
            local group=locationGroup({zone=name,mapID=info.mapID})
            if name~=group then add(group,name) end
        end
        for mapID, info in pairs(ns.ForeverCatalog and ns.ForeverCatalog.zones or {}) do
            local group = locationGroup({zone=info.name,mapID=mapID})
            if info.isZone ~= false and (info.name~=group or group=="Zephras Isle") then add(group,info.name) end
        end
        add("Eastern Kingdoms", "Blasted Lands")
        add("Eastern Kingdoms", "Stranglethorn Vale")
        add("Zephras Isle", "Zephras Isle")
        for _, recipe in ipairs(recipes or {}) do
            for _, loc in ipairs(recipe.locations) do add(locationGroup(loc), loc.zone or loc.dungeon) end
        end
        return groups
    end

    local function fitLabel(button, label, size, inset)
        local font, _, flags = button.label:GetFont()
        local physicalMin = N.PixelSize(button, 11)
        button.label:SetFont(font, math.max(physicalMin, size), flags)
        button.label:SetText(label)
        local estimate = button.label.GetUnboundedStringWidth and button.label:GetUnboundedStringWidth() or button.label:GetStringWidth()
        local maxWidth = math.max(1, button:GetWidth() - inset)
        if estimate and estimate > maxWidth then
            button.label:SetFont(font, math.max(physicalMin, size * maxWidth / estimate), flags)
        end
    end

    local function captionSize(fullSize)
        local unit=N.PixelSize(panel, 1)
        -- Match the other compact selectors at 400 px, growing to the normal size by 480 px.
        local roomy=math.max(0, math.min(1, (panel:GetWidth()/unit-400)/80))
        return math.floor(13+(fullSize-13)*roomy+.5)*unit
    end

    local function makeMenu()
        local frame = CreateFrame("Frame", nil, panel, "BackdropTemplate")
        frame:SetWidth(N.PixelSize(panel, 178))
        frame:SetFrameLevel(panel:GetFrameLevel()+24)
        frame:SetClampedToScreen(true)
        frame:EnableMouse(true)
        frame:EnableMouseWheel(true)
        frame:SetBackdrop({ bgFile="Interface/Buttons/WHITE8X8" })
        frame:SetBackdropColor(.10, .06, .035, 1)
        N.BronzeRectangle(frame,2)
        frame:Hide()
        local menu = {frame=frame, rows={}, values={}, offset=0}
        menu.Render = function()
            local height = N.PixelSize(frame, 26)
            local count = math.min(11, #menu.values)
            frame:SetHeight(count*height+8)
            for i, button in ipairs(menu.rows) do
                local entry = i<=count and menu.values[i+menu.offset]
                button.entry = entry
                button:SetShown(entry and true or false)
                if entry then
                    button:ClearAllPoints()
                    button:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, -4-(i-1)*height)
                    button:SetWidth(frame:GetWidth()-8)
                    button:SetHeight(height)
                    fitLabel(button, entry.label, captionSize(14), 15)
                end
            end
        end
        for i=1,11 do
            local button = N.PlainButton(frame, "", 150, nil, true)
            button.label:ClearAllPoints()
            button.label:SetPoint("LEFT", button, "LEFT", 7, 0)
            button.label:SetPoint("RIGHT", button, "RIGHT", -7, 0)
            button.label:SetTextColor(.98, .84, .58)
            button.label:SetJustifyH("LEFT")
            button:HookScript("OnEnter", function(self)
                if self.entry and self.entry.hover then self.entry.hover() end
            end)
            button:SetScript("OnClick", function(self)
                if self.entry then self.entry.click() end
            end)
            menu.rows[i] = button
        end
        frame:SetScript("OnMouseWheel", function(_, delta)
            menu.offset = math.max(0,math.min(math.max(0,#menu.values-11),menu.offset-delta))
            menu.Render()
        end)
        return menu
    end

    local menu, submenu = makeMenu(), makeMenu()
    local menuOwner, openGroup
    local function closeMenus()
        menu.frame:Hide()
        submenu.frame:Hide()
        menuOwner, openGroup = nil, nil
    end
    local function openMenu(owner, values)
        if menuOwner == owner then closeMenus(); return end
        closeMenus()
        menuOwner = owner
        menu.frame:ClearAllPoints()
        menu.frame:SetPoint("TOPLEFT", owner, "BOTTOMLEFT", 0, -2)
        menu.frame:SetWidth(N.PixelSize(panel, 178))
        menu.values, menu.offset = values, 0
        menu.Render()
        menu.frame:Show()
    end
    local function applyFilters()
        closeMenus()
        expanded = nil
        feedback:SetText("")
        refresh()
    end
    zoneButton:SetScript("OnClick", function(self)
        local groups = browseZones()
        local function pick(continent, zone)
            chosenContinent, chosenZone = continent, zone
            applyFilters()
        end
        local values = {
            {label="Current Zone", click=function() pick(nil,nil) end},
            {label="All Zones", click=function() pick(nil,"All Zones") end},
        }
        for _, entry in ipairs(values) do
            entry.hover=function() submenu.frame:Hide();openGroup=nil end
        end
        for _, name in ipairs(sortedKeys(groups)) do
            local function expand()
                if openGroup == name then return end
                openGroup = name
                local childValues = {{label="All "..name, click=function() pick(name,"All Zones") end}}
                for _, zone in ipairs(sortedKeys(groups[name])) do
                    childValues[#childValues+1] = {label=zone, click=function() pick(name,zone) end}
                end
                local frame = submenu.frame
                local width = N.PixelSize(panel, 190)
                frame:ClearAllPoints()
                local right = menu.frame:GetRight()
                if right and right + width > UIParent:GetWidth() then
                    frame:SetPoint("TOPRIGHT", menu.frame, "TOPLEFT", 0, 0)
                else
                    frame:SetPoint("TOPLEFT", menu.frame, "TOPRIGHT", 0, 0)
                end
                frame:SetWidth(width)
                submenu.values, submenu.offset = childValues, 0
                submenu.Render()
                frame:Show()
            end
            values[#values+1] = {label=name.."  ›", click=expand, hover=expand}
        end
        openMenu(self,values)
    end)
    professionButton:SetScript("OnClick", function(self)
        local names = {}
        for _, recipe in ipairs(recipes or {}) do
            if recipe.profession then names[recipe.profession] = true end
        end
        local professions = sortedKeys(names)
        table.sort(professions, function(a,b)
            local aa,bb=professionRank[a] or 1,professionRank[b] or 1
            return aa == bb and a < b or aa < bb
        end)
        local values = {{label="All Professions", click=function() profession=nil; applyFilters() end}}
        for _, name in ipairs(professions) do
            values[#values+1] = {label=name, click=function() profession=name; applyFilters() end}
        end
        openMenu(self,values)
    end)

    for _, label in ipairs(scopes) do
        local button = N.WoodButton(panel,label,120,function()
            scope=label; source="All"; applyFilters()
        end)
        N.UnderlineControl(button, true)
        scopeButtons[#scopeButtons+1] = button
    end
    for _, label in ipairs(sourceTabs) do
        local button = N.WoodButton(panel,label,70,function()
            source=label; applyFilters()
        end)
        N.UnderlineControl(button, true)
        sourceButtons[#sourceButtons+1] = button
    end

    local function recipeIcon(recipe, productID)
        local itemID = productID or recipe.learnableItemID or recipe.productID
        local icon = itemID and E.Call(C_Item and C_Item.GetItemIconByID or GetItemIcon, itemID)
        if not E.Public(icon) then icon = nil end
        if productID then
            return icon or "Interface\\Icons\\INV_Misc_QuestionMark"
        end
        if not icon and recipe.spellID then
            icon = E.Call(C_Spell and C_Spell.GetSpellTexture or GetSpellTexture, recipe.spellID)
        end
        return E.Public(icon) and icon or "Interface\\Icons\\INV_Scroll_03"
    end

    local function recipeItemLabel(id, link)
        if not id then return end
        local name = link and link:match("|h%[(.-)%]|h") or E.ItemLabel(id)
        if not name then pendingItemNames[id] = true end
        return name
    end

    local function matchesName(name, query)
        return name and name:lower():find(query, 1, true)
    end

    local function rowItem(row)
        local recipe = row.recipe
        if row.productID then return recipe.productLink or row.productID end
        return recipe.learnableItemID or recipe.productLink or recipe.productID
    end

    local function priceText(loc)
        if loc.source ~= "Vendor" then return end
        if merchantFavor(loc) then
            if type(loc.currencyAmount)=="number" then return loc.currencyAmount.." Merchant's Favor" end
            return "Merchant's Favor"
        end
        if type(loc.price) ~= "number" then return "Price unrecorded" end
        return GetCoinTextureString and GetCoinTextureString(loc.price) or loc.price.."c"
    end

    local function skillText(recipe)
        local skill=(recipe.skill or 0)>0 and " "..recipe.skill or ""
        return (recipe.profession or "Recipe")..skill
    end

    local function sourceCountText(row)
        local count=#row.sources
        return count..(count==1 and " source" or " sources")..(row.known and " · Known" or "")
    end

    local function describeWorldDrop(recipe)
        local sources=recipe.locations
        local low,high,best
        local zones,hints={},{}
        local hasGeneric, zoneCount = false, 0
        for _, loc in ipairs(sources) do
            if sourceTab(loc) == "Drops" then
                if loc.source == "World Drop" then
                    hasGeneric = true
                    if loc.name and loc.name~="World Drop" then hints[loc.name] = true end
                end
                if loc.zone and not zones[loc.zone] then zones[loc.zone]=true;zoneCount=zoneCount+1 end
                if loc.mobMinLevel then low=math.min(low or loc.mobMinLevel,loc.mobMinLevel) end
                if loc.mobMaxLevel then high=math.max(high or loc.mobMaxLevel,loc.mobMaxLevel) end
                if type(loc.rate)=="number" and type(loc.sampleSize)=="number" and loc.sampleSize>0
                    and not loc.classicFallback and not (loc.provenance or ""):lower():find("classic",1,true)
                    and (not best or loc.rate>best.rate) then best=loc end
            end
        end
        local catalogData = ns.ForeverCatalog
        local rollup = catalogData and catalogData.dropSummary and catalogData.dropSummary[recipe.learnableItemID]
        if rollup then
            for _,name in ipairs(rollup.zones or {}) do
                if not zones[name] then zones[name]=true;zoneCount=zoneCount+1 end
            end
            if rollup.minLevel then low=math.min(low or rollup.minLevel,rollup.minLevel) end
            if rollup.maxLevel then high=math.max(high or rollup.maxLevel,rollup.maxLevel) end
            local highest=rollup.highestObserved
            if highest and (not best or highest.rate>best.rate) then best=highest end
        end
        if not hasGeneric and zoneCount < 2 and not best then return end
        local span = low and high and (low==high and tostring(low) or (low.."–"..high)) or nil
        local label = (hasGeneric or zoneCount>=2) and "World drop" or "Recorded drop"
        if span then label=label.." · mob levels "..span end
        local detail = best and ("Highest recorded: %.3g%% · %s (%s attempts)"):format(best.rate*100,best.name or "Unknown source",best.sampleSize)
            or "Forever drop rate unverified"
        local lines = {}
        if next(zones) then lines[#lines+1] = "Recorded source zones: "..table.concat(sortedKeys(zones),", ") end
        if rollup and rollup.npcCount then lines[#lines+1]=rollup.npcCount.." recorded drop sources" end
        for _, hint in ipairs(sortedKeys(hints)) do lines[#lines+1] = "Catalog range: "..hint end
        return {label=label, detail=detail, lines=lines}
    end

    local function draw()
        rowOffset = math.min(rowOffset, math.max(0, #rows-pageSize))
        local tooltipOwner = GameTooltip and GameTooltip:GetOwner()
        for i, button in ipairs(buttons) do
            local row = i<=pageSize and rows[rowOffset+i]
            button.record = row
            button:SetShown(row and true or false)
            if row then
                local loc, recipe = row.location, row.recipe
                button.fill:SetColorTexture(.28,.50,.39,loc and selected == tostring(recipe.key).."/"..catalog.SourceKey(loc) and .34
                    or (expanded == recipe.key and not loc) and .20 or 0)
                button.icon:SetTexture(loc and (loc.source=="Trainer" and W.TrainerIcon(recipe)
                    or loc.source=="Vendor" and "Interface\\Icons\\INV_Misc_Coin_01"
                    or "Interface\\Icons\\INV_Misc_Map_01") or recipeIcon(recipe, row.productID))
                button.disclosure:SetShown(not loc and not row.summary and not row.productID)
                local iconInset = N.PixelSize(panel, row.productID and 24 or 16)
                local textInset = N.PixelSize(panel, row.productID and 54 or 46)
                button.icon:SetPoint("LEFT", button, "LEFT", iconInset, 0)
                button.label:SetPoint("TOPLEFT", button, "TOPLEFT", textInset, -N.PixelSize(panel, 4))
                button.detail:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", textInset, N.PixelSize(panel, 3))
                if row.productID then
                    button.label:SetText(recipeItemLabel(row.productID, recipe.productLink) or ("Item "..row.productID))
                    button.detail:SetText("Crafted item")
                elseif row.summary then
                    button.label:SetText(row.summary.label)
                    button.detail:SetText(row.summary.detail)
                elseif loc then
                    local price=priceText(loc)
                    button.label:SetText(loc.name or "Unknown source")
                    button.detail:SetText((loc.zone or loc.dungeon or loc.source or "Unknown zone") .. (price and " · "..price or "")
                        .. (catalog.HasWaypoint(loc) and " · Pin" or ""))
                else
                    button.disclosure:SetRotation(expanded==recipe.key and -math.pi/2 or 0)
                    button.label:SetText(recipe.name)
                    button.detail:SetText(skillText(recipe).." · "..sourceCountText(row))
                end
            end
            if tooltipOwner == button then
                if row then button:GetScript("OnEnter")(button) else GameTooltip:Hide() end
            end
        end
        status:SetText(#rows==0 and "No recipes match these filters" or
            ("%d–%d of %d"):format(rowOffset+1,math.min(#rows,rowOffset+pageSize),#rows))
        if syncScroll then syncScroll() end
    end

    local function fitFilters()
        fitLabel(zoneButton, chosenZone=="All Zones" and (chosenContinent or chosenZone) or chosenZone or "Current Zone", captionSize(15), N.PixelSize(panel, 32))
        fitLabel(professionButton, profession or "All Professions", captionSize(15), N.PixelSize(panel, 32))
    end

    refresh = function(keepPage, revealProduct)
        local typed=search:GetText() or ""
        local query=typed:match("^%s*(.-)%s*$"):lower()
        local searching=query~=""
        local zone,mapID=selectedZone()
        -- An explicit search spans the catalog; browse filters resume when it is cleared.
        if searching then zone,mapID=nil,nil end
        local scopeKey=(zone or "All Zones")..":"..tostring(mapID or "")
        if not recipes or revision ~= catalog.revision or mergedScope~=scopeKey then
            recipes = catalog.Browse()
            revision,mergedScope = catalog.revision,scopeKey
            for _, recipe in ipairs(recipes) do mergeSources(recipe,zone,mapID) end
            table.sort(recipes,function(a,b)
                local ap,bp=a.profession or "",b.profession or ""
                local ar,br=professionRank[ap] or 1,professionRank[bp] or 1
                if ar~=br then return ar<br end
                if ap~=bp then return ap<bp end
                return a.name<b.name
            end)
        end
        local state=E.state or E.Snapshot()
        placeholder:SetShown(typed=="")
        fitFilters()
        location:SetText(searching and "Searching all zones, professions and sources" or "Browsing "..(zone or chosenContinent or "All Zones"))
        for i, button in ipairs(scopeButtons) do
            button:SetSelected(scope==scopes[i])
        end
        for i, button in ipairs(sourceButtons) do
            button:SetShown(scope=="Local")
            button:SetSelected(source==sourceTabs[i])
        end
        rows={}
        for _,recipe in ipairs(recipes) do
            if E.Eligible(recipe,state) then
                local recipeMatch=searching and (matchesName(recipe.name, query)
                    or matchesName(recipeItemLabel(recipe.productID, recipe.productLink), query)
                    or (recipe.learnableItemID ~= recipe.productID
                        and matchesName(recipeItemLabel(recipe.learnableItemID), query)))
                if searching or not profession or recipe.profession==profession then
                    local matched={}
                    for _, loc in ipairs(recipe.locations) do
                        local inZone = not zone or loc.zone==zone or loc.dungeon==zone or mapID and loc.mapID==mapID
                        if (zone or chosenContinent) and sourceTab(loc)=="Drops" and
                            (loc.source=="World Drop" or loc.classicFallback or
                            (loc.fromCatalog and loc.coordinateEvidence~="Everloot loot location")) then
                            inZone=false
                        end
                        local inContinent = not chosenContinent or locationGroup(loc)==chosenContinent
                        local matches=searching and (recipeMatch or matchesName(loc.name,query))
                            or not searching and inZone and inContinent and sourceScope(loc)==scope and (source=="All" or sourceTab(loc)==source)
                        if matches
                            and E.Eligible(loc,state) then matched[#matched+1]=loc end
                    end
                    if #matched>0 and (searching or not profession or recipe.profession==profession) then
                        local row = {recipe=recipe,sources=matched,known=E.Known(recipe)==true}
                        rows[#rows+1]=row
                        if expanded==recipe.key then
                            if recipe.productID then
                                rows[#rows+1]={recipe=recipe,productID=recipe.productID}
                            end
                            local detail=not searching and scope=="Local" and (source=="All" or source=="Drops") and describeWorldDrop(recipe)
                            if detail then rows[#rows+1]={recipe=recipe,summary=detail} end
                            local limit=detail and not zone and 12 or #matched
                            for i=1,math.min(limit,#matched) do rows[#rows+1]={recipe=recipe,location=matched[i]} end
                            if limit<#matched then rows[#rows+1]={recipe=recipe,summary={
                                label=(#matched-limit).." more source records",
                                detail="Choose a zone to view the local sources",lines={}
                            }} end
                        end
                    end
                end
            end
        end
        if keepPage~=true then rowOffset=0 end
        if revealProduct then
            for index, row in ipairs(rows) do
                if row.productID and row.recipe.key==revealProduct then
                    rowOffset = math.max(index-pageSize, math.min(rowOffset, index-2))
                    break
                end
            end
        end
        draw()
    end

    for i=1,26 do
        local button = CreateFrame("Button",nil,viewport)
        button.gfRecipeSourceRow = true
        button.fill=button:CreateTexture(nil,"BACKGROUND")
        button.fill:SetAllPoints()
        button:SetHighlightTexture("Interface\\Buttons\\WHITE8X8")
        button:GetHighlightTexture():SetVertexColor(.8,.6,.3,.16)
        button.label=N.MakeText(button,15,"",true)
        button.label:SetWordWrap(false)
        button.label:SetJustifyH("LEFT")
        button.detail=N.MakeText(button,12,"",true)
        button.detail:SetWordWrap(false)
        button.detail:SetJustifyH("LEFT")
        button.icon=button:CreateTexture(nil,"ARTWORK")
        button.disclosure=button:CreateTexture(nil,"ARTWORK")
        button.disclosure:SetTexture(assets.."ControlTriangleRight")
        buttons[i]=button
        button:SetScript("OnEnter",function(self)
            local row=self.record
            if not row or not GameTooltip then return end
            local recipe,loc=row.recipe,row.location
            local tip=GameTooltip
            tip:SetOwner(self,"ANCHOR_RIGHT")
            E.Call(tip.ClearLines,tip)
            local function line(value)
                if value and value~="" then tip:AddLine(value,.98,.84,.58,true) end
            end
            if row.summary then
                line(row.summary.label)
                line(row.summary.detail)
                for _,value in ipairs(row.summary.lines) do line(value) end
                tip:Show()
                return
            end
            if row.productID then
                if not ns.SetNativeItemTooltip(tip, rowItem(row)) then
                    line(recipeItemLabel(row.productID, recipe.productLink) or ("Item "..row.productID))
                end
                tip:Show()
                return
            end
            local item = rowItem(row)
            local nativeTitle = item and ns.SetNativeItemTooltip(tip, item)
            if not nativeTitle then line(recipe.name) end
            if not nativeTitle or not recipe.learnableItemID then line(skillText(recipe)) end
            if loc then
                local name=loc.name or "Unknown source"
                line(loc.source and loc.source~=name and loc.source.." · "..name or name)
                local place=loc.zone or loc.dungeon
                if catalog.HasWaypoint(loc) then
                    place=("%s %.1f, %.1f"):format(place or "Map",loc.x,loc.y)
                end
                if place~=name then line(place) end
                local price=priceText(loc)
                line(price)
                if loc.requirement~=price then line(loc.requirement) end
                if type(loc.rate)=="number" and type(loc.sampleSize)=="number" then
                    line(("Recorded rate: %.3g%% (%d attempts)"):format(loc.rate*100,loc.sampleSize))
                elseif type(loc.classicRate)=="number" then
                    line(("Classic fallback: %.3g%%"):format(loc.classicRate*100))
                end
            else
                line(sourceCountText(row))
            end
            tip:Show()
        end)
        button:SetScript("OnLeave",function() GameTooltip:Hide() end)
        button:SetScript("OnClick",function(self)
            local row=self.record
            if row and not row.summary and not row.location then
                local item = rowItem(row)
                if item and ns.HandleItemChatClick(item) then return end
            end
            closeMenus()
            if not row or row.summary or row.productID then return end
            local recipe,loc=row.recipe,row.location
            if not loc then
                if expanded==recipe.key then expanded=nil else expanded=recipe.key end
                refresh(true, expanded)
                return
            end
            if not catalog.HasWaypoint(loc) then
                feedback:SetText((loc.name or recipe.name).." has no recorded waypoint.")
                return
            end
            selected=tostring(recipe.key).."/"..catalog.SourceKey(loc)
            local pinned,tracked=catalog.PinSource(recipe,loc)
            feedback:SetText((loc.name or loc.zone or recipe.name).." · "..(pinned and "World Map" or "World Map pin unavailable")
                ..(tracked and " / Compass" or " / Compass Off"))
            draw()
        end)
    end

    local function resize()
        local px = function(value) return N.PixelSize(panel, value) end
        local inset, gap = px(18), px(6)
        local top = (N.HeaderSize and N.HeaderSize(panel) or px(56))+px(9)
        local width = panel:GetWidth()-2*inset
        local function position(widget,x,y,w,h)
            widget:ClearAllPoints()
            widget:SetPoint("TOPLEFT",panel,"TOPLEFT",inset+x,-top-y)
            widget:SetSize(w,h)
        end
        local scopeWidth = {width*.22-gap, width*.28-gap, width*.50}
        local x=0
        for i,button in ipairs(scopeButtons) do
            position(button,x,0,scopeWidth[i],px(29))
            fitLabel(button,scopes[i],captionSize(14),px(15))
            x=x+scopeWidth[i]+gap
        end
        local zoneWidth = px(math.floor(width/px(1)*.51+.5))
        position(zoneButton,0,px(35),zoneWidth,px(29))
        position(professionButton,zoneWidth+gap,px(35),width-zoneWidth-gap,px(29))
        local planWidth=planButton and px(120) or 0
        position(search,0,px(71),width-planWidth-(planButton and gap or 0),px(26))
        if planButton then
            position(planButton,width-planWidth,px(71),planWidth,px(26))
            fitLabel(planButton,'Profession plan',px(14),px(12))
        end
        position(location,0,px(102),width,px(19))
        search:SetFont(face,px(14),"")
        placeholder:SetFont(face,px(14),"")
        location:SetFont(face,px(15),"")
        status:SetFont(face,px(12),"")
        feedback:SetFont(face,px(12),"")
        location:SetJustifyH("LEFT")
        for i,button in ipairs(sourceButtons) do
            local w=(width-3*gap)/4
            position(button,(i-1)*(w+gap),px(125),w,px(27))
            fitLabel(button, sourceTabs[i],px(13),px(12))
        end
        viewport:ClearAllPoints()
        viewport:SetPoint("TOPLEFT",panel,"TOPLEFT",inset,-top-px(160))
        viewport:SetPoint("BOTTOMRIGHT",panel,"BOTTOMRIGHT",-px(40),px(55))
        status:ClearAllPoints()
        status:SetPoint("BOTTOM",panel,"BOTTOM",0,px(16))
        feedback:ClearAllPoints()
        feedback:SetPoint("BOTTOMLEFT",panel,"BOTTOMLEFT",inset,px(35))
        feedback:SetPoint("BOTTOMRIGHT",panel,"BOTTOMRIGHT",-inset,px(35))
        local rowHeight=px(40)
        local viewportHeight=panel:GetHeight()-top-px(160+55)
        pageSize=math.max(1,math.min(#buttons,math.floor(viewportHeight/rowHeight)))
        for i,button in ipairs(buttons) do
            button:ClearAllPoints()
            button:SetPoint("TOPLEFT",viewport,"TOPLEFT",0,-(i-1)*rowHeight)
            button:SetPoint("TOPRIGHT",viewport,"TOPRIGHT",0,-(i-1)*rowHeight)
            button:SetHeight(rowHeight-px(1))
            button.icon:ClearAllPoints();button.icon:SetPoint("LEFT",button,"LEFT",px(16),0);button.icon:SetSize(px(25),px(25))
            button.disclosure:ClearAllPoints();button.disclosure:SetPoint("LEFT",button,"LEFT",px(3),0);button.disclosure:SetSize(px(10),px(10))
            button.label:ClearAllPoints();button.label:SetPoint("TOPLEFT",button,"TOPLEFT",px(46),-px(4));button.label:SetPoint("TOPRIGHT",button,"TOPRIGHT",-px(6),-px(4))
            button.detail:ClearAllPoints();button.detail:SetPoint("BOTTOMLEFT",button,"BOTTOMLEFT",px(46),px(3));button.detail:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",-px(6),px(3))
            local font=button.label:GetFont()
            button.label:SetFont(font,px(15))
            button.detail:SetFont(font,px(12))
        end
        fitFilters()
        draw()
    end

    syncScroll=N.PanelScroll(panel,viewport,function() return rowOffset end,
        function(value) rowOffset=math.floor(value+.5);draw() end,
        function() return math.max(0,#rows-pageSize) end,3)
    N.PanelChrome(panel,{"Recipe","Sources"},500,430,resize)
    N.LiveLayout(panel,resize)
    local pendingSearch
    local function queueRefresh(keepPage)
        if pendingSearch then
            if keepPage then return end
            pendingSearch:Cancel()
        end
        if not (C_Timer and C_Timer.NewTimer) then refresh(keepPage); return end
        pendingSearch = C_Timer.NewTimer(.18, function()
            pendingSearch = nil
            if panel:IsShown() then refresh(keepPage) end
        end)
    end
    panel:SetScript("OnEvent",function(_,_,id,success)
        if not E.Public(success) or not success or not E.Public(id) or not pendingItemNames[id] then return end
        pendingItemNames[id] = nil
        queueRefresh(true)
    end)
    panel:RegisterEvent("GET_ITEM_INFO_RECEIVED")
    panel:HookScript("OnShow",function()
        panel:RegisterEvent("GET_ITEM_INFO_RECEIVED")
        resize()
        refresh()
    end)
    panel:HookScript("OnHide",function()
        panel:UnregisterEvent("GET_ITEM_INFO_RECEIVED")
        recipes,rows=nil,{}
        pendingItemNames={}
        if pendingSearch then pendingSearch:Cancel(); pendingSearch = nil end
        closeMenus()
        local owner=GameTooltip:GetOwner()
        if owner and owner.GetParent and owner:GetParent()==viewport then GameTooltip:Hide() end
    end)
    search:SetScript("OnEditFocusGained",closeMenus)
    search:SetScript("OnEnterPressed",function(self) self:ClearFocus();refresh() end)
    search:SetScript("OnEscapePressed",function(self) self:ClearFocus();closeMenus() end)
    search:SetScript("OnTextChanged",function() queueRefresh(false) end)
    resize()
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
    local unit = N.PixelSize(steps,1)
    local inset = 20*unit
    local gap = 3*unit
    local buttons = {recipeButton,farmButton,dungeonButton}
    local available = steps:GetWidth()-2*inset-2*gap
    local equal = available/#buttons
    local minimums, required, widest = {}, 0, 0
    for i,button in ipairs(buttons) do
        local caption = button.label
        local width = caption.GetUnboundedStringWidth and caption:GetUnboundedStringWidth() or caption:GetStringWidth()
        minimums[i] = (math.ceil(width/unit) + 12)*unit
        required = required + minimums[i]
        widest = math.max(widest, minimums[i])
    end
    local extra = math.max(0, available-required)/#buttons
    local compress = math.min(1, available/required)
    local height = 32*unit
    local top = 33*unit
    local x = inset
    for i,button in ipairs(buttons) do
        local width = widest <= equal and equal or minimums[i]*compress+extra
        button:ClearAllPoints()
        button:SetPoint("TOPLEFT",steps,"TOPLEFT",x,-top)
        button:SetSize(width,height)
        x = x + width + gap
    end
    farmButton:SetSelected(ns.FarmingPlanner.route ~= nil)
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
        recipeButton = N.WoodButton(r.panels[1], "Recipe Sources", 165, showRecipes)
        farmButton = N.WoodButton(r.panels[1], "Farming", 90, function()
            local button = N.farmButton
            local click = button and button:GetScript("OnClick")
            if click then click(button, "LeftButton") end
        end)
        N.UnderlineControl(farmButton, true)
        dungeonButton = N.WoodButton(r.panels[1], "Dungeons", 90, ns.ToggleDungeonBrowser)
    end
    if N.mode ~= "compact" or W.view ~= "steps" or W.recipeCompact then
        legacySetView("steps")
    end
    Showcase.Show()
end

local events = CreateFrame("Frame")
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
events:RegisterEvent("PLAYER_LOGIN")

ns.ProfessionKnowledge.InitializeAuction(E)
