local _, ns = ...
local E, P, N = ns.Forever, ns.ProfessionGuide, ns.NormalUI
local D = ns.ForeverQuestData
local evidence = ns.StepObjectiveEvidence or {}
local guidance = ns.QuestProcedureGuidance or {}
local Steps = {}
ns.GroupedQuestSteps = Steps

local function copy(row)
 local out = {}
 for key, value in pairs(row) do out[key] = value end
 return out
end

local function addMobs(out, seen, row)
 for _, id in ipairs(row.mobIDs or {}) do
  if not seen[id] then out[#out+1] = id; seen[id] = true end
 end
end

function Steps.Fact(quest, slot)
 local bundled, supplement
 for _, row in ipairs(D.quests[quest] and D.quests[quest].objectives or {}) do
  if row.n == slot then bundled = row; break end
 end
 for _, row in ipairs(evidence[quest] and evidence[quest].objectives or {}) do
  if row.slot == slot then supplement = row; break end
 end
 return bundled, supplement
end

function Steps.Progress(goal)
 if type(goal) ~= 'table' then return end
 local done = E.Public(goal.finished) and (goal.finished == true or goal.finished == 1)
 local have = E.Public(goal.numFulfilled) and tonumber(goal.numFulfilled) or nil
 local total = E.Public(goal.numRequired) and tonumber(goal.numRequired) or nil
 if total and total <= 0 then total = nil end
 if have and have < 0 then have = nil end
 local label = E.Public(goal.text) and type(goal.text) == 'string' and goal.text or nil
 if label then
  local a, b = label:match('^%s*(%d+)%s*/%s*(%d+)%s+')
  if not a then a, b = label:match('%s*%(?(%d+)%s*/%s*(%d+)%)?%s*$') end
  have, total = have or tonumber(a), total or tonumber(b)
 end
 return done or (total and total > 0 and have and have >= total), have, total, label
end

local verbs = {kill='Kill', item='Collect', object='Interact with', talk='Speak to'}
local liveVerbs = {kill='Kill', monster='Kill', item='Collect', object='Interact with', talk='Speak to'}
local explicitVerbs = {use=true,loot=true,speak=true,talk=true,deliver=true,['return']=true,bring=true,
 enter=true,explore=true,investigate=true,discover=true,find=true,open=true,inspect=true,click=true,read=true,
 summon=true,cast=true,place=true,survive=true,press=true,take=true,buy=true,grind=true,free=true,
 craft=true,gather=true,fish=true,mine=true,skin=true,cook=true,smelt=true,make=true}
local uncounted = {explore=true,discover=true,enter=true,investigate=true}

local function clean(label)
 if type(label) ~= 'string' then return end
 label = label:gsub('^%s*%d+%s*/%s*%d+%s+', ''):gsub('%s*%(?%d+%s*/%s*%d+%)?%s*$', '')
 label = label:gsub('%s+[x×]%s*%d+%s*$', ''):gsub('^%s+', ''):gsub('[:%s]+$', '')
 if label ~= '' and label ~= 'slain' then return label end
end

local function bagCount(id)
 local value = E.Call(C_Item and C_Item.GetItemCount or GetItemCount, id, false)
 if E.Public(value) and type(value) == 'number' and value >= 0 then return value end
end

-- Quest objectives locate these specific source entities within named Forever
-- areas. The bundled coordinates elsewhere remain scoped only to their maps.
local coven = {id=365, name='Burning Blade Coven'}
local mine = {id=360, name='The Venture Co. Mine'}
local objectSites = {
 [1411]={[178087]=coven},
 [1412]={[673494]=mine,[673496]=mine,[673497]=mine},
 [1426]={[672508]={id=136,name='The Grizzled Den'}},
 [1429]={[694772]={id=18,name='Crystal Lake'}},
}
local triggerSites = {
 [62]={id=57,name='Fargodeep Mine',mapID=1429,x=40.56,y=82.26},
 [76]={id=54,name='Jasperlode Mine',mapID=1429,x=61.93,y=53.16},
 [287]={id=135,name='Frostmane Hold',mapID=1426,x=21.2,y=54},
 [590]={id=154,name='Deathknell',mapID=1420,x=38.19,y=56.74},
 [99053]={id=262,name="Ban'ethil Barrow Den",mapID=1438,x=43.08,y=51.65},
}
local function pointArea(point, quest)
 if not point then return end
 local area = point.subzone or point.district or point.areaName
 if E.Public(area) and type(area) == 'string' and area:match('%S') then return area end
 local objects = objectSites[point.mapID]
 local site = objects and objects[point.objectID]
 local trigger = triggerSites[quest]
 if not site and trigger and point.mapID == trigger.mapID and point.x == trigger.x and point.y == trigger.y then
  site = trigger
 end
 local npc = point.npcID
 -- The scoped Felstalker and Yarrog spawn points are at the Coven.
 if not site and point.mapID == 1411 and (npc == 3102 or npc == 3183)
  and type(point.x) == 'number' and type(point.y) == 'number'
  and point.x >= 42.4 and point.x <= 45.6 and point.y >= 52 and point.y <= 55.8 then
  site = coven
 end
 if site then
  local label = E.Call(C_Map and C_Map.GetAreaInfo, site.id)
  return E.Public(label) and type(label) == 'string' and label:match('%S') and label or site.name
 end
end

local function itemSources(id, preferred, catalog, supplement)
 local selected = preferred and preferred.sourceName
 local names, kinds, seen = {}, {}, {}
 local factRows = D.itemSources[id] or {}
 for _, row in ipairs(factRows) do
  local name = D.names[row.kind..':'..row.id]
  if name then kinds[name] = row.kind end
 end
 if selected then return {selected}, kinds[selected] end
 local function add(name)
  if name and not seen[name] and #names < 2 then names[#names+1] = name; seen[name] = true end
 end
 for _, name in ipairs(catalog and catalog.sourceNames or {}) do add(name) end
 for _, name in ipairs(supplement and supplement.sourceNames or {}) do add(name) end
 if #names == 0 then
  for _, row in ipairs(factRows) do add(D.names[row.kind..':'..row.id]) end
 end
 local kind = kinds[names[1]]
 if names[2] and kinds[names[2]] ~= kind then kind = nil end
 return names, kind
end

local gatherActions = {
 Mining={action='Mine', source='Gather from ore veins.', prerequisite='Requires Mining and a mining tool.'},
 Herbalism={action='Gather', source='Pick these herbs from herb nodes.', prerequisite='Requires Herbalism.'},
 Fishing={action='Fish for', prerequisite='Requires Fishing.'},
 Skinning={action='Gather', source='Skin eligible beasts.', prerequisite='Requires Skinning and a skinning tool.'},
}
local function gatherDetail(id, names, kind)
 local material = ns.MaterialRoutes and ns.MaterialRoutes.byID[id]
 local gather = material and gatherActions[material.kind]
 if not gather then return end
 if material.kind == 'Fishing' then
  return gather.action, 'Fish at '..material.name..'.', gather.prerequisite
 end
 if kind == 'object' and (material.kind == 'Mining' or material.kind == 'Herbalism') then
  return gather.action, 'From '..table.concat(names, ' or ')..'.', gather.prerequisite
 end
 return gather.action, gather.source, gather.prerequisite
end

local function craftDetail(id, remaining)
 local runtime = ns.QuestGathering and ns.QuestGathering.Runtime
 local books = runtime and runtime.books or {}
 local saved = E.db and E.db.craftingBooks or {}
 local r, fulfillment, learned, rank
 local function consider(recipe, observed, known)
  if not recipe.name or recipe.catalogOnly then return end
  local exact = observed and type(observed.yield) == 'number' and observed.yield >= 1 and observed.yield % 1 == 0
   and type(observed.reagents) == 'table' and next(observed.reagents)
  local score = known == true and (exact and 3 or 2) or 1
  if not rank or score > rank or score == rank and recipe.spellID < r.spellID then
   r, fulfillment, learned, rank = recipe, exact and observed or nil, known, score
  end
 end
 for _, recipe in pairs(E.recipes or {}) do
  if recipe.productID == id and recipe.spellID then consider(recipe, recipe.fulfillment, E.Known(recipe)) end
 end
 local skills = E.state and E.state.skills or {}
 for profession in pairs(skills) do
  local book = books[profession] or saved[profession]
  for _, row in ipairs(book and book.rows or {}) do
   if row.product == id and row.known and row.id and row.name then
    local recipe = E.recipes and E.recipes[row.id]
    if not recipe or recipe.catalogOnly then recipe = {spellID=row.id, name=row.name, profession=profession} end
    if E.Known(recipe) ~= false then consider(recipe, {yield=row.output,reagents=row.reagents}, true) end
   end
  end
 end
 if not r then return end
 local description = (r.profession and r.profession..': ' or '')..r.name
 local prerequisite = type(r.requiredSkill) == 'number' and r.requiredSkill > 0 and r.profession
  and ('Requires '..r.profession..' '..r.requiredSkill..'.') or nil
 if learned ~= true then
  if learned == false then prerequisite = (prerequisite and prerequisite..' ' or '')..'Learn the recipe first.' end
  return nil, 'Crafting option: '..description..'.', prerequisite
 end
 local action = r.profession == 'Mining' and 'Smelt' or r.profession == 'Cooking' and 'Cook' or 'Craft'
 if not fulfillment or not remaining then
  return action, 'Use '..description..' in your profession book.', prerequisite
 end
 local crafts = math.ceil(remaining / fulfillment.yield)
 local materials = {}
 for item, quantity in pairs(fulfillment.reagents) do
  if type(quantity) ~= 'number' or quantity < 1 or quantity % 1 ~= 0 then
   return action, 'Use '..description..' in your profession book.', prerequisite
  end
  local have, need = bagCount(item), quantity * crafts
  local name = E.ItemLabel(item) or D.names['item:'..item] or 'Item '..item
  local label = ('%d %s%s'):format(need, name, have and (' (%d in bags)'):format(have) or '')
  materials[#materials+1] = {text=label,itemID=item}
 end
 table.sort(materials, function(a,b) return a.text < b.text end)
 -- The live book may report a minimum yield for variable-output recipes.
 return action, ('%s · Up to %d %s.'):format(description, crafts, crafts == 1 and 'craft' or 'crafts'),
  prerequisite, materials
end

local function itemAcquisition(target, preferred, catalog, supplement, name, remaining)
 local names, kind = itemSources(target, preferred, catalog, supplement)
 local action, detail, prerequisite = gatherDetail(target, names, kind)
 if action then return action, detail, prerequisite end
 local vendor = E.activeRecipeMerchant
 local sale = vendor and vendor.items[target]
 if sale and type(sale.stock) == 'number' and (sale.stock == -1 or sale.stock > 0)
  and sale.price and sale.price > 0 and not sale.hasExtendedCost then
  local source = E.vendors[vendor.npcID]
  local vendorName = source and source.name or D.names['npc:'..vendor.npcID]
  if vendorName then return 'Buy', 'From '..vendorName..'.' end
 end
 local site = pointArea(preferred)
 local suffix = site and ' at '..site..'.' or '.'
 if #names == 1 and names[1] == name and kind == 'object' and site then
  return 'Collect', 'Pick it up at '..site..'.'
 end
 if #names > 0 and not (#names == 1 and names[1] == name) then
  local source = table.concat(names, ' or ')
  if kind == 'npc' then return 'Loot', 'From '..source..suffix end
  if kind == 'object' then return 'Collect', 'Interact with '..source..suffix end
  return 'Collect', 'From '..source..suffix
 end
 return craftDetail(target, remaining)
end

local itemVerbs = {collect=true, gather=true, loot=true, craft=true, smelt=true, buy=true, cook=true, bring=true, get=true}
local function describesItem(text, name)
 if not text then return true end
 if not name then return false end
 local phrase = clean(text)
 if not phrase then return false end
 phrase, name = phrase:lower(), name:lower()
 local verb, rest = phrase:match('^(%a+)%s+(.+)$')
 if itemVerbs[verb] then
  phrase = rest:gsub('^%d+%s+', ''):gsub('^the%s+', ''):gsub('^an?%s+', '')
  phrase = phrase:gsub('%s+from%s+.+$', ''):gsub('%s+to%s+.+$', '')
 end
 phrase = phrase:gsub('%s+collected$', ''):gsub('%s+gathered$', ''):gsub('%s+looted$', ''):gsub('%s+crafted$', '')
 return phrase == name or phrase == name..'s' or phrase == name:gsub('(%S+) of ', '%1s of ', 1)
  or phrase == name:gsub('hoof$', 'hooves')
end

function Steps.Instruction(child, live, preferred)
 local slot = child.slot
 local goal = slot and live and live.objectives and live.objectives[slot]
 local done, have, total, liveText = Steps.Progress(goal)
 local phase = child.procedure
 if phase then
  return {
   label=phase.title, count=phase.count, source=phase.body, itemID=phase.itemID,
   phaseNumber=phase.phaseNumber, phaseCount=phase.phaseCount,
   nextAction=phase.upcoming and phase.upcoming[1],
   mapPoint=phase.destination,
   confirm=phase.canAcknowledge and {quest=child.quest, slot=slot, id=phase.id} or nil,
  }
 end
 if done then return end
 local fact, extra = Steps.Fact(child.quest, slot)
 local catalog = child.objectiveEvidence
 local captured = guidance[child.quest] and guidance[child.quest].objective
 captured = captured and captured[slot]
 local kind = catalog and catalog.kind or fact and fact.kind or extra and extra.kind
 local liveType = goal and E.Public(goal.type) and goal.type
 local action = liveVerbs[liveType] or verbs[kind]
 local explicit = clean(liveText) or clean(catalog and catalog.text) or clean(captured and captured.text) or clean(extra and extra.text)
 local nameKind = (kind == 'kill' or kind == 'talk') and 'npc' or kind
 local name = catalog and catalog.name or fact and fact.target and nameKind and D.names[nameKind..':'..fact.target]
 name = name or extra and extra.name
 local label = explicit
 local instruction = explicit and explicit:lower():match('^(%a+)')
 if explicitVerbs[instruction] then
  action = nil
 elseif action == 'Kill' then
  label = explicit and explicit:gsub('^[Kk]ill%s+', ''):gsub('%s+[Ss]lain$', '') or name
 elseif action == 'Collect' then
  label = explicit and explicit:gsub('^[Cc]ollect%s+', '') or name
 elseif action == 'Interact with' or action == 'Speak to' then
  label = name or explicit and explicit:gsub('^'..action..'%s+', '')
 end
 if not label then
  local text = guidance[child.quest] and guidance[child.quest].text
  text = text or evidence[child.quest] and evidence[child.quest].text
  text = text or ns.DungeonObjectiveText and ns.DungeonObjectiveText[child.quest]
  label = clean(text) or 'Check the quest log for this objective.'
  action = nil
 end
 local factCount = fact and tonumber(fact.count)
 if liveType ~= 'event' and not uncounted[instruction] then
  total = total or factCount and factCount > 0 and factCount or extra and tonumber(extra.required)
 end
 local count
 if total and total > 0 then count = have and string.format('%d/%d', have, total) or string.format('Need %d', total) end
 local source, prerequisite, materials, itemID
 if kind == 'item' and (not liveType or liveType == 'item') then
  local target = catalog and catalog.target or fact and fact.target or extra and extra.target
  if target and describesItem(liveText, name or E.ItemLabel(target)) then
   itemID = target
   local held = have or bagCount(target)
   local remaining = total and held and math.max(0, total - held)
   if remaining ~= 0 then
    local acquire
    acquire, source, prerequisite, materials = itemAcquisition(target, preferred, catalog, extra, name, remaining)
    if acquire and (action == 'Collect' or not liveText and not explicit) then action, label = acquire, name or label end
   end
  end
 end
 return {action=action, label=label, count=count, source=source, prerequisite=prerequisite, materials=materials, itemID=itemID}
end

local function zoneName(point)
 local info = E.Call(C_Map and C_Map.GetMapInfo, point.mapID)
 return point.zone or (info and E.Public(info.name) and info.name) or 'Nearby objectives'
end

local function differentArea(area, zone)
 return E.Public(area) and type(area) == 'string' and area:match('%S') and area:lower() ~= zone:lower()
end

local function groupHeading(selected, zone)
 local first = selected[1].position.point
 for _, member in ipairs(selected) do
  local area = member.position.area
  if differentArea(area, zone) then return area, area end
 end
 local landmark = first.name
 if differentArea(landmark, zone) and landmark ~= 'Quest objective' and landmark ~= 'Quest source' then
  return 'Near '..landmark
 end
 return ('%s (%.1f, %.1f)'):format(zone, first.x, first.y)
end

local function candidates(rows, state)
 local result = {}
 local player = state.position
 local world, x, y = E.World(player.mapID, player.x, player.y)
 if not world then return result end
 local function candidate(point, list, quest)
  if not point or point.mapID ~= player.mapID then return end
  local instance, px, py = E.World(point.mapID, point.x, point.y)
  if instance ~= world then return end
  local yards = math.sqrt((px-x)^2 + (py-y)^2)
  if yards <= 650 then
   local area = pointArea(point, quest)
   if not differentArea(area, point.zone or '') then area = nil end
   list[#list+1] = {point=point,x=px,y=py,yards=yards,area=area}
  end
 end
 for index, row in ipairs(rows) do
  local live = row.quest and state.quests[row.quest]
  if row.kind == 'objective' and not row._questRisk and not row.overworldTravel and not row.materialBoard and live and live.inLog == true then
   for _, child in ipairs(row.objectives or {row}) do
    local supported=(row.quest~=97583 and row.quest~=97485) or child.procedure
    if supported and child.slot and not Steps.Progress(live.objectives and live.objectives[child.slot]) then
     local list = {}
     for _, point in ipairs(child.objectivePoints or {}) do candidate(point, list, child.quest) end
     if #list > 0 then
      table.sort(list, function(a,b) return a.yards < b.yards end)
      result[#result+1] = {row=row, child=child, index=index, points=list}
     end
    end
   end
  end
 end
 table.sort(result, function(a,b)
  return a.points[1].yards == b.points[1].yards and a.child.id < b.child.id or a.points[1].yards < b.points[1].yards
 end)
 return result
end

function Steps.Group(rows, state)
 if not state or not state.position or not state.quests then return rows end
 local pool = candidates(rows, state)
 local groupedAt, members, used = {}, {}, {}
 for _, first in ipairs(pool) do
  if not used[first.child.id] then
   local selected, quests = {{candidate=first, position=first.points[1]}}, {[first.child.quest]=true}
   local questCount = 1
   for _, candidate in ipairs(pool) do
    if candidate ~= first and not used[candidate.child.id] then
     for _, position in ipairs(candidate.points) do
      local fits = true
      for _, prior in ipairs(selected) do
       local other = prior.position
       if (other.x-position.x)^2 + (other.y-position.y)^2 > 150^2
        or other.area and position.area and other.area:lower() ~= position.area:lower() then fits = false; break end
      end
      if fits then
       selected[#selected+1] = {candidate=candidate, position=position}
       local quest = candidate.child.quest
       if not quests[quest] then quests[quest]=true; questCount=questCount+1 end
       break
      end
     end
    end
   end
   if questCount > 1 then
    local at, keys, groups, attached, mobSet, mobs = first.index, {}, {}, {}, {}, {}
    for _, match in ipairs(selected) do
     local entry, point = match.candidate, match.position.point
     local child, row = entry.child, entry.row
     used[child.id] = true
     members[row.id] = members[row.id] or {}
     members[row.id][child.id] = true
     keys[#keys+1] = child.quest..':'..child.slot
     at = math.min(at, entry.index)
     local group = attached[child.quest]
     if not group then
      group = {quest=child.quest, questTitle=row.title, children={}}
      attached[child.quest] = group
      groups[#groups+1] = group
     end
     group.children[#group.children+1] = {row=child, point=point}
     addMobs(mobs, mobSet, child)
    end
    table.sort(keys)
    local id = 'nearby:'..table.concat(keys, ',')
    if not (E.db and E.db.deferred and (E.db.deferred[id] or 0) > E.Time()) then
     local destination = copy(first.points[1].point)
     local zone = zoneName(destination)
     local heading, subzone = groupHeading(selected, zone)
     destination.name = heading
     if subzone then destination.subzone = subzone end
     groupedAt[at] = groupedAt[at] or {}
     groupedAt[at][#groupedAt[at]+1] = {id=id, kind='objective', category=first.row.category, title=heading,
      context=questCount..' quests · '..#selected..' objectives', groupObjectives=groups, areaTask=true,
      destination=destination, zone=zone, mobIDs=mobs, areaDistance=first.points[1].yards,
      resourceCounters=rows[at].resourceCounters, craftingSections=rows[at].craftingSections}
    end
   end
  end
 end
 if not next(members) then return rows end
 local result = {}
 for i,row in ipairs(rows) do
  for _, group in ipairs(groupedAt[i] or {}) do result[#result+1] = group end
  if not members[row.id] then
   result[#result+1] = row
  else
   local remaining, mobs, mobSet = {}, {}, {}
   local best, yards
   for _, child in ipairs(row.objectives or {row}) do
    if not members[row.id][child.id] then
     remaining[#remaining+1] = child
     addMobs(mobs, mobSet, child)
     local distance = E.Distance(state.position, child.destination)
     if not best or distance and (not yards or distance < yards) then best, yards = child, distance end
    end
   end
   if best then
    local remainder = copy(row)
    remainder.objectives, remainder.destination = remaining, best.destination
    remainder.questDestination = best.destination
    remainder.mobIDs, remainder.nearestDistance = mobs, yards
    remainder.zone = best.destination and best.destination.zone
    result[#result+1] = remainder
   end
  end
 end
 return result
end

function Steps.Details(step)
 local groups = {}
 for _, part in ipairs(step.groupObjectives or {{quest=step.quest,questTitle=step.title,children=step.objectives}}) do
  local live = E.QuestState(part.quest)
  local entries = {}
  for _, child in ipairs(part.children or {}) do
   local entry = Steps.Instruction(child.row or child, live, child.point or child.destination)
   if entry then entries[#entries+1] = entry end
  end
  if #entries > 0 then
   local directions
   local fact=guidance[part.quest]
   local hasProcedure=false
   for _,entry in ipairs(entries)do if entry.phaseNumber then hasProcedure=true;break end end
   if not hasProcedure and fact and fact.complex then
    directions = clean(fact.text)
    if #entries==1 and directions==entries[1].label then directions=nil end
   end
   groups[#groups+1] = {questTitle=part.questTitle,entries=entries,directions=directions}
  end
 end
 return groups
end

local refresh = P.Refresh
function P.Refresh(...)
 local rows = refresh(...)
 if ns.DungeonPrep and ns.DungeonPrep.active or ns.FarmingPlanner and ns.FarmingPlanner.route then return rows end
 P.steps = Steps.Group(rows, E.state)
 P.firstPending = P.steps[1] and P.steps[1].id
 return P.steps
end

local display = N.WorkflowLive
function N.WorkflowLive(step)
 if step.materialBoard then
  local row=copy(step)
  local completed=0
  for _,material in ipairs(row.materialBoard.materials)do
   if material.complete then completed=completed+1 end
  end
  row.actionHeadline=row.title
  row.actionContext=('Materials %d/%d'):format(completed,#row.materialBoard.materials)
  row.body,row.craftingBody='',''
  return row
 end
 if step.kind ~= 'objective' or not step.procedure and (step.quest == 97583 or step.quest == 97485) or not step.groupObjectives and not step.objectives then
  return display(step)
 end
 local row = copy(step)
 row.objectiveDetails = Steps.Details(step)
 row.actionHeadline = row.title
 row.actionContext = row.context
 row.body, row.craftingBody = '', ''
 return row
end
