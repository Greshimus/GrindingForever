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
 summon=true,cast=true,place=true,survive=true,press=true,take=true,buy=true,grind=true,free=true}
local uncounted = {explore=true,discover=true,enter=true,investigate=true}

local function clean(label)
 if type(label) ~= 'string' then return end
 label = label:gsub('^%s*%d+%s*/%s*%d+%s+', ''):gsub('%s*%(?%d+%s*/%s*%d+%)?%s*$', '')
 label = label:gsub('%s+[x×]%s*%d+%s*$', ''):gsub('^%s+', ''):gsub('%s+$', '')
 if label ~= '' and label ~= 'slain' then return label end
end

local function sourceDetail(fact, supplement, preferred, catalog)
 local ids = fact and fact.target and D.itemSources[fact.target] or nil
 local names, seen = {}, {}
 local function add(name)
  if name and not seen[name] then names[#names+1] = name; seen[name] = true end
 end
 if preferred then add(preferred.sourceName) end
 if #names > 0 then return 'From '..names[1] end
 for _, name in ipairs(catalog and catalog.sourceNames or {}) do add(name) end
 if #names == 0 then for _, source in ipairs(ids or {}) do add(D.names[source.kind..':'..source.id]) end end
 if #names == 0 then for _, name in ipairs(supplement and supplement.sourceNames or {}) do add(name) end end
 if #names == 1 then return 'From '..names[1] end
 if #names == 2 then return 'From '..names[1]..' or '..names[2] end
end

function Steps.Instruction(child, live, preferred)
 local slot = child.slot
 local goal = slot and live and live.objectives and live.objectives[slot]
 local done, have, total, liveText = Steps.Progress(goal)
 local phase = child.procedure
 if phase then
  return {
   label=phase.title, count=phase.count, source=phase.body,
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
 local source = action == 'Collect' and sourceDetail(fact, extra, preferred, catalog) or nil
 if source and source:lower() == ('from '..label):lower() then source = nil end
 return {action=action, label=label, count=count, source=source}
end

local function zoneName(point)
 local info = E.Call(C_Map and C_Map.GetMapInfo, point.mapID)
 return point.zone or (info and E.Public(info.name) and info.name) or 'Nearby objectives'
end

local function candidates(rows, state)
 local result = {}
 local player = state.position
 local world, x, y = E.World(player.mapID, player.x, player.y)
 if not world then return result end
 local function candidate(point, list)
  if not point or point.mapID ~= player.mapID then return end
  local instance, px, py = E.World(point.mapID, point.x, point.y)
  if instance ~= world then return end
  local yards = math.sqrt((px-x)^2 + (py-y)^2)
  if yards <= 650 then list[#list+1] = {point=point,x=px,y=py,yards=yards} end
 end
 for index, row in ipairs(rows) do
  local live = row.quest and state.quests[row.quest]
  if row.kind == 'objective' and not row.materialBoard and live and live.inLog == true then
   for _, child in ipairs(row.objectives or {row}) do
    local supported=(row.quest~=97583 and row.quest~=97485) or child.procedure
    if supported and child.slot and not Steps.Progress(live.objectives and live.objectives[child.slot]) then
     local list = {}
     for _, point in ipairs(child.objectivePoints or {}) do candidate(point, list) end
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
       if (other.x-position.x)^2 + (other.y-position.y)^2 > 150^2 then fits = false; break end
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
     destination.name = zone
     groupedAt[at] = groupedAt[at] or {}
     groupedAt[at][#groupedAt[at]+1] = {id=id, kind='objective', category=first.row.category, title=zone,
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
