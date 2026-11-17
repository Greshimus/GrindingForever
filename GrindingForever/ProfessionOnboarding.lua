local _, ns = ...
local E, P, N = ns.Forever, ns.ProfessionGuide, ns.NormalUI
local B = {}
ns.ProfessionOnboarding = B

local primary = {'Alchemy', 'Blacksmithing', 'Enchanting', 'Engineering', 'Herbalism',
    'Leatherworking', 'Mining', 'Skinning', 'Tailoring'}
local secondary = {'Cooking', 'Fishing', 'First Aid'}
local allowed = {}
for _, name in ipairs(primary) do allowed[name] = true end
local isSecondary = {}
for _, name in ipairs(secondary) do isSecondary[name] = true end

-- On-use gathering manuals from the Forever client and QuestieDB Forever 1.1.2.
local books = {
    {id=247840, name='Mining for Dummies', profession='Mining', pairing='Mining supplies Blacksmithing or Engineering.'},
    {id=247841, name='Wild Harvest', profession='Herbalism', partner='Alchemy', pairing='Herbalism supplies Alchemy.'},
    {id=247846, name='Pelt Collecting for Beginners', profession='Skinning', partner='Leatherworking', pairing='Skinning supplies Leatherworking.'},
}
local bookState, bookSequence, booksRead = {}, 0, false
local quotes, liveQuote = {}, nil
local nearTrainerYards, quoteLifetime = 90, 120

local function number(value)
    return E.Public(value) and type(value) == 'number' and value >= 0 and value < math.huge
end

local function learned(state, name)
    local skill = state.skills and state.skills[name]
    local rank = skill and skill.rank
    return E.Public(rank) and type(rank) == 'number' and rank > 0
end

local function choices(state)
    local known, plan, selected = {}, {}, {}
    for _, name in ipairs(primary) do
        if learned(state, name) then known[#known + 1] = name end
    end
    local available = math.max(0, 2 - #known)
    local saved = E.db and E.db.professionPlan
    for _, name in ipairs(type(saved) == 'table' and saved or {}) do
        if #plan >= available then break end
        if allowed[name] and not selected[name] and not learned(state, name) then
            plan[#plan + 1] = name
            selected[name] = true
        end
    end
    return known, plan, selected, available
end

local function closestTrainer(state, name)
    local position = state.position
    if not position or (state.faction ~= 'Alliance' and state.faction ~= 'Horde') then return end
    local sites = ns.ProfessionOnboardingTrainers or {}
    local candidates = sites[ns.ForeverFacts.professionIDs[name]] or {}
    local best, nearest, bestLocal, bestLocalDistance
    for _, site in ipairs(candidates) do
        if site.faction == state.faction or site.faction == 'Both' then
            local yards = E.Distance(position, site)
            if yards and (not nearest or yards < nearest) then best, nearest = site, yards end
            if site.mapID == position.mapID and not yards then
                local dx, dy = site.x - position.x, site.y - position.y
                local offset = dx * dx + dy * dy
                if not bestLocalDistance or offset < bestLocalDistance then bestLocal, bestLocalDistance = site, offset end
            end
        end
    end
    return best or bestLocal, nearest
end

local function readBooks()
    if not E.db then return end
    booksRead = true
    local countItem = C_Item and C_Item.GetItemCount or GetItemCount
    local dismissed = E.db.professionBooksLater
    for _, book in ipairs(books) do
        local count = E.Call(countItem, book.id, false)
        if number(count) then
            local old = bookState[book.id]
            if count > 0 and (not old or count > old.count) then
                bookSequence = bookSequence + 1
                bookState[book.id] = {count=count, sequence=bookSequence}
                if old and dismissed then dismissed[book.id] = nil end
            elseif old then
                old.count = count
            end
            if count == 0 and dismissed then dismissed[book.id] = nil end
        end
    end
end

local function exactTrainer(name, id, position, faction)
    local sites = ns.ProfessionOnboardingTrainers[ns.ForeverFacts.professionIDs[name]] or {}
    for _, site in ipairs(sites) do
        if site.npcID == id and (site.faction == 'Both' or site.faction == faction) then
            local yards = E.Distance(position, site)
            if yards and yards <= nearTrainerYards then return site end
        end
    end
end

local function readTraining()
    local previous = liveQuote
    liveQuote = nil
    local id = E.NPCID(E.Call(UnitGUID, 'npc'))
    local trainer = E.Call(UnitName, 'npc')
    local index = E.Call(GetTrainerServiceStepIndex)
    if not id or not E.Public(trainer) or type(trainer) ~= 'string' or not number(index) or index < 1 or index%1~=0 then
        if previous then quotes[previous.cacheKey]=nil end
        return
    end
    local profession = E.Call(GetTrainerServiceSkillLine, index)
    if not E.Public(profession) or not (allowed[profession] or isSecondary[profession]) then
        if previous then quotes[previous.cacheKey]=nil end
        return
    end
    local key = id..':'..profession
    local _, status, _, level = E.Call(GetTrainerServiceInfo, index)
    local cost = E.Call(GetTrainerServiceCost, index)
    local prior = quotes[key]
    if not E.Public(status) or status ~= 'available' or not number(cost) or cost%1~=0 then
        quotes[key] = nil
        return
    end
    local now = E.Time()
    liveQuote = {key='trainer:'..key, cacheKey=key, profession=profession, trainer=trainer, cost=cost,
        level=number(level) and level or nil, expires=now+quoteLifetime,
        destination=exactTrainer(profession, id, E.CurrentPosition(), E.Call(UnitFactionGroup, 'player')),
        later=prior and prior.cost == cost and prior.later or nil}
    quotes[key] = liveQuote
end

local function fee(amount)
    if amount == 0 then return 'Free' end
    local values = {}
    local gold, silver, copper = math.floor(amount / 10000), math.floor(amount / 100) % 100, amount % 100
    if gold > 0 then values[#values+1] = gold..'g' end
    if silver > 0 then values[#values+1] = silver..'s' end
    if copper > 0 then values[#values+1] = copper..'c' end
    return table.concat(values, ' ')
end

function B.Opportunity(state, position)
    if not E.db or not state or not state.skills or E.Call(IsInInstance)
        or (ns.DungeonPrep and ns.DungeonPrep.active) or (ns.FarmingPlanner and ns.FarmingPlanner.route) then return end
    if not booksRead then readBooks() end
    local _, plan, selected, available = choices(state)
    local free = available - #plan
    local best, newest
    if available > 0 then
        for _, book in ipairs(books) do
            local held = bookState[book.id]
            local dismissed = E.db.professionBooksLater and E.db.professionBooksLater[book.id]
            if held and held.count > 0 and not dismissed and not learned(state, book.profession)
                and (not newest or held.sequence > newest) then
                best, newest = book, held.sequence
            end
        end
    end
    if best then
        local booked = selected[best.profession]
        local pair = best.partner
        if pair and (learned(state,pair) or selected[pair] or free < (booked and 1 or 2)) then pair = nil end
        return {kind='book', key='book:'..best.id, profession=best.profession, itemID=best.id,
            title=best.profession..' book found',
            body='Use '..best.name..' from your bags when ready. '..best.pairing,
            plan=not booked and free > 0, pair=pair, review=not booked and free == 0}
    end

    position = position or state.position
    local money = state.money
    if not number(money) then return end
    local now, selectedQuote, selectedRange = E.Time()
    for key, quote in pairs(quotes) do
        local here = quote == liveQuote
        local yards = quote.destination and E.Distance(position, quote.destination)
        local near = here or (yards and yards <= nearTrainerYards)
        local name = quote.profession
        if not near then quote.later = nil end
        if now > quote.expires and not here then
            quotes[key] = nil
        elseif near and not quote.later and money >= quote.cost and not learned(state,name)
            and (not quote.level or number(state.level) and state.level >= quote.level)
            and (isSecondary[name] or available > 0 and (selected[name] or free > 0)) then
            local range = here and -1 or yards
            if not selectedRange or range < selectedRange then selectedQuote, selectedRange = quote, range end
        end
    end
    if selectedQuote then
        local quote = selectedQuote
        return {kind='trainer', key=quote.key, profession=quote.profession, cost=quote.cost, trainer=quote.trainer,
            destination=quote.destination, quote=quote, plan=allowed[quote.profession] and not selected[quote.profession],
            title='Learn '..quote.profession,
            body=quote.trainer..' offers Apprentice '..quote.profession..' · '..fee(quote.cost)..'.'}
    end
end

local function showPlan(state)
    local known, plan, selected, available = choices(state)
    local picks = #plan > 0 and table.concat(plan, ', ') or 'None yet'
    B.panel.summary:SetText('Learned: '..(#known > 0 and table.concat(known, ', ') or 'None')..'\n'
        ..'Planned: '..picks..'  ('..#plan..'/'..available..' available slots)')
    for _, name in ipairs(primary) do
        local button = B.primaryButtons[name]
        local hasLearned = learned(state, name)
        local enabled = not hasLearned and (selected[name] or #plan < available)
        button.label:SetText(name..(hasLearned and '  · Learned' or selected[name] and '  · Chosen' or ''))
        button:SetEnabled(enabled)
        button:SetAlpha(enabled and 1 or hasLearned and .8 or .55)
    end
end

local function toggleChoice(name)
    if not E.db then return end
    local state = E.Snapshot()
    local _, plan, selected, available = choices(state)
    if learned(state, name) then return end
    if selected[name] then
        for index, current in ipairs(plan) do
            if current == name then table.remove(plan, index); break end
        end
    elseif #plan < available then
        plan[#plan + 1] = name
    else
        return
    end
    E.db.professionPlan = plan
    showPlan(state)
    N.Refresh(true)
end

local function makePanel()
    local panel = CreateFrame('Frame', nil, UIParent)
    panel:SetSize(478, 310)
    panel:SetPoint('CENTER')
    panel:SetClampedToScreen(true)
    panel:EnableMouse(true)
    panel:SetFrameStrata('DIALOG')
    panel:SetToplevel(true)
    N.BronzeRectangle(panel)
    local background = panel:CreateTexture(nil, 'BACKGROUND')
    background:SetAllPoints()
    background:SetColorTexture(.11, .066, .035, .98)

    local function caption(size, value, y)
        local label = N.MakeText(panel, size, value, false)
        label:SetPoint('TOPLEFT', 16, -y)
        label:SetPoint('TOPRIGHT', -16, -y)
        label:SetTextColor(1, .89, .68)
        label:SetJustifyH('LEFT')
        return label
    end
    caption(20, 'Primary professions', 13)
    panel.summary = caption(14, '', 45)
    B.primaryButtons = {}
    for index, profession in ipairs(primary) do
        local name = profession
        local button = N.WoodButton(panel, name, 142, function() toggleChoice(name) end)
        button:SetSize(142, 34)
        button:SetPoint('TOPLEFT', 16 + ((index - 1) % 3) * 152, -92 - math.floor((index - 1) / 3) * 38)
        button.label:SetFont('Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf', 13, '')
        B.primaryButtons[name] = button
    end
    local pairs = caption(13, 'Common pairs: Herbalism + Alchemy, Mining + Blacksmithing or Engineering, Skinning + Leatherworking, Tailoring + Enchanting.', 211)
    pairs:SetWordWrap(true)
    local close = N.WoodButton(panel, 'Close', 94, function() panel:Hide() end)
    close:SetSize(94, 30)
    close:SetPoint('BOTTOM', 66, 14)
    local trainers = N.WoodButton(panel, 'Find trainers', 120, function() B.FindTrainers() end)
    trainers:SetSize(120, 30)
    trainers:SetPoint('BOTTOM', -55, 14)
    return panel
end

function B.Open()
    if not E.db then return end
    if B.trainers then B.trainers:Hide() end
    if not B.panel then B.panel = makePanel() end
    showPlan(E.Snapshot())
    B.panel:Show()
    B.panel:Raise()
end

local function pin(location)
    local map = ns.MapControls99
    if location and map then map.ShowStepPoint(location) end
end

function B.FindTrainers()
    if not B.trainers then
        local panel = CreateFrame('Frame', nil, UIParent)
        panel:SetSize(478, 310)
        panel:SetPoint('CENTER')
        panel:SetClampedToScreen(true)
        panel:SetFrameStrata('DIALOG')
        panel:EnableMouse(true)
        N.BronzeRectangle(panel)
        local backdrop = panel:CreateTexture(nil, 'BACKGROUND')
        backdrop:SetAllPoints()
        backdrop:SetColorTexture(.11, .066, .035, .98)
        local title = N.MakeText(panel,20,'Profession trainers',false)
        title:SetPoint('TOPLEFT',16,-14)
        title:SetTextColor(1,.89,.68)
        panel.rows={}
        for index=1,5 do
            local label = N.MakeText(panel,14,'',false)
            label:SetPoint('TOPLEFT',16,-48-(index-1)*41)
            label:SetWidth(340)
            label:SetJustifyH('LEFT')
            label:SetTextColor(1,.89,.68)
            local button = N.WoodButton(panel,'Pin',75,function(self) pin(self.trainer) end)
            button:SetSize(75,28)
            button:SetPoint('TOPRIGHT',-16,-47-(index-1)*41)
            panel.rows[index]={label=label,button=button}
        end
        local back=N.WoodButton(panel,'Back',94,B.Open)
        back:SetSize(94,30)
        back:SetPoint('BOTTOM',0,14)
        B.trainers=panel
    end
    local state = E.Snapshot()
    local _, names = choices(state)
    for _, name in ipairs(secondary) do if not learned(state,name) then names[#names+1]=name end end
    for index,row in ipairs(B.trainers.rows) do
        local name = names[index]
        local site = name and closestTrainer(state,name)
        row.label:SetText(name and (name..'\n'..(site and (site.name..' · '..site.zone) or 'Ask a city guard for directions.'))
            or index==1 and 'No professions are waiting for training.' or '')
        row.button.trainer=site
        row.button:SetShown(site~=nil)
    end
    B.panel:Hide()
    B.trainers:Show()
end

local function dismiss(offer)
    if offer.kind == 'book' then
        E.db.professionBooksLater=E.db.professionBooksLater or {}
        E.db.professionBooksLater[offer.itemID]=true
    elseif offer.quote then
        offer.quote.later=true
    end
    N.Refresh(true)
end

local function planOpportunity(offer, includePair)
    local state=E.Snapshot()
    local _, plan, selected, available=choices(state)
    for _, name in ipairs({offer.profession,includePair and offer.pair or nil}) do
        if not selected[name] and not learned(state,name) then
            if #plan>=available then return end
            plan[#plan+1]=name
        end
    end
    E.db.professionPlan=plan
    dismiss(offer)
end

local function place(widget, parent, x, y, width, height)
    widget:ClearAllPoints()
    widget:SetPoint('TOPLEFT',parent,'TOPLEFT',x,-y)
    widget:SetSize(width,height)
end

local function newCard(panel)
    local card=CreateFrame('Frame',nil,panel)
    card.header=N.WoodButton(card,'',230,function()
        card.collapsed=not card.collapsed
        N.Refresh(true)
    end)
    card.header.label:ClearAllPoints()
    card.header.label:SetPoint('LEFT',card.header,'LEFT',9,0)
    card.header.label:SetPoint('RIGHT',card.header,'RIGHT',-22,0)
    card.header.label:SetJustifyH('LEFT')
    card.header.label:SetWordWrap(true)
    card.arrow=N.ButtonArrow(card.header,'right','RIGHT')
    local detail=CreateFrame('Frame',nil,card)
    card.detail=detail
    N.BronzeRectangle(detail,1)
    local cream=detail:CreateTexture(nil,'BACKGROUND')
    cream:SetAllPoints()
    cream:SetColorTexture(.98,.90,.73,.88)
    card.body=N.MakeText(detail,14,'',false)
    card.body:SetTextColor(.19,.105,.045)
    card.body:SetJustifyH('LEFT')
    card.body:SetWordWrap(true)
    card.action=N.WoodButton(detail,'',100,function()
        local offer=card.offer
        if offer.plan then planOpportunity(offer,false)
        elseif offer.review then B.Open()
        else pin(offer.destination) end
    end)
    card.pair=N.WoodButton(detail,'Plan pair',84,function() planOpportunity(card.offer,true) end)
    card.later=N.WoodButton(detail,'Later',56,function() dismiss(card.offer) end)
    return card
end

function B.LayoutOpportunity(root,panel,y,width,hidden)
    local state=P.character or E.state
    if state and B.panel and B.panel:IsShown() then showPlan(state) end
    local offer=not hidden and B.Opportunity(state,E.CurrentPosition())
    local card=root.professionOpportunity
    if not offer then
        if card then card.offer=nil;card:Hide() end
        return y
    end
    if not card then card=newCard(panel);root.professionOpportunity=card end
    if not card.offer or card.offer.key~=offer.key then card.collapsed=false end
    card.offer=offer
    card.header.label:SetText(offer.title)
    card.header.label:SetWidth(width-31)
    local headerHeight=math.max(29,card.header.label:GetStringHeight()+10)
    place(card.header,card,0,0,width,headerHeight)
    card.arrow:SetRotation(card.collapsed and 0 or -math.pi/2)
    card.detail:SetShown(not card.collapsed)
    local height=headerHeight
    if not card.collapsed then
        local label=card.body
        label:ClearAllPoints()
        label:SetPoint('TOPLEFT',card.detail,'TOPLEFT',9,-7)
        label:SetWidth(width-18)
        label:SetText(offer.body)
        label:SetHeight(0)
        local buttonsY=label:GetStringHeight()+13
        local action=offer.plan and 'Plan it' or offer.review and 'Review plan' or offer.destination and 'Pin trainer'
        local actionWidth=offer.pair and 73 or 104
        card.action:SetShown(action~=nil)
        card.pair:SetShown(offer.pair~=nil)
        if action then card.action.label:SetText(action);place(card.action,card.detail,9,buttonsY,actionWidth,25)end
        if offer.pair then place(card.pair,card.detail,action and actionWidth+15 or 9,buttonsY,80,25)end
        place(card.later,card.detail,width-65,buttonsY,56,25)
        local detailHeight=buttonsY+33
        place(card.detail,card,0,headerHeight+2,width,detailHeight)
        height=height+detailHeight+2
    end
    place(card,panel,28,y,width,height)
    card:Show()
    return y+height+6
end

local trainerOpen=false
local watch=CreateFrame('Frame')
watch:SetScript('OnEvent',function(_,event)
    if event=='TRAINER_SHOW' then trainerOpen=true;readTraining()
    elseif event=='TRAINER_UPDATE' and trainerOpen then readTraining()
    elseif event=='TRAINER_CLOSED' then trainerOpen=false;liveQuote=nil
    elseif event=='PLAYER_ENTERING_WORLD' then trainerOpen=false;liveQuote=nil;quotes={};readBooks()
    elseif event=='UPDATE_FACTION' then quotes={};liveQuote=nil;if trainerOpen then readTraining()end
    elseif event=='BAG_UPDATE_DELAYED' then readBooks() end
    P.dirty=true
end)
for _,event in ipairs({'TRAINER_SHOW','TRAINER_UPDATE','TRAINER_CLOSED','PLAYER_MONEY','UPDATE_FACTION',
    'BAG_UPDATE_DELAYED','PLAYER_ENTERING_WORLD','SKILL_LINES_CHANGED'}) do watch:RegisterEvent(event) end

local checkedAt=0
local tick=N.Tick
function N.Tick(...)
    local result=tick(...)
    local now=E.Time()
    local card=N.root and N.root.professionOpportunity
    if next(quotes) and N.root and N.root.panels[1]:IsShown() and N.frame:IsShown() and now>=checkedAt then
        checkedAt=now+1
        local offer=B.Opportunity(P.character or E.state,E.CurrentPosition())
        local previous=card and card.offer
        if (offer and offer.key)~=(previous and previous.key) then N.Refresh(true) end
    end
    return result
end
