local _, ns = ...
local E, facts = ns.Forever, ns.RecipeSourceFacts
local Catalog = { professions = facts.professions, revision = 0, sourceRevision = 0 }
ns.RecipeCatalog = Catalog

local vendorReagents = {
    [2320]=true, [2321]=true, [4291]=true, [8343]=true, [14341]=true,
    [4289]=true, [2678]=true, [3371]=true, [3372]=true, [4470]=true,
    [2324]=true, [2604]=true, [6260]=true, [2605]=true, [4341]=true,
    [4340]=true, [6261]=true, [2325]=true, [4342]=true,
    [2880]=true, [3466]=true, [3857]=true, [4399]=true, [4400]=true,
}
local stockRead
local observedByVendor, observedByItem
local purchaseRecipes
function E.NoteVendorStock(id)
    vendorReagents[id] = true
end

function E.IsVendorReagent(id)
    if vendorReagents[id] then return true end
    if not stockRead then
        stockRead = true
        for _, vendor in pairs(E.vendors) do
            for itemID in pairs(vendor.stockItems or {}) do
                E.NoteVendorStock(itemID)
            end
        end
    end
    return vendorReagents[id] == true
end

function E.SupplementalDrops(npcID)
    return facts.mobMaterials[npcID]
end

local function indexObserved(recipe, npcID)
    if not npcID then return end
    local key = recipe.spellID or recipe.learnableItemID
    local vendorRecipes = observedByVendor[npcID]
    if not vendorRecipes then
        vendorRecipes = {}
        observedByVendor[npcID] = vendorRecipes
    end
    vendorRecipes[key] = recipe
    if recipe.learnableItemID then observedByItem[recipe.learnableItemID] = recipe end
end

local function ensureObserved()
    if observedByVendor then return end
    observedByVendor, observedByItem = {}, {}
    for _, recipe in pairs(E.recipes) do
        if recipe.observed then
            for _, loc in ipairs(recipe.locations) do
                if loc.source == "Vendor" then indexObserved(recipe, loc.npcID) end
            end
        end
    end
end

function E.NoteRecipeSource(recipe, npcID)
    ensureObserved()
    purchaseRecipes = nil
    local key = recipe.spellID or recipe.learnableItemID
    local previous = observedByVendor[npcID]
    if not previous or not previous[key] then
        indexObserved(recipe, npcID)
    end
    -- An existing observation can update price, currency or source details too.
    Catalog.sourceRevision = Catalog.sourceRevision + 1
    Catalog.revision = Catalog.revision + 1
end

local function exact(loc)
    return type(loc) == "table" and loc.routingAllowed~=false and E.Public(loc.mapID) and E.Public(loc.x) and E.Public(loc.y)
        and type(loc.mapID) == "number" and type(loc.x) == "number" and type(loc.y) == "number"
        and loc.mapID > 0 and loc.x > 0 and loc.x <= 100 and loc.y > 0 and loc.y <= 100
end
Catalog.HasWaypoint = exact

local sourcePin, sourcePinCanvas, sourceLocationOnMap, mapHooked, ownedNativeWaypoint, sourceMapOwner
local function clearSourcePin()
    sourceLocationOnMap = nil
    sourceMapOwner = nil
    if sourcePin then sourcePin:Hide() end
end

local function nativeWaypoint()
    return C_Map and E.Call(C_Map.GetUserWaypoint)
end

local function nativeWaypointChanged()
    if sourceLocationOnMap and (nativeWaypoint() or C_Map and E.Call(C_Map.HasUserWaypoint)) then
        clearSourcePin()
    end
end

local function renderSourcePin()
    nativeWaypointChanged()
    local map = WorldMapFrame
    local loc = sourceLocationOnMap
    if not loc or not map or map:GetMapID() ~= loc.mapID then
        if sourcePin then sourcePin:Hide() end
        return
    end
    local scroll = map.ScrollContainer
    local canvas = E.Call(map.GetCanvas, map) or (scroll and (E.Call(scroll.GetScrollChild, scroll) or scroll.Child))
    if not canvas then
        if sourcePin then sourcePin:Hide() end
        return
    end
    if canvas ~= sourcePinCanvas then
        if sourcePin then sourcePin:Hide() end
        sourcePinCanvas = canvas
        sourcePin = canvas:CreateTexture(nil, "OVERLAY")
        sourcePin:SetTexture("Interface\\AddOns\\GrindingForever\\Media\\RecipePin")
        sourcePin:SetSize(22, 30)
        canvas:HookScript("OnSizeChanged", renderSourcePin)
    end
    sourcePin:ClearAllPoints()
    sourcePin:SetPoint("BOTTOM", canvas, "TOPLEFT", loc.x * canvas:GetWidth() / 100, -loc.y * canvas:GetHeight() / 100)
    sourcePin:Show()
end

function Catalog.PinWorldMap(loc)
    if not exact(loc) then return false end
    clearSourcePin()
    local map = WorldMapFrame
    if not map then
        E.Call(C_AddOns and C_AddOns.LoadAddOn or LoadAddOn, "Blizzard_WorldMap")
        map = WorldMapFrame
    end
    if map then
        if not mapHooked then
            mapHooked = true
            E.Call(map.RegisterCallback, map, "MapChanged", renderSourcePin, Catalog)
            map:HookScript("OnShow", renderSourcePin)
            local events = CreateFrame("Frame")
            E.Call(events.RegisterEvent, events, "USER_WAYPOINT_UPDATED")
            events:SetScript("OnEvent", nativeWaypointChanged)
        end
        map:Show()
        E.Call(map.SetMapID, map, loc.mapID)
    end
    local pinned = false
    local canPin = C_Map and (not C_Map.CanSetUserWaypointOnMap or E.Call(C_Map.CanSetUserWaypointOnMap, loc.mapID))
    if canPin and C_Map.SetUserWaypoint and UiMapPoint then
        local point = E.Call(UiMapPoint.CreateFromCoordinates, loc.mapID, loc.x / 100, loc.y / 100)
        if point then
            local ok, result = pcall(C_Map.SetUserWaypoint, point)
            pinned = ok and E.Public(result) and result ~= false
            if pinned and C_Map.GetUserWaypoint then
                local current = nativeWaypoint()
                local x, y
                if current and current.position then x, y = E.Call(current.position.GetXY, current.position) end
                pinned = current and E.Public(current.uiMapID) and current.uiMapID == loc.mapID and E.Public(x) and E.Public(y)
                    and type(x) == "number" and type(y) == "number"
                    and math.abs(x - loc.x / 100) < .0001 and math.abs(y - loc.y / 100) < .0001
            end
        end
    end
    if pinned then
        ownedNativeWaypoint = {mapID=loc.mapID, x=loc.x, y=loc.y}
        return true
    end
    local mapInfo = C_Map and E.Call(C_Map.GetMapInfo, loc.mapID)
    local zoneType = Enum and Enum.UIMapType and Enum.UIMapType.Zone or 3
    local mapType = mapInfo and mapInfo.mapType
    if not map or not E.Public(mapType) or type(mapType) ~= "number" or mapType < zoneType then return false end
    sourceLocationOnMap = loc
    renderSourcePin()
    return pinned == true or (sourcePin and sourcePin:IsShown() and map:GetMapID() == loc.mapID) == true
end

-- Clear only the waypoint created by this catalog at the requested location.
-- Browsing or replacing the player's waypoint must never erase another target.
function Catalog.UnpinWorldMap(loc)
    if not exact(loc) then return false end
    local function same(a)
        return a and a.mapID == loc.mapID and type(a.x) == "number" and type(a.y) == "number"
            and math.abs(a.x-loc.x) < .01 and math.abs(a.y-loc.y) < .01
    end
    local removed = false
    if same(sourceLocationOnMap) then clearSourcePin(); removed = true end
    if same(ownedNativeWaypoint) then
        local current = nativeWaypoint()
        local x, y
        if current and current.position then x,y = E.Call(current.position.GetXY,current.position) end
        local matches = current and E.Public(current.uiMapID) and current.uiMapID == loc.mapID
            and E.Public(x) and E.Public(y) and type(x)=="number" and type(y)=="number"
            and math.abs(x-loc.x/100)<.0001 and math.abs(y-loc.y/100)<.0001
        if matches and C_Map and C_Map.ClearUserWaypoint then
            local ok, result = pcall(C_Map.ClearUserWaypoint)
            if ok and E.Public(result) and result ~= false then
                local after = nativeWaypoint()
                local ax, ay
                if after and after.position then ax,ay=E.Call(after.position.GetXY,after.position) end
                local stillOwned = after and E.Public(after.uiMapID) and after.uiMapID == loc.mapID
                    and E.Public(ax) and E.Public(ay) and type(ax)=="number" and type(ay)=="number"
                    and math.abs(ax-loc.x/100)<.0001 and math.abs(ay-loc.y/100)<.0001
                if not stillOwned then removed = true; ownedNativeWaypoint = nil end
            end
        elseif not matches then
            ownedNativeWaypoint = nil
        end
    end
    return removed
end

function Catalog.PinSource(recipe, loc)
    if not exact(loc) then return false, false end
    local compass, workflow = ns.NavigationCompass, ns.WindowWorkflow
    local tracked = compass and compass.Enabled() or false
    if tracked then
        local key = "recipe-browser"
        compass.pins[key] = {key=key, name=loc.name and Catalog.SourceDisplayName(loc) or recipe.name, zone=loc.zone, location=loc,
            icon=loc.source=="Trainer" and workflow.TrainerIcon(recipe) or compass.professionPinTexture,
            professionPin=loc.source~="Trainer", customIcon=true}
        compass.age = 1
    end
    local pinned=Catalog.PinWorldMap(loc)
    if pinned==true then sourceMapOwner={location=loc,key=Catalog.SourceKey(loc)} end
    return pinned, tracked
end

local function sameSourceTarget(a,b)
    if not exact(a) or not exact(b) then return false end
    for _,key in ipairs({"npcID","questID","sourceID","nodeID"}) do
        if a[key] and b[key] and a[key]~=b[key] then return false end
    end
    return a.mapID==b.mapID
        and math.abs(a.x-b.x)<.0001 and math.abs(a.y-b.y)<.0001
        and Catalog.SourceKey(a)==Catalog.SourceKey(b)
end

function Catalog.IsSourcePinned(loc)
    if not exact(loc) then return false,false,false end
    local compass=ns.NavigationCompass
    local pin=compass and compass.pins and compass.pins["recipe-browser"]
    local compassPinned=pin and sameSourceTarget(pin.location,loc) or false
    local mapPinned=false
    if sourceMapOwner and sourceMapOwner.key==Catalog.SourceKey(loc) and sameSourceTarget(sourceMapOwner.location,loc) then
        if sameSourceTarget(sourceLocationOnMap,loc) then mapPinned=true
        elseif ownedNativeWaypoint and ownedNativeWaypoint.mapID==loc.mapID then
            local current=nativeWaypoint()
            local x,y
            if current and current.position then x,y=E.Call(current.position.GetXY,current.position) end
            mapPinned=current and E.Public(current.uiMapID) and current.uiMapID==loc.mapID
                and E.Public(x) and E.Public(y) and type(x)=="number" and type(y)=="number"
                and math.abs(x-loc.x/100)<.000001 and math.abs(y-loc.y/100)<.000001 or false
        end
    end
    return mapPinned or compassPinned,mapPinned,compassPinned
end

function Catalog.UnpinSource(loc)
    local _,mapPinned,compassPinned=Catalog.IsSourcePinned(loc)
    local mapRemoved=mapPinned and Catalog.UnpinWorldMap(loc) or false
    if mapRemoved then sourceMapOwner=nil end
    if compassPinned then
        ns.NavigationCompass.pins["recipe-browser"]=nil
        ns.NavigationCompass.age=1
    end
    return mapRemoved,compassPinned
end

local function locate(kind, id)
    local entity = facts.entities[kind] and facts.entities[kind][id]
    if not entity then return {name = kind .. " #" .. id, source = kind, sourceID = id} end
    local name, zone, mapID, x, y, faction = unpack(entity, 1, 6)
    local data = ns.ForeverQuestData
    if kind == "Quest" then
        local title = E.Call(C_QuestLog and C_QuestLog.GetTitleForQuestID, id)
        if E.Public(title) and type(title) == "string" and title ~= "" then name = title end
    end
    if not mapID then
        local zoneInfo = zone and ns.ForeverData.zones[zone]
        mapID = zoneInfo and zoneInfo.mapID
    end
    if kind ~= "Quest" and not x and mapID and data and data.spawns then
        for _, spawn in ipairs(data.spawns["npc:" .. id] or {}) do
            if spawn.mapID == mapID and spawn.x and spawn.y then
                x, y = spawn.x, spawn.y
                break
            end
        end
    end
    return { name = name or kind .. " #" .. id, zone = zone, mapID = mapID, x = x, y = y,
        faction = faction, source = kind, sourceID = id, npcID = kind ~= "Quest" and id or nil,
        questID = kind == "Quest" and id or nil }
end

local offerCostFields={"price","quantity","hasExtendedCost","verifiedCoinCost","currency","currencyType","currencyID",
    "currencyItemID","currencyAmount","merchantFavor","costComponents","costComponentsComplete","costEvidence",
    "costSignature","costText","offerCostEvidence","costReadIncomplete","costReference","costAvailabilityNote",
    "costEvidenceTier","priceEvidence"}
Catalog.OfferCostFields=offerCostFields
local function costInteger(value,minimum)
    return E.Public(value) and type(value)=="number" and value==value and value>=minimum
        and value<=1e12 and value==math.floor(value) and value or nil
end
function Catalog.IsVerifiedCoinOffer(loc)
    return type(loc)=="table" and loc.verifiedCoinCost==true and loc.hasExtendedCost~=true and costInteger(loc.price,0)~=nil
end
function Catalog.HasNativeOfferCost(loc)
    return type(loc)=="table" and (loc.costEvidence=="native-merchant-offer" and loc.costComponentsComplete==true
        or loc.evidence=="observed-player-at-vendor" and Catalog.IsVerifiedCoinOffer(loc)) and true or false
end
function Catalog.ApplyOfferCost(itemID,loc)
    if type(loc)~="table" or loc.source~="Vendor" then return loc end
    if Catalog.HasNativeOfferCost(loc) then return loc end
    local offers=facts.vendorOfferCosts and facts.vendorOfferCosts[itemID]
    local offer=offers and offers[loc.npcID or loc.sourceID]
    if not offer then return loc end
    local copy={};for key,value in pairs(loc) do copy[key]=value end
    if offer.costComponentsComplete==true or offer.verifiedCoinCost==true and offer.hasExtendedCost==false then
        for _,key in ipairs(offerCostFields) do copy[key]=nil end
    end
    for _,key in ipairs(offerCostFields) do if offer[key]~=nil then copy[key]=offer[key] end end
    return copy
end
function Catalog.OfferCostText(loc,favor)
    if type(loc)~="table" then return end
    local function display(text)return loc.costReference==true and "Reference cost: "..text or text end
    local function coin(amount)
        return GetCoinTextureString and E.Call(GetCoinTextureString,amount) or tostring(amount).."c"
    end
    if loc.costComponentsComplete==true and type(loc.costComponents)=="table" then
        local pieces={}
        for _,component in ipairs(loc.costComponents) do
            if type(component)~="table" then return end
            local amount=costInteger(component.amount,1)
            if not amount then return end
            if component.kind=="coin" then pieces[#pieces+1]=coin(amount)
            elseif component.kind=="currency" or component.kind=="item" then
                local id=costInteger(component.kind=="currency" and component.currencyID or component.itemID,1)
                if not id then return end
                local name=E.Public(component.name) and type(component.name)=="string" and component.name:find("%S") and component.name
                    or (component.kind=="currency" and "Currency " or "Item ")..id
                pieces[#pieces+1]=amount.." × "..name
            else return end
        end
        if #pieces>0 then return display(table.concat(pieces," + ")) end
        if Catalog.IsVerifiedCoinOffer(loc) and loc.price==0 then return display(coin(0)) end
    end
    local amount=costInteger(loc.currencyAmount,1)
    if favor and amount then
        local price=costInteger(loc.price,1)
        return display((price and coin(price).." + " or "")..amount.." Merchant's Favor")
    end
    if Catalog.IsVerifiedCoinOffer(loc) then return display(coin(loc.price)) end
    if not favor and not loc.costReadIncomplete and loc.hasExtendedCost~=true and costInteger(loc.price,1) then return display(coin(loc.price)) end
end

local function sourceLocation(raw,itemID)
    local kind, id = raw[1], raw[2]
    local loc
    if facts.entities[kind] then
        loc = locate(kind, id)
    elseif kind == "World Drop" then
        loc = { name = id or kind, source = kind }
    else
        loc = { name = type(id) == "string" and id or kind, source = kind }
    end
    loc.stock = raw[3]
    loc.requirement = raw[4]
    return Catalog.ApplyOfferCost(itemID,loc)
end

local function identity(loc)
    local kind = loc.source or ""
    local id = loc.sourceID or loc.npcID or loc.questID
    if id then return kind .. ":" .. id .. ":" .. (loc.mapID or "") end
    return kind .. ":" .. (loc.name or "") .. ":" .. (loc.zone or "")
end

Catalog.SourceKey = identity

local function addLocation(recipe, loc)
    local key = identity(loc)
    local at = recipe.sourceIndexes[key]
    if not at then
        at = #recipe.locations + 1
        recipe.sourceIndexes[key] = at
    else
        local previous = recipe.locations[at]
        if exact(previous) and not exact(loc) then return end
        local inherit=previous.requirement and not loc.requirement
        for _,field in ipairs(offerCostFields) do if loc[field]==nil and previous[field]~=nil then inherit=true;break end end
        if inherit then
            local merged = {}
            for field, value in pairs(loc) do merged[field] = value end
            merged.requirement = merged.requirement or previous.requirement
            -- A complete current observation supersedes an older reference cost.
            if not Catalog.HasNativeOfferCost(loc) then
                for _,field in ipairs(offerCostFields) do if merged[field]==nil then merged[field]=previous[field] end end
            end
            loc = merged
        end
    end
    recipe.locations[at] = loc
end

local function buildFacts(checkpoint)
    local recipes = {}
    for _, fact in ipairs(facts.recipes) do
        local profession, spellID, name, skill, itemID, productID, sources = unpack(fact, 1, 7)
        local recipe = {
            profession = facts.professions[profession], spellID = spellID, name = name,
            skill = skill, itemID = itemID, learnableItemID = itemID, productID = productID,
            locations = {}, sourceIndexes = {},
        }
        recipes[#recipes + 1] = recipe
        for _, raw in ipairs(sources) do
            addLocation(recipe, sourceLocation(raw,itemID))
            if checkpoint then checkpoint() end
        end
        if checkpoint then checkpoint() end
    end
    return recipes
end

local function hasText(value)
    return type(value) == "string" and value:find("%S") ~= nil
end

local function positiveInteger(value)
    if not E.Public(value) then return end
    local number = type(value)=="number" and value or type(value)=="string" and tonumber(value)
    if number and number>0 and number<math.huge and number==math.floor(number) then return number end
end

-- Unicode cmap coverage of the bundled Naowh.ttf; layout whitespace is allowed.
local displayRanges={
    {160,255},{305,305},{321,322},{338,339},{352,353},{376,376},{381,382},{402,402},
    {710,711},{713,713},{728,733},{894,894},{916,916},{937,937},{956,956},{960,960},
    {8211,8212},{8216,8218},{8220,8222},{8224,8226},{8230,8230},{8240,8240},{8249,8250},
    {8364,8364},{8482,8482},{8706,8706},{8719,8719},{8721,8722},{8725,8725},{8730,8730},
    {8734,8734},{8747,8747},{8776,8776},{8800,8800},{8804,8805},{8901,8901},{9674,9674},{64257,64258},
}
local displaySupport={}
function Catalog.SupportsDisplayText(value)
    if not E.Public(value) or type(value)~="string" then return false end
    if displaySupport[value]~=nil then return displaySupport[value] end
    local at,supported=1,true
    while at<=#value do
        local first=value:byte(at)
        local code,length,minimum=first,1,0
        if first>=194 and first<=223 then code,length,minimum=first-192,2,128
        elseif first>=224 and first<=239 then code,length,minimum=first-224,3,2048
        elseif first>=240 and first<=244 then code,length,minimum=first-240,4,65536
        elseif first>=128 then supported=false;break end
        for offset=1,length-1 do
            local byte=value:byte(at+offset)
            if not byte or byte<128 or byte>191 then supported=false;break end
            code=code*64+byte-128
        end
        if not supported or code<minimum or code>1114111 or code>=55296 and code<=57343 then supported=false;break end
        if code>126 then
            local mapped=false
            for _,range in ipairs(displayRanges) do if code>=range[1] and code<=range[2] then mapped=true;break end end
            if not mapped then supported=false;break end
        elseif code<32 and code~=9 and code~=10 and code~=13 then supported=false;break end
        at=at+length
    end
    displaySupport[value]=supported
    return supported
end
function Catalog.SourceDisplayName(loc)
    loc=type(loc)=="table" and loc or {}
    local name=E.Public(loc.name) and hasText(loc.name) and loc.name
        or E.Public(loc.source) and hasText(loc.source) and loc.source or "Source"
    if Catalog.SupportsDisplayText(name) then return name,true end
    local id=positiveInteger(loc.npcID)
    local data=ns.ForeverQuestData
    local aliases=ns.ForeverCatalog and ns.ForeverCatalog.npcNames
    local canonical=id and data and data.names and data.names["npc:"..id]
    if not (hasText(canonical) and Catalog.SupportsDisplayText(canonical)) then canonical=id and aliases and aliases[id] end
    if hasText(canonical) and Catalog.SupportsDisplayText(canonical) then return canonical,true end
    -- Retain meaningful Unicode when no verified same-ID name is available.
    return name,false
end

local function thistleTea(recipe)
    local spell=positiveInteger(recipe.spellID)
    local item=positiveInteger(recipe.learnableItemID or recipe.itemID or recipe.itemId)
    return spell==9513 or item==18160 or item==7678
end

local thistleQuests={Alliance=2359,Horde=2478}
function Catalog.PurchasePolicyAllows(recipe,state)
    if type(recipe)~="table" or not thistleTea(recipe) then return true end
    state=state or E.state or E.Snapshot()
    if state.class~="ROGUE" then return false end
    local questID=thistleQuests[state.faction]
    local cooking=state.skills and state.skills.Cooking
    local rank=type(cooking)=="table" and positiveInteger(cooking.rank)
    if not questID or not rank or rank<60 then return false end
    if state.completed and state.completed[questID]==true then return true end
    local quest=E.Call(E.QuestState,questID)
    return type(quest)=="table" and E.Public(quest.rewarded) and quest.rewarded==true or false
end

local itemNames, requestedNames, pendingNames, itemNameVersions = {}, {}, {}, {}
Catalog.PendingItemNames = pendingNames
local function usableItemName(name)
    return E.Public(name) and hasText(name) and not name:match("^Item%s*#?%d+$")
end

local function readItemName(itemID)
    local name=E.Call(C_Item and C_Item.GetItemNameByID,itemID)
    if not usableItemName(name) then name=(facts.ingredientNames or {})[itemID] end
    -- Recorded names avoid thousands of legacy GetItemInfo cache requests
    -- while searching the full catalogue. Request only unresolved identities.
    if not usableItemName(name) then name=E.Call(C_Item and C_Item.GetItemInfo or GetItemInfo,itemID) end
    if usableItemName(name) then return name end
end

function Catalog.ItemName(itemID)
    itemID=positiveInteger(itemID)
    if not itemID then return end
    if itemNames[itemID] then return itemNames[itemID] end
    if pendingNames[itemID] then return end
    local name=readItemName(itemID)
    if name then
        itemNames[itemID]=name
        itemNameVersions[itemID]=(itemNameVersions[itemID] or 0)+1
        return name
    end
    if not requestedNames[itemID] then
        requestedNames[itemID],pendingNames[itemID]=true,true
        E.Call(C_Item and C_Item.RequestLoadItemDataByID,itemID)
    end
end

local nameEvents=CreateFrame("Frame")
nameEvents:SetScript("OnEvent",function(_,_,itemID,success)
    itemID=positiveInteger(itemID)
    if not itemID or not E.Public(success) or not (requestedNames[itemID] or itemNames[itemID]) then return end
    local wasPending=pendingNames[itemID]
    pendingNames[itemID]=nil
    if success==true then
        local previous=itemNames[itemID]
        local name=readItemName(itemID)
        if name then
            itemNames[itemID]=name
            if name~=previous then itemNameVersions[itemID]=(itemNameVersions[itemID] or 0)+1 end
        end
        if wasPending or (name and name~=previous) then Catalog.revision=Catalog.revision+1 end
    end
end)
nameEvents:RegisterEvent("GET_ITEM_INFO_RECEIVED")
pcall(nameEvents.RegisterEvent,nameEvents,"ITEM_DATA_LOAD_RESULT")

local function observedIngredients(reagents)
    if not E.Public(reagents) or type(reagents)~="table" then return end
    local amounts,rows={},{}
    for key,value in pairs(reagents) do
        local item,count=positiveInteger(key),positiveInteger(value)
        if not item or not count or amounts[item] then return end
        amounts[item]=count
        rows[#rows+1]={item,count}
    end
    if #rows==0 then return end
    table.sort(rows,function(a,b)return a[1]<b[1]end)
    return rows
end

function Catalog.Ingredients(recipe)
    recipe=type(recipe)=="table" and recipe or {}
    local recorded=observedIngredients(recipe.reagents)
    local source=recorded and "observed" or "exported"
    if not recorded then recorded=(facts.ingredients or {})[positiveInteger(recipe.spellID or recipe.id)] end
    local result,completeNames={},true
    for _,pair in ipairs(recorded or {}) do
        local name=Catalog.ItemName(pair[1])
        result[#result+1]={itemID=pair[1],name=name,count=pair[2],unresolvedName=not name or nil}
        if not name then completeNames=false end
    end
    if #result==0 then source,completeNames="unrecorded",false end
    return result,{source=source,completeNames=completeNames,clientBuild=source=="exported" and facts.ingredientMeta and facts.ingredientMeta.clientBuild or nil}
end

local itemQueryIndexes=setmetatable({}, {__mode="k"})
local function queryInputs(recipe)
    local spell=positiveInteger(recipe.spellID or recipe.id)
    local product=positiveInteger(recipe.productID)
    local learnable=positiveInteger(recipe.learnableItemID or recipe.itemID or recipe.itemId)
    local link=E.Public(recipe.productLink) and type(recipe.productLink)=="string" and recipe.productLink or nil
    local reagents=E.Public(recipe.reagents) and recipe.reagents or nil
    return spell,product,learnable,link,reagents
end
local function queryIndexCurrent(index,recipe,spell,product,learnable,link,reagents)
    if not index or index.spell~=spell or index.product~=product or index.learnable~=learnable or index.link~=link
        or index.reagents~=reagents or index.exported~=(facts.ingredients or {})[spell] then return false end
    if type(reagents)=="table" then
        local count=0
        for key,value in pairs(reagents) do
            if not E.Public(key) or not E.Public(value) or not index.reagentValues or index.reagentValues[key]~=value then return false end
            count=count+1
        end
        if count~=index.reagentCount then return false end
    end
    if index.exportRows then
        local count=0
        for i,pair in ipairs(index.exported) do
            local previous=index.exportRows[i]
            if not previous or previous[1]~=pair or previous[2]~=pair[1] or previous[3]~=pair[2] then return false end
            count=count+1
        end
        if count~=#index.exportRows then return false end
    end
    for _,entry in ipairs(index.entries) do
        local itemID=entry.lookupID
        if itemID and not entry.literal and (entry.version~=(itemNameVersions[itemID] or 0)
            or (not entry.text and not pendingNames[itemID] and not itemNames[itemID])) then return false end
    end
    return true
end
local function appendQueryName(index,name,role,itemID,literal)
    local lookupID=positiveInteger(itemID)
    index.entries[#index.entries+1]={text=usableItemName(name) and name:lower() or nil,role=role,itemID=itemID,
        literal=literal,lookupID=lookupID,version=itemNameVersions[lookupID] or 0}
end
local function buildQueryIndex(recipe,spell,product,learnable,link,reagents)
    local index={spell=spell,product=product,learnable=learnable,link=link,reagents=reagents,
        exported=(facts.ingredients or {})[spell],entries={}}
    if type(reagents)=="table" then
        index.reagentValues={};index.reagentCount=0
        for key,value in pairs(reagents) do
            if E.Public(key) and E.Public(value) then
                index.reagentValues[key]=value;index.reagentCount=index.reagentCount+1
            end
        end
    end
    local ingredients,metadata=Catalog.Ingredients(recipe)
    if metadata.source~="observed" and type(index.exported)=="table" then
        index.exportRows={}
        for _,pair in ipairs(index.exported) do index.exportRows[#index.exportRows+1]={pair,pair[1],pair[2]} end
    end
    for _,ingredient in ipairs(ingredients) do appendQueryName(index,ingredient.name,"ingredient",ingredient.itemID) end
    itemQueryIndexes[recipe]=index
    return index
end
local function findQueryMatch(index,query,first)
    for i=first or 1,#index.entries do
        local entry=index.entries[i]
        if entry.text and entry.text:find(query,1,true) then
            index.matched,index.role,index.itemID=true,entry.role,entry.itemID;return true
        end
    end
    return false
end
function Catalog.MatchesItemQuery(recipe,query)
    if type(recipe)~="table" or not E.Public(query) or type(query)~="string" then return false end
    query=query:match("^%s*(.-)%s*$"):lower()
    if query=="" then return false end
    local spell,product,learnable,link,reagents=queryInputs(recipe)
    local index=itemQueryIndexes[recipe]
    if not queryIndexCurrent(index,recipe,spell,product,learnable,link,reagents) then index=buildQueryIndex(recipe,spell,product,learnable,link,reagents) end
    if index.query~=query then
        index.query,index.matched,index.role,index.itemID=query,false,nil,nil
        findQueryMatch(index,query)
        if not index.matched and not index.productBuilt then
            index.productBuilt=true
            local first=#index.entries+1
            if product then
                appendQueryName(index,Catalog.ItemName(product),"product",product)
                if link and E.ItemID(link)==product then appendQueryName(index,link:match("|h%[(.-)%]|h"),"product",product,true) end
            end
            findQueryMatch(index,query,first)
        end
        if not index.matched and not index.learnableBuilt then
            index.learnableBuilt=true
            local first=#index.entries+1
            if learnable then appendQueryName(index,Catalog.ItemName(learnable),"learnable",learnable) end
            findQueryMatch(index,query,first)
        end
    end
    if index.matched then return true,index.role,index.itemID end
    return false
end

function Catalog.RequirementLines(recipe,loc,state)
    recipe=type(recipe)=="table" and recipe or {}
    local original=E.recipes[positiveInteger(recipe.spellID or recipe.id)]
    if type(original)=="table" and original~=recipe then
        local display={}
        for key,value in pairs(original) do display[key]=value end
        for key,value in pairs(recipe) do display[key]=value end
        recipe=display
    end
    loc=type(loc)=="table" and loc or {}
    state=state or E.state or {}
    local lines,seen={},{}
    local function add(text)
        if usableItemName(text) and not seen[text] then seen[text]=true;lines[#lines+1]=text end
    end
    local function text(value)return E.Public(value) and type(value)=="string" and hasText(value) and value or nil end
    local skill=positiveInteger(recipe.requiredSkill) or positiveInteger(recipe.skill) or positiveInteger(loc.requiredSkill)
    if skill and text(recipe.profession) then add(recipe.profession.." "..skill.." required") end
    for _,row in ipairs({recipe,loc}) do
        add(text(row.requirement))
        if text(row.faction) and row.faction~="Both" and row.faction~="Neutral" then add("Faction: "..row.faction) end
        if text(row.class) then add("Class: "..row.class) end
        if text(row.race) then add("Race: "..row.race) end
        local rep=positiveInteger(row.reputationID)
        if rep then
            local names={[1]="Hated",[2]="Hostile",[3]="Unfriendly",[4]="Neutral",[5]="Friendly",[6]="Honored",[7]="Revered",[8]="Exalted"}
            local current=state.reputations and state.reputations[rep]
            local faction=current and text(current.name) or "Reputation "..rep
            local standing=positiveInteger(row.reputationStanding)
            add(faction..(standing and (" · "..(names[standing] or "standing "..standing).." required") or " required"))
        end
        local specialization=positiveInteger(row.specializationSpell)
        if specialization then add("Specialization: "..(E.SpellName(specialization) or "Spell "..specialization)) end
    end
    -- Source min/max levels can describe NPCs. Only explicit player-level
    -- fields and canonical quest min_level are requirements here.
    local minimum=positiveInteger(recipe.minLevel) or positiveInteger(loc.requiredLevel)
    local maximum=positiveInteger(recipe.maxLevel)
    if minimum then add("Level "..minimum.." required") end
    if maximum then add("Maximum level: "..maximum) end
    local data=ns.ForeverQuestData
    local function questName(id)
        local quest=data and data.quests and data.quests[id]
        return quest and text(quest.title) or text(E.Call(C_QuestLog and C_QuestLog.GetTitleForQuestID,id)) or "Quest "..id
    end
    if thistleTea(recipe) then
        add("Acquisition: Rogue class quest")
        local thistleQuest=thistleQuests[state.faction]
        add(thistleQuest and ("Vendor purchase requires completed quest: "..questName(thistleQuest))
            or "Vendor purchase requires the completed faction Rogue class quest")
    end
    local function prerequisite(id)
        if not E.Public(id) or type(id)~="number" or id==0 or id<=-math.huge or id>=math.huge or id~=math.floor(id) then return end
        local key=math.abs(id)
        return (id<0 and "In quest log: " or "Complete: ")..questName(key)
    end
    local required=positiveInteger(recipe.requiredQuest) or positiveInteger(loc.requiredQuest)
    if required then add("Requires quest: "..questName(required)) end
    local questID=positiveInteger(loc.questID) or positiveInteger(recipe.questID)
    if questID then add("Quest: "..questName(questID)) end
    local visited={}
    for _,id in ipairs({required or false,questID or false}) do
      if id and not visited[id] then
        visited[id]=true
        local quest=data and data.quests and data.quests[id]
        if quest then
            local level=positiveInteger(quest.min_level)
            if level then add("Quest requires level "..level) end
            local any={}
            for _,record in ipairs(quest.prerequisites or {}) do
                local label=prerequisite(record.pre)
                if label then
                    if record.mode=="any" then any[#any+1]=label
                    else add("Known prerequisite · "..label) end
                end
            end
            if #any>0 then add("Known prerequisite · one of: "..table.concat(any," or ")) end
        end
      end
    end
    return lines
end

-- Create Item effects in Forever 1.60.1.70938 SpellEffect.db2 (confirmed in ItemSparse).
local clientProductIDs = {
    [3276] = 2581, [3277] = 3530, [3278] = 3531, [7928] = 6450, [7934] = 6452,
    [1262975] = 279948, [1262980] = 279964, [1262985] = 279969,
    [1262990] = 279965, [1262996] = 279940, [1263005] = 279970,
}
-- Forever teaches these potion recipes under First Aid. Trainer offers come from the observed Forever catalog.
local firstAidPotions = {
    {spellID = 1244432, name = "Lesser Healing Potion", productID = 858, requiredSkill = 55},
    {spellID = 1244433, name = "Healing Potion", productID = 929, requiredSkill = 110},
}

function Catalog.Browse(checkpoint)
    if type(checkpoint)~="function" then checkpoint=nil end
    local rows, bySpell, byItem = {}, {}, {}
    local function merge(recipe)
        local itemID = recipe.learnableItemID or recipe.itemID
        local row = recipe.spellID and bySpell[recipe.spellID] or nil
        -- The bundled Forever acquisition uses18160. The older7678 lead is
        -- retained in E.recipes, but cannot replace it without observation.
        if row and row.spellID==9513 and row.learnableItemID==18160 and itemID==7678
            and recipe.catalogOnly and not recipe.observed then itemID=18160 end
        local itemMatch = itemID and byItem[itemID]
        if not row and itemMatch and (not itemMatch.spellID or not recipe.spellID) then row = itemMatch end
        if not row then
            row = {locations = {}, sourceIndexes = {}}
            rows[#rows + 1] = row
        end
        if recipe.productID and row.productID ~= recipe.productID then
            row.productID, row.productLink = recipe.productID, nil
        end
        if recipe.productLink and E.ItemID(recipe.productLink) == row.productID then
            row.productLink = recipe.productLink
        end
        for _, key in ipairs({"spellID", "profession", "faction", "skill", "requiredSkill", "knowledgeVerified", "learned",
            "minLevel", "maxLevel", "requiredQuest", "reputationID", "reputationStanding", "specializationSpell", "reagents"}) do
            if recipe[key] ~= nil and (key ~= "profession" or hasText(recipe[key])) then row[key] = recipe[key] end
        end
        if itemID then row.learnableItemID = itemID; byItem[itemID] = row end
        if row.spellID then bySpell[row.spellID] = row end
        if hasText(recipe.name) and not recipe.name:match("^Spell %d+$") then row.name = recipe.name end
        for _, loc in ipairs(recipe.locations or {}) do
            addLocation(row, loc)
            if checkpoint then checkpoint() end
        end
        if checkpoint then checkpoint() end
    end
    for _, recipe in ipairs(buildFacts(checkpoint)) do merge(recipe) end
    local offers = ns.ForeverCatalog and ns.ForeverCatalog.recipes
    for _, potion in ipairs(firstAidPotions) do
        local locations = {}
        for _, trainer in ipairs(offers and offers[potion.spellID] or {}) do
            locations[#locations + 1] = {
                name = trainer.name, source = trainer.kind, npcID = trainer.npcID,
                mapID = trainer.mapID, zone = trainer.zone, x = trainer.x, y = trainer.y,
                faction = trainer.faction, price = trainer.price,
            }
            if checkpoint then checkpoint() end
        end
        merge({
            spellID = potion.spellID, name = potion.name, productID = potion.productID,
            profession = "First Aid", requiredSkill = potion.requiredSkill, locations = locations,
        })
    end
    for _, recipe in pairs(E.recipes) do
        local oldAlchemyPotion = recipe.spellID == 2337 or recipe.spellID == 3447
        if not oldAlchemyPotion or recipe.observed then merge(recipe) end
    end
    for _, recipe in ipairs(rows) do
        recipe.productID = recipe.productID or clientProductIDs[recipe.spellID]
        if not hasText(recipe.name) then
            local spellName = recipe.spellID and E.SpellName(recipe.spellID)
            recipe.name = hasText(spellName) and spellName or "Unnamed Recipe"
        end
        recipe.key = recipe.spellID or recipe.learnableItemID or recipe.name
        recipe.sourceIndexes = nil
        if checkpoint then checkpoint() end
    end
    return rows
end

function Catalog.PurchaseRecipes()
    if purchaseRecipes then return purchaseRecipes end
    local rows = {}
    local sources = ns.ForeverCatalog and ns.ForeverCatalog.byItem or {}
    for _, recipe in ipairs(Catalog.Browse()) do
        local itemID = recipe.learnableItemID
        local vendors = {}
        for _, loc in ipairs(recipe.locations) do
            if loc.source == "Vendor" and (not thistleTea(recipe) or loc.npcID==6779) then vendors[#vendors + 1] = loc end
        end
        for _, loc in ipairs(sources[itemID] or {}) do
            if (loc.kind == "Vendor" or loc.source == "Vendor") and (not thistleTea(recipe) or loc.npcID==6779) then vendors[#vendors + 1] = loc end
        end
        recipe.requiredSkill = recipe.skill or recipe.requiredSkill
        if itemID and recipe.spellID and recipe.requiredSkill and #vendors > 0 then
            recipe.vendors = vendors
            rows[#rows + 1] = recipe
        end
    end
    table.sort(rows, function(a, b) return a.spellID < b.spellID end)
    purchaseRecipes = rows
    return rows
end

local recipeItemPrefixes = {
    Recipe = true, Pattern = true, Plans = true, Formula = true,
    Schematic = true, Manual = true, Design = true, Technique = true,
}

local function vendorRecipeName(name)
    local prefix, title = name:match("^(%a+):%s*(.+)$")
    return recipeItemPrefixes[prefix] and title or name
end

local function vendorTooltipLines(id)
    local rows, byItem, bySpell = {}, {}, {}
    local function add(itemID, spellID, name, profession, skill)
        if not hasText(name) then return end
        local label = vendorRecipeName(name)
        local hasSkill = hasText(profession) and type(skill) == "number" and skill > 0
        if hasSkill then label = label .. (" (%s %d)"):format(profession, skill) end
        local row = byItem[itemID] or bySpell[spellID]
        if not row then
            row = { label = label, hasSkill = hasSkill }
            rows[#rows + 1] = row
        elseif hasSkill and not row.hasSkill then
            row.label, row.hasSkill = label, true
        end
        if itemID then byItem[itemID] = row end
        if spellID then bySpell[spellID] = row end
    end
    local function addFact(fact, fallback)
        if not E.SeasonalAvailable({spellID = fact[2], learnableItemID = fact[5]}) then return end
        local name = fact[3] or E.SpellName(fact[2])
        local skill = fact[4] and fact[4] > 0 and fact[4] or fallback
        add(fact[5], fact[2], name, facts.professions[fact[1]], skill)
    end

    for _, index in ipairs(facts.byVendor[id] or {}) do
        addFact(facts.recipes[index])
    end
    for _, recipe in pairs(observedByVendor[id] or {}) do
        if E.SeasonalAvailable(recipe) then
            local itemID = recipe.learnableItemID
            local fact
            for _, index in ipairs(facts.byItem[itemID] or {}) do
                local candidate = facts.recipes[index]
                -- This index also contains finished products, including items that teach another recipe.
                if candidate[5] == itemID then
                    fact = candidate
                    break
                end
            end
            if fact then
                addFact(fact, recipe.requiredSkill or recipe.skill)
            else
                add(itemID, recipe.spellID, recipe.name, recipe.profession, recipe.requiredSkill or recipe.skill)
            end
        end
    end

    local lines = {}
    for _, row in ipairs(rows) do lines[#lines + 1] = row.label end
    return lines
end

local function recipeItemSourceLines(id)
    local indexes, observed = facts.byItem[id], observedByItem[id]
    if not indexes and not observed then return {} end
    local faction = E.state and E.state.faction or E.Call(UnitFactionGroup, "player")
    local player = E.CurrentPosition()
    local merchant = E.activeRecipeMerchant
    local trading = merchant and MerchantFrame and E.Call(MerchantFrame.IsShown, MerchantFrame) == true
    local function factionAllows(side)
        return not side or side == "Neutral" or side == "Both"
            or E.Public(faction) and faction == side
    end
    local function nearby(vendor, npcID)
        if not vendor or not factionAllows(vendor.faction) then return false end
        if trading and merchant.npcID == npcID then return true end
        local yards = player and exact(vendor) and E.Distance(player, vendor)
        return yards and yards <= E.RecipeVendorRadius
    end
    local sources, seen = {}, {}
    local function addSource(key, description, zone)
        local source = seen[key]
        if source then
            source.zone = source.zone or zone
        else
            source = {description = description, zone = zone}
            seen[key] = source
            sources[#sources + 1] = source
        end
    end
    for _, index in ipairs(indexes or {}) do
        local fact = facts.recipes[index]
        if E.SeasonalAvailable({spellID = fact[2], learnableItemID = fact[5]}) then
            for _, source in ipairs(fact[7]) do
                local kind, sourceID = source[1], source[2]
                local entity = facts.entities[kind] and facts.entities[kind][sourceID]
                if kind == "Vendor" then
                    local vendor = E.vendors[sourceID]
                    if not nearby(vendor, sourceID) then vendor = entity and locate(kind, sourceID) end
                    if nearby(vendor, sourceID) then
                        local crafted = fact[6] == id and fact[5] ~= id
                        local verb = crafted and "Recipe sold by " or "Sold by "
                        local key = "Vendor:" .. sourceID .. (crafted and ":recipe" or "")
                        addSource(key, verb .. (vendor.name or "Vendor #" .. sourceID), vendor.zone)
                    end
                elseif kind ~= "Trainer" and entity and factionAllows(entity[6]) then
                    local verb = kind == "Drop" and "Drops from " or "Reward from "
                    local name = entity[1] or (kind .. " #" .. sourceID)
                    addSource(kind .. ":" .. sourceID, verb .. name, entity[2])
                elseif kind == "World Drop" then
                    addSource(kind .. ":" .. (sourceID or ""), "World drop", sourceID)
                end
            end
        end
    end
    if observed and E.SeasonalAvailable(observed) then
        for _, loc in ipairs(observed.locations) do
            if loc.source == "Vendor" and loc.npcID and loc.name and nearby(loc, loc.npcID) then
                addSource("Vendor:" .. loc.npcID, "Sold by " .. loc.name, loc.zone)
            end
        end
    end
    local lines = {}
    for _, source in ipairs(sources) do
        local label = source.description .. (source.zone and (" (" .. source.zone .. ")") or "")
        lines[#lines + 1] = label
    end
    return lines
end

function E.RecipeTooltipLines(id, isUnit)
    ensureObserved()
    local lines = isUnit and vendorTooltipLines(id) or recipeItemSourceLines(id)
    if #lines == 0 then return nil end
    local out, seen = {}, {}
    for _, label in ipairs(lines) do
        if not seen[label] then
            seen[label] = true
            out[#out + 1] = label
        end
    end
    table.sort(out)
    if #out > 10 then
        local count = #out
        for i = count, 11, -1 do out[i] = nil end
        out[11] = "+" .. (count - 10) .. " more in Recipe Sources"
    end
    if isUnit then table.insert(out, 1, "Recipes for sale") end
    return out
end
