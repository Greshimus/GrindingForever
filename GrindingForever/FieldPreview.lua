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
    if loc.source~="Vendor" then return false end
    if loc.merchantFavor~=nil then return loc.merchantFavor==true end
    local catalog=ns.RecipeCatalog
    if catalog and catalog.IsVerifiedCoinOffer and catalog.IsVerifiedCoinOffer(loc) then return false end
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

local containerKinds={}
local function containerKind(value)
    if type(value)~="string" then return false end
    if containerKinds[value]~=nil then return containerKinds[value] end
    local lower=value:lower()
    local result=lower=="open" or lower=="container"
    containerKinds[value]=result
    return result
end
local function containerSource(loc)
    return containerKind(loc.source) or containerKind(loc.kind)
end

local dungeonZones = {}
local function dungeonFamily(name)
    local key=ns.DungeonNameKey(name)
    return (key:match("^(.-):") or key:match("^(.-)%s+%-%s+") or key):match("^%s*(.-)%s*$")
end
for name in pairs(ns.DungeonReference or {}) do dungeonZones[ns.DungeonNameKey(name)]=true;dungeonZones[dungeonFamily(name)]=true end
for name in pairs(ns.DungeonEntrances or {}) do dungeonZones[ns.DungeonNameKey(name)]=true;dungeonZones[dungeonFamily(name)]=true end
local function isDungeonName(name)
    return name and (dungeonZones[ns.DungeonNameKey(name)] or dungeonZones[dungeonFamily(name)])
end

local function sortedKeys(values)
    local keys = {}
    for key in pairs(values) do keys[#keys+1] = key end
    table.sort(keys, function(a,b) return a:lower() < b:lower() end)
    return keys
end

local professionTiers={
    {name="Primary Crafting",professions={"Alchemy","Blacksmithing","Enchanting","Engineering","Leatherworking","Tailoring"}},
    {name="Secondary Crafting",professions={"Cooking","First Aid"}},
    {name="Primary Gathering",professions={"Herbalism","Mining","Skinning"}},
    {name="Secondary Gathering",professions={"Fishing"}},
}
local professionOrder,professionTier={},{}
for tierIndex,tier in ipairs(professionTiers) do
    for index,name in ipairs(tier.professions) do
        professionOrder[name]=tierIndex*100+index;professionTier[name]=tierIndex
    end
end
local function professionLess(a,b)
    local aa,bb=professionOrder[a] or math.huge,professionOrder[b] or math.huge
    if aa~=bb then return aa<bb end
    return a:lower()<b:lower()
end
local function sortedProfessions(values)
    local names=sortedKeys(values);table.sort(names,professionLess);return names
end

local function openingZone()
    local position=E.Position()
    local info=position and position.mapID and E.Call(C_Map and C_Map.GetMapInfo,position.mapID)
    local exported=position and position.mapID and ns.ForeverCatalog and ns.ForeverCatalog.zones and ns.ForeverCatalog.zones[position.mapID]
    local name=info and (not info.mapType or info.mapType>=3) and info.name
        or exported and exported.isZone~=false and exported.name
    if type(name)~="string" or name=="" then name=E.Call(GetRealZoneText) end
    return type(name)=="string" and name~="" and name~="Unknown" and name or nil
end

local professionSkillIDs={Alchemy=171,Blacksmithing=164,Enchanting=333,Engineering=202,
    Leatherworking=165,Tailoring=197,Cooking=185,["First Aid"]=129,Herbalism=182,Mining=186,Skinning=393,Fishing=356}
local professionSkillNames={}
for name,id in pairs(professionSkillIDs) do professionSkillNames[id]=name end
local function readLearnedProfessions()
    local learned,readable={},false
    local function add(name,rank,id)
        if not E.Public(rank) or type(rank)~="number" or rank<1 then return end
        local canonical=E.Public(id) and professionSkillNames[id] or nil
        if not canonical and E.Public(name) and professionSkillIDs[name] then canonical=name end
        if canonical then learned[canonical]=true end
    end
    local skill=C_SkillInfo or {}
    if type(skill.GetNumSkillLines)=="function" and type(skill.GetSkillLineInfo)=="function" then
        local ok,count=pcall(skill.GetNumSkillLines)
        if ok and E.Public(count) and type(count)=="number" and count>=0 and count<=10000 then
            local valid=count==0
            for index=1,count do
                local success,row=pcall(skill.GetSkillLineInfo,index)
                if success and E.Public(row) and type(row)=="table" and E.Public(row.name) and type(row.name)=="string" then
                    valid=true
                    if E.Public(row.isHeader) and not row.isHeader then add(row.name,row.rank,row.skillLineID) end
                end
            end
            readable=readable or valid
        end
    elseif type(GetNumSkillLines)=="function" and type(GetSkillLineInfo)=="function" then
        local ok,count=pcall(GetNumSkillLines)
        if ok and E.Public(count) and type(count)=="number" and count>=0 and count<=10000 then
            local valid=count==0
            for index=1,count do
                local success,name,header,_,rank=pcall(GetSkillLineInfo,index)
                if success and E.Public(name) and type(name)=="string" then
                    valid=true
                    if E.Public(header) and not header then add(name,rank) end
                end
            end
            readable=readable or valid
        end
    end
    if type(skill.GetSkillLineInfoByID)=="function" then
        for name,id in pairs(professionSkillIDs) do
            local ok,row=pcall(skill.GetSkillLineInfoByID,id)
            if ok and E.Public(row) and type(row)=="table" then
                readable=true;add(name,row.rank,id)
            end
        end
    end
    if type(GetProfessions)=="function" and type(GetProfessionInfo)=="function" then
        local slots={pcall(GetProfessions)}
        if slots[1] then
            local valid=true
            for index=2,7 do
                local slot=slots[index]
                if slot~=nil then
                    if E.Public(slot) and type(slot)=="number" then
                        local ok,name,_,rank,_,_,_,id=pcall(GetProfessionInfo,slot)
                        if ok and E.Public(name) and type(name)=="string" then add(name,rank,id) else valid=false end
                    else valid=false end
                end
            end
            readable=readable or valid
        end
    end
    if C_TradeSkillUI and type(C_TradeSkillUI.GetAllProfessionTradeSkillLines)=="function"
        and type(C_TradeSkillUI.GetProfessionInfoBySkillLineID)=="function" then
        local ok,ids=pcall(C_TradeSkillUI.GetAllProfessionTradeSkillLines)
        if ok and E.Public(ids) and type(ids)=="table" then
            local valid=true
            for _,id in ipairs(ids) do
                local success,row=pcall(C_TradeSkillUI.GetProfessionInfoBySkillLineID,id)
                if success and E.Public(row) and type(row)=="table" then add(row.professionName,row.skillLevel,id) else valid=false end
            end
            readable=readable or valid
        end
    end
    if not readable and E.state and type(E.state.skills)=="table" then
        readable=true
        for name,entry in pairs(E.state.skills) do
            if type(entry)=="table" then add(name,entry.rank,entry.id) end
        end
    end
    return learned,readable
end

local function showRecipes()
    if panel then panel:SetShown(not panel:IsShown()); return end
    local assets = "Interface\\AddOns\\GrindingForever\\Media\\"
    local face, catalog = assets.."Naowh.ttf", ns.RecipeCatalog
    panel = CreateFrame("Frame", nil, UIParent)
    panel:SetSize(480,720); panel:SetPoint("CENTER")
    N.ApplyWindowLayer(panel,"recipes")
    panel:EnableMouse(true); panel:SetMovable(true); panel:SetClampedToScreen(true)
    local learned,professionKnowledgeAvailable=readLearnedProfessions()
    local state={browseOpen=true,browseActivated=true,how="world",zone=openingZone(),profession="mine",
        myProfessions=learned,professionKnowledgeAvailable=professionKnowledgeAvailable,
        groupOpen={},categoryOpen={},scroll=0,sourcePage=0}
    local recipes,revision,sourceRevision,groups,entries = nil,nil,nil,{},{}
    local pendingItemNames,mapGroups={},{}
    local locationGroups,browseGroups,sourceResults,sourceFilter={{},{},{}},nil,{},nil
    local acquisitionProfiles,npcTargetKeys={},{}
    local refresh,resize,drawVisible,syncScroll,cancelPreparation,queueRefresh
    local preparation,publishedContext
    local function px(n) return N.PixelSize(panel,n) end
    local function font(text,size,dark)
        text:SetFont(face,px(size),"")
        if dark then text:SetTextColor(.12,.07,.03,1)
        else text:SetTextColor(245/255,223/255,174/255,1) end
        text:SetJustifyH("LEFT"); text:SetWordWrap(true)
    end
    local search=CreateFrame("EditBox",nil,panel)
    search:SetAutoFocus(false); search:SetTextInsets(7,7,0,0); search:SetText("")
    local searchFill=search:CreateTexture(nil,"BACKGROUND")
    searchFill:SetAllPoints();searchFill:SetColorTexture(.12,.07,.03,.98)
    N.BronzeRectangle(search,1)
    local placeholder=N.MakeText(search,13,"Search recipes or items",true)
    placeholder:SetPoint("LEFT",search,"LEFT",7,0);placeholder:SetAlpha(.8)
    local searchClear=N.WoodButton(panel,"×",26,function() search:SetText(""); if refresh then refresh() end end)
    local filterFrame=CreateFrame("Frame",nil,panel)
    local filterCream=filterFrame:CreateTexture(nil,"BACKGROUND")
    filterCream:SetAllPoints();filterCream:SetColorTexture(.98,.90,.73,.88)
    N.BronzeRectangle(filterFrame,1)
    local professionButton=N.WoodButton(filterFrame,"All professions",200)
    local locationButton=N.WoodButton(filterFrame,"All locations",200)
    local howButton=N.WoodButton(filterFrame,"Vendors, quests & drops",200)
    local filterLabels={}
    for i,label in ipairs({"Profession","Location","Source"}) do
        filterLabels[i]=N.MakeText(filterFrame,12,label,true)
    end
    for _,button in ipairs({professionButton,locationButton,howButton}) do button.arrow=N.ButtonArrow(button,"down","RIGHT") end
    local activeFilters=N.MakeText(panel,12,"",true)
    local clearFilters=N.WoodButton(panel,"Clear",64)
    local status=N.MakeText(panel,12,"",true)
    local feedback=N.MakeText(panel,12,"",true)
    local plan=ns.ProfessionOnboarding
    local planButton=plan and N.WoodButton(panel,"Profession plan",130,plan.Open)
    local viewport=CreateFrame("ScrollFrame",nil,panel)
    local content=CreateFrame("Frame",nil,viewport)
    viewport:SetScrollChild(content)
    local headers={}
    local categoryBodies,categorySpans={},{}
    local detail=CreateFrame("Frame",nil,content)
    detail.cream=detail:CreateTexture(nil,"BACKGROUND")
    detail.cream:SetAllPoints();detail.cream:SetColorTexture(.98,.90,.73,.88)
    N.BronzeRectangle(detail,1)
    detail.nodes={};detail:Hide()
    local measure=N.MakeText(content,14,"",true);measure:Hide()
    local api={frame=panel,search=search,filterFrame=filterFrame,
        professionButton=professionButton,locationButton=locationButton,howButton=howButton,
        activeFilters=activeFilters,clearFilters=clearFilters,viewport=viewport,content=content,
        headers=headers,categoryBodies=categoryBodies,categorySpans=categorySpans,
        detail=detail,state=state,groups=groups,entries=entries,
        status=status,feedback=feedback,planButton=planButton}
    ns.RecipeLibrary=api
    if ns.RegisterItemSearchBox then ns.RegisterItemSearchBox(search) end

    -- Shared catalogue/location helpers are kept local to this window.
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

    local function uncachedLocationGroup(loc)
        local name = loc.zone or loc.dungeon
        if loc.raid or (name and raidZones[ns.DungeonNameKey(name)]) then return "Raids" end
        if loc.dungeon or isDungeonName(name) then return "Dungeons" end
        if name == "Zephras Isle" then return name end
        local entry = name and ns.ForeverData.zones[name]
        if entry and entry.raid then return "Raids" end
        if entry and entry.instance then return "Dungeons" end
        local exported=loc.mapID and ns.ForeverCatalog and ns.ForeverCatalog.zones and ns.ForeverCatalog.zones[loc.mapID]
        if exported and (isDungeonName(exported.name) or isDungeonName(exported.continent)) then return "Dungeons" end
        return mapContinent(loc.mapID or (entry and entry.mapID))
    end
    local function locationGroup(loc)
        local kind=loc.raid and 1 or loc.dungeon and 2 or 3
        local names=locationGroups[kind]
        local name=loc.zone or loc.dungeon or false
        local maps=names[name]
        if not maps then maps={};names[name]=maps end
        local mapID=loc.mapID or false
        if maps[mapID]~=nil then return maps[mapID] or nil end
        local value=uncachedLocationGroup(loc)
        maps[mapID]=value or false
        return value
    end

    local sourceKinds = {vendor="Vendor", trainer="Trainer", drop="Drop", open="Container", quest="Quest", ["quest reward"]="Quest Reward"}
    local coordinateFields={"mapID","x","y","zone","coordinateEvidence","coordinateSourceRevision","coordinateSourceURL",
        "coordinateRole","routingAllowed","associationStatus"}
    local function sameCoordinate(a,b)
        return a==b or type(a)=="number" and type(b)=="number" and math.abs(a-b)<=.00000001
    end
    local function normalizedSource(loc)
        local data=ns.ForeverCatalog
        local kind=loc.source or loc.kind
        kind=type(kind)=="string" and kind:lower()
        local id=loc.npcID or (kind=="vendor" or kind=="trainer" or kind=="drop") and loc.sourceID
        if not id or not data then return loc end
        local replacement=data.canonicalSingleSpawnNPCs and data.canonicalSingleSpawnNPCs[id]
        if not replacement then
            for _,correction in ipairs(data.sourceCoordinateCorrections and data.sourceCoordinateCorrections[id] or {}) do
                local from=correction.from
                if from and loc.mapID==from.mapID and sameCoordinate(loc.x,from.x) and sameCoordinate(loc.y,from.y) then replacement=correction.to;break end
            end
        end
        if not replacement then return loc end
        local changed=false
        for _,key in ipairs(coordinateFields) do if replacement[key]~=nil and replacement[key]~=loc[key] then changed=true;break end end
        if not changed then return loc end
        local normalized={};for key,value in pairs(loc) do normalized[key]=value end
        local history={}
        for _,item in ipairs(loc.sourceLocationHistory or {}) do history[#history+1]=item end
        local original={}
        for _,key in ipairs(coordinateFields) do original[key]=loc[key] end
        history[#history+1]=original
        for _,item in ipairs(replacement.sourceLocationHistory or {}) do history[#history+1]=item end
        for _,key in ipairs(coordinateFields) do if replacement[key]~=nil then normalized[key]=replacement[key] end end
        normalized.sourceLocationHistory=history
        return normalized
    end
    local function mergeSources(recipe, zone, mapID,checkpoint)
        local data = ns.ForeverCatalog
        if not data then return end
        local indexes = {}
        local function matchKey(loc)
            local id = loc.npcID or loc.questID or loc.sourceID or loc.name or ""
            return (loc.source or "") .. ":" .. tostring(id) .. ":" .. (loc.zone or loc.mapID or "")
        end
        for index, loc in ipairs(recipe.locations) do
            loc=normalizedSource(loc);recipe.locations[index]=loc;indexes[matchKey(loc)]=index
            if checkpoint then checkpoint() end
        end
        local function add(sources)
            for _, row in ipairs(sources or {}) do
                if checkpoint then checkpoint() end
                    row=normalizedSource(row)
                local src = row.source or (row.kind and sourceKinds[row.kind:lower()])
                if src and (not zone or row.zone==zone or row.dungeon==zone or mapID and row.mapID==mapID) then
                    local loc = {}
                    for k, value in pairs(row) do loc[k] = value end
                    loc.source = src
                    if catalog.ApplyOfferCost then loc=catalog.ApplyOfferCost(recipe.learnableItemID,loc) end
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
                        if catalog.HasNativeOfferCost and catalog.HasNativeOfferCost(loc) then
                            for _,field in ipairs(catalog.OfferCostFields or {}) do merged[field]=loc[field] end
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

    local function browseZones(checkpoint)
        if browseGroups then return browseGroups end
        local groups = {["Eastern Kingdoms"]={}, Kalimdor={}, ["Zephras Isle"]={}, Dungeons={}, Raids={}}
        local function add(group, name)
            if isDungeonName(group) then group="Dungeons" end
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
            if checkpoint then checkpoint() end
            local group=locationGroup({zone=name,mapID=info.mapID})
            if name~=group then add(group,name) end
        end
        for mapID, info in pairs(ns.ForeverCatalog and ns.ForeverCatalog.zones or {}) do
            if checkpoint then checkpoint() end
            local group = locationGroup({zone=info.name,mapID=mapID})
            if info.isZone ~= false and (info.name~=group or group=="Zephras Isle") then add(group,info.name) end
        end
        add("Eastern Kingdoms", "Blasted Lands")
        add("Eastern Kingdoms", "Stranglethorn Vale")
        add("Zephras Isle", "Zephras Isle")
        for _, recipe in ipairs(recipes or {}) do
            for _, loc in ipairs(recipe.locations) do
                add(locationGroup(loc), loc.zone or loc.dungeon)
                if checkpoint then checkpoint() end
            end
        end
        browseGroups=groups
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
    local menuEntry
    menu.frame:HookScript("OnShow",function()
        if not menuOwner then return end
        N.dropdownMenus=N.dropdownMenus or {}
        menuEntry={menu.frame,menuOwner}
        N.dropdownMenus[#N.dropdownMenus+1]=menuEntry
    end)
    menu.frame:HookScript("OnHide",function()
        if menuEntry then
            for i=#(N.dropdownMenus or {}),1,-1 do
                if N.dropdownMenus[i]==menuEntry then table.remove(N.dropdownMenus,i) end
            end
            menuEntry=nil
        end
        submenu.frame:Hide();menuOwner,openGroup=nil,nil
    end)
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
        local name = link and link:match("|h%[(.-)%]|h") or catalog.ItemName and catalog.ItemName(id) or E.ItemLabel(id)
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
        local favor=merchantFavor(loc) and true or false
        local recorded=catalog.OfferCostText and catalog.OfferCostText(loc,favor)
        if recorded then return recorded end
        if merchantFavor(loc) then
            return "Merchant's Favor · Cost unrecorded"
        end
        return "Price unrecorded"
    end

    local function skillText(recipe)
        local skill=(recipe.skill or 0)>0 and " "..recipe.skill or ""
        return (recipe.profession or "Recipe")..skill
    end

    local function sourceCountText(row)
        local count=#row.sources
        return (count==0 and "No listed acquisition source" or count..(count==1 and " source" or " sources"))
            ..(row.known and " · Known" or "")
    end

    local function sourceName(loc)
        return catalog.SourceDisplayName and catalog.SourceDisplayName(loc) or loc.name or loc.source or "Source"
    end
    local function sourceFaction(loc)
        local function known(value)
            if not E.Public(value) or type(value)~="string" then return end
            if value=="Horde" or value=="H" then return "H","Horde" end
            if value=="Alliance" or value=="A" then return "A","Alliance" end
            if value=="Both" or value=="Neutral" or value=="AH" or value=="H+A" then return "H+A","Both" end
        end
        local id=loc.npcID or (loc.source=="Vendor" or loc.source=="Trainer" or loc.source=="Drop") and loc.sourceID
        if not id then return end
        local entities=ns.RecipeSourceFacts and ns.RecipeSourceFacts.entities
        local kinds=loc.source=="Trainer" and {"Trainer","Vendor","Drop"}
            or loc.source=="Drop" and {"Drop","Vendor","Trainer"} or {"Vendor","Trainer","Drop"}
        for _,kind in ipairs(kinds) do
            local entity=entities and entities[kind] and entities[kind][id]
            local badge,faction=known(entity and entity[6])
            if badge then return badge,faction end
        end
        -- Older observations stored the player's faction at an NPC visit.
        -- Those values cannot establish the NPC's allegiance.
        for _,field in ipairs({"evidence","coordinateEvidence","provenance","rawCoordinateRole","positionKind"}) do
            local value=type(loc[field])=="string" and loc[field]:lower() or ""
            if value:find("player",1,true) or value:find("observ",1,true) or value:find("tracker",1,true)
                or value:find("manual",1,true) then return end
        end
        if loc.source~="Quest" and loc.source~="Quest Reward" then return known(loc.faction) end
    end
    local function sourceHeading(loc)
        local id=loc.npcID or (loc.source=="Vendor" or loc.source=="Trainer" or loc.source=="Drop") and loc.sourceID
        local data=ns.ForeverQuestData
        local aliases=ns.ForeverCatalog and ns.ForeverCatalog.npcNames
        local name=id and (data and data.names and data.names["npc:"..id] or aliases and aliases[id])
        if not (type(name)=="string" and name:find("%S")) and id then
            local entities=ns.RecipeSourceFacts and ns.RecipeSourceFacts.entities
            for _,kind in ipairs({"Vendor","Trainer","Drop"}) do
                local entity=entities and entities[kind] and entities[kind][id]
                if entity and type(entity[1])=="string" and entity[1]:find("%S") then name=entity[1];break end
            end
        end
        local badge=sourceFaction(loc)
        local label=type(name)=="string" and name:find("%S") and sourceName({name=name,npcID=id,source=loc.source}) or sourceName(loc)
        return label..(badge and " ("..badge..")" or "")
    end
    local function compactPrice(loc)
        if loc.source~="Vendor" and loc.source~="Trainer" then return end
        local function number(value,minimum)
            return E.Public(value) and type(value)=="number" and value==value and value>=minimum
                and value<=1e12 and value==math.floor(value) and value or nil
        end
        local function coin(amount)
            local native=E.Call(GetCoinTextureString,amount)
            return E.Public(native) and type(native)=="string" and native~="" and native or amount.."c"
        end
        local function token(amount,id,name)
            if id==3402 then return amount.." |T135725:13:13:0:0|t" end
            return amount.." × "..(type(name)=="string" and name:find("%S") and name or "Currency "..id)
        end
        if loc.costComponentsComplete==true and type(loc.costComponents)=="table" then
            local parts,valid={},true
            for _,component in ipairs(loc.costComponents) do
                local amount=type(component)=="table" and number(component.amount,1)
                if not amount then valid=false;break end
                if component.kind=="coin" then parts[#parts+1]=coin(amount)
                elseif component.kind=="currency" and number(component.currencyID,1) then
                    parts[#parts+1]=token(amount,component.currencyID,component.name)
                elseif component.kind=="item" and number(component.itemID,1) then
                    local name=E.Public(component.name) and type(component.name)=="string" and component.name:find("%S") and component.name
                    parts[#parts+1]=amount.." × "..(name or catalog.ItemName(component.itemID) or "Item "..component.itemID)
                else valid=false;break end
            end
            if valid and #parts>0 then return table.concat(parts," + ") end
        end
        local amount=number(loc.currencyAmount,1)
        if amount and loc.currencyID==3402 then
            local price=number(loc.price,1)
            return (price and coin(price).." + " or "")..token(amount,3402)
        end
        if catalog.IsVerifiedCoinOffer and catalog.IsVerifiedCoinOffer(loc) then return coin(loc.price) end
        if not loc.costReadIncomplete and loc.hasExtendedCost~=true and number(loc.price,1) then return coin(loc.price) end
        return loc.source=="Trainer" and "Training cost unrecorded" or "Cost unrecorded"
    end
    local function dropTarget(loc)
        local id=loc.npcID or loc.source=="Drop" and loc.sourceID
        if not id then return end
        if npcTargetKeys[id] then return npcTargetKeys[id],id end
        local names=ns.ForeverQuestData and ns.ForeverQuestData.names
        local aliases=ns.ForeverCatalog and ns.ForeverCatalog.npcNames
        local canonical=names and names["npc:"..id] or aliases and aliases[id]
        local key=type(canonical)=="string" and canonical~="" and ("name:"..canonical:lower()) or ("npc:"..id)
        npcTargetKeys[id]=key
        return key,id
    end
    local function dropProfile(recipe,checkpoint)
        local cached=acquisitionProfiles[recipe]
        if cached then return cached end
        local types,npcs,count,npcCount,generic,hasDrops={},{},0,0,false,false
        for _,loc in ipairs(recipe.locations or {}) do
            if checkpoint then checkpoint() end
            if sourceTab(loc)=="Drops" then
                hasDrops=true;generic=generic or loc.source=="World Drop"
                local key,id=dropTarget(loc)
                if key and not types[key] then types[key]=true;count=count+1 end
                if id and not npcs[id] then npcs[id]=true;npcCount=npcCount+1 end
            end
        end
        local rollup=ns.ForeverCatalog and ns.ForeverCatalog.dropSummary and ns.ForeverCatalog.dropSummary[recipe.learnableItemID]
        local documented=recipe.targetedDropType or rollup and rollup.targetedNPCType
        cached={hasDrops=hasDrops,broad=hasDrops and not documented and (generic or count>1),npcCount=npcCount}
        acquisitionProfiles[recipe]=cached
        return cached
    end
    local conditionFields={"requirement","class","race","faction","requiredLevel","requiredSkill","requiredQuest",
        "reputationID","reputationStanding","specializationSpell"}
    local function conditionKey(loc)
        local parts,any={},false
        for _,key in ipairs(conditionFields) do
            local value=loc[key]
            if value~=nil then any=true end
            parts[#parts+1]=value~=nil and tostring(value) or ""
        end
        return any and table.concat(parts,"\031") or nil
    end
    local function sameConditions(a,b)
        for _,key in ipairs(conditionFields) do if a[key]~=nil and a[key]~=b[key] then return false end end
        return true
    end
    local function knownLocation(loc)
        return loc.zone or loc.dungeon or catalog.HasWaypoint and catalog.HasWaypoint(loc)
    end
    local function verifiedChance(loc)
        return type(loc.rate)=="number" and loc.rate>0 and loc.rate<=1 and type(loc.sampleSize)=="number" and loc.sampleSize>0
            and not loc.classicFallback and not (type(loc.provenance)=="string" and loc.provenance:lower():find("classic",1,true))
    end
    local displayConditionFields={"requirement","class","race","faction","requiredLevel","requiredSkill","requiredQuest",
        "reputationID","reputationStanding","specializationSpell","price","currency","currencyType","currencyID",
        "currencyItemID","currencyAmount","merchantFavor","questRole","sourceRole","role","sourceQuest",
        "costSignature","quantity","hasExtendedCost"}
    local function displayIdentity(loc)
        if loc.source=="Vendor" or loc.source=="Trainer" then return loc.source,loc.npcID or loc.sourceID end
        if loc.source=="Quest" or loc.source=="Quest Reward" then return "Quest",loc.questID or loc.sourceQuest and loc.sourceID end
    end
    local function displayPoint(loc)
        return loc.coordinateRole~="player" and loc.positionKind~="player"
            and catalog.HasWaypoint and catalog.HasWaypoint(loc)
    end
    local function displayPlace(loc)
        local name=loc.zone or loc.dungeon
        return type(name)=="string" and name~="" and name~="Unknown" and name or nil
    end
    local function compatibleDisplaySources(a,b,kind)
        for _,field in ipairs(displayConditionFields) do
            if a[field]~=nil and b[field]~=nil and a[field]~=b[field] then return false end
        end
        if a.mapID and b.mapID and a.mapID~=b.mapID then return false end
        local aa,bb=displayPlace(a),displayPlace(b)
        if aa and bb and aa~=bb then return false end
        if kind=="Quest" then
            if a.npcID and b.npcID and a.npcID~=b.npcID then return false end
            if (a.npcID~=nil)~=(b.npcID~=nil) and not (a.mapID and a.mapID==b.mapID) then return false end
        end
        if displayPoint(a) and displayPoint(b) and (math.abs(a.x-b.x)>2 or math.abs(a.y-b.y)>2) then return false end
        return true
    end
    local function displaySourceScore(loc,kind)
        local score=displayPoint(loc) and 100000 or 0
        if kind=="Quest" and loc.npcID then score=score+10000 end
        if displayPlace(loc) then score=score+100 end
        if type(loc.name)=="string" and loc.name~="" and loc.name~=loc.source then score=score+20 end
        for _,field in ipairs(displayConditionFields) do if loc[field]~=nil then score=score+1 end end
        return score
    end
    local function dedupeDisplaySources(sources,checkpoint)
        local ordered={}
        for index,loc in ipairs(sources) do
            if checkpoint then checkpoint() end
            local kind,id=displayIdentity(loc)
            ordered[#ordered+1]={location=loc,kind=kind,id=id,index=index,score=displaySourceScore(loc,kind)}
        end
        table.sort(ordered,function(a,b)return a.score==b.score and a.index<b.index or a.score>b.score end)
        local clusters={}
        for _,entry in ipairs(ordered) do
            if checkpoint then checkpoint() end
            local match,matches
            if entry.kind and entry.id then
                matches=0
                for _,cluster in ipairs(clusters) do
                    if checkpoint then checkpoint() end
                    if cluster.kind==entry.kind and cluster.id==entry.id then
                        local compatible=true
                        for _,other in ipairs(cluster.members) do
                            if checkpoint then checkpoint() end
                            if not compatibleDisplaySources(entry.location,other,entry.kind) then compatible=false;break end
                        end
                        if compatible then match=cluster;matches=matches+1 end
                    end
                end
            end
            if matches==1 then
                match.members[#match.members+1]=entry.location
                for _,field in ipairs(displayConditionFields) do
                    if match.location[field]==nil then match.location[field]=entry.location[field] end
                end
                for _,field in ipairs(catalog.OfferCostFields or {}) do
                    if match.location[field]==nil then match.location[field]=entry.location[field] end
                end
                match.index=math.min(match.index,entry.index)
            else
                local copy={};for key,value in pairs(entry.location) do copy[key]=value end
                clusters[#clusters+1]={location=copy,kind=entry.kind,id=entry.id,index=entry.index,members={entry.location}}
            end
        end
        table.sort(clusters,function(a,b)return a.index<b.index end)
        local result={};for _,cluster in ipairs(clusters) do result[#result+1]=cluster.location end
        return result
    end
    local function cacheAcquisition(cache,result,checkpoint)
        result.sources=dedupeDisplaySources(result.sources,checkpoint)
        cache.acquisition=result
        return result
    end
    local broadPlaceLabels={world=true,azeroth=true,unknown=true,unrecorded=true,["location unrecorded"]=true,
        ["current zone"]=true,["all locations"]=true,["world drop"]=true,["eastern kingdoms"]=true,
        kalimdor=true,dungeons=true,raids=true}
    local function highestNPCLocations(best,sources,checkpoint)
        local places,seen={},{}
        local function usable(value)
            if type(value)~="string" then return end
            local label=value:match("^%s*(.-)%s*$")
            return label~="" and not broadPlaceLabels[label:lower()] and label or nil
        end
        local function add(value)
            local label=usable(value)
            if label and not seen[label:lower()] then seen[label:lower()]=true;places[#places+1]=label end
        end
        local function addRecord(loc)
            if not loc then return end
            add(usable(loc.dungeon) or loc.zone)
        end
        local function npcID(loc)
            if not loc then return end
            local value=loc.npcID
            if not value and loc.source=="Drop" then value=loc.sourceID end
            local id=(type(value)=="number" or type(value)=="string") and tonumber(value) or nil
            return id and id>0 and id or nil
        end
        addRecord(best)
        local id=npcID(best)
        if id then
            for _,loc in ipairs(sources) do
                if checkpoint then checkpoint() end
                if sourceTab(loc)=="Drops" and npcID(loc)==id then addRecord(loc) end
            end
            if #places==0 then
                local labels=ns.ForeverCatalog and ns.ForeverCatalog.npcLocationLabels
                local record=labels and labels[id]
                for _,label in ipairs(record and record.locations or {}) do
                    if checkpoint then checkpoint() end
                    add(label)
                end
            end
        end
        table.sort(places,function(a,b)return a:lower()<b:lower()end)
        return #places>0 and table.concat(places,", ") or "Unrecorded"
    end
    local function prepareAcquisition(recipe,sources,checkpoint)
        local cache=sourceResults[recipe]
        if cache.acquisition then return cache.acquisition end
        local profile=dropProfile(recipe,checkpoint)
        local result={sources=sources,conditions={}}
        if not profile.hasDrops then return cacheAcquisition(cache,result,checkpoint) end
        local drops,nonDrops,types,ids,conditionSeen,zones,areas={}, {},{},{},{},{},{}
        local best
        local function consider(loc)
            if not verifiedChance(loc) then return end
            if not best or loc.rate>best.rate or loc.rate==best.rate and (loc.sampleSize>best.sampleSize
                or loc.sampleSize==best.sampleSize and not (catalog.HasWaypoint and catalog.HasWaypoint(best))
                    and catalog.HasWaypoint and catalog.HasWaypoint(loc)) then best=loc end
        end
        for _,loc in ipairs(sources) do
            if checkpoint then checkpoint() end
            if sourceTab(loc)=="Drops" then
                drops[#drops+1]=loc;consider(loc)
                local zone=loc.zone or loc.dungeon
                if zone then zones[zone]=true end
                local area=locationGroup(loc);if area then areas[area]=true end
                local key,id=dropTarget(loc)
                if id then ids[id]=ids[id] or loc;if catalog.HasWaypoint and catalog.HasWaypoint(loc) then ids[id]=loc end end
                if key then
                    local level=types[key] or {};types[key]=level
                    local low,high=tonumber(loc.mobMinLevel),tonumber(loc.mobMaxLevel)
                    if low and high and low>0 and high>=low then
                        level.low=math.min(level.low or low,low);level.high=math.max(level.high or high,high)
                    end
                end
                local condition=conditionKey(loc)
                if condition and not conditionSeen[condition] then conditionSeen[condition]=true;result.conditions[#result.conditions+1]=loc end
            else nonDrops[#nonDrops+1]=loc end
        end
        if #drops==0 then return cacheAcquisition(cache,result,checkpoint) end
        if profile.broad then
            local rollup=ns.ForeverCatalog and ns.ForeverCatalog.dropSummary and ns.ForeverCatalog.dropSummary[recipe.learnableItemID]
            local highest=rollup and (rollup.highestRecorded or rollup.highestObserved)
            local id=highest and (highest.npcID or highest.sourceID)
            if id and ids[id] and verifiedChance(highest) then
                local combined={};for key,value in pairs(ids[id]) do combined[key]=value end
                for _,key in ipairs({"rate","sampleSize","sampleKind","drops","reporters","provenance"}) do combined[key]=highest[key] end
                consider(combined)
            end
            local bestID=best and (best.npcID or best.sourceID)
            local target=bestID and ids[bestID]
            if target and catalog.HasWaypoint and catalog.HasWaypoint(target) and not catalog.HasWaypoint(best) then
                local combined={};for key,value in pairs(target) do combined[key]=value end
                for _,key in ipairs({"rate","sampleSize","sampleKind","drops","reporters","provenance"}) do combined[key]=best[key] end
                for _,key in ipairs(conditionFields) do if best[key]~=nil then combined[key]=best[key] end end
                best=combined
            end
            local count,known,sum=0,0,0
            for _,level in pairs(types) do
                count=count+1
                if level.low and level.high then known=known+1;sum=sum+(level.low+level.high)/2 end
            end
            local mean=known>0 and sum/known or nil
            local selectedNPCs=0;for _ in pairs(ids) do selectedNPCs=selectedNPCs+1 end
            if rollup and selectedNPCs==profile.npcCount and count==selectedNPCs and rollup.documentedNPCCount==selectedNPCs
                and type(rollup.meanNPCLevel)=="number" and rollup.meanNPCLevel>0 and type(rollup.levelNPCCount)=="number"
                and rollup.levelNPCCount>0 and rollup.levelNPCCount<=selectedNPCs then
                mean,known=rollup.meanNPCLevel,rollup.levelNPCCount
            end
            local names=sortedKeys(zones)
            local area
            if sourceFilter.zone=="current" then area=sourceFilter.name else area=sourceFilter.zone or sourceFilter.continent end
            if not area then
                if #names>0 and #names<=2 then area=table.concat(names,", ")
                else local regions=sortedKeys(areas);area=#regions>0 and table.concat(regions,", ") or "Unrecorded" end
            end
            result.sources=nonDrops;result.drop={best=best,typeCount=count,knownLevels=known,meanLevel=mean,area=area,
                foundIn=highestNPCLocations(best,sources,checkpoint)}
        else
            local retained={}
            for _,loc in ipairs(sources) do
                if checkpoint then checkpoint() end
                local duplicate=false
                local id=loc.npcID or loc.source=="Drop" and loc.sourceID
                if sourceTab(loc)=="Drops" and id and not knownLocation(loc) then
                    for _,other in ipairs(drops) do
                        if checkpoint then checkpoint() end
                        if other~=loc and (other.npcID or other.sourceID)==id and knownLocation(other) and sameConditions(loc,other) then duplicate=true;break end
                    end
                end
                if not duplicate then retained[#retained+1]=loc end
            end
            result.sources=retained
        end
        return cacheAcquisition(cache,result,checkpoint)
    end


    local howChoices={{id="world",label="Vendors, Quests & Drops"},{id="trained",label="Trained Recipes"},
        {id="favor",label="Merchant's Favor"}}
    local function howLabel()
        for _,choice in ipairs(howChoices) do if choice.id==state.how then return choice.label end end
    end
    local function queryText() return (search:GetText() or ""):match("^%s*(.-)%s*$"):lower() end
    local function professionLabel() return state.profession=="mine" and "My Professions" or state.profession or "All professions" end
    local function singleProfession() return state.profession~=nil and state.profession~="mine" end
    local function matchesProfession(recipe,searching)
        if searching or not state.profession then return true end
        if state.profession=="mine" then return state.myProfessions[recipe.profession] and true or false end
        return recipe.profession==state.profession
    end
    local function filterControls(active)
        local searching=queryText()~=""
        local disabled=active or searching
        for index,button in ipairs({professionButton,locationButton,howButton}) do
            if button.SetEnabled then button:SetEnabled(not disabled) end
            button:EnableMouse(not disabled);button:SetAlpha(disabled and .55 or 1)
            filterLabels[index]:SetAlpha(searching and .55 or 1)
        end
        if clearFilters.SetEnabled then clearFilters:SetEnabled(not searching) end
        clearFilters:EnableMouse(not searching);clearFilters:SetAlpha(searching and .55 or 1)
    end
    local function loadingStatus() return queryText()~="" and "Searching all recipes..." or "Loading recipes..." end
    local function recipeKey(recipe) return recipe.key or recipe.spellID or recipe.learnableItemID or recipe.name end
    local function rank(recipe)
        local value=tonumber(recipe.requiredSkill)
        if not value or value<=0 then value=tonumber(recipe.skill) end
        return value and value>0 and value or math.huge
    end
    local function skillLabel(recipe)
        local value=rank(recipe)
        return value<math.huge and ((recipe.profession or "Recipe").." "..value) or (recipe.profession or "Recipe")
    end
    local function stateNow() return E.state or {} end
    local function matchesLocation(loc,current)
        if current.global then return true end
        if state.zone=="current" then
            return loc.mapID==current.mapID or (loc.zone or loc.dungeon)==current.name
        end
        if state.zone and (loc.zone or loc.dungeon)~=state.zone then return false end
        if state.continent then
            local group=locationGroup(loc)
            if state.continent=="World" then return group=="Eastern Kingdoms" or group=="Kalimdor" or group=="Zephras Isle" end
            if state.continent=="Instances" then return group=="Dungeons" or group=="Raids" end
            if group~=state.continent then return false end
        end
        return true
    end
    local function matchesHow(loc,current)
        if containerSource(loc) then return false end
        if current.global then return true end
        if state.how=="trained" then return loc.source=="Trainer" end
        if state.how=="favor" then return merchantFavor(loc) and true or false end
        if state.how=="world" then return loc.source~="Trainer" and not merchantFavor(loc) and sourceTab(loc)~="All" end
        return false
    end
    local function prepareSourceFilter()
        local current={global=queryText()~=""}
        local how,zone,continent=state.how,state.zone,state.continent
        if current.global then how,zone,continent="all",nil,nil end
        if zone=="current" then
            local pos=E.Position()
            local info=pos.mapID and E.Call(C_Map and C_Map.GetMapInfo,pos.mapID)
            current.mapID,current.name=pos.mapID,info and info.name or E.Call(GetRealZoneText)
        end
        local previous=sourceFilter
        if not previous or previous.how~=how or previous.zone~=zone or previous.continent~=continent
            or previous.mapID~=current.mapID or previous.name~=current.name then
            sourceResults={}
            sourceFilter={how=how,zone=zone,continent=continent,mapID=current.mapID,name=current.name}
        end
        return current
    end
    local function filteredSources(recipe,current,checkpoint)
        local cached=sourceResults[recipe]
        if cached then return cached.sources,cached.allSuppressed end
        local sources,allSuppressed={},true
        for _,loc in ipairs(recipe.locations or {}) do
            if checkpoint then checkpoint() end
            if not containerSource(loc) then allSuppressed=false end
            if matchesHow(loc,current) and matchesLocation(loc,current) then sources[#sources+1]=loc end
        end
        sourceResults[recipe]={sources=sources,allSuppressed=allSuppressed}
        return sources,allSuppressed
    end
    local function itemMatch(recipe,query)
        if catalog.MatchesItemQuery then return catalog.MatchesItemQuery(recipe,query) end
        for _,id in ipairs({recipe.learnableItemID or 0,recipe.productID or 0}) do
            if id>0 and matchesName(recipeItemLabel(id),query) then return true,"item",id end
        end
        for id in pairs(recipe.reagents or {}) do
            if matchesName(recipeItemLabel(id),query) then return true,"ingredient",id end
        end
        return false
    end
    local function ingredients(recipe)
        if catalog.Ingredients then return catalog.Ingredients(recipe) end
        local list={}
        for id,count in pairs(recipe.reagents or {}) do
            list[#list+1]={itemID=tonumber(id),name=recipeItemLabel(tonumber(id)),count=count}
        end
        table.sort(list,function(a,b)return (a.name or tostring(a.itemID))<(b.name or tostring(b.itemID)) end)
        return list
    end
    local function requirements(recipe,loc)
        if catalog.RequirementLines then return catalog.RequirementLines(recipe,loc,stateNow()) or {} end
        local result={}
        if recipe.requirement then result[#result+1]=recipe.requirement end
        if loc and loc.requirement then result[#result+1]=loc.requirement end
        return result
    end
    local function activateItem(widget,item)
        widget.itemID=type(item)=="number" and item or widget.itemID
        widget.itemLink=type(item)=="string" and item or nil
        widget:RegisterForClicks("LeftButtonUp","RightButtonUp")
        widget:SetScript("OnClick",function(self,button)
            closeMenus()
            if button=="LeftButton" and item and ns.HandleItemChatClick then ns.HandleItemChatClick(item) end
        end)
        widget:SetScript("OnEnter",function(self)
            if not item then return end
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
            if GameTooltip.ClearLines then GameTooltip:ClearLines() end
            if not ns.SetNativeItemTooltip or not ns.SetNativeItemTooltip(GameTooltip,item) then
                GameTooltip:AddLine(self.label:GetText(),1,.84,.5,true)
            end
            GameTooltip:Show()
        end)
        widget:SetScript("OnLeave",function(self) if GameTooltip:GetOwner()==self then GameTooltip:Hide() end end)
    end
    local function pinKey(loc) return catalog.SourceKey and catalog.SourceKey(loc) or tostring(loc) end
    local function sourcePinned(loc)
        if catalog.IsSourcePinned then return catalog.IsSourcePinned(loc) end
        return state.pinnedSource==pinKey(loc)
    end
    local function pinSource(recipe,loc)
        closeMenus()
        local key=pinKey(loc)
        if sourcePinned(loc) then
            if catalog.UnpinSource then catalog.UnpinSource(loc)
            elseif catalog.UnpinWorldMap then catalog.UnpinWorldMap(loc) end
            state.pinnedSource=nil;feedback:SetText("Waypoint removed")
        else
            local mapped,tracked=catalog.PinSource(recipe,loc)
            state.pinnedSource=(mapped or tracked) and key or nil
            feedback:SetText((mapped or tracked) and "Recipe destination pinned" or "Coordinates unavailable for this source")
        end
        if drawVisible then drawVisible() end
    end
    local function measured(text,width,size)
        font(measure,size,true);measure:SetWidth(math.max(px(10),width));measure:SetText(text or "")
        return math.max(px(size+2),measure:GetStringHeight())
    end
    local function sourceDescription(loc)
        local area=loc.zone or loc.dungeon or "Location unrecorded"
        local coords=loc.routingAllowed~=false and type(loc.x)=="number" and type(loc.y)=="number" and (" · %.1f, %.1f"):format(loc.x,loc.y) or ""
        local text=(loc.source or "Source").." · "..area..coords
        if loc.routingAllowed==false then text=text.."\nExact NPC position unverified" end
        local price=priceText(loc)
        if loc.source=="Trainer" then price=type(loc.price)=="number" and (GetCoinTextureString and GetCoinTextureString(loc.price) or loc.price.."c") or "Training cost unrecorded" end
        if price then text=text.."\n"..price end
        if type(loc.costAvailabilityNote)=="string" and loc.costAvailabilityNote:find("%S") then text=text.."\n"..loc.costAvailabilityNote end
        return text
    end
    local function compactLocation(loc)
        local zone=loc.zone or loc.dungeon
        local maps=ns.ForeverCatalog and ns.ForeverCatalog.zones
        zone=zone or maps and maps[loc.mapID] and maps[loc.mapID].name or "Location unrecorded"
        local point=catalog.HasWaypoint and catalog.HasWaypoint(loc)
        return zone..(point and (" (%.1f, %.1f)"):format(loc.x,loc.y) or "")
    end
    local function buildSpecs(row,width)
        local recipe,specs=row.recipe,{}
        local function add(role,text,size,extra)
            local spec=extra or {};spec.role=role;spec.text=text;spec.size=size or 14
            specs[#specs+1]=spec
        end
        if row.matchRole=="ingredient" then add("summary","Uses the searched ingredient",12) end
        if recipe.productID or recipe.productLink then
            local id=recipe.productID
            add("product",recipeItemLabel(id,recipe.productLink) or recipe.productName or ("Item "..tostring(id)),14,
                {itemID=id,itemLink=recipe.productLink,item=recipe.productLink or id,icon=recipeIcon(recipe,id)})
        end
        local list=ingredients(recipe)
        add("summary","Materials",13)
        if #list==0 then add("summary","Materials unrecorded",13) end
        for _,ingredient in ipairs(list) do
            add("reagent",ingredient.name or recipeItemLabel(ingredient.itemID) or ("Item "..tostring(ingredient.itemID)),14,
                {itemID=ingredient.itemID,item=ingredient.itemID,count=ingredient.count or 1,
                    icon=recipeIcon(recipe,ingredient.itemID),ingredient=ingredient})
        end
        local req=requirements(recipe)
        local shownRequirements={}
        local skill=skillLabel(recipe)
        local function addRequirement(line)
            if line~=skill and line~=skill.." required" and not shownRequirements[line] then
                shownRequirements[line]=true;add("requirements",line,13)
            end
        end
        for _,line in ipairs(req) do addRequirement(line) end
        local acquisition=row.acquisition or {sources=row.sources}
        if acquisition.drop then
            for _,loc in ipairs(acquisition.conditions or {}) do
                -- A dropping NPC's faction is not a recipe-learning restriction.
                local condition=loc
                if loc.faction then condition={};for key,value in pairs(loc) do if key~="faction" then condition[key]=value end end end
                for _,line in ipairs(requirements(recipe,condition)) do addRequirement(line) end
            end
        end
        add("summary","Source:",13)
        local displayedSources=acquisition.sources
        if #displayedSources==0 and not acquisition.drop then
            add("summary","No listed acquisition source. This recipe remains in the repository; its source is unrecorded or excluded from these filters.",13)
        end
        local maxPage=math.max(0,math.ceil(#displayedSources/8)-1)
        state.sourcePage=math.min(state.sourcePage,maxPage)
        for i=state.sourcePage*8+1,math.min(#displayedSources,state.sourcePage*8+8) do
            local loc=displayedSources[i]
            local text=sourceHeading(loc).."\n"..compactLocation(loc)
            local price=compactPrice(loc)
            if price then text=text.."\n"..price end
            local tooltipLines={sourceHeading(loc),sourceDescription(loc)}
            if loc.source=="Quest" or loc.source=="Quest Reward" then
                local data=ns.ForeverQuestData
                local quest=data and data.quests and data.quests[loc.questID]
                local name=quest and quest.title or sourceName(loc)
                if type(name)=="string" and name:find("%S") then tooltipLines[#tooltipLines+1]="Quest: "..name end
            end
            if type(loc.quantity)=="number" and loc.quantity>1 then tooltipLines[#tooltipLines+1]="Offer quantity: "..loc.quantity end
            local condition={};for key,value in pairs(loc) do condition[key]=value end
            local _,faction=sourceFaction(loc);condition.faction=faction
            for _,line in ipairs(requirements(recipe,condition)) do
                local duplicate=false;for _,common in ipairs(req) do if common==line then duplicate=true;break end end
                for _,shown in ipairs(tooltipLines) do if shown==line then duplicate=true;break end end
                if not duplicate then tooltipLines[#tooltipLines+1]=line end
            end
            add("source",text,13,{location=loc,tooltipLines=tooltipLines,record={recipe=recipe,location=loc},pin=catalog.HasWaypoint and catalog.HasWaypoint(loc)})
        end
        if #displayedSources>8 then add("paging",("Sources %d–%d of %d"):format(state.sourcePage*8+1,math.min(#displayedSources,state.sourcePage*8+8),#displayedSources),12,{maxPage=maxPage}) end
        local drop=acquisition.drop
        if drop then
            local best=drop.best
            local chance=best and ("Highest recorded drop: %s · %.3g%% (%s %s)"):format(sourceName(best),best.rate*100,tostring(best.sampleSize),best.sampleKind or "recorded samples")
                or "Highest recorded drop chance: unverified"
            local level=drop.meanLevel and ("Average mob level: "..math.floor(drop.meanLevel+.5))
                or "Average mob level: unrecorded"
            if drop.meanLevel and drop.knownLevels<drop.typeCount then level=level..(" (known %d/%d types)"):format(drop.knownLevels,drop.typeCount) end
            local place=drop.foundIn~="Unrecorded" and drop.foundIn or "Location unrecorded"
            local ownPlace=best and (best.dungeon or best.zone)
            local exactPoint=best and ownPlace==place and displayPoint(best)
            local maps=ns.ForeverCatalog and ns.ForeverCatalog.zones
            local map=best and maps and maps[best.mapID]
            if exactPoint and (not map or map.name~=ownPlace
                or best.dungeon and best.zone and best.dungeon~=best.zone) then exactPoint=false end
            -- A broad drop may have many spawn areas. Only pair a point with
            -- the selected NPC's one concrete, matching recorded location.
            if exactPoint then
                local coordinateEvidence=type(best.coordinateEvidence)=="string" and best.coordinateEvidence:lower() or ""
                local npcPointEvidence=coordinateEvidence:find("npc",1,true)
                    and (coordinateEvidence:find("position",1,true) or coordinateEvidence:find("spawn",1,true) or coordinateEvidence:find("coordinate",1,true))
                    or coordinateEvidence:find("questie",1,true) and coordinateEvidence:find("spawn",1,true)
                for _,key in ipairs({"coordinateRole","rawCoordinateRole","positionKind","coordinateEvidence"}) do
                    local value=best[key]
                    if type(value)=="string" then
                        value=value:lower()
                        if value:find("player",1,true) or value:find("provisional",1,true) or value:find("unverified",1,true)
                            or value:find("approx",1,true) then exactPoint=false;break end
                    end
                end
                -- Loot-sample provenance can describe a player observation
                -- independently of an explicitly verified NPC spawn point.
                if exactPoint and not npcPointEvidence then
                    for _,key in ipairs({"coordinateRole","rawCoordinateRole","positionKind","coordinateEvidence","evidence","provenance"}) do
                        local value=best[key]
                        if type(value)=="string" then
                            value=value:lower()
                            if value:find("player",1,true) or value:find("observ",1,true) or value:find("manual",1,true)
                                or value:find("tracker",1,true) or value:find("provisional",1,true) or value:find("unverified",1,true)
                                or value:find("approx",1,true) then exactPoint=false;break end
                        end
                    end
                end
            end
            if exactPoint then place=place..(" (%.1f, %.1f)"):format(best.x,best.y) end
            local compactLevel="Level "..(drop.meanLevel and math.floor(drop.meanLevel+.5) or "unrecorded").." World Drop"
            local compactChance=best and ("%s - %.3g%%"):format(sourceName(best),best.rate*100)
                or "Drop source unrecorded - chance unrecorded"
            local text=compactLevel.."\n"..compactChance.."\n"..place
            local tooltipLines={"World Drop",chance,"Found in: "..drop.foundIn,level,"General area: "..drop.area}
            local recorded=ns.ForeverCatalog and ns.ForeverCatalog.recipeDungeonSources
            local dungeons=recorded and recorded[recipe.learnableItemID]
            if type(dungeons)=="table" and #dungeons>0 then
                tooltipLines[#tooltipLines+1]="Recorded dungeon sources: "..table.concat(dungeons,", ")
            end
            add("source",text,13,{location=best,tooltipLines=tooltipLines,record={recipe=recipe,location=best},pin=false})
        end
        local y=px(10)
        for _,spec in ipairs(specs) do
            local inset=spec.item and px(27) or 0
            local reserve=spec.count and px(35) or spec.pin and px(33) or spec.role=="paging" and px(64) or 0
            spec.y=y;spec.textWidth=math.max(px(20),width-px(20)-inset-reserve)
            -- Reserve either learned-state label without querying a hidden recipe.
            local measureText=spec.knowledgeSummary and (skillLabel(recipe).." · Known") or spec.text
            spec.height=math.max(spec.item and px(24) or 0,measured(measureText,spec.textWidth,spec.size))+px(7)
            y=y+spec.height
        end
        return specs,y+px(5)
    end
    local function ensureNode(index)
        if detail.nodes[index] then return detail.nodes[index] end
        local node=CreateFrame("Button",nil,detail)
        node.label=N.MakeText(node,14,"",true)
        node.icon=node:CreateTexture(nil,"ARTWORK")
        node.quantity=N.MakeText(node,13,"",true)
        node.pinButton=N.WoodButton(node,"",26,function() if node.location then pinSource(detail.recipe,node.location) end end)
        local nail=node.pinButton:CreateTexture(nil,"OVERLAY");nail:SetAllPoints();node.pinButton.nail=nail
        node.pinButton:SetScript("OnEnter",function(self)
            GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
            if GameTooltip.ClearLines then GameTooltip:ClearLines() end
            GameTooltip:AddLine(sourcePinned(node.location) and "Unpin recipe destination" or "Pin recipe destination",1,.84,.5,true)
            GameTooltip:Show()
        end)
        node.pinButton:SetScript("OnLeave",function(self) if GameTooltip:GetOwner()==self then GameTooltip:Hide() end end)
        detail.nodes[index]=node;return node
    end
    local previous=N.PlainButton(detail,"‹",24,function() state.sourcePage=math.max(0,state.sourcePage-1);resize() end)
    local nextPage=N.PlainButton(detail,"›",24,function() state.sourcePage=state.sourcePage+1;resize() end)
    detail.previous,detail.nextPage=previous,nextPage
    local function drawDetail(entry)
        detail.recipe=entry.row.recipe;detail.record=entry.row;detail.gfRecipeRole="detail"
        detail:ClearAllPoints();detail:SetPoint("TOPLEFT",content,"TOPLEFT",entry.x,-entry.y)
        detail:SetSize(entry.width,entry.height);detail:Show()
        previous:Hide();nextPage:Hide()
        for _,node in ipairs(detail.nodes) do node:Hide();node.location=nil end
        for i,spec in ipairs(entry.specs) do
            local node=ensureNode(i)
            node:ClearAllPoints();node:SetPoint("TOPLEFT",detail,"TOPLEFT",px(10),-spec.y)
            node:SetSize(entry.width-px(20),spec.height-px(4));node:Show()
            node.gfRecipeRole=spec.role;node.gfRecipeSourceRow=true;node.record=spec.record or spec.ingredient or entry.row
            node.itemID=spec.itemID;node.location=spec.location
            node.icon:SetShown(spec.item and true or false)
            node.icon:ClearAllPoints();node.icon:SetPoint("TOPLEFT",node,"TOPLEFT",0,0);node.icon:SetSize(px(22),px(22))
            if spec.item then node.icon:SetTexture(spec.icon) end
            node.label:ClearAllPoints();node.label:SetPoint("TOPLEFT",node,"TOPLEFT",spec.item and px(27) or 0,0)
            font(node.label,spec.size,true);node.label:SetWidth(spec.textWidth);node.label:SetText(spec.text)
            node.label:SetHeight(spec.height-px(5))
            node.quantity:ClearAllPoints();node.quantity:SetPoint("TOPRIGHT",node,"TOPRIGHT",0,0)
            font(node.quantity,13,true);node.quantity:SetWidth(px(33));node.quantity:SetJustifyH("RIGHT")
            node.quantity:SetText(spec.count and ("×"..spec.count) or "");node.quantity:SetShown(spec.count and true or false)
            node.pinButton:SetShown(spec.pin and true or false)
            node.pinButton:ClearAllPoints();node.pinButton:SetPoint("TOPRIGHT",node,"TOPRIGHT",0,0);node.pinButton:SetSize(px(26),px(26))
            if spec.pin then node.pinButton.nail:SetTexture(assets..(sourcePinned(spec.location) and "JournalNailOnlyOn.tga" or "JournalNailOnlyOff.tga")) end
            activateItem(node,spec.item)
            if spec.role=="source" then node:SetScript("OnClick",function() if spec.pin then pinSource(detail.recipe,spec.location) end end) end
            if spec.tooltipLines then node:SetScript("OnEnter",function(self)
                GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
                if GameTooltip.ClearLines then GameTooltip:ClearLines() end
                for index,line in ipairs(spec.tooltipLines) do GameTooltip:AddLine(line,index==1 and 1 or .98,index==1 and .84 or .90,index==1 and .5 or .73,true) end
                GameTooltip:Show()
            end) end
            if spec.role=="paging" then
                previous:ClearAllPoints();nextPage:ClearAllPoints()
                previous:SetPoint("TOPRIGHT",node,"TOPRIGHT",-px(30),0);nextPage:SetPoint("TOPRIGHT",node,"TOPRIGHT",0,0)
                previous:SetSize(px(25),px(23));nextPage:SetSize(px(25),px(23))
                previous:SetShown(state.sourcePage>0);nextPage:SetShown(state.sourcePage<spec.maxPage)
            end
        end
    end
    local function ensureHeader(index)
        if headers[index] then return headers[index] end
        local header=N.WoodButton(content,"",300)
        header.sub=N.MakeText(header,12,"",false)
        header.arrow=N.ButtonArrow(header,"right","RIGHT")
        header:RegisterForClicks("LeftButtonUp","RightButtonUp")
        header:SetScript("OnClick",function(self,button)
            closeMenus()
            local row=self.record;if not row then return end
            if row.recipe and button=="LeftButton" and ns.HandleItemChatClick and ns.HandleItemChatClick(rowItem(row)) then return end
            if button~="LeftButton" then return end
            if row.kind=="category" then
                state.categoryOpen[row.key]=not row.open
            elseif row.kind=="group" then
                state.groupOpen[row.name]=not row.open
                if not state.groupOpen[row.name] then state.expanded=nil end
            else
                if state.expanded==recipeKey(row.recipe) then state.expanded=nil
                else state.expanded=recipeKey(row.recipe) end
                state.sourcePage=0
                if state.expanded and not row.acquisition then refresh(true);return end
            end
            resize()
        end)
        header:SetScript("OnEnter",function(self)
            if not self.record or not self.record.recipe then return end
            local item=rowItem(self.record)
            if item then
                GameTooltip:SetOwner(self,"ANCHOR_RIGHT")
                if GameTooltip.ClearLines then GameTooltip:ClearLines() end
                if ns.SetNativeItemTooltip then ns.SetNativeItemTooltip(GameTooltip,item) end
                GameTooltip:Show()
            end
        end)
        header:SetScript("OnLeave",function(self) if GameTooltip:GetOwner()==self then GameTooltip:Hide() end end)
        headers[index]=header;return header
    end
    drawVisible=function()
        local owner=GameTooltip:GetOwner()
        while owner do
            if owner==content then GameTooltip:Hide();break end
            owner=owner.GetParent and owner:GetParent()
        end
        for _,header in ipairs(headers) do header:Hide();header.record=nil end
        detail:Hide()
        local shown,top,bottom=0,state.scroll,state.scroll+viewport:GetHeight()
        local checked={}
        local function updateKnown(row)
            if checked[row] then return end
            checked[row]=true;row.known=E.Known and E.Known(row.recipe)==true or false
        end
        for _,body in pairs(categoryBodies) do body:Hide();body.span=nil end
        for index,span in ipairs(categorySpans) do
            local visibleTop,visibleBottom=math.max(span.y,top),math.min(span.y+span.height,bottom)
            if visibleBottom>visibleTop then
                local body=categoryBodies[index]
                if not body then
                    body=CreateFrame("Frame",nil,viewport)
                    body:SetFrameLevel(viewport:GetFrameLevel());body:EnableMouse(false)
                    body.cream=body:CreateTexture(nil,"BACKGROUND")
                    body.cream:SetAllPoints();body.cream:SetColorTexture(.98,.90,.73,.88)
                    N.BronzeRectangle(body,1);categoryBodies[index]=body
                end
                body.categoryKey,body.span=span.key,span
                body:ClearAllPoints();body:SetPoint("TOPLEFT",viewport,"TOPLEFT",span.x,-(visibleTop-top))
                body:SetSize(span.width,visibleBottom-visibleTop);body:Show()
            end
        end
        for _,entry in ipairs(entries) do
            if entry.y+entry.height>=top and entry.y<=bottom then
                if entry.kind=="detail" then
                    updateKnown(entry.row)
                    for _,spec in ipairs(entry.specs) do
                        if spec.knowledgeSummary then spec.text=skillLabel(entry.row.recipe)..(entry.row.known and " · Known" or "") end
                    end
                    drawDetail(entry)
                elseif shown<40 then
                    shown=shown+1;local header=ensureHeader(shown)
                    header.record=entry.row;header.gfRecipeRole=entry.kind;header.gfRecipeSourceRow=entry.kind=="recipe"
                    if entry.kind=="recipe" then updateKnown(entry.row) end
                    header:EnableMouse(true)
                    if header.woodFace then header.woodFace:GetParent():Show() end
                    header.arrow:Show()
                    header:ClearAllPoints();header:SetPoint("TOPLEFT",content,"TOPLEFT",entry.x,-entry.y)
                    header:SetSize(entry.width,entry.height-px(4));header:Show()
                    header.label:ClearAllPoints();header.label:SetPoint("TOPLEFT",header,"TOPLEFT",px(9),-px(5))
                    font(header.label,14,false);header.label:SetWidth(entry.width-px(40));header.label:SetHeight(entry.titleHeight)
                    header.label:SetText(entry.kind=="category" and entry.row.name or entry.kind=="group" and (entry.row.name.." · "..#entry.row.rows) or entry.row.recipe.name)
                    header.sub:ClearAllPoints();header.sub:SetPoint("TOPLEFT",header.label,"BOTTOMLEFT",0,-px(2))
                    font(header.sub,12,false);header.sub:SetWidth(entry.width-px(40));header.sub:SetText(entry.kind=="recipe" and (skillLabel(entry.row.recipe)..(entry.row.known and " · Known" or "")) or "")
                    header.sub:SetShown(entry.kind=="recipe")
                    local opened=(entry.kind=="category" or entry.kind=="group") and entry.row.open
                    if entry.kind=="recipe" then opened=state.expanded==recipeKey(entry.row.recipe) end
                    if header.arrow then header.arrow:SetRotation(opened and -math.pi/2 or 0) end
                end
            end
        end
        viewport:SetVerticalScroll(state.scroll)
        if syncScroll then syncScroll() end
    end
    local function resetResults()
        state.groupOpen={};state.categoryOpen={};state.expanded=nil;state.scroll=0;state.sourcePage=0;feedback:SetText("")
    end
    local function filterChanged()
        closeMenus();state.browseActivated=true;resetResults();refresh()
    end
    professionButton:SetScript("OnClick",function(self)
        if queryText()~="" then return end
        local names={};for _,recipe in ipairs(recipes or {}) do names[recipe.profession or "Other recipes"]=true end
        for _,tier in ipairs(professionTiers) do for _,name in ipairs(tier.professions) do names[name]=true end end
        local values={{label="All professions",click=function() state.profession=nil;filterChanged() end},
            {label="My Professions",click=function() state.profession="mine";filterChanged() end}}
        for _,name in ipairs(sortedProfessions(names)) do values[#values+1]={label=name,click=function() state.profession=name;filterChanged() end} end
        openMenu(self,values)
    end)
    locationButton:SetScript("OnClick",function(self)
        if queryText()~="" then return end
        local function pick(continent,zone) state.continent,state.zone=continent,zone;filterChanged() end
        local rootValues,branchValues
        local function render(values) menu.values,menu.offset=values,0;menu.Render() end
        branchValues=function(branch)
            local options={{label="‹ All locations",click=function() render(rootValues()) end},
                {label=branch=="World" and "All world locations" or "All instances",click=function() pick(branch,nil) end}}
            local names=branch=="World" and {"Eastern Kingdoms","Kalimdor","Zephras Isle"} or {"Dungeons","Raids"}
            for _,name in ipairs(names) do
                local name=name
                options[#options+1]={label=name.." ›",click=function()
                    local zones={{label="‹ "..branch,click=function() render(branchValues(branch)) end},
                        {label="All "..name,click=function() pick(name,nil) end}}
                    for _,zone in ipairs(sortedKeys(browseZones()[name] or {})) do
                        zones[#zones+1]={label=zone,click=function() pick(name,zone) end}
                    end
                    render(zones)
                end}
            end
            return options
        end
        rootValues=function()
            return {{label="All locations",click=function() pick(nil,nil) end},
                {label="World ›",click=function() render(branchValues("World")) end},
                {label="Instances ›",click=function() render(branchValues("Instances")) end}}
        end
        openMenu(self,rootValues())
    end)
    howButton:SetScript("OnClick",function(self)
        if queryText()~="" then return end
        local values={}
        for _,choice in ipairs(howChoices) do
            local choice=choice
            values[#values+1]={label=choice.label,click=function()
                if choice.id=="favor" and state.how~="favor" then
                    state.ordinaryLocation={zone=state.zone,continent=state.continent}
                    state.zone,state.continent=nil,nil
                elseif choice.id~="favor" and state.how=="favor" then
                    local previous=state.ordinaryLocation
                    if previous then state.zone,state.continent=previous.zone,previous.continent end
                    state.ordinaryLocation=nil
                end
                state.how=choice.id;filterChanged()
            end}
        end
        openMenu(self,values)
    end)
    api.menu,api.submenu=menu,submenu
    clearFilters:SetScript("OnClick",function()
        if queryText()~="" then return end
        state.profession,state.zone,state.continent=nil,nil,nil
        state.how="world";state.ordinaryLocation=nil
        resetResults();refresh()
    end)
    local function prepareResults(job,checkpoint)
        local query=queryText()
        local active=query~="" or state.browseActivated
        local currentSourceRevision=catalog.sourceRevision
        if currentSourceRevision==nil then currentSourceRevision=catalog.revision end
        if active and (not recipes or sourceRevision~=currentSourceRevision) then
            local prepared=catalog.Browse(checkpoint)
            for _,recipe in ipairs(prepared) do
                recipe.locations=recipe.locations or {};mergeSources(recipe,nil,nil,checkpoint)
                checkpoint()
            end
            recipes=prepared;sourceRevision=currentSourceRevision
            locationGroups,mapGroups,browseGroups,sourceResults,sourceFilter={{},{},{}},{},nil,{},nil
            acquisitionProfiles,npcTargetKeys={},{}
        end
        revision=catalog.revision
        if active then browseZones(checkpoint) end
        local preparedGroups={};local byProfession,seen,preparedRows={},{},{}
        if active then
            local current=prepareSourceFilter()
            job.currentMapID,job.currentZone=current.mapID,current.name
            for _,recipe in ipairs(recipes) do
                checkpoint()
                local key=recipeKey(recipe)
                if not seen[key] and matchesProfession(recipe,query~="") then
                    local matched,role=query=="",nil
                    if query~="" then
                        matched=matchesName(recipe.name,query) and true or false
                        if not matched then matched,role=itemMatch(recipe,query) end
                    end
                    if matched then
                        local sources,allSuppressed=filteredSources(recipe,current,checkpoint)
                        local unknown=#(recipe.locations or {})==0
                        local allowUnknown=query~="" and (unknown or allSuppressed)
                        if #sources>0 or allowUnknown then
                            seen[key]=true
                            local name=recipe.profession or "Other recipes"
                            local group=byProfession[name]
                            if not group then group={kind="group",name=name,rows={}};byProfession[name]=group;preparedGroups[#preparedGroups+1]=group end
                            local acquisition=sourceResults[recipe].acquisition
                            if state.expanded==recipeKey(recipe) then acquisition=prepareAcquisition(recipe,sources,checkpoint) end
                            local row={kind="recipe",recipe=recipe,sources=sources,matchRole=role,acquisition=acquisition}
                            group.rows[#group.rows+1]=row;preparedRows[key]=row
                        end
                    end
                end
            end
        end
        table.sort(preparedGroups,function(a,b)return professionLess(a.name,b.name) end)
        local count=0
        for _,group in ipairs(preparedGroups) do
            checkpoint()
            table.sort(group.rows,function(a,b)
                local aa,bb=rank(a.recipe),rank(b.recipe)
                if aa~=bb then return aa<bb end
                return (a.recipe.name or "")<(b.recipe.name or "")
            end)
            group.open=state.groupOpen[group.name]
            if group.open==nil then group.open=query~="" or singleProfession() end
            count=count+#group.rows
        end
        -- Readers can scroll or choose another card while an unchanged-context
        -- background refresh is preparing. Finish the currently selected card,
        -- then publish one complete result without restoring an old scroll.
        local selected
        repeat
            selected=state.expanded
            local row=selected and preparedRows[selected]
            if row and not row.acquisition then row.acquisition=prepareAcquisition(row.recipe,row.sources,checkpoint) end
            if active then checkpoint(true) end
            if not job.valid(true) then return false end
        until selected==state.expanded
        groups=preparedGroups;state.scroll=job.preserveVisible and state.scroll or job.scroll
        publishedContext={query=job.query,profession=job.profession,zone=job.zone,continent=job.continent,how=job.how}
        api.groups=groups;api.count=count
        if query~="" then
            status:SetText("Searching all recipes · "..(count==0 and "No matches." or count..(count==1 and " result" or " results")))
        elseif state.profession=="mine" and not next(state.myProfessions) then
            status:SetText(state.professionKnowledgeAvailable and "No learned professions. Choose All professions to browse." or "Professions unavailable. Choose All professions to browse.")
        else
            status:SetText(not active and "Look up a recipe or ingredient, or open Browse." or count==0 and "No matching recipes. Try another location or acquisition source." or (count..(count==1 and " recipe" or " recipes")))
        end
        resize()
        return true
    end
    resize=function()
        local unit=px(1);local width=panel:GetWidth();local left=px(18);local usable=width-px(51)
        font(placeholder,13,false);placeholder:SetTextColor(.86,.80,.67,1)
        search:SetFont(face,px(14),"");search:SetTextColor(.96,.90,.76,1)
        search:SetTextInsets(px(7),px(7),0,0)
        search:ClearAllPoints();search:SetPoint("TOPLEFT",panel,"TOPLEFT",left,-px(62));search:SetSize(usable-px(31),px(29))
        searchClear:ClearAllPoints();searchClear:SetPoint("TOPLEFT",search,"TOPRIGHT",px(5),0);searchClear:SetSize(px(26),px(29))
        -- The filter/count card is always present; no separate Browse toggle.
        state.browseOpen=true
        local y=px(99)
        filterFrame:ClearAllPoints();filterFrame:SetPoint("TOPLEFT",panel,"TOPLEFT",left,-y);filterFrame:SetWidth(usable)
        filterFrame:SetHeight(state.browseOpen and px(124) or 0);filterFrame:SetShown(state.browseOpen)
        local controls={professionButton,locationButton,howButton}
        local labels={professionLabel(),state.zone or state.continent or "All locations",howLabel()}
        for i,button in ipairs(controls) do
            filterLabels[i]:ClearAllPoints();filterLabels[i]:SetPoint("TOPLEFT",filterFrame,"TOPLEFT",px(8),-px((i-1)*28+6));font(filterLabels[i],12,true)
            filterLabels[i]:SetWidth(px(94));filterLabels[i]:SetHeight(px(24));filterLabels[i]:SetJustifyV("MIDDLE")
            button:ClearAllPoints();button:SetPoint("TOPLEFT",filterFrame,"TOPLEFT",px(110),-px((i-1)*28+6))
            button:SetSize(math.max(px(100),usable-px(118)),px(24));fitLabel(button,labels[i],captionSize(14),px(30))
            button.label:ClearAllPoints();button.label:SetPoint("LEFT",button,"LEFT",px(7),0);button.label:SetPoint("RIGHT",button,"RIGHT",-px(23),0)
            button.arrow:ClearAllPoints();button.arrow:SetPoint("RIGHT",button,"RIGHT",-px(10),0);button.arrow:SetSize(px(11),px(11))
        end
        local constrained=state.profession or state.zone or state.continent or state.how~="world"
        local summary=labels[1].." · "..labels[2].." · "..labels[3]
        local clearWidth=px(64)
        activeFilters:ClearAllPoints();activeFilters:SetPoint("TOPLEFT",panel,"TOPLEFT",left,-y)
        font(activeFilters,12,true);activeFilters:SetWidth(usable);activeFilters:SetText(summary)
        local showSummary=constrained and not state.browseOpen and queryText()==""
        local summaryHeight=showSummary and math.max(px(18),activeFilters:GetStringHeight()) or 0
        activeFilters:SetHeight(summaryHeight)
        activeFilters:SetShown(showSummary and true or false);clearFilters:SetShown(constrained and true or false)
        if state.browseOpen then
            status:SetParent(filterFrame);clearFilters:SetParent(filterFrame)
            status:ClearAllPoints();status:SetPoint("TOPLEFT",filterFrame,"TOPLEFT",px(8),-px(92))
            clearFilters:ClearAllPoints();clearFilters:SetPoint("TOPRIGHT",filterFrame,"TOPRIGHT",-px(8),-px(92))
            y=y+px(124)+px(8)
        else
            status:SetParent(panel);clearFilters:SetParent(panel)
            y=y+px(8)
            activeFilters:ClearAllPoints();activeFilters:SetPoint("TOPLEFT",panel,"TOPLEFT",left,-y)
            if showSummary then y=y+summaryHeight+px(7) end
            status:ClearAllPoints();status:SetPoint("TOPLEFT",panel,"TOPLEFT",left,-y)
            clearFilters:ClearAllPoints();clearFilters:SetPoint("TOPRIGHT",panel,"TOPRIGHT",-px(33),-y)
        end
        clearFilters:SetSize(clearWidth,px(25))
        fitLabel(clearFilters,"Clear",px(13),px(16))
        font(status,12,true)
        local statusWidth=usable-(state.browseOpen and px(16) or 0)
        status:SetWidth(constrained and math.max(px(1),statusWidth-clearWidth-px(7)) or statusWidth)
        local statusHeight=math.max(px((constrained or state.browseOpen) and 25 or 18),status:GetStringHeight());status:SetHeight(statusHeight)
        if state.browseOpen then
            filterFrame:SetHeight(px(99)+statusHeight);y=y+statusHeight-px(25)
        else y=y+statusHeight+px(7) end
        filterControls(preparation~=nil)
        if planButton then
            planButton:ClearAllPoints();planButton:SetPoint("BOTTOMLEFT",panel,"BOTTOMLEFT",left,px(17));planButton:SetSize(px(130),px(25));fitLabel(planButton,"Profession plan",px(13),14)
            planButton:SetShown(state.browseOpen)
        end
        feedback:ClearAllPoints();feedback:SetPoint("BOTTOMLEFT",panel,"BOTTOMLEFT",left,px(47));font(feedback,12,true);feedback:SetWidth(usable)
        local feedbackHeight=(feedback:GetText() or "")~="" and math.max(px(17),feedback:GetStringHeight()) or 0
        feedback:SetHeight(feedbackHeight)
        viewport:ClearAllPoints();viewport:SetPoint("TOPLEFT",panel,"TOPLEFT",left,-y)
        viewport:SetSize(usable,math.max(px(65),panel:GetHeight()-y-px(55)-feedbackHeight))
        content:SetWidth(usable);entries={};categorySpans={};local cursor=0
        local function addHeader(kind,row,x,w)
            local text=kind=="category" and row.name or kind=="group" and (row.name.." · "..#row.rows) or row.recipe.name
            local titleHeight=measured(text,w-px(40),14)
            local h=titleHeight+px(kind=="recipe" and 29 or 15)
            entries[#entries+1]={kind=kind,row=row,x=x,y=cursor,width=w,height=h,titleHeight=titleHeight}
            cursor=cursor+h
        end
        local previousTier,category,span
        local function finishCategory()
            if span then
                cursor=cursor+px(4);span.height=cursor-span.y
                categorySpans[#categorySpans+1]=span;span=nil
            end
            if category then cursor=cursor+px(8) end
        end
        for _,group in ipairs(groups) do
            local tier=professionTier[group.name]
            if tier~=previousTier then
                finishCategory();category=nil;previousTier=tier
                if tier then
                    local opened=state.categoryOpen[tier]
                    if opened==nil then opened=queryText()~="" or singleProfession() end
                    category={kind="category",key=tier,name=professionTiers[tier].name,open=opened}
                    addHeader("category",category,0,usable)
                    if category.open then
                        span={key=tier,name=category.name,x=0,y=cursor-px(4),width=usable}
                        cursor=cursor+px(4)
                    end
                end
            end
            group.open=state.groupOpen[group.name]
            if group.open==nil then group.open=queryText()~="" or singleProfession() end
            if not category or category.open then
                local inset=category and px(8) or 0
                addHeader("group",group,inset,usable-inset*2)
                if group.open then
                    for _,row in ipairs(group.rows) do
                        local recipeInset=inset+px(8)
                        addHeader("recipe",row,recipeInset,usable-recipeInset*2)
                        if state.expanded==recipeKey(row.recipe) then
                            local specs,h=buildSpecs(row,usable-recipeInset*2)
                            entries[#entries+1]={kind="detail",row=row,x=recipeInset,y=cursor,width=usable-recipeInset*2,height=h,specs=specs}
                            cursor=cursor+h+px(6)
                        end
                    end
                end
            end
        end
        finishCategory()
        content:SetHeight(math.max(1,cursor));state.maxScroll=math.max(0,cursor-viewport:GetHeight())
        state.scroll=math.max(0,math.min(state.scroll,state.maxScroll));api.entries=entries;api.categorySpans=categorySpans
        drawVisible()
    end
    local preparationDriver=CreateFrame("Frame",nil,panel);preparationDriver:Hide()
    local function setPreparing(active)
        filterControls(active)
    end
    cancelPreparation=function()
        local job=preparation
        if not job then return end
        preparation=nil
        if job.timer and job.timer.Cancel then job.timer:Cancel() end
        preparationDriver:SetScript("OnUpdate",nil);preparationDriver:Hide()
        setPreparing(false)
    end
    local function contentRevision()
        if catalog.sourceRevision~=nil then return catalog.sourceRevision end
        return catalog.revision
    end
    local function budgetClock()
        local value=E.Call(GetTimePreciseSec)
        return E.Public(value) and type(value)=="number" and value or nil
    end
    refresh=function(keepPosition)
        local scroll=keepPosition and (preparation and preparation.scroll or state.scroll) or 0
        cancelPreparation()
        closeMenus()
        local query=queryText()
        placeholder:SetShown(query=="");searchClear:SetShown(query~="")
        local job={query=query,profession=state.profession,zone=state.zone,continent=state.continent,how=state.how,
            sourceRevision=contentRevision(),revision=catalog.revision,scroll=scroll,units=0}
        job.preserveVisible=keepPosition and publishedContext and publishedContext.query==job.query
            and publishedContext.profession==job.profession and publishedContext.zone==job.zone
            and publishedContext.continent==job.continent and publishedContext.how==job.how
        function job.valid(checkLocation)
            if preparation~=job or not panel:IsShown() or queryText()~=job.query or state.profession~=job.profession
                or state.zone~=job.zone or state.continent~=job.continent or state.how~=job.how
                or contentRevision()~=job.sourceRevision or catalog.revision~=job.revision then return false end
            if checkLocation and job.zone=="current" then
                local current=E.Position()
                local info=current.mapID and E.Call(C_Map and C_Map.GetMapInfo,current.mapID)
                local name=info and info.name or E.Call(GetRealZoneText)
                if current.mapID~=job.currentMapID or name~=job.currentZone then return false end
            end
            return true
        end
        local function checkpoint(publish)
            if publish then
                local now=job.started and budgetClock()
                if not now or now-job.started>=.002 then coroutine.yield() end
                return
            end
            job.units=job.units+1
            if job.units%32==0 then
                local now=job.started and budgetClock()
                if job.units>=4096 or now and now-job.started>=.007 then coroutine.yield() end
            end
        end
        job.thread=coroutine.create(function()return prepareResults(job,checkpoint)end)
        preparation=job
        if not job.preserveVisible then
            groups={};api.groups=groups;api.count=0;state.scroll=0
            status:SetText(loadingStatus());resize()
        end
        setPreparing(true)
        local function slice()
            if preparation~=job then return end
            if not job.valid(false) then
                cancelPreparation();if panel:IsShown() then queueRefresh(true) end;return
            end
            job.units,job.started=0,budgetClock()
            local ok,result=coroutine.resume(job.thread)
            if not ok then cancelPreparation();error(result,0) end
            if coroutine.status(job.thread)=="dead" then
                if result then preparation=nil;setPreparing(false)
                else cancelPreparation();if panel:IsShown() then queueRefresh(true) end end
            elseif C_Timer and C_Timer.NewTimer then job.timer=C_Timer.NewTimer(0,slice)
            elseif C_Timer and C_Timer.After then C_Timer.After(0,slice)
            else
                preparationDriver:SetScript("OnUpdate",function(self)
                    self:SetScript("OnUpdate",nil);self:Hide();slice()
                end)
                preparationDriver:Show()
            end
        end
        slice()
    end
    syncScroll=N.PanelScroll(panel,viewport,function() return state.scroll/px(1) end,
        function(value) state.scroll=math.max(0,math.min(state.maxScroll or 0,value*px(1)));drawVisible() end,
        function() return (state.maxScroll or 0)/px(1) end,40)
    N.PanelChrome(panel,{"Recipe","Sources"},400,560,resize)
    N.LiveLayout(panel,resize)
    local pendingSearch
    queueRefresh=function(keep)
        if pendingSearch then if keep then return end;pendingSearch:Cancel() end
        if not C_Timer or not C_Timer.NewTimer then refresh(keep);return end
        pendingSearch=C_Timer.NewTimer(.16,function() pendingSearch=nil;if panel:IsShown() then refresh(keep) end end)
    end
    local knowledgeEvents={SPELLS_CHANGED=true,NEW_RECIPE_LEARNED=true,TRADE_SKILL_LIST_UPDATE=true,CRAFT_UPDATE=true,SKILL_LINES_CHANGED=true}
    local function watchKnowledge(enabled)
        for event in pairs(knowledgeEvents) do pcall(enabled and panel.RegisterEvent or panel.UnregisterEvent,panel,event) end
    end
    search:SetScript("OnEditFocusGained",closeMenus)
    search:SetScript("OnEnterPressed",function(self) self:ClearFocus();refresh() end)
    search:SetScript("OnEscapePressed",function(self) self:ClearFocus();closeMenus() end)
    panel:HookScript("OnMouseDown",closeMenus)
    viewport:HookScript("OnMouseDown",closeMenus)
    detail:HookScript("OnMouseDown",closeMenus)
    if planButton then planButton:HookScript("OnClick",closeMenus) end
    local previousQuery=queryText()
    search:SetScript("OnTextChanged",function()
        local query=queryText()
        if state.resetting then previousQuery=query;return end
        if query==previousQuery then return end
        previousQuery=query
        cancelPreparation()
        resetResults();groups={};api.groups=groups;api.count=0
        status:SetText(loadingStatus());resize();queueRefresh(false)
    end)
    panel:SetScript("OnEvent",function(_,event,id,success)
        if event=="SKILL_LINES_CHANGED" then
            state.myProfessions,state.professionKnowledgeAvailable=readLearnedProfessions()
            if state.profession=="mine" and queryText()=="" then cancelPreparation();queueRefresh(true) end
            return
        end
        if knowledgeEvents[event] then sourceRevision=nil;cancelPreparation();queueRefresh(true);return end
        if not E.Public(id) or not E.Public(success) or not success then return end
        local relevant=pendingItemNames[id] or catalog.PendingItemNames and catalog.PendingItemNames[id] or revision~=catalog.revision
        if relevant then pendingItemNames[id]=nil;cancelPreparation();queueRefresh(true) end
    end)
    panel:HookScript("OnShow",function()
        state.resetting=true;previousQuery="";search:SetText("");state.resetting=nil
        state.browseOpen=true;state.browseActivated=true;state.how="world";state.ordinaryLocation=nil
        state.profession,state.zone,state.continent="mine",openingZone(),nil
        state.myProfessions,state.professionKnowledgeAvailable=readLearnedProfessions();resetResults()
        panel:RegisterEvent("GET_ITEM_INFO_RECEIVED");pcall(panel.RegisterEvent,panel,"ITEM_DATA_LOAD_RESULT");watchKnowledge(true);refresh()
    end)
    panel:HookScript("OnHide",function()
        cancelPreparation()
        panel:UnregisterEvent("GET_ITEM_INFO_RECEIVED");pcall(panel.UnregisterEvent,panel,"ITEM_DATA_LOAD_RESULT");watchKnowledge(false)
        if pendingSearch then pendingSearch:Cancel();pendingSearch=nil end
        closeMenus()
        local owner=GameTooltip:GetOwner()
        while owner do if owner==panel then GameTooltip:Hide();break end;owner=owner.GetParent and owner:GetParent() end
    end)
    panel:RegisterEvent("GET_ITEM_INFO_RECEIVED");pcall(panel.RegisterEvent,panel,"ITEM_DATA_LOAD_RESULT");watchKnowledge(true)
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

-- Explicit goals can reopen Steps even after the minimap visibility toggle.
function W.OpenSteps()
    hidden=false
    W.selection="step"
    applyMode()
    local frame=N.frame or N.root
    if frame and frame.Raise then frame:Raise() end
    return true
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
