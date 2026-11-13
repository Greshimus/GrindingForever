local addonName, ns = ...
local P = {}
ns.ProfessionKnowledge = P

P.maps = {
    Westfall = 1436, ["Redridge Mountains"] = 1433, ["Deadwind Pass"] = 1430,
    ["Swamp of Sorrows"] = 1435, Azshara = 1447, Silithus = 1451,
}

-- Camp destinations are open routes with no inferred segments.
local function camp(zone, level, x, y, targets, ...)
    return {kind="Cloth", zone=zone, minSkill=1, minLevel=level,
        materials={...}, points={{x,y}}, mode="open", targets=targets}
end
P.maps["Western Plaguelands"] = 1422
local function hordeCamp(...)
    local route = camp(...)
    route.faction = "Horde"
    return route
end
P.camps = {
    hordeCamp("Durotar", 6, 59.2, 58.5, "Kul Tiras sailors and marines at Tiragarde Keep", "Linen Cloth"),
    hordeCamp("The Barrens", 16, 44, 51, "Bristleback quilboars", "Wool Cloth", "Linen Cloth"),
    hordeCamp("Hillsbrad Foothills", 22, 33, 41, "Hillsbrad farmers and footmen", "Wool Cloth", "Linen Cloth"),
    camp("Westfall", 11, 47, 19, "Riverpaw gnolls and Defias", "Linen Cloth"),
    camp("The Barrens", 12, 63, 46, "Southsea pirates", "Linen Cloth"),
    camp("Hillsbrad Foothills", 20, 79, 43, "Durnholde Syndicate", "Wool Cloth", "Linen Cloth"),
    camp("Arathi Highlands", 30, 32, 29, "Northfold Manor Syndicate", "Silk Cloth"),
    camp("Stranglethorn Vale", 34, 24, 11, "Bloodscalp trolls", "Silk Cloth"),
    camp("Tanaris", 45, 40, 54, "Dunemaul ogres", "Mageweave Cloth"),
    camp("Felwood", 49, 41.1, 82.9, "Jadefire Glen satyrs", "Mageweave Cloth"),
    camp("Felwood", 52, 42, 18, "Jadefire Run satyrs", "Felcloth", "Runecloth"),
    camp("Western Plaguelands", 56, 63, 58, "Gahrron's Withering ghosts", "Runecloth"),
    camp("Winterspring", 56, 67, 37.4, "Winterfall furbolgs", "Runecloth"),
    camp("Silithus", 58, 39, 45, "Twilight's Hammer cultists", "Runecloth"),
}

-- Camp approaches only. Skinning tables can overlap between leather tiers.
local function skin(zone, level, skill, x, y, targets, ...)
    P.camps[#P.camps+1] = {kind="Skinning",zone=zone,minLevel=level,minSkill=skill,
        points={{x,y}},mode="open",targets=targets,materials={...}}
end
P.maps["Ashenvale"] = 1440
P.maps["Dustwallow Marsh"] = 1445
skin("Darkshore", 14, 75, 48, 34, "Moonstalkers", "Light Leather")
skin("Wetlands", 22, 115, 33, 49, "Mottled Raptors", "Light Leather", "Medium Leather")
skin("Wetlands", 26, 135, 33.9, 48.3, "Mottled Razormaws", "Heavy Leather")
skin("Duskwood", 27, 145, 72, 74, "Nightbane worgen", "Medium Leather", "Heavy Leather")
skin("Tanaris", 47, 240, 34.3, 66.1, "Rabid Blisterpaws", "Thick Leather")
skin("Winterspring", 55, 285, 66, 42, "Ice Thistle Yetis outside the cave", "Rugged Leather")

-- Session prices are local to the auction house this character scanned.
P.auctionPrices = {}
local function unitPrice(itemID)
    return P.auctionPrices[itemID]
end

-- options is an array of alternatives, each with item IDs and quantities.
function P.CheapestSupplies(options, countOwned)
    local best, bestCost, compared = nil, nil, 0
    for index, option in ipairs(options) do
        local cost = 0
        for itemID, quantity in pairs(option) do
            local count = countOwned(itemID)
            if count == nil then cost = nil; break end
            local need = math.max(0, quantity - count)
            if need > 0 then
                local price = unitPrice(itemID)
                if not price then cost = nil; break end
                cost = cost + need * price
            end
        end
        if cost then compared = compared + 1 end
        if cost and (not bestCost or cost < bestCost) then
            best, bestCost = index, cost
        end
    end
    return best, bestCost, compared
end

function P.InitializeAuction(E)
    local api = C_AuctionHouse
    if not api or not api.ReplicateItems or not api.GetNumReplicateItems
        or not api.GetReplicateItemInfo then return end
    local listener = CreateFrame("Frame")
    local button, pending, job, scanned
    local function reset(message)
        pending, job = nil, nil
        listener:UnregisterEvent("REPLICATE_ITEM_LIST_UPDATE")
        listener:SetScript("OnUpdate", nil)
        if button then button:SetText(message); button:Enable() end
    end
    local function process(_, elapsed)
        if not job then
            pending = pending - elapsed
            if pending <= 0 then reset("Retry GF Scan") end
            return
        end
        for index = job.next, math.min(job.next + 199, job.total - 1) do
            local ok, _, _, quantity, _, _, _, _, _, _, buyout, _, _, _, _, _, _, itemID =
                pcall(api.GetReplicateItemInfo, index)
            if ok and E.Public(itemID) and E.Public(quantity) and E.Public(buyout)
                and type(itemID) == "number" and itemID > 0 and type(quantity) == "number"
                and quantity > 0 and type(buyout) == "number" and buyout > 0 then
                local price = math.ceil(buyout / quantity)
                if not job.prices[itemID] or price < job.prices[itemID] then
                    job.prices[itemID] = price
                end
            end
        end
        job.next = job.next + 200
        if job.next >= job.total then
            if next(job.prices) then
                P.auctionPrices, scanned = job.prices, GetTime()
                reset("Scan GF Prices")
            else
                reset("Retry GF Scan")
            end
        end
    end
    listener:SetScript("OnEvent", function(self, event)
        if event == "AUCTION_HOUSE_SHOW" then
            local parent = AuctionHouseFrame
            if not parent then return end
            if not button then
                button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
                button:SetSize(115, 22)
                button:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", -28, 2)
                button:SetScript("OnClick", function()
                    if pending or job then return end
                    if api.IsThrottledMessageSystemReady
                        and E.Call(api.IsThrottledMessageSystemReady) == false then
                        button:SetText("Try GF Scan Later")
                        return
                    end
                    pending = 30
                    button:Disable()
                    button:SetText("Scanning...")
                    self:RegisterEvent("REPLICATE_ITEM_LIST_UPDATE")
                    self:SetScript("OnUpdate", process)
                    if not pcall(api.ReplicateItems) then reset("Retry GF Scan") end
                end)
                button:SetText("Scan GF Prices")
            end
        elseif event == "AUCTION_HOUSE_CLOSED" then
            reset("Scan GF Prices")
        elseif pending and not job then
            local total = E.Call(api.GetNumReplicateItems)
            if E.Public(total) and type(total) == "number" and total > 0 then
                job = {next=0, total=total, prices={}}
            else
                reset("Retry GF Scan")
            end
        end
    end)
    listener:RegisterEvent("AUCTION_HOUSE_SHOW")
    listener:RegisterEvent("AUCTION_HOUSE_CLOSED")

    local crates = {
        [248682] = {{[2447]=20}, {[765]=20}, {[2449]=10}, {[785]=10}, {[2450]=10}},
        [248683] = {{[2770]=20}, {[2771]=20}},
        [248685] = {{[10940]=20}, {[10939]=4}, {[10978]=6}, {[11084]=2}},
        [248702] = {{[4231]=2}, {[2996]=20}},
        [248703] = {{[2840]=20}, {[3576]=20}, {[2841]=10}},
        [248704] = {{[4359]=16}, {[4361]=16}, {[4363]=4}},
        [248684] = {{[2589]=40}, {[2318]=20}},
        [248688] = {{[2592]=20}, {[4306]=40}, {[2319]=20}},
    }
    local names = {[2589]="Linen Cloth",[2318]="Light Leather",[2592]="Wool Cloth",
        [4306]="Silk Cloth",[2319]="Medium Leather"}
    local writs = {}
    for _, quest in pairs(ns.ForeverQuestData and ns.ForeverQuestData.quests or {}) do
        if type(quest.title) == "string" and quest.title:match("^Craftsman's Writ: ") then
            for _, start in ipairs(quest.starts or {}) do
                if start.kind == "item" then
                    local items = {}
                    for _, objective in ipairs(quest.objectives or {}) do
                        if objective.kind == "item" and objective.target ~= start.id
                            and type(objective.target) == "number" and type(objective.count) == "number"
                            and objective.count > 0 then
                            items[objective.target] = objective.count
                        end
                    end
                    if next(items) then writs[start.id] = items end
                end
            end
        end
    end
    local function owned(itemID)
        local count = E.Call(C_Item and C_Item.GetItemCount or GetItemCount, itemID)
        if E.Public(count) and type(count) == "number" then return count end
    end
    local function costText(cost)
        return GetCoinTextureString and GetCoinTextureString(cost) or (cost .. " copper")
    end
    local function addFulfillment(tooltip, itemID)
        local function line(value)
            tooltip:AddLine(value, .8, .9, 1, true)
        end
        local options = crates[itemID]
        if options then
            local index, cost, compared = P.CheapestSupplies(options, owned)
            if index then
                local id, quantity = next(options[index])
                local label = cost == 0 and "GF fill from bags: "
                    or compared == #options and "GF cheapest scanned fill: " or "GF priced fill: "
                local name = names[id] or E.Call(GetItemInfo, id)
                if not E.Public(name) or type(name) ~= "string" then name = "item " .. id end
                line(label .. quantity .. " " .. name .. (cost > 0 and (" / est. " .. costText(cost)) or ""))
            else
                line("GF: Scan the Auction House to compare missing supplies.")
            end
            return
        end
        if not writs[itemID] then return end
        for product, quantity in pairs(writs[itemID]) do
            local count = owned(product)
            local name = E.Call(GetItemInfo, product)
            if not E.Public(name) or type(name) ~= "string" then name = "item " .. product end
            if not count then
                line("GF: Bag count unavailable for " .. name .. ".")
            elseif count >= quantity then
                line("GF: Bags cover " .. quantity .. " " .. name .. ".")
            else
                local missing = quantity - count
                local price = unitPrice(product)
                local buy = price and price * missing
                local craft, canCraft
                for _, recipe in pairs(E.recipes or {}) do
                    if recipe.productID == product and recipe.fulfillment and E.Known(recipe) then
                        canCraft = true
                        local plan = recipe.fulfillment
                        local materials = {}
                        for material, amount in pairs(plan.reagents) do
                            materials[material] = amount * math.ceil(missing / plan.yield)
                        end
                        local _, cost = P.CheapestSupplies({materials}, owned)
                        if cost and (not craft or cost < craft) then craft = cost end
                    end
                end
                local action, cost
                if craft and (not buy or craft <= buy) then action, cost = "Craft", craft
                elseif buy then action, cost = "Buy", buy end
                if action then
                    local label = (craft and buy or cost == 0) and "GF: " or "GF priced option: "
                    line(label .. action .. " " .. missing .. " " .. name .. " / est. " .. costText(cost))
                    if craft and buy then
                        line("GF alternative: " .. (action == "Craft" and "Buy / " .. costText(buy) or "Craft / " .. costText(craft)))
                    end
                end
                if not canCraft then line("GF: Open the profession window to check your recipe.")
                elseif not craft then line("GF: Reagent prices unavailable.") end
                if not buy then line("GF: No scanned buyout for " .. name .. ".") end
            end
        end
    end
    local function addPrice(tooltip, itemID)
        addFulfillment(tooltip, itemID)
        local price = unitPrice(itemID)
        if price and scanned and GetCoinTextureString then
            tooltip:AddLine(("GF scan low: %s each (%dm ago)"):format(
                GetCoinTextureString(price), math.floor((GetTime() - scanned) / 60)), .8, .9, 1)
        end
    end
    if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum
        and Enum.TooltipDataType and Enum.TooltipDataType.Item then
        TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tooltip, data)
            if tooltip == GameTooltip and data and E.Public(data.id) then addPrice(tooltip, data.id) end
        end)
    elseif GameTooltip and GameTooltip.HookScript then
        pcall(GameTooltip.HookScript, GameTooltip, "OnTooltipSetItem", function(tooltip)
            local _, link = tooltip:GetItem()
            if E.Public(link) and type(link) == "string" then
                addPrice(tooltip, tonumber(link:match("item:(%d+)")))
            end
        end)
    end
end
