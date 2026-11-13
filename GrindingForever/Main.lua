-- Grinding Forever: Forever tester build 37.
local ADDON,GF=...
-- GF_MODULE_BEGIN Engine
;(function(...)
-- Forever-only planning and observation boundary. No protected gameplay actions.
local _,ns=...
local E={version=1,recipes={},trainers={},vendors={},camps={},dungeons={},collections={},route={},flights={},events={},known={},reagents={},itemQuests={},mobDrops={},gatherables={},crafted={},farmFlags={},issues={}}
ns.Forever=E;ns.Retail={ready=false,storageWritable=false};ns.UI={Showcase={}};ns.Map={};ns.Guide={};ns.guides={};ns.routes={};ns.functions={};ns.DB={};ns.Native={gameplayEnabled=false}
ns.name='GrindingForever';ns.version='forever-5';ns.game='FOREVER';ns.ForeverData={zones={},areas={},steps={}};ns.ForeverRecipes={}
local function call(fn,...)if type(fn)=='function'then local ok,a,b,c,d,e,f,g,h,i,j,k,l,m,n=pcall(fn,...);if ok then return a,b,c,d,e,f,g,h,i,j,k,l,m,n end end end
E.Call=call
local function public(v)return not issecretvalue or call(issecretvalue,v)==false end
E.Public=public
local function num(v,a,b)if public(v)and type(v)=='number'and v==v and v>=a and v<=b then return v end end
local itemLabels={}
local function usableItemLabel(value)
 if public(value) and type(value)=='string' and value~='' then return value end
end
function E.ItemLabel(id)
 if not public(id) or type(id)~='number' then return end
 local label=itemLabels[id]
 if label then return label end
 local facts=ns.ForeverQuestData and ns.ForeverQuestData.names
 label=usableItemLabel(call(C_Item and C_Item.GetItemNameByID,id))
  or usableItemLabel(call(C_Item and C_Item.GetItemInfo,id))
  or usableItemLabel(call(GetItemInfo,id))
  or (facts and facts['item:'..id])
 if label then itemLabels[id]=label end
 return label
end
local function item(id)return E.ItemLabel(id)or(public(id)and'Item '..tostring(id)or'Unknown Item')end
local function spell(id)return call(C_Spell and C_Spell.GetSpellName,id)or call(GetSpellInfo,id)or('Spell '..tostring(id))end
E.ItemName=item;E.SpellName=spell
local function idFromLink(link)return public(link)and type(link)=='string'and tonumber(link:match('item:(%d+)'))end
E.ItemID=idFromLink
function E.NPCID(guid)if public(guid)and type(guid)=='string'and guid:match('^Creature%-')then local t={};for p in guid:gmatch('[^%-]+')do t[#t+1]=p end;return tonumber(t[6])end end
function E.Time()return call(GetTime)or 0 end
function E.Position()
 local map=call(C_Map and C_Map.GetBestMapForUnit,'player');local p=map and call(C_Map and C_Map.GetPlayerMapPosition,map,'player')
 if not p then return{status='unavailable',mapID=map}end
 local x,y;if p.GetXY then x,y=call(p.GetXY,p)else x,y=p.x,p.y end
 if num(x,0,1)and num(y,0,1)then return{status='available',mapID=map,x=x,y=y}end
 return{status='map-only',mapID=map}
end
function E.World(map,x,y)
 if not num(map,1,1e8)or not num(x,0,100)or not num(y,0,100)then return end
 local v=call(CreateVector2D,x/100,y/100);local instance,p=call(C_Map and C_Map.GetWorldPosFromMapPos,map,v)
 if p and public(p)then local a,b;if p.GetXY then a,b=call(p.GetXY,p)else a,b=p.x,p.y end;if num(instance,0,1e8)and num(a,-1e9,1e9)and num(b,-1e9,1e9)then return instance,a,b end end
end
function E.Distance(a,b)
 if not a or not b then return end
 local i,x,y=E.World(a.mapID,a.x,a.y);local j,u,v=E.World(b.mapID,b.x,b.y)
 if i and i==j and x and y and u and v then return math.sqrt((u-x)^2+(v-y)^2)end
end
function E.CurrentPosition()local p=E.Position();if p.status=='available'then return{mapID=p.mapID,x=p.x*100,y=p.y*100,evidence='observed-player-approach'}end end
function E.QuestState(id)
 if not num(id,1,1e8)then return{status='invalid'}end
 local q=C_QuestLog or{};local inLog=call(q.IsOnQuest,id);local rewarded=call(q.IsQuestFlaggedCompleted or IsQuestFlaggedCompleted,id)
 if not public(inLog)then inLog=nil end;if not public(rewarded)then rewarded=nil end
 if inLog~=true and inLog~=false then local index=call(q.GetLogIndexForQuestID or GetQuestLogIndexByID,id);if num(index,0,1e8)then inLog=index>0 elseif public(inLog)and type(inLog)=='number'then inLog=inLog==1 else inLog=nil end end
  rewarded=rewarded==true or rewarded==1
  if inLog~=true then return{status=inLog==false and'available'or'unavailable',inLog=false,rewarded=rewarded,ready=false,complete=false}end
 local objectives=call(q.GetQuestObjectives,id);local ready=call(q.IsComplete or IsQuestComplete,id)
 if type(objectives)~='table'then local index=call(q.GetLogIndexForQuestID or GetQuestLogIndexByID,id);if index and index>0 then objectives={};for slot=1,call(GetNumQuestLeaderBoards,index)or 0 do local text,kind,done=call(GetQuestLogLeaderBoard,slot,index);if text then local current,total=text:match('(%d+)%s*/%s*(%d+)');objectives[#objectives+1]={text=text,type=kind,finished=done==true,numFulfilled=tonumber(current),numRequired=tonumber(total)}end end end end
 return{status=type(inLog)=='boolean'and'available'or'unavailable',inLog=inLog,rewarded=rewarded,complete=ready,ready=ready,objectives=type(objectives)=='table'and objectives or nil}
end
function E.Record() end
function E.Snapshot()
 local _,race=call(UnitRace,'player');local _,class=call(UnitClass,'player')
 local s={faction=call(UnitFactionGroup,'player'),race=race,class=class,level=call(UnitLevel,'player'),position=E.CurrentPosition(),skills={},known={},quests={},completed={},auras={},talents={},reputations={},speed=call(GetUnitSpeed,'player'),money=call(GetMoney)}
 -- Read learned skills through the client's available API generation.
 local function learned(name,rank,cap,id)
  if public(name)and type(name)=='string'and num(rank,1,10000)then s.skills[name]={rank=rank,cap=num(cap,1,10000)or rank,id=id}end
 end
 local api=C_SkillInfo or{}
 if type(api.GetNumSkillLines)=='function'and type(api.GetSkillLineInfo)=='function'then
  for i=1,num(call(api.GetNumSkillLines),0,10000)or 0 do local v=call(api.GetSkillLineInfo,i);if type(v)=='table'and public(v.isHeader)and not v.isHeader then learned(v.name,v.rank,v.maxRank or v.maxSkillLevel,v.skillLineID)end end
 else
  for i=1,num(call(GetNumSkillLines),0,10000)or 0 do local name,header,_,rank,_,_,cap=call(GetSkillLineInfo,i);if public(header)and not header then learned(name,rank,cap)end end
 end
 if type(api.GetSkillLineInfoByID)=='function'then
  for _,id in ipairs({171,164,333,202,182,755,165,186,393,197,185,129,356})do local v=call(api.GetSkillLineInfoByID,id);if type(v)=='table'then learned(v.name,v.rank,v.maxRank or v.maxSkillLevel,id)end end
 end
 local indexes={call(GetProfessions)};for slot=1,6 do local index=indexes[slot];if num(index,1,10000)then local name,_,rank,cap,_,_,id=call(GetProfessionInfo,index);learned(name,rank,cap,id)end end
 if C_TradeSkillUI and C_TradeSkillUI.GetAllProfessionTradeSkillLines then
  for _,id in ipairs(call(C_TradeSkillUI.GetAllProfessionTradeSkillLines)or{})do local v=call(C_TradeSkillUI.GetProfessionInfoBySkillLineID,id);if type(v)=='table'then learned(v.professionName,v.skillLevel,v.maxSkillLevel,id)end end
 end
 for id,v in pairs(E.known)do if v then s.known[id]=true end end
 local ids=call(C_QuestLog and C_QuestLog.GetAllCompletedQuestIDs)
 s.completedAvailable=type(ids)=='table';if s.completedAvailable then for _,id in ipairs(ids)do s.completed[id]=true end end
 local n=call(C_QuestLog and C_QuestLog.GetNumQuestLogEntries or GetNumQuestLogEntries);s.questLogAvailable=num(n,0,1e5)~=nil;n=s.questLogAvailable and n or 0
 for i=1,n do local q=call(C_QuestLog and C_QuestLog.GetInfo,i);if not q then local title,_,_,header,_,_,_,id=call(GetQuestLogTitle,i);if title and id then q={questID=id,isHeader=header,title=title}end end;if q and q.questID and not q.isHeader then s.quests[q.questID]=E.QuestState(q.questID);s.quests[q.questID].title=q.title;s.quests[q.questID].inLog=true;if q.isComplete==true or q.isComplete==1 then s.quests[q.questID].ready=true end end end
 if C_UnitAuras and C_UnitAuras.GetAuraDataByIndex then
  for i=1,80 do local a=call(C_UnitAuras.GetAuraDataByIndex,'player',i,'HELPFUL');if not a then break end;if public(a.spellId)then s.auras[a.spellId]={duration=a.duration,expiration=a.expirationTime}end end
 else for i=1,80 do local name,_,_,_,duration,expires,_,_,_,id=call(UnitBuff,'player',i);if not name then break end;if id then s.auras[id]={duration=duration,expiration=expires}end end end
 for tab=1,call(GetNumTalentTabs)or 0 do for i=1,call(GetNumTalents,tab)or 0 do local name,_,_,_,rank,maxRank=call(GetTalentInfo,tab,i);if name then s.talents[name]={rank=rank,maxRank=maxRank}end end end
 for i=1,call(GetNumFactions)or 0 do local name,_,standing,_,_,value,_,_,header,_,_,_,_,id=call(GetFactionInfo,i);if name and not header then s.reputations[id or name]={name=name,standing=standing,value=value}end end
 for _,f in ipairs(ns.ForeverFacts and ns.ForeverFacts.selfBuffs or{})do if call(IsPlayerSpell or IsSpellKnown,f.id)==true then s.known[f.id]=true end end
 E.state=s;return s
end
-- Reuse one live snapshot only inside a synchronous guide refresh. Never
-- retain it across events or movement, and always restore APIs after errors.
function E.WithSnapshot(fn,...)
 if E.snapshotScope then return fn(...)end
 local snapshot,questState,known,world=E.Snapshot,E.QuestState,E.Known,E.World
 local state=snapshot();local fallback={};local recipeKnowledge={};local positions={}
 E.World=function(map,x,y)
  if not num(map,1,1e8)or not num(x,0,100)or not num(y,0,100)then return end
  local maps=positions[map];if not maps then maps={};positions[map]=maps end
  local xs=maps[x];if not xs then xs={};maps[x]=xs end
  local value=xs[y];if not value then value={world(map,x,y)};xs[y]=value end;return unpack(value)
 end
 if known then E.Known=function(r)local v=recipeKnowledge[r];if not v then v={known(r)};recipeKnowledge[r]=v end;return v[1]end end
 E.snapshotScope=true;E.Snapshot=function()return state end
 E.QuestState=function(id)
  if state.quests[id]then return state.quests[id]end
  if state.completed[id]then return{rewarded=true,inLog=false}end
  if state.questLogAvailable then
   if fallback[id]==nil then fallback[id]={status='available',inLog=false,ready=false,complete=false,rewarded=not state.completedAvailable and call(C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted or IsQuestFlaggedCompleted,id)==true or false}end
   return fallback[id]
  end
  if fallback[id]==nil then fallback[id]=questState(id)or{}end
  return fallback[id]
 end
 local function pack(...)return{n=select('#',...),...}end
 local result=pack(pcall(fn,...))
 E.Snapshot=snapshot;E.QuestState=questState;E.Known=known;E.World=world;E.snapshotScope=nil
 if not result[1]then error(result[2],0)end
 return unpack(result,2,result.n)
end
function E.ReadBook()
 local function add(id,name,learned,product,reagents,profession,required)
  if not id or profession=='Skinning'or profession=='Herbalism'or profession=='Fishing'then return end
  if learned==true then E.known[id]=true elseif learned==false then E.known[id]=nil end
  local r=E.recipes[id]or{spellID=id,name=name or spell(id),sources={},locations={}};E.recipes[id]=r
  r.name=name or r.name;r.profession=profession or r.profession;r.requiredSkill=required or r.requiredSkill;r.productID=product or r.productID;r.reagents=reagents or r.reagents;r.observed=true
  if product then E.crafted[product]=true end
  for material in pairs(reagents or{})do E.reagents[material]=E.reagents[material]or{};if r.profession then E.reagents[material][r.profession]=true end end
 end
 if call(GetTradeSkillIsLinked)~=true then
  local profession=call(GetTradeSkillLine)
  for i=1,call(GetNumTradeSkills)or 0 do local name,kind=call(GetTradeSkillInfo,i);if kind~='header'then
   local link=call(GetTradeSkillRecipeLink,i);local id=type(link)=='string'and tonumber(link:match('enchant:(%d+)')or link:match('spell:(%d+)'));local reagents={}
   local slots=call(GetTradeSkillNumReagents,i) or 0;local complete=slots>0
   for k=1,slots do local material=idFromLink(call(GetTradeSkillReagentItemLink,i,k));local _,_,quantity=call(GetTradeSkillReagentInfo,i,k);if material and quantity then reagents[material]=(reagents[material] or 0)+quantity else complete=false end end
   add(id,name,true,idFromLink(call(GetTradeSkillItemLink,i)),reagents,profession)
   local yield=call(GetTradeSkillNumMade,i)
   if complete and id and E.recipes[id] and type(yield)=='number' and yield>0 then
    E.recipes[id].fulfillment={reagents=reagents,yield=yield}
   end
  end end
 end
 -- Enchanting uses the legacy craft book on some Forever builds.
 local profession=call(GetCraftDisplaySkillLine)
 for i=1,call(GetNumCrafts)or 0 do local name,_,kind=call(GetCraftInfo,i);if kind~='header'then local link=call(GetCraftRecipeLink,i);local id=type(link)=='string'and tonumber(link:match('enchant:(%d+)')or link:match('spell:(%d+)'));local reagents={};for k=1,call(GetCraftNumReagents,i)or 0 do local material=idFromLink(call(GetCraftReagentItemLink,i,k));local _,_,quantity=call(GetCraftReagentInfo,i,k);if material and quantity then reagents[material]=quantity end end;add(id,name,true,idFromLink(call(GetCraftItemLink,i)),reagents,profession)end end
end
function E.Known(r)
 if E.known[r.spellID]then return true end
 if r.spellID and(call(IsPlayerSpell,r.spellID)==true or call(IsSpellKnown,r.spellID)==true)then return true end
 if r.knowledgeVerified==true and r.learned==false then return false end
 return nil -- Unknown knowledge evidence is not an unknown acquisition category.
end
local seasonalRecipes={[21143]=true,[21144]=true,[45022]=true}
local seasonalItems={[17200]=true,[17201]=true,[34413]=true}
local seasonalMerchants={[13429]=true,[13432]=true,[13420]=true,[13433]=true,[13435]=true}
function E.SeasonalAvailable(row)
 local recipe=seasonalRecipes[row.spellID]or seasonalItems[row.learnableItemID]
 if not recipe and not seasonalMerchants[row.npcID]then return true end
 if not MerchantFrame or call(MerchantFrame.IsShown,MerchantFrame)~=true then return false end
 local guid=call(UnitGUID,'npc');local npc=public(guid)and type(guid)=='string'and tonumber(guid:match('Creature%-%d+%-%d+%-%d+%-%d+%-(%d+)'))
 if row.npcID and npc~=row.npcID then return false end
 for i=1,num(call(GetMerchantNumItems),0,10000)or 0 do
  local id=E.ItemID(call(GetMerchantItemLink,i))
  if id and(recipe and id==row.learnableItemID or not recipe and seasonalItems[id])then return true end
 end
 return false
end
function E.Eligible(row,state)
 if not E.SeasonalAvailable(row)then return false end
 state=state or E.state or E.Snapshot()
 if row.faction and row.faction~='Both'and row.faction~='Neutral'and row.faction~=state.faction then return false end
 if row.race and row.race~=state.race or row.class and row.class~=state.class then return false end
 if row.minLevel and state.level<row.minLevel then return false end
 if row.maxLevel and state.level>row.maxLevel then return false end
 if row.requiredQuest and not state.completed[row.requiredQuest]and E.QuestState(row.requiredQuest).rewarded~=true then return false end
 if row.reputationID then local rep=state.reputations[row.reputationID];if not rep or not row.reputationStanding or rep.standing<row.reputationStanding then return false end end
 if row.specializationSpell and call(IsPlayerSpell or IsSpellKnown,row.specializationSpell)~=true then return false end
 return true
end
-- Compare the fastest ground approach with the cheapest observed affordable flight.
function E.Travel(destination,state)
 state=state or E.state or E.Snapshot();local distance=E.Distance(state.position,destination);local speed=math.max(1,(public(state.speed)and tonumber(state.speed))or 7);if speed<1.1 then speed=7 end
 local best=distance and{cost=0,seconds=distance/speed,kind='ground',estimate=true}or nil;local flight
 for _,edge in ipairs(E.flights)do if edge.known and edge.from and edge.to and type(edge.cost)=='number' and type(edge.seconds)=='number' and edge.seconds>0 and (not state.money or edge.cost<=state.money) then
  local a,b=E.Distance(state.position,edge.from),E.Distance(edge.to,destination)
  if a and b then local candidate={cost=edge.cost,seconds=(a+b)/speed+edge.seconds,kind='flight',estimate=true};if not flight or candidate.seconds<flight.seconds or candidate.seconds==flight.seconds and candidate.cost<flight.cost then flight=candidate end end
 end end
 if flight and(not best or flight.seconds<best.seconds)then flight.groundAlternative=best;return flight end
 if best then best.flightAlternative=flight end
 return best
end
function E.Nearest(rows,state)
 state=state or E.state or E.Snapshot();local best,score
 for _,row in ipairs(rows or{})do if E.Eligible(row,state)then local travel=E.Travel(row,state);if travel and(not score or travel.seconds<score.seconds or travel.seconds==score.seconds and travel.cost<score.cost)then best,score=row,travel end end end
 return best,score
end
function E.CampPlan(state)
 state=state or E.state or E.Snapshot();if state.auras[1229741]then return end
 local useful={};for _,feature in ipairs(ns.ForeverFacts and ns.ForeverFacts.campFeatures or{})do
  local conflict=false;for _,id in ipairs(feature.conflicts or{})do if state.known[id]or state.auras[id]then conflict=true end end
  if not conflict and(not feature.classes or feature.classes[state.class])then useful[#useful+1]=feature end
 end
 if #useful==0 then return end
 local campfireNearbyRadius=100 -- Campfire Nearby (spell 1283391).
 local nearby={};for _,camp in ipairs(E.camps)do local d=E.Distance(state.position,camp);if camp.expires>E.Time()and d and d<=campfireNearbyRadius then nearby[#nearby+1]=camp end end
 local camp=E.Nearest(nearby,state)
 if camp then return{id='camp:visit',kind='camp',category='Questing',title='Refresh camp benefits',destination=camp,body='Visit the observed campsite and sit nearby until Camp Benefits appears. Choose a useful feature that does not duplicate your class buffs. Camp may have expired; actions remain manual.',priority=85}end
 local kit
 for _,option in ipairs({{279974,220,'Expert Campfire Kit'},{279961,140,'Journeyman Campfire Kit'},{279981,0,'Basic Campfire Kit'}})do local cooking=state.skills.Cooking;if(option[2]==0 or cooking and cooking.rank>=option[2])and(call(GetItemCount,option[1])or 0)>0 then kit=option[3];break end end
 if kit then return{id='camp:place',kind='camp',category='Crafting',title='Set up your camp',body='Use your '..kit..' on safe accessible ground. Add one useful feature from your supplies, then sit nearby until Camp Benefits appears. Placement, crafting and sitting are manual.',priority=75}end
 for _,feature in ipairs(useful)do local r=E.recipes[feature.spellID];if r and E.Known(r)==true and state.skills[feature.profession]and state.skills[feature.profession].rank>=20 then
  local enough=true;for id,quantity in pairs(r.reagents or{})do if(call(GetItemCount,id)or 0)<quantity then enough=false end end
  local start,duration=call(GetSpellCooldown,feature.spellID)
  local cooling=type(start)=='number'and type(duration)=='number'and duration>1.5 and start+duration>E.Time()
  if enough and next(r.reagents or{})and not cooling then return{id='camp:craft:'..feature.spellID,kind='camp',category='Crafting',title='Prepare '..feature.name,body='You know this camp recipe and have its observed ingredients. Craft manually, obtain a campfire kit, and place the feature at a safe camp. Check the shared feature cooldown first.',priority=65}end
 end end
end
function E.RecipeOpportunity(r,state)
 state=state or E.state or E.Snapshot();local skill=r.profession and state.skills[r.profession]
 if not skill then return end
 if type(r.requiredSkill)~='number'or r.requiredSkill>skill.rank+25 then return end
 if r.requiredSkill<skill.rank-25 and not r.specializationSpell then return end
 if E.Known(r)~=false or not E.Eligible(r,state)then return end
 local locations={};for _,v in ipairs(r.locations or{})do if v.source=='Vendor'and v.evidence~='classic-reference-unconfirmed'then locations[#locations+1]=v end end
 local near=E.Nearest(locations,state);local distance=near and E.Distance(state.position,near)
 if not distance or distance>650 then return end
 local key=r.spellID or r.learnableItemID
 local deferred=E.db and E.db.recipeDeferred and E.db.recipeDeferred[key]
 if deferred and deferred.npcID==near.npcID then local away=E.Distance(state.position,deferred.position);if away and away>900 then deferred.left=true end;if not deferred.left then return end end
 return{id='recipe:'..key..':'..tostring(near.npcID),kind='recipe',category='Crafting',title='Buy '..r.name,destination=near,recipe=r,body='Check '..(near.name or'vendor')..' for '..r.name..'. '..(r.requiredSkill>skill.rank and'Buy ahead before leaving this area; learn it when your skill is sufficient.'or'Learn the recipe after buying it.')..' Check price and limited stock before purchase.',priority=r.specializationSpell and 105 or 70}
end
function E.Priority(row,state)
 local score=row.priority or 30
 if row.professionRisk or row.materialTierEnding then score=150 end
 if row.dungeon then local d=E.dungeons[row.dungeon];if d then
  if d.lfgMax and state.level>=d.lfgMax-2 and state.level<=d.lfgMax then score=160
  elseif d.minimum and d.maximum and state.level>=(d.minimum+d.maximum)/2 and state.level<=d.maximum then score=120 end
 end end
 if E.db and E.db.pace=='Relaxed'and not row.professionRisk and not row.dungeon then if row.profession=='Fishing'or row.lowAttention then score=score+80 elseif row.combat then score=score-60 end end
 return score
end
function E.Order(rows,state,beforeSort)
 state=state or E.state or E.Snapshot();local out={}
 local complete={};for _,row in ipairs(rows)do if row.complete then complete[row.id]=true end end
 for i,row in ipairs(rows)do local blocked=false;for _,id in ipairs(row.dependencies or{})do if not complete[id]and not(E.db and E.db.manual[id])then blocked=true end end;if not blocked and not row.complete and not(E.db and E.db.manual[row.id])and not(E.db and E.db.deferred[row.id]and E.db.deferred[row.id]>E.Time())and E.Eligible(row,state)then row._priority=E.Priority(row,state);row._sequence=i;out[#out+1]=row end end
 if beforeSort then beforeSort(out,state)end
 table.sort(out,function(a,b)if a._priority~=b._priority then return a._priority>b._priority end;return a._sequence<b._sequence end)
 return out
end
function E.KnownRecipeRows(zone,search)
 local out,groups={},{};local state=E.state or E.Snapshot();local query=search and search:lower()
 for _,r in pairs(E.recipes)do if E.Eligible(r,state)and(query and r.name:lower():find(query,1,true)or not query and E.Known(r)~=true)then
  local shown=false
  for _,loc in ipairs(r.locations or{})do if (not zone or loc.zone==zone)and E.Eligible(loc,state)then
   if loc.source=='Trainer'and not query then
    local key=(r.profession or'')..':'..loc.name;local group=groups[key]
    if not group then group={id='trainer:'..key,name=loc.name,profession=r.profession,rank=loc.rank,kind='trainer',recipes={},location=loc};groups[key]=group end
    group.recipes[#group.recipes+1]=r
   elseif not shown then out[#out+1]=r;shown=true end
  end end
 end end
 if not query then for _,loc in ipairs(ns.ForeverFacts.trainerRoster or{})do if(not zone or loc.zone==zone)and E.Eligible(loc,state)then local key=loc.profession..':'..loc.name;if not groups[key]then groups[key]={id='trainer:'..key,name=loc.name,profession=loc.profession,rank=loc.rank,kind='trainer',recipes={},location=loc,unobserved=true}end end end end
 local trainers={};for _,g in pairs(groups)do table.sort(g.recipes,function(a,b)return(a.requiredSkill or 0)<(b.requiredSkill or 0)end);trainers[#trainers+1]=g end
 table.sort(out,function(a,b)return a.name<b.name end)
 table.sort(trainers,function(a,b)local x=state.skills[a.profession]~=nil;local y=state.skills[b.profession]~=nil;if x~=y then return x end;return a.name<b.name end)
 for _,r in ipairs(trainers)do out[#out+1]=r end;return out
end
function E.FlagRecipe(r,enabled)
 if not r or not(r.spellID or r.learnableItemID)then return false end
 local sources={};for _,loc in ipairs(r.locations or{})do if loc.source=='Drop'or loc.source=='Treasure'then sources[#sources+1]=loc end end
 if #sources==0 then return false end
 E.farmFlags[r.spellID or r.learnableItemID]=enabled and true or nil;if E.db then E.db.farmFlags=E.farmFlags end;return true
end
function E.BossLoot(boss)
 local out,seen={},{};for _,v in ipairs(boss.loot or{})do if(type(v[4])=='number'and v[4]>=3)or tostring(v[3]):lower():find('quest',1,true)or v.startsQuest then out[#out+1]=v;seen[v[1]]=true end end
 for _,dungeon in pairs(E.dungeons)do for _,q in ipairs(dungeon.quests or{})do local item=q.startItem;if boss.name and item and not seen[item[1]]and type(item[4])=='string'and item[4]:find('Dropped by: '..boss.name,1,true)then out[#out+1]={item[1],item[2],'Starts quest: '..q.name,item[3],startsQuest=q.id};seen[item[1]]=true end end end
 return out
end
function E.ObserveCamp()
 local s=E.state or E.Snapshot();if not s.auras[1229739]then return end
 local p=E.CurrentPosition();if not p then return end
 p.name='Observed campsite';p.expires=E.Time()+300;p.evidence='player-inside-welcoming-campfire-aura'
 for i,c in ipairs(E.camps)do local d=E.Distance(c,p);if d and d<40 then E.camps[i]=p;return end end
 E.camps[#E.camps+1]=p;if #E.camps>24 then table.remove(E.camps,1)end
end
function E.UsageLines(itemID,isQuestItem)
 local out={};local names={};for profession in pairs(E.reagents[itemID]or{})do names[#names+1]=profession end;table.sort(names)
 if #names>0 then out[#out+1]='Used by '..table.concat(names,', ')end
 if not isQuestItem then local quests={};for _,name in pairs(E.itemQuests[itemID]or{})do quests[#quests+1]=name end;table.sort(quests);if #quests>0 then out[#out+1]='Used for '..table.concat(quests,', ')end end
 return out
end
local skinningMaterials={ [2934]=true,[2318]=true,[2319]=true,[4234]=true,[4304]=true,[8170]=true }
function E.DropLines(npcID)
 local out,seen={},{}
 local function add(itemID)
  if seen[itemID] then return end
  seen[itemID]=true
  if not E.crafted[itemID]and not E.gatherables[itemID]and(E.reagents[itemID]or E.itemQuests[itemID]or skinningMaterials[itemID])
   and(E.itemQuests[itemID]or not E.IsVendorReagent or not E.IsVendorReagent(itemID))then out[#out+1]=item(itemID)end
 end
 for itemID in pairs(E.mobDrops[npcID]or{})do add(itemID)end
 for _,itemID in ipairs(E.SupplementalDrops and E.SupplementalDrops(npcID)or{})do add(itemID)end
 table.sort(out);return out
end
local P={steps={},skills={},book={},active=true,character={level=1}};ns.ProfessionGuide=P
function P.ReadSkills()local s=E.Snapshot();P.skills=s.skills;P.character=s;return P.skills end
function P.ReadBook()E.ReadBook();return P.book end
function P.Refresh()
 local s=E.Snapshot();P.skills=s.skills;P.character=s;local rows={};local manual=E.db and E.db.manual or{};local deferred=E.db and E.db.deferred or{}
 for _,entry in pairs(E.db and E.db.recipeDeferred or{})do local away=E.Distance(s.position,entry.position);if away and away>900 then entry.left=true end end
 local source=E.db and E.db.journey=='Completionist'and E.collections or E.route
 for _,base in ipairs(source)do local row={};for k,v in pairs(base)do row[k]=v end
  local q=row.quest and E.QuestState(row.quest);row.complete=manual[row.id]or q and((row.kind=='accept'and q.inLog==true)or(row.kind=='turnin'and q.rewarded==true)or(row.kind=='objective'and q.objectives and row.slot and q.objectives[row.slot]and q.objectives[row.slot].finished==true))
  if not deferred[row.id]or E.Time()>deferred[row.id]then rows[#rows+1]=row end
 end
 for _,r in pairs(E.recipes)do local opportunity=E.RecipeOpportunity(r,s);if opportunity and(not deferred[opportunity.id]or E.Time()>deferred[opportunity.id])then rows[#rows+1]=opportunity end end
 local camp=E.CampPlan(s);if camp and(not deferred[camp.id]or E.Time()>deferred[camp.id])then rows[#rows+1]=camp end
 for _,r in ipairs(E.CatchupSteps and E.CatchupSteps(s,source)or{})do rows[#rows+1]=r end
 for _,r in ipairs(E.CraftingCatchup and E.CraftingCatchup(s,source)or{})do rows[#rows+1]=r end
 for _,r in ipairs(E.farmSteps or{})do rows[#rows+1]=r end
 for id in pairs(E.farmFlags)do local r=E.recipes[id];if r and E.Known(r)~=true then local locations={};for _,v in ipairs(r.locations or{})do if v.source=='Drop'or v.source=='Treasure'then locations[#locations+1]=v end end;local loc=E.Nearest(locations,s);local dungeon=not loc and r.locations[1]and E.dungeons[r.locations[1].dungeon];if dungeon then loc=dungeon.entrance end;rows[#rows+1]={id='farmrecipe:'..id,kind='farmRecipe',category='Crafting',title='Find '..r.name,body='Farm '..(r.learnableName or r.name)..' from '..(r.locations[1]and r.locations[1].name or'its recorded source')..'. Drops are not guaranteed.',destination=loc,priority=90}end end
 if #rows==0 then rows[1]={id='awaiting-route',kind='information',category='Questing',title='Forever guide preparation',body='No eligible route is loaded. Your Forever Factoruide export is pending. Profession and collection recommendations appear only when their sources and requirements are known.'}end
 P.steps=E.Order(rows,s)
 if #P.steps==0 and E.db and E.db.journey=='Completionist'then
  local required;for _,r in ipairs(E.collections)do if r.minLevel and r.minLevel>s.level and(not required or r.minLevel<required)then required=r.minLevel end end
  if required then for _,row in ipairs(E.route)do if not manual[row.id]and E.Eligible(row,s)then P.steps[1]=row;break end end
   if #P.steps==0 then P.steps[1]={id='collection:level-gate',kind='information',category='Questing',title='Collection preparation: level '..required,body='The next sourced collection activities recommend level '..required..'. Your Forever Factoruide export will supply the prerequisite leveling steps. No quest or location is invented.'}end
  end
 end
 P.firstPending=P.steps[1]and P.steps[1].id;return P.steps
end
function P.Destination()local row=P.selected;return row and row.destination end
function P.Done()local r=P.selected;if not r or r.kind=='accept'or r.kind=='turnin'or r.kind=='objective'then return false end;if E.db then if r.urgentBags then E.db.deferred[r.id]=E.Time()+600 elseif r.kind=='camp'or r.kind=='recipe'or r.kind=='profession'then E.db.deferred[r.id]=E.Time()+300 else E.db.manual[r.id]=true end end;P.Refresh();if ns.NormalUI then ns.NormalUI.Resync()end;return true end
function P.Skip()local r=P.selected;if r and E.db then if r.urgentBags then E.db.deferred[r.id]=E.Time()+600 elseif r.recipe and r.destination then E.db.recipeDeferred=E.db.recipeDeferred or{};E.db.recipeDeferred[r.recipe.spellID or r.recipe.learnableItemID]={npcID=r.destination.npcID,position=E.CurrentPosition()}else E.db.deferred[r.id]=E.Time()+180 end end;P.Refresh();if ns.NormalUI then ns.NormalUI.Resync()end;return true end
function P.SetEnabled()return true end
ns.Retail.Client={Number=num,Character=function()return E.Snapshot()end,PlayerPosition=E.Position,WorldPosition=E.World,QuestState=E.QuestState,Facing=function()return call(GetPlayerFacing)end,Text=function(v)if type(v)=='string'then return v end end}
ns._listeners={};function ns.RegisterMessage(event,fn)ns._listeners[event]=ns._listeners[event]or{};table.insert(ns._listeners[event],fn)end
function ns.SendMessage(event,...)for _,fn in ipairs(ns._listeners[event]or{})do local ok,err=pcall(fn,event,...);if not ok then E.issues[#E.issues+1]=tostring(err);ns.Print('A Forever callback failed; /gf diagnose shows the last error.')end end end
function ns.Print(s)if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage('|cffc49a58Grinding Forever:|r '..tostring(s))end end
ns.StripColors=function(s)return type(s)=='string'and s:gsub('|c%x%x%x%x%x%x%x%x',''):gsub('|r','')or''end
ns.PlayerPosition=function()local p=E.Position();return p.mapID,p.x and p.x*100,p.y and p.y*100 end
ns.QuestDone=function(id)return E.QuestState(id).rewarded==true end
ns.IsOnQuest=function(id)return E.QuestState(id).inLog==true end
ns.Faction=function()return call(UnitFactionGroup,'player')end
ns.Level=function()return call(UnitLevel,'player')end
ns.BindForeverRecipes=function(N)N.recipeRecords={};N.foreverBound=true end
ns.ForeverMapTexture=function()return nil end
ns.RenderForeverMap=function()return false end
ns.FarmingPlanner={route=nil,StartCurrent=function()return false,'Select a recipe with a verified Forever material source.'end}

end)(ADDON,GF)
-- GF_MODULE_END Engine
-- GF_MODULE_BEGIN Facts
;(function(...)
-- Factual Forever beta references checked 2026-10-28. Live recipe/aura data wins.
local _,ns=...
local F={version=1,client='1.60.1.70658',campAura=1229741,campWarmupAura=1229739,campDuration=3600,campKit=279981,recipes={},campFeatures={},selfBuffs={},gatherables={},sourceDates={}}
ns.ForeverFacts=F
local campSource='https://www.wow-professions.com/forever/camping-guide'
local overview='https://www.wowhead.com/forever/guide/camping-overview-unlock-rewards'
F.sources={campSource,overview,'https://www.wowhead.com/forever/spell=1229741/camp-benefits','https://www.wowhead.com/forever/spell=1229739/welcoming-campfire'}
local features={
 {'Alchemy','Mana Well',1230564,{[2447]=1,[3371]=1},{19742,19850,19852,19853,19854,25894},'mana'},
 {'Blacksmithing','Sharpening Wheel',1230171,{[2835]=1,[2840]=1},{8075,8160,8161,10442},'strength'},
 {'Enchanting','Enchanted Lute',1230643,{[4470]=1,[10940]=1},{1126,5232,6756,5234,8907,9884,9885,21849,21850},'all'},
 {'Engineering','Reagent Bot',1230656,{[4359]=1,[4361]=1},{},'supplies'},
 {'Leatherworking','Camp Tent',1229432,{[2318]=5},{},'rested'},
 {'Tailoring','Faction Banner',1229504,{[2996]=1,[2320]=1},{14752,14818,14819,27841,27681},'spirit'},
 {'Herbalism','Incense Candle',1229705,{[2447]=1,[765]=1},{1459,1460,1461,10156,10157,23028},'intellect'},
 {'Mining','Lodestone',1230161,{[2835]=1,[2840]=1},{19740,19834,19835,19836,19837,19838,25782},'attack'},
 {'Skinning','Camp Chair',1229517,{[2318]=3,[4470]=2},{24907},'critical'},
 {'First Aid','First Aid Kit',1230117,{[1251]=3,[159]=1},{1243,1244,1245,2791,10937,10938,21562,21564},'stamina'},
 {'Fishing','Fish Bowl',1229745,{[6291]=1,[3371]=1},{20217,25898},'all'},
}
local caster={MAGE=true,PRIEST=true,WARLOCK=true,PALADIN=true,SHAMAN=true,DRUID=true,HUNTER=true}
local melee={WARRIOR=true,PALADIN=true,ROGUE=true,SHAMAN=true,DRUID=true}
for _,v in ipairs(features)do
 local feature={profession=v[1],name=v[2],spellID=v[3],reagents=v[4],conflicts=v[5],benefit=v[6],source=campSource}
 if v[6]=='mana'or v[6]=='intellect'or v[6]=='spirit'then feature.classes=caster elseif v[6]=='strength'or v[6]=='attack'then feature.classes=melee end
 F.campFeatures[#F.campFeatures+1]=feature
 F.recipes[#F.recipes+1]={name=v[2],spellID=v[3],profession=v[1],requiredSkill=20,reagents=v[4],sourceURL=campSource,locations={},sources={'Trainer'},campFeature=true}
 for _,id in ipairs(v[5])do F.selfBuffs[#F.selfBuffs+1]={id=id}end
end
local tier2={
 {'Alchemy','Fermenter',1263005,273085,'Ruins of Lordaeron',"Rath'mael"},
 {'Blacksmithing','Anvil',1263041,273086,'The Deadmines','Gilnid'},
 {'Enchanting','Arcane Salvager',1263056,273103,'City of Dalaran','Shade of the Archmage'},
 {'Engineering','Repair Bot',1263034,273092,'The Deadmines','Sneed'},
 {'Leatherworking','Tanning Rack',1263031,273096,'Shadowfang Keep','Razorclaw the Butcher'},
 {'Tailoring','Spinning Wheel',1263032,273099,'City of Dalaran','Unstable Sentinel'},
 {'Herbalism','Greenhouse',1262980,273106,'Excavation Site: Wetlands','Shadetooth'},
 {'Mining','Rock Garden',1262975,273097,'Excavation Site: Wetlands','Relic Guardian'},
 {'Skinning','Field Guide',1262985,273098,'Wailing Caverns','Lady Anacondra'},
 {'Cooking',"Cookie's Feast",1262978,273102,'The Deadmines','Cookie'},
 {'First Aid','Toxin Study',1262996,273105,'Shadowfang Keep','Commander Springvale'},
 {'Fishing','Fishing Rack',1262990,273141,'Blackfathom Deeps','Gelihast'},
}
for _,v in ipairs(tier2)do F.recipes[#F.recipes+1]={name=v[2],spellID=v[3],learnableItemID=v[4],learnableName='Blueprint: '..v[2],profession=v[1],requiredSkill=140,sourceURL=campSource,sources={'Drop'},locations={{source='Drop',zone=v[5],dungeon=v[5],name=v[6]}}}end
F.recipes[#F.recipes+1]={name='Journeyman Campfire Kit',learnableItemID=273087,productID=279961,profession='Cooking',requiredSkill=90,useSkill=140,sourceURL=campSource,sources={'Drop'},locations={{source='Drop',zone='Wailing Caverns',dungeon='Wailing Caverns',name='Lord Serpentis'}}}
-- No guessed tier3 blueprint drop locations. The reference explicitly does not know them.
F.professions={'Alchemy','Blacksmithing','Cooking','Enchanting','Engineering','First Aid','Fishing','Herbalism','Leatherworking','Mining','Skinning','Tailoring'}
F.professionIDs={Alchemy=171,Blacksmithing=164,Cooking=185,Enchanting=333,Engineering=202,['First Aid']=129,Fishing=356,Herbalism=182,Leatherworking=165,Mining=186,Skinning=393,Tailoring=197}
F.professionSources={};for _,name in ipairs(F.professions)do F.professionSources[name]='https://www.wow-professions.com/forever/'..name:lower():gsub(' ','-')..'-leveling-guide'end
F.professionSources.Fishing='https://www.wow-professions.com/forever/fishing-and-cooking-leveling-guide'
-- Material boundaries are route planning inputs, never a hard character-level gate.
F.materialBands={
 ['First Aid']={{skill=1,untilSkill=80,item=2589,name='Linen Cloth'},{skill=80,untilSkill=150,item=2592,name='Wool Cloth'},{skill=150,untilSkill=210,item=4306,name='Silk Cloth'},{skill=210,untilSkill=260,item=4338,name='Mageweave Cloth'},{skill=260,untilSkill=300,item=14047,name='Runecloth'}},
 Mining={{skill=1,untilSkill=65,item=2770,name='Copper Ore'},{skill=65,untilSkill=125,item=2771,name='Tin Ore'},{skill=125,untilSkill=175,item=2772,name='Iron Ore'},{skill=175,untilSkill=245,item=3858,name='Mithril Ore'},{skill=245,untilSkill=300,item=10620,name='Thorium Ore'}},
 Herbalism={{skill=1,untilSkill=70,item=2447,name='Peacebloom'},{skill=70,untilSkill=115,item=2450,name='Briarthorn'},{skill=115,untilSkill=170,item=2453,name='Bruiseweed'},{skill=170,untilSkill=205,item=3357,name='Liferoot'},{skill=205,untilSkill=230,item=4625,name='Firebloom'},{skill=230,untilSkill=270,item=8838,name='Sungrass'},{skill=270,untilSkill=300,item=13464,name='Golden Sansam'}},
}
for _,bands in pairs(F.materialBands)do for _,band in ipairs(bands)do if band.item~=2589 and band.item~=2592 and band.item~=4306 and band.item~=4338 and band.item~=14047 then F.gatherables[band.item]=true end end end
for _,id in ipairs({2318,2319,4234,4304,8170,783,4232,4235,8169,15412,15414,15415,6291,6289,6308,6361,6362,7974,6358,6359,13754,13755,13756,13758,13759,13760,2835,2836,2838,7912,12365})do F.gatherables[id]=true end
F.healingProducts={[118]=true,[858]=true,[929]=true,[1710]=true,[3928]=true,[13446]=true}
F.changes={healingPotionsProfession='First Aid',source='https://www.wow-professions.com/forever/first-aid-leveling-guide'}
-- User-supplied quest example; the item-to-quest relationship is independent of turn-in count.
F.itemQuests={[5114]={[7899]='Small Furry Paws'}}

end)(ADDON,GF)
-- GF_MODULE_END Facts
-- GF_MODULE_BEGIN Maps
;(function(...)
local _,ns=...
ns.ForeverFacts.maps={
["Alterac Mountains"]={id=36,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap36",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/36.jpg"},
["Arathi Highlands"]={id=45,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap45",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/45.jpg"},
["Ashenvale"]={id=331,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap331",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/331.jpg"},
["Azshara"]={id=16,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap16",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/16.jpg"},
["Badlands"]={id=3,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap3",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/3.jpg"},
["Blasted Lands"]={id=4,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap4",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/4.jpg"},
["Burning Steppes"]={id=46,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap46",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/46.jpg"},
["Darkshore"]={id=148,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap148",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/148.jpg"},
["Darnassus"]={id=1657,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap1657",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/1657.jpg"},
["Deadwind Pass"]={id=41,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap41",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/41.jpg"},
["Desolace"]={id=405,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap405",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/405.jpg"},
["Dun Morogh"]={id=1,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap1",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/1.jpg"},
["Durotar"]={id=14,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap14",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/14.jpg"},
["Duskwood"]={id=10,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap10",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/10.jpg"},
["Dustwallow Marsh"]={id=15,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap15",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/15.jpg"},
["Eastern Plaguelands"]={id=139,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap139",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/139.jpg"},
["Elwynn Forest"]={id=12,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap12",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/12.jpg"},
["Felwood"]={id=361,u=1.0,v=0.66796875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap361",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/361.jpg"},
["Feralas"]={id=357,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap357",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/357.jpg"},
["Hillsbrad Foothills"]={id=267,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap267",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/267.jpg"},
["Ironforge"]={id=1537,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap1537",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/1537.jpg"},
["Loch Modan"]={id=38,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap38",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/38.jpg"},
["Moonglade"]={id=493,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap493",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/493.jpg"},
["Mount Hyjal"]={id=616,u=1.0,v=0.66796875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap616",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/616.jpg"},
["Mulgore"]={id=215,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap215",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/215.jpg"},
["Orgrimmar"]={id=1637,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap1637",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/1637.jpg"},
["Redridge Mountains"]={id=44,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap44",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/44.jpg"},
["Riverglades"]={id=16591,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap16591",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/16591.jpg"},
["Searing Gorge"]={id=51,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap51",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/51.jpg"},
["Shen'dralas"]={id=16651,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap16651",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/16651.jpg"},
["Silithus"]={id=1377,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap1377",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/1377.jpg"},
["Silverpine Forest"]={id=130,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap130",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/130.jpg"},
["Stonetalon Mountains"]={id=406,u=1.0,v=0.66796875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap406",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/406.jpg"},
["Stormwind City"]={id=1519,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap1519",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/1519.jpg"},
["Stranglethorn Vale"]={id=33,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap33",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/33.jpg"},
["Swamp of Sorrows"]={id=8,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap8",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/8.jpg"},
["Tanaris"]={id=440,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap440",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/440.jpg"},
["Teldrassil"]={id=141,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap141",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/141.jpg"},
["The Barrens"]={id=17,u=1.0,v=0.66796875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap17",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/17.jpg"},
["The Hinterlands"]={id=47,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap47",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/47.jpg"},
["Thousand Needles"]={id=400,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap400",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/400.jpg"},
["Thunder Bluff"]={id=1638,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap1638",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/1638.jpg"},
["Tirisfal Glades"]={id=85,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap85",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/85.jpg"},
["Un'Goro Crater"]={id=490,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap490",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/490.jpg"},
["Undercity"]={id=1497,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap1497",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/1497.jpg"},
["Western Plaguelands"]={id=28,u=1.0,v=0.6689453125,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap28",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/28.jpg"},
["Westfall"]={id=40,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap40",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/40.jpg"},
["Wetlands"]={id=11,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap11",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/11.jpg"},
["Winterspring"]={id=618,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap618",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/618.jpg"},
["Zephras Isle"]={id=16593,u=1.0,v=0.6669921875,path="Interface\\AddOns\\GrindingForever\\Media\\ZoneMap16593",source="https://wow.zamimg.com/images/wow/classicplus/maps/enus/original/16593.jpg"},
}
end)(ADDON,GF)
-- GF_MODULE_END Maps
-- GF_MODULE_BEGIN Providers
;(function(...)
-- References installed Forever catalogs in memory; never duplicates their databases.
local _,ns=...
local E,F=ns.Forever,ns.ForeverFacts;local call=E.Call
E.gatherables=F.gatherables;E.itemQuests=F.itemQuests
for id in pairs(F.healingProducts)do E.crafted[id]=true end
for _,id in ipairs({2589,2592,4306,4338,14047})do E.reagents[id]={['First Aid']=true,Tailoring=true}end
E.reagents[6291]={Cooking=true,Fishing=true};E.reagents[6289]={Cooking=true}
function E.IndexRecipe(r)
 local key=r.spellID or r.learnableItemID;if not key then return end
 r.id='recipe:'..key;r.sources=r.sources or{};r.locations=r.locations or{};r.quality=r.quality or 1
 local existing=E.recipes[key]
 if existing and existing~=r then for k,v in pairs(r)do if existing[k]==nil then existing[k]=v end end;r=existing end
 E.recipes[key]=r
 if r.productID then E.crafted[r.productID]=true end
 for item in pairs(r.reagents or{})do E.reagents[item]=E.reagents[item]or{};if r.profession then E.reagents[item][r.profession]=true end end
 return r
end
for _,r in ipairs(F.recipes)do E.IndexRecipe(r)end
E.IndexRecipe({spellID=7751,learnableItemID=6325,itemId=6325,productID=6290,craftedItemId=6290,name='Brilliant Smallfish',profession='Cooking',requiredSkill=1,reagents={[6291]=1},sources={'Vendor'},locations={{npcID=3550,name='Martine Tramblay',zone='Tirisfal Glades',mapID=1420,x=65.888,y=59.641,faction='Horde',source='Vendor',evidence='player-observed-vendor; purchase-reported',sourceURL='https://www.wow-professions.com/forever/fishing-and-cooking-leveling-guide'}}})
function E.LoadDungeonCatalog()
 local journal=_G.ForeverDungeonJournal_NS
 if not journal or type(journal.DB)~='table'then E.issues.dungeonCatalog='ForeverDungeonJournal is not loaded.';return false end
 E.journal=journal
 for name,data in pairs(journal.DB)do if ns.IsForeverDungeon(name) then
  local a,b=tostring(data.level):match('(%d+)%D+(%d+)')
  local d={name=name,minimum=tonumber(a),maximum=tonumber(b),bosses=data.bosses or{},quests=data.quests or{},map=journal.DUNGEON_MAPS and journal.DUNGEON_MAPS[name],source='installed-ForeverDungeonJournal-cache',sourceData=data}
  if data.entrance then d.entrance={mapID=data.entrance.mapID,x=data.entrance.x*100,y=data.entrance.y*100,name=name..' entrance'}end;E.dungeons[name]=d
  ns.ForeverData.zones[name]=ns.ForeverData.zones[name]or{instance=true,name=name,v=1}
  for _,q in ipairs(d.quests)do
   for _,f in ipairs({'requiredItems','items'})do for id in pairs(type(q[f])=='table'and q[f]or{})do if type(id)=='number'then E.itemQuests[id]=E.itemQuests[id]or{};E.itemQuests[id][q.id]=q.name end end end
  end
  for _,boss in ipairs(d.bosses)do
   for _,loot in ipairs(boss.loot or{})do
    local recipe
    for _,r in pairs(E.recipes)do if r.learnableItemID==loot[1]then recipe=r;break end end
    if recipe then for _,loc in ipairs(recipe.locations)do if loc.dungeon==name and loc.name==boss.name then loc.npcID=boss.npcID;loc.portrait=journal.STATIC_DISPLAY_IDS and journal.STATIC_DISPLAY_IDS[boss.npcID]end end end
    local atlas=AtlasLoot and AtlasLoot.Data and AtlasLoot.Data.Recipe
    if atlas and call(atlas.IsRecipe,loot[1])then
     local fact=call(atlas.GetRecipeData,loot[1]);local profession=type(fact)=='table'and({[1]='First Aid',[2]='Blacksmithing',[3]='Leatherworking',[4]='Alchemy',[5]='Herbalism',[6]='Cooking',[7]='Mining',[8]='Tailoring',[9]='Engineering',[10]='Enchanting',[11]='Fishing',[12]='Skinning'})[fact[1]]
     if profession then E.IndexRecipe({spellID=fact[3],name=loot[2],learnableName=loot[2],learnableItemID=loot[1],profession=profession,requiredSkill=fact[2],sources={'Drop'},locations={{source='Drop',zone=name,dungeon=name,name=boss.name,npcID=boss.npcID}},sourceURL='installed-ForeverDungeonJournal-cache'})end
    end
   end
  end
 end end
 E.issues.dungeonCatalog=nil;return true
end
function E.ReadZones()
 local maps=ns.ForeverData.zones
 for name in pairs(F.maps or{})do maps[name]=maps[name]or{name=name,v=1}end
 for _,continent in ipairs(call(C_Map and C_Map.GetMapChildrenInfo,947,2,true)or{})do
  for _,v in ipairs(call(C_Map and C_Map.GetMapChildrenInfo,continent.mapID,3,true)or{})do
   if v.name and v.mapID and v.mapType==3 then maps[v.name]=maps[v.name]or{name=v.name,v=1};maps[v.name].mapID=v.mapID end
  end
 end
 -- The current client map is valid even when continent enumeration is unavailable.
 local p=E.Position();local info=p.mapID and call(C_Map and C_Map.GetMapInfo,p.mapID)
 if info and info.name then maps[info.name]=maps[info.name]or{name=info.name,v=1};maps[info.name].mapID=p.mapID end
end
E.ReadZones()
function E.RefreshCatalog()
 E.LoadDungeonCatalog();E.ReadBook()
 for key,r in pairs(E.recipes)do
  if r.productID and F.healingProducts[r.productID]and not E.known[r.spellID]then r.profession='First Aid' end
  if not r.name or r.name:match('^Spell %d+$')then r.name=E.SpellName(r.spellID)end
  E.IndexRecipe(r)
 end
end
function ns.BindForeverRecipes(N)
 E.RefreshCatalog();N.recipeRecords={}
 for _,r in pairs(E.recipes)do
  r.source=r.sources[1];r.zone=r.locations[1]and r.locations[1].zone;r.icon=call(C_Item and C_Item.GetItemIconByID,r.productID or r.learnableItemID)or 134400
  if #r.locations>0 then N.recipeRecords[#N.recipeRecords+1]=r end
 end
 N.foreverBound=true
end
function E.ObserveTrainer()
 local id=E.NPCID(call(UnitGUID,'npc'));local p=E.CurrentPosition();if not id or not p then return end
 local name=call(UnitName,'npc')or'Profession trainer';local state=E.state or E.Snapshot();local map=call(C_Map and C_Map.GetMapInfo,p.mapID);p.name=name;p.npcID=id;p.zone=map and map.name;p.source='Trainer';p.faction=state.faction;p.evidence='observed-player-at-trainer'
 E.trainers[id]=p
 for i=1,call(GetNumTrainerServices)or 0 do
  local service,_,kind=call(GetTrainerServiceInfo,i);local link=call(GetTrainerServiceItemLink,i);local spellID=type(link)=='string'and tonumber(link:match('spell:(%d+)')or link:match('enchant:(%d+)'))
  local profession,rank=call(GetTrainerServiceSkillReq,i)
  if spellID and service and type(profession)=='string'then
   local row=E.recipes[spellID]or{spellID=spellID,name=service,profession=profession,requiredSkill=rank,sources={'Trainer'},locations={}}
   local found=false;for _,v in ipairs(row.locations)do if v.npcID==id then found=true end end
   if not found then row.locations[#row.locations+1]=p end
   if kind=='used'then E.known[spellID]=true;row.knowledgeVerified=true;row.learned=true elseif kind=='available'or kind=='unavailable'then row.knowledgeVerified=true;row.learned=false end
   row.observed=true;E.IndexRecipe(row)
  end
 end
 E.Record('trainer-observed',{npcID=id})
end
-- A source observation is not proof that the character has learned its recipe.
function E.ObserveVendorRecipe(itemID)
 for _,r in pairs(E.recipes)do if r.learnableItemID==itemID then return r end end
 local name,_,_,_,required,_,subclass,_,_,icon,_,classID=call(C_Item and C_Item.GetItemInfo or GetItemInfo,itemID)
 if not E.Public(name)or type(name)~='string'or not E.Public(classID)or classID~=9 then return end
 if not E.Public(subclass)or type(subclass)~='string'then return end
 local profession=({Alchemy='Alchemy',Blacksmithing='Blacksmithing',Cooking='Cooking',Enchanting='Enchanting',Engineering='Engineering',['First Aid']='First Aid',Fishing='Fishing',Jewelcrafting='Jewelcrafting',Leatherworking='Leatherworking',Tailoring='Tailoring'})[subclass]
 if not profession then return end
 return E.IndexRecipe({learnableItemID=itemID,itemId=itemID,name=name,profession=profession,icon=E.Public(icon)and icon or nil,sources={},locations={},catalogOnly=true,observed=true})
end
function E.ObserveMerchant()
 local id=E.NPCID(call(UnitGUID,'npc'));local p=E.CurrentPosition();if not id or not p then return end
 local state=E.state or E.Snapshot();local info=call(C_Map and C_Map.GetMapInfo,p.mapID);p.zone=info and info.name;p.name=call(UnitName,'npc');p.npcID=id;p.faction=state.faction;p.source='Vendor';p.evidence='observed-player-at-vendor'
 local previous=E.vendors[id]
 p.stockItems=previous and previous.stockItems or{};E.vendors[id]=p
 for i=1,call(GetMerchantNumItems)or 0 do local itemID=E.ItemID(call(GetMerchantItemLink,i));if itemID then
  local _,_,price,_,_,_,extended=call(GetMerchantItemInfo,i)
  local merchant=call(C_MerchantFrame and C_MerchantFrame.GetItemInfo,i)
  if E.Public(merchant)and type(merchant)=='table'then price=merchant.price;extended=merchant.hasExtendedCost end
  if E.Public(price)and E.Public(extended)and type(price)=='number'and price>0 and not extended then p.stockItems[itemID]=true;if E.NoteVendorStock then E.NoteVendorStock(itemID)end end
  local r=E.ObserveVendorRecipe(itemID)
  if r then
   local info=call(C_MerchantFrame and C_MerchantFrame.GetItemInfo,i)
   local _,_,price,_,stock=call(GetMerchantItemInfo,i)
   if type(info)=='table'then price=info.price;stock=info.numAvailable end
   if not E.Public(price)or type(price)~='number'then price=nil end
   if not E.Public(stock)or type(stock)~='number'then stock=nil end
   local exists=false;for _,loc in ipairs(r.locations)do if loc.npcID==id and loc.source=='Vendor'then loc.price=price;loc.stock=stock;exists=true end end
   if not exists then local loc={};for k,v in pairs(p)do if k~='stockItems'then loc[k]=v end end;loc.price=price;loc.stock=stock;r.locations[#r.locations+1]=loc end
   local source=false;for _,v in ipairs(r.sources)do if v=='Vendor'then source=true end end;if not source then r.sources[#r.sources+1]='Vendor'end
   r.observed=true
   if E.NoteRecipeSource then E.NoteRecipeSource(r,id)end
  end
 end end
 E.Record('vendor-observed',{npcID=id})
end
function E.ObserveLoot()
 local p=E.CurrentPosition();if not p then return end
 for slot=1,call(GetNumLootItems)or 0 do
  local itemID=E.ItemID(call(GetLootSlotLink,slot));local guid=call(GetLootSourceInfo,slot);local npc=E.NPCID(guid)
  if itemID and npc then
   E.mobDrops[npc]=E.mobDrops[npc]or{};E.mobDrops[npc][itemID]=true
   E.materialSites=E.materialSites or{};local list=E.materialSites[itemID]or{};local near=false;for _,site in ipairs(list)do local d=E.Distance(site,p);if d and d<40 then near=true end end
   if not near then local site={mapID=p.mapID,x=p.x,y=p.y,npcID=npc,name=(E.NPCID(call(UnitGUID,'target'))==npc and call(UnitName,'target'))or('NPC '..npc),evidence='observed-player-at-loot'};list[#list+1]=site;if #list>24 then table.remove(list,1)end;E.materialSites[itemID]=list end
   E.Record('loot',{npcID=npc,itemID=itemID})
   local current=ns.NormalUI and ns.NormalUI.model:Current()
   if current and current.kind=='objective'and current.targetKind=='item'and current.targetID==itemID then E.objectiveArea={key=current.id,position=p}end
  end
 end
end
function E.CatchupSteps(state,route)
 local rows={};local futureZones={};for i=1,math.min(12,#route)do if route[i].zone then futureZones[route[i].zone]=true end end
 for profession,skill in pairs(state.skills)do
  local endangered={}
  for _,r in pairs(E.recipes)do if r.profession==profession and E.Known(r)==true and(not r.greySkill or skill.rank<r.greySkill)then
   for material in pairs(r.reagents or{})do local sites=E.materialSites and E.materialSites[material]or{};local localSource=false
    for _,site in ipairs(sites)do local d=E.Distance(state.position,site);if d and d<1800 then localSource=true end end
    -- Risk is asserted only when the imported route explicitly identifies a tier transition.
    for _,nextStep in ipairs(route)do if nextStep.materialTierLeaving and nextStep.materialTierLeaving[material]and localSource then endangered[material]=true end end
   end
  end end
  for material in pairs(endangered)do local destination=E.Nearest(E.materialSites[material],state);if destination then rows[#rows+1]={id='catchup:'..profession..':'..material,kind='profession',profession=profession,professionRisk=true,category='Crafting',title='Catch up '..profession,body='Before leaving this material tier, collect '..E.ItemName(material)..' and use a known recipe that still raises '..profession..'. Check the current skill-up color and supplies. Craft manually.',destination=destination}end end
 end
 return rows
end
function E.FarmSelected()
 local i=call(GetTradeSkillSelectionIndex);local materials={}
 if i and call(GetTradeSkillIsLinked)~=true then for k=1,call(GetTradeSkillNumReagents,i)or 0 do local id=E.ItemID(call(GetTradeSkillReagentItemLink,i,k));local _,_,need=call(GetTradeSkillReagentInfo,i,k);local have=id and call(GetItemCount,id)or 0;if id and need and have and need>have then materials[#materials+1]={item=id,need=need-have}end end end
 local rows={}
 for _,m in ipairs(materials)do local site=E.Nearest(E.materialSites and E.materialSites[m.item]or{});if site then rows[#rows+1]={id='material:'..m.item,kind='farm',category='Gathering',title='Collect '..m.need..' '..E.ItemName(m.item),body='Visit a personally observed source area. This position was recorded while collecting loot and is not an exact spawn point.',destination=site,materialID=m.item,requiredCount=m.need,priority=155}end end
 if #rows==0 then return false,'No verified Forever source is available for the missing materials yet.'end
 E.farmSteps=rows;ns.ProfessionGuide.Refresh();if ns.NormalUI then ns.NormalUI.Resync()end;return true
end
ns.FarmingPlanner.StartCurrent=E.FarmSelected
-- Two-way extension points accept only sourced Forever records.
function E.RegisterRoute(route)
 if type(route)~='table'or route.client~='FOREVER'or type(route.steps)~='table'then return false,'A Forever Factoruide export is required.'end
 local ids={};for _,r in ipairs(route.steps)do if not r.id or ids[r.id]or type(r.title)~='string'or not r.source then return false,'Route needs stable unique IDs, titles and provenance.'end;ids[r.id]=true end
 E.route=route.steps;ns.ForeverData.steps=E.route;return true
end

end)(ADDON,GF)
-- GF_MODULE_END Providers
-- GF_MODULE_BEGIN ProfessionRules
;(function(...)
-- Recipe choices checked against the Forever beta guides on 2026-10-28.
-- These are skill intervals, not promises of one point per craft. Live book wins.
local _,ns=...
local E,F=ns.Forever,ns.ForeverFacts;local call=E.Call
-- Named trainer locations confirmed by the Forever trainer pages; coordinates are
-- intentionally absent until independently sourced or observed in this client.
F.trainerRoster={}
local function roster(profession,faction,rows)
 for _,r in ipairs(rows)do F.trainerRoster[#F.trainerRoster+1]={name=r[1],zone=r[2],profession=profession,faction=faction,rank='Apprentice training',source='Trainer',sourceURL='https://www.wow-professions.com/forever/'..profession:lower()..'-trainers'}end
end
roster('Tailoring','Horde',{{'Snang','Orgrimmar'},{'Vhan','Thunder Bluff'},{'Victor Ward','Undercity'},{'Bowen Brisboise','Tirisfal Glades'}})
roster('Tailoring','Alliance',{{'Lawrence Schneider','Stormwind City'},{'Uthrar Threx','Ironforge'},{'Trianna','Darnassus'},{'Eldrin','Elwynn Forest'}})
roster('Tailoring','Both',{{'Othesia Evengale','Zephras Isle'},{'Taleen Shimmerthread','Zephras Isle'}})
roster('Enchanting','Horde',{{'Jhag','Orgrimmar'},{'Malcomb Wynn','Undercity'},{'Mot Dawnstrider','Thunder Bluff'},{"Pa'zula",'Durotar'},{'Vance Undergloom','Tirisfal Glades'}})
roster('Enchanting','Alliance',{{'Betty Quin','Stormwind City'},{'Thonys Pillarstone','Ironforge'},{'Lalina Summermoon','Darnassus'},{'Alanna Raveneye','Teldrassil'}})
roster('Enchanting','Both',{{'Eaysaa Brightgust','Zephras Isle'},{'Nasalanna Windsinger','Zephras Isle'}})
roster('Blacksmithing','Horde',{{"Ug'thok",'Orgrimmar'},{'Basil Frye','Undercity'},{'Thrag Stonehoof','Thunder Bluff'},{'Dwukk','Durotar'},{'Angus Hammerhand','Tirisfal Glades'}})
roster('Blacksmithing','Alliance',{{'Dane Lindgren','Stormwind City'},{'Groum Stonebeard','Ironforge'},{'Smith Argus','Elwynn Forest'},{'Tognus Flintfire','Dun Morogh'},{'Delfrum Flintbeard','Darkshore'}})
roster('Blacksmithing','Both',{{'Daeann Steelwind','Zephras Isle'},{'Aedi Thriceforged','Zephras Isle'}})
roster('Alchemy','Horde',{{'Whuut','Orgrimmar'},{'Doctor Martin Felben','Undercity'},{'Kray','Thunder Bluff'},{"Miao'zan",'Durotar'},{'Carolai Anise','Tirisfal Glades'}})
roster('Alchemy','Alliance',{{"Tel'Athir",'Stormwind City'},{'Vosur Brakthel','Ironforge'},{'Milla Fairancora','Darnassus'},{'Alchemist Mallory','Elwynn Forest'},{'Cyndra Kindwhisper','Teldrassil'}})
roster('Alchemy','Both',{{'Iaadaria Bitterwind','Zephras Isle'},{'Valiena Swiftgale','Zephras Isle'},{'Nyassa Swiftdraught','Zephras Isle'}})
F.levelingChoices={
 ['First Aid']={{1,40,'Linen Bandage'},{40,80,'Heavy Linen Bandage'},{80,115,'Wool Bandage'},{115,150,'Heavy Wool Bandage'},{150,180,'Silk Bandage'},{180,210,'Heavy Silk Bandage'},{210,225,'Mageweave Bandage'}},
 Tailoring={{1,30,'Bolt of Linen Cloth'},{30,55,'Linen Belt'},{55,80,'Bolt of Woolen Cloth'},{80,95,'Woolen Cape'},{95,100,'Double-stitched Woolen Shoulders'},{100,120,'Bolt of Silk Cloth'}},
 Enchanting={{1,2,'Runed Copper Rod'},{2,20,'Enchant Bracer - Inferior Stamina'},{20,70,'Enchant Chest - Inferior Stamina'}},
 Engineering={{1,30,'Rough Blasting Powder'},{30,50,'Handful of Copper Bolts'},{50,51,'Arclight Spanner'},{51,75,'Rough Copper Bomb'},{75,90,'Coarse Blasting Powder'},{90,100,'Coarse Dynamite'},{100,105,'Silver Contact'},{105,125,'Bronze Tube'}},
 Leatherworking={{1,30,'Light Leather'},{1,30,'Light Armor Kit'},{30,55,'Cured Light Hide'},{55,75,'Embossed Leather Gloves'},{75,80,'Medium Leather'},{80,90,'Cured Medium Hide'},{90,100,'Fine Leather Belt'},{100,115,'Light Leather Pants'}},
 Alchemy={{1,10,'Minor Arcane Elixir'},{1,10,'Elixir of Minor Force'},{10,55,'Elixir of Minor Defense'},{55,65,'Minor Mana Potion'},{65,90,'Elixir of Minor Fortitude'},{90,120,'Elixir of Wisdom'},{120,130,'Lesser Mana Potion'},{130,150,'Fire Oil'}},
 Blacksmithing={{1,25,'Rough Sharpening Stone'},{25,50,'Rough Grinding Stone'},{50,67,'Coarse Grinding Stone'},{67,75,'Runed Copper Gauntlets'},{75,80,'Runed Copper Belt'},{80,95,'Rough Bronze Leggings'},{95,100,'Patterned Bronze Bracers'}},
}
F.professionNotes={
 Enchanting='Early recipes use Mote of Magic in Forever. Buy rod supplies from a confirmed Enchanting supplier; confirm required reagents in your recipe book.',
 Engineering='Forever Gnome Engineering Specialization reduces failures/backfires; it does not add 15 skill.',
 ['First Aid']='Healing potions belong to First Aid in Forever. Keep cloth needed by both First Aid and Tailoring.',
 Fishing='Assume a basic Fishing Pole and no lure. Use only a documented or personally observed accessible fishery; retain useful fish for known Cooking recipes.',
}
function E.CraftingCatchup(state,route)
 local rows={};local goals=E.db and E.db.professionGoals or{}
 for _,step in ipairs(route or{})do for profession,target in pairs(step.professionTargets or{})do if not goals[profession]or target>goals[profession]then goals[profession]=target end end end
 for profession,skill in pairs(state.skills)do
  local goal=goals[profession];if E.db and E.db.pace=='Relaxed'and not goal then goal=math.min(skill.cap or skill.rank,skill.rank+5)end
  if goal and skill.rank<goal then
   for _,choice in ipairs(F.levelingChoices[profession]or{})do if skill.rank>=choice[1]and skill.rank<choice[2]then
    local recipe;for _,r in pairs(E.recipes)do if r.profession==profession and r.name==choice[3]and E.Known(r)==true then recipe=r;break end end
    if recipe and next(recipe.reagents or{})then local enough=true;local parts={}
     for material,quantity in pairs(recipe.reagents)do local have=call(GetItemCount,material)or 0;if have<quantity then enough=false end;parts[#parts+1]=quantity..' '..E.ItemName(material)end
     if enough then
      local tools=profession=='Blacksmithing'or profession=='Engineering';local nearby=not tools
      if tools then for _,trainer in pairs(E.trainers)do local d=E.Distance(state.position,trainer);if d and d<=40 and trainer.profession==profession and trainer.toolsObserved then nearby=true end end end
      if nearby then rows[#rows+1]={id='craftcatchup:'..profession,kind='profession',category='Crafting',profession=profession,profession=profession,title='Practice '..profession..': '..recipe.name,body='Current skill '..skill.rank..'; next route goal '..goal..'.\nUse your known '..recipe.name..' recipe manually while it still awards skill.\nOne craft uses '..table.concat(parts,', ')..'.\n'..(F.professionNotes[profession]or''),lowAttention=true,targetSkill=goal,source=F.professionSources[profession]};break end
     end
    end
   end end
  end
 end
 return rows
end

end)(ADDON,GF)
-- GF_MODULE_END ProfessionRules
;(function(...)
local _,ns=...;local E,F=ns.Forever,ns.ForeverFacts;local call=E.Call

-- Classic acquisition leads from the already bundled LibProfessionDB; live Forever observations take precedence.
--[[
MIT License

Copyright (c) 2026 Pimptasty

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]]
local baseline={{["spellID"]=7428,["name"]="Enchant Bracer - Minor Deflection",["profession"]="Enchanting",["requiredSkill"]=20,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=7732,["itemId"]=16083,["name"]="Fishing",["profession"]="Fishing",["requiredSkill"]=125,["refs"]={{2626,"Old Man Heming","Vendor"}}},{["spellID"]=7924,["itemId"]=16084,["name"]="First Aid",["profession"]="First Aid",["requiredSkill"]=125,["refs"]={{2805,"Deneb Walker","Vendor"}}},{["spellID"]=8776,["name"]="Linen Belt",["profession"]="Tailoring",["requiredSkill"]=15,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=2331,["name"]="Minor Mana Potion",["profession"]="Alchemy",["requiredSkill"]=25,["refs"]={{3009,"Bena Winterhoof","Trainer"},{1215,"Alchemist Mallory","Trainer"},{1386,"Rogvar","Trainer"},{2132,"Carolai Anise","Trainer"},{3347,"Yelmak","Trainer"},{2391,"Serge Hinott","Trainer"},{3603,"Cyndra Kindwhisper","Trainer"},{1470,"Ghak Healtouch","Trainer"},{2837,"Jaxin Chong","Trainer"},{4160,"Ainethil","Trainer"},{3964,"Kylanna","Trainer"}}},{["spellID"]=13607,["name"]="Enchant Chest - Mana",["profession"]="Enchanting",["requiredSkill"]=145,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=2395,["name"]="Barbaric Linen Vest",["profession"]="Tailoring",["requiredSkill"]=70,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=2539,["name"]="Spiced Wolf Meat",["profession"]="Cooking",["requiredSkill"]=10,["refs"]={{3067,"Pyall Silentstride","Trainer"},{1355,"Cook Ghilm","Trainer"},{1382,"Mudduk","Trainer"},{1699,"Gremlock Pilsnor","Trainer"},{3087,"Crystal Boughman","Trainer"},{3399,"Zamja","Trainer"},{2818,"Slagg","Trainer"},{4210,"Alegorn","Trainer"},{1430,"Tomas","Trainer"},{3026,"Aska Mistrunner","Trainer"},{4894,"Craig Nollward","Trainer"},{4552,"Eunice Burch","Trainer"}}},{["spellID"]=2547,["itemId"]=2699,["name"]="Redridge Goulash",["profession"]="Cooking",["requiredSkill"]=100,["refs"]={{340,"Kendor Kabonka","Vendor"}}},{["spellID"]=2675,["name"]="Shining Silver Breastplate",["profession"]="Blacksmithing",["requiredSkill"]=145,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=2739,["name"]="Copper Shortsword",["profession"]="Blacksmithing",["requiredSkill"]=25,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=2795,["itemId"]=2889,["name"]="Beer Basted Boar Ribs",["profession"]="Cooking",["requiredSkill"]=10,["refs"]={{340,"Kendor Kabonka","Vendor"},{2880,"[UNUSED] Hurom Juggendolf","Trainer"}}},{["spellID"]=12584,["name"]="Gold Power Core",["profession"]="Engineering",["requiredSkill"]=150,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3171,["name"]="Elixir of Wisdom",["profession"]="Alchemy",["requiredSkill"]=90,["refs"]={{3009,"Bena Winterhoof","Trainer"},{1215,"Alchemist Mallory","Trainer"},{1386,"Rogvar","Trainer"},{2132,"Carolai Anise","Trainer"},{3347,"Yelmak","Trainer"},{2391,"Serge Hinott","Trainer"},{3603,"Cyndra Kindwhisper","Trainer"},{1470,"Ghak Healtouch","Trainer"},{2837,"Jaxin Chong","Trainer"},{4160,"Ainethil","Trainer"},{3964,"Kylanna","Trainer"}}},{["spellID"]=6501,["itemId"]=5528,["name"]="Clam Chowder",["profession"]="Cooking",["requiredSkill"]=90,["refs"]={{4305,"Kriggon Talsone","Vendor"},{4307,"Heldan Galesong","Vendor"}}},{["spellID"]=6517,["name"]="Pearl-handled Dagger",["profession"]="Blacksmithing",["requiredSkill"]=110,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=9065,["name"]="Light Leather Bracers",["profession"]="Leatherworking",["requiredSkill"]=70,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=3307,["name"]="Smelt Iron",["profession"]="Mining",["requiredSkill"]=125,["refs"]={{3555,"Johan Focht","Trainer"},{1681,"Brock Stoneseeker","Trainer"},{1701,"Dank Drizzlecut","Trainer"},{3137,"Matt Johnson","Trainer"},{4254,"Geofram Bouldertoe","Trainer"},{4598,"Brom Killian","Trainer"},{3175,"Krunn","Trainer"},{5392,"Yarr Hammerstone","Trainer"},{3001,"Brek Stonehoof","Trainer"},{3357,"Makaru","Trainer"},{6297,"Kurdram Stonehammer","Trainer"},{5513,"Gelman Stonehand","Trainer"}}},{["spellID"]=9193,["name"]="Heavy Quiver",["profession"]="Leatherworking",["requiredSkill"]=150,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=3371,["itemId"]=3679,["name"]="Blood Sausage",["profession"]="Cooking",["requiredSkill"]=60,["refs"]={{340,"Kendor Kabonka","Vendor"}}},{["spellID"]=9513,["itemId"]=7678,["name"]="Thistle Tea",["profession"]="Cooking",["requiredSkill"]=60,["refs"]={{6779,"Smudge Thunderwood","Vendor"}}},{["spellID"]=3491,["name"]="Big Bronze Knife",["profession"]="Blacksmithing",["requiredSkill"]=105,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=3755,["name"]="Linen Bag",["profession"]="Tailoring",["requiredSkill"]=45,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=3763,["name"]="Fine Leather Belt",["profession"]="Leatherworking",["requiredSkill"]=80,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=3843,["name"]="Heavy Woolen Gloves",["profession"]="Tailoring",["requiredSkill"]=85,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=3859,["name"]="Azure Silk Vest",["profession"]="Tailoring",["requiredSkill"]=150,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=3915,["name"]="Brown Linen Shirt",["profession"]="Tailoring",["requiredSkill"]=1,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=3931,["name"]="Coarse Dynamite",["profession"]="Engineering",["requiredSkill"]=75,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3939,["itemId"]=13309,["name"]="Lovingly Crafted Boomstick",["profession"]="Engineering",["requiredSkill"]=120,["refs"]={{2682,"Fradd Swiftgear","Vendor"},{6730,"Jinky Twizzlefixxit","Vendor"},{8736,"Buzzek Bracketswing","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{11025,"Mukdrak","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5518,"Lilliam Sparkspindle","Trainer"},{16667,"Danwe","Trainer"},{11037,"Jenna Lemkenilli","Trainer"}}},{["spellID"]=3947,["name"]="Crafted Solid Shot",["profession"]="Engineering",["requiredSkill"]=125,["refs"]={{8736,"Buzzek Bracketswing","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{11017,"Roxxik","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11025,"Mukdrak","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5518,"Lilliam Sparkspindle","Trainer"},{11037,"Jenna Lemkenilli","Trainer"},{11031,"Franklin Lloyd","Trainer"}}},{["spellID"]=3955,["name"]="Explosive Sheep",["profession"]="Engineering",["requiredSkill"]=150,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=9194,["name"]="Heavy Leather Ammo Pouch",["profession"]="Leatherworking",["requiredSkill"]=150,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=19666,["name"]="Silver Skeleton Key",["profession"]="Blacksmithing",["requiredSkill"]=100,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=7430,["name"]="Arclight Spanner",["profession"]="Engineering",["requiredSkill"]=50,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=19667,["name"]="Golden Skeleton Key",["profession"]="Blacksmithing",["requiredSkill"]=150,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=9068,["name"]="Light Leather Pants",["profession"]="Leatherworking",["requiredSkill"]=95,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=2332,["name"]="Minor Rejuvenation Potion",["profession"]="Alchemy",["requiredSkill"]=40,["refs"]={{3009,"Bena Winterhoof","Trainer"},{1215,"Alchemist Mallory","Trainer"},{1386,"Rogvar","Trainer"},{2132,"Carolai Anise","Trainer"},{3347,"Yelmak","Trainer"},{2391,"Serge Hinott","Trainer"},{3603,"Cyndra Kindwhisper","Trainer"},{1470,"Ghak Healtouch","Trainer"},{2837,"Jaxin Chong","Trainer"},{4160,"Ainethil","Trainer"},{3964,"Kylanna","Trainer"}}},{["spellID"]=2396,["name"]="Green Linen Shirt",["profession"]="Tailoring",["requiredSkill"]=70,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=2548,["itemId"]=2700,["name"]="Succulent Pork Ribs",["profession"]="Cooking",["requiredSkill"]=110,["refs"]={{340,"Kendor Kabonka","Vendor"}}},{["spellID"]=14379,["name"]="Golden Rod",["profession"]="Blacksmithing",["requiredSkill"]=150,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=2668,["name"]="Rough Bronze Leggings",["profession"]="Blacksmithing",["requiredSkill"]=105,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=2740,["name"]="Bronze Mace",["profession"]="Blacksmithing",["requiredSkill"]=110,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=2964,["name"]="Bolt of Woolen Cloth",["profession"]="Tailoring",["requiredSkill"]=75,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=3116,["name"]="Coarse Weightstone",["profession"]="Blacksmithing",["requiredSkill"]=65,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=3276,["name"]="Heavy Linen Bandage",["profession"]="First Aid",["requiredSkill"]=40,["refs"]={{4211,"Dannelor","Trainer"},{2326,"Thamner Pol","Trainer"},{2327,"Shaina Fuller","Trainer"},{2798,"Pand Stonebinder","Trainer"},{4591,"Mary Edras","Trainer"},{5150,"Nissa Firestone","Trainer"},{3181,"Fremal Doohickey","Trainer"},{5759,"Nurse Neela","Trainer"},{2329,"Michelle Belle","Trainer"},{3373,"Arnok","Trainer"},{5943,"Rawrk","Trainer"},{5939,"Vira Younghoof","Trainer"}}},{["spellID"]=3292,["name"]="Heavy Copper Broadsword",["profession"]="Blacksmithing",["requiredSkill"]=95,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=3372,["itemId"]=3680,["name"]="Murloc Fin Soup",["profession"]="Cooking",["requiredSkill"]=90,["refs"]={{340,"Kendor Kabonka","Vendor"}}},{["spellID"]=7255,["itemId"]=6053,["name"]="Holy Protection Potion",["profession"]="Alchemy",["requiredSkill"]=100,["refs"]={{1685,"Xandar Goodbeard","Vendor"},{3134,"Kzixx","Vendor"}}},{["spellID"]=3756,["name"]="Embossed Leather Gloves",["profession"]="Leatherworking",["requiredSkill"]=55,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=3764,["name"]="Hillman's Leather Gloves",["profession"]="Leatherworking",["requiredSkill"]=145,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=3780,["name"]="Heavy Armor Kit",["profession"]="Leatherworking",["requiredSkill"]=150,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=3852,["name"]="Gloves of Meditation",["profession"]="Tailoring",["requiredSkill"]=130,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=7751,["itemId"]=6325,["name"]="Brilliant Smallfish",["profession"]="Cooking",["requiredSkill"]=1,["refs"]={{5494,"Catherine Leland","Vendor"},{66,"Tharynn Bouden","Vendor"},{1684,"Khara Deepwater","Vendor"},{3550,"Martine Tramblay","Vendor"},{5940,"Harn Longcast","Vendor"},{8508,"Gretta Ganter","Vendor"},{4265,"Nyoma","Vendor"},{3029,"Sewa Mistrunner","Vendor"},{4574,"Lizbeth Cromwell","Vendor"}}},{["spellID"]=3932,["name"]="Target Dummy",["profession"]="Engineering",["requiredSkill"]=85,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3956,["name"]="Green Tinted Goggles",["profession"]="Engineering",["requiredSkill"]=150,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=12045,["name"]="Simple Linen Boots",["profession"]="Tailoring",["requiredSkill"]=20,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=8334,["name"]="Practice Lock",["profession"]="Engineering",["requiredSkill"]=100,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=21143,["itemId"]=17200,["name"]="Gingerbread Cookie",["profession"]="Cooking",["requiredSkill"]=1,["refs"]={{13429,"Nardstrum Copperpinch","Vendor"},{13432,"Seersa Copperpinch","Vendor"},{13420,"Penney Copperpinch","Vendor"},{13433,"Wulmort Jinglepocket","Vendor"},{13435,"Khole Jinglepocket","Vendor"}}},{["spellID"]=9070,["itemId"]=7289,["name"]="Black Whelp Cloak",["profession"]="Leatherworking",["requiredSkill"]=100,["refs"]={{2697,"Clyde Ranthal","Vendor"}}},{["spellID"]=13421,["name"]="Enchant Cloak - Lesser Protection",["profession"]="Enchanting",["requiredSkill"]=115,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=21144,["itemId"]=17201,["name"]="Egg Nog",["profession"]="Cooking",["requiredSkill"]=35,["refs"]={{13429,"Nardstrum Copperpinch","Vendor"},{13432,"Seersa Copperpinch","Vendor"},{13420,"Penney Copperpinch","Vendor"},{13433,"Wulmort Jinglepocket","Vendor"},{13435,"Khole Jinglepocket","Vendor"}}},{["spellID"]=15853,["itemId"]=12227,["name"]="Lean Wolf Steak",["profession"]="Cooking",["requiredSkill"]=125,["refs"]={{12246,"Super-Seller 680","Vendor"}}},{["spellID"]=12046,["name"]="Simple Kilt",["profession"]="Tailoring",["requiredSkill"]=75,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=7256,["itemId"]=6054,["name"]="Shadow Protection Potion",["profession"]="Alchemy",["requiredSkill"]=135,["refs"]={{2393,"Christoph Jeffcoat","Vendor"},{3956,"Harklan Moongrove","Vendor"}}},{["spellID"]=7624,["name"]="White Linen Robe",["profession"]="Tailoring",["requiredSkill"]=30,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=7752,["itemId"]=6326,["name"]="Slitherskin Mackerel",["profession"]="Cooking",["requiredSkill"]=1,["refs"]={{4305,"Kriggon Talsone","Vendor"},{5162,"Tansy Puddlefizz","Vendor"},{3550,"Martine Tramblay","Vendor"},{5942,"Zansoa","Vendor"},{10118,"Nessa Shadowsong","Vendor"}}},{["spellID"]=23066,["itemId"]=18647,["name"]="Red Firework",["profession"]="Engineering",["requiredSkill"]=150,["refs"]={{3413,"Sovik","Vendor"}}},{["spellID"]=7928,["name"]="Silk Bandage",["profession"]="First Aid",["requiredSkill"]=150,["refs"]={{4211,"Dannelor","Trainer"},{2326,"Thamner Pol","Trainer"},{2327,"Shaina Fuller","Trainer"},{2798,"Pand Stonebinder","Trainer"},{4591,"Mary Edras","Trainer"},{5150,"Nissa Firestone","Trainer"},{3181,"Fremal Doohickey","Trainer"},{5759,"Nurse Neela","Trainer"},{2329,"Michelle Belle","Trainer"},{3373,"Arnok","Trainer"},{5943,"Rawrk","Trainer"},{5939,"Vira Younghoof","Trainer"}}},{["spellID"]=2165,["name"]="Medium Armor Kit",["profession"]="Leatherworking",["requiredSkill"]=100,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=8880,["name"]="Copper Dagger",["profession"]="Blacksmithing",["requiredSkill"]=30,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=9072,["itemId"]=7290,["name"]="Red Whelp Gloves",["profession"]="Leatherworking",["requiredSkill"]=120,["refs"]={{2679,"Wenna Silkbeard","Vendor"}}},{["spellID"]=23067,["itemId"]=18649,["name"]="Blue Firework",["profession"]="Engineering",["requiredSkill"]=150,["refs"]={{1304,"Darian Singh","Vendor"},{5175,"Gearcutter Cogspinner","Vendor"}}},{["spellID"]=2397,["name"]="Reinforced Linen Cape",["profession"]="Tailoring",["requiredSkill"]=60,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=2541,["name"]="Coyote Steak",["profession"]="Cooking",["requiredSkill"]=50,["refs"]={{3067,"Pyall Silentstride","Trainer"},{1355,"Cook Ghilm","Trainer"},{1382,"Mudduk","Trainer"},{1699,"Gremlock Pilsnor","Trainer"},{3087,"Crystal Boughman","Trainer"},{3399,"Zamja","Trainer"},{2818,"Slagg","Trainer"},{4210,"Alegorn","Trainer"},{1430,"Tomas","Trainer"},{3026,"Aska Mistrunner","Trainer"},{4894,"Craig Nollward","Trainer"},{4552,"Eunice Burch","Trainer"}}},{["spellID"]=2549,["itemId"]=2701,["name"]="Seasoned Wolf Kabob",["profession"]="Cooking",["requiredSkill"]=100,["refs"]={{340,"Kendor Kabonka","Vendor"}}},{["spellID"]=2661,["name"]="Copper Chain Belt",["profession"]="Blacksmithing",["requiredSkill"]=35,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=23068,["itemId"]=18648,["name"]="Green Firework",["profession"]="Engineering",["requiredSkill"]=150,["refs"]={{2838,"Crazk Sparks","Vendor"},{3495,"Gagsprocket","Vendor"}}},{["spellID"]=3117,["name"]="Heavy Weightstone",["profession"]="Blacksmithing",["requiredSkill"]=125,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=8465,["name"]="Simple Dress",["profession"]="Tailoring",["requiredSkill"]=40,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=6521,["name"]="Pearl-clasped Cloak",["profession"]="Tailoring",["requiredSkill"]=90,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=3277,["name"]="Wool Bandage",["profession"]="First Aid",["requiredSkill"]=80,["refs"]={{4211,"Dannelor","Trainer"},{2326,"Thamner Pol","Trainer"},{2327,"Shaina Fuller","Trainer"},{2798,"Pand Stonebinder","Trainer"},{4591,"Mary Edras","Trainer"},{5150,"Nissa Firestone","Trainer"},{3181,"Fremal Doohickey","Trainer"},{5759,"Nurse Neela","Trainer"},{2329,"Michelle Belle","Trainer"},{3373,"Arnok","Trainer"},{5943,"Rawrk","Trainer"},{5939,"Vira Younghoof","Trainer"}}},{["spellID"]=3293,["name"]="Copper Battle Axe",["profession"]="Blacksmithing",["requiredSkill"]=35,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=6617,["itemId"]=5640,["name"]="Rage Potion",["profession"]="Alchemy",["requiredSkill"]=60,["refs"]={{1669,"Defias Profiteer","Vendor"},{1685,"Xandar Goodbeard","Vendor"},{3499,"Ranik","Vendor"},{3335,"Hagrus","Vendor"}}},{["spellID"]=3333,["name"]="Silvered Bronze Gauntlets",["profession"]="Blacksmithing",["requiredSkill"]=135,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=3373,["itemId"]=3681,["name"]="Crocolisk Gumbo",["profession"]="Cooking",["requiredSkill"]=120,["refs"]={{340,"Kendor Kabonka","Vendor"}}},{["spellID"]=3397,["itemId"]=3734,["name"]="Big Bear Steak",["profession"]="Cooking",["requiredSkill"]=110,["refs"]={{3960,"Ulthaan","Vendor"},{12246,"Super-Seller 680","Vendor"}}},{["spellID"]=3413,["itemId"]=16072,["name"]="Cooking",["profession"]="Cooking",["requiredSkill"]=125,["refs"]={{12033,"Wulan","Vendor"}}},{["spellID"]=3757,["name"]="Woolen Bag",["profession"]="Tailoring",["requiredSkill"]=80,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=3813,["name"]="Small Silk Pack",["profession"]="Tailoring",["requiredSkill"]=150,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=3845,["name"]="Soft-soled Linen Boots",["profession"]="Tailoring",["requiredSkill"]=80,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=3869,["itemId"]=14627,["name"]="Bright Yellow Shirt",["profession"]="Tailoring",["requiredSkill"]=135,["refs"]={{2668,"Danielle Zipstitch","Vendor"}}},{["spellID"]=7753,["itemId"]=6328,["name"]="Longjaw Mud Snapper",["profession"]="Cooking",["requiredSkill"]=50,["refs"]={{5162,"Tansy Puddlefizz","Vendor"},{1684,"Khara Deepwater","Vendor"},{5940,"Harn Longcast","Vendor"},{3027,"Naal Mistrunner","Vendor"},{66,"Tharynn Bouden","Vendor"},{4265,"Nyoma","Vendor"},{4574,"Lizbeth Cromwell","Vendor"},{5748,"Killian Sanatha","Vendor"}}},{["spellID"]=3941,["name"]="Small Bronze Bomb",["profession"]="Engineering",["requiredSkill"]=120,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3949,["name"]="Silver-plated Shotgun",["profession"]="Engineering",["requiredSkill"]=130,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3973,["name"]="Silver Contact",["profession"]="Engineering",["requiredSkill"]=90,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=9074,["name"]="Nimble Leather Gloves",["profession"]="Leatherworking",["requiredSkill"]=120,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=6458,["name"]="Ornate Spyglass",["profession"]="Engineering",["requiredSkill"]=135,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=7754,["itemId"]=6329,["name"]="Loch Frenzy Delight",["profession"]="Cooking",["requiredSkill"]=50,["refs"]={{1684,"Khara Deepwater","Vendor"}}},{["spellID"]=7818,["name"]="Silver Rod",["profession"]="Blacksmithing",["requiredSkill"]=100,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=2166,["name"]="Toughened Leather Armor",["profession"]="Leatherworking",["requiredSkill"]=120,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=2334,["name"]="Elixir of Minor Fortitude",["profession"]="Alchemy",["requiredSkill"]=50,["refs"]={{3009,"Bena Winterhoof","Trainer"},{1215,"Alchemist Mallory","Trainer"},{1386,"Rogvar","Trainer"},{2132,"Carolai Anise","Trainer"},{3347,"Yelmak","Trainer"},{2391,"Serge Hinott","Trainer"},{3603,"Cyndra Kindwhisper","Trainer"},{1470,"Ghak Healtouch","Trainer"},{2837,"Jaxin Chong","Trainer"},{4160,"Ainethil","Trainer"},{3964,"Kylanna","Trainer"}}},{["spellID"]=2406,["name"]="Gray Woolen Shirt",["profession"]="Tailoring",["requiredSkill"]=100,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=2542,["itemId"]=2697,["name"]="Goretusk Liver Pie",["profession"]="Cooking",["requiredSkill"]=50,["refs"]={{340,"Kendor Kabonka","Vendor"}}},{["spellID"]=2662,["name"]="Copper Chain Pants",["profession"]="Blacksmithing",["requiredSkill"]=1,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=2670,["name"]="Rough Bronze Cuirass",["profession"]="Blacksmithing",["requiredSkill"]=105,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=2742,["name"]="Bronze Shortsword",["profession"]="Blacksmithing",["requiredSkill"]=120,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=25124,["itemId"]=20758,["name"]="Minor Wizard Oil",["profession"]="Enchanting",["requiredSkill"]=45,["refs"]={{5757,"Lilly","Vendor"},{1318,"Jessara Cordell","Vendor"},{3012,"Nata Dawnstrider","Vendor"},{4228,"Vaean","Vendor"},{5758,"Leo Sarn","Vendor"},{15419,"Kania","Vendor"},{4617,"Thaddeus Webb","Vendor"},{16635,"Lyna","Vendor"},{3346,"Kithas","Vendor"},{5158,"Tilli Thistlefuzz","Vendor"},{16722,"Egomis","Vendor"}}},{["spellID"]=3294,["name"]="Thick War Axe",["profession"]="Blacksmithing",["requiredSkill"]=70,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=3326,["name"]="Coarse Grinding Stone",["profession"]="Blacksmithing",["requiredSkill"]=75,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=9269,["itemId"]=7560,["name"]="Gnomish Universal Remote",["profession"]="Engineering",["requiredSkill"]=125,["refs"]={{5175,"Gearcutter Cogspinner","Vendor"},{6730,"Jinky Twizzlefixxit","Vendor"}}},{["spellID"]=3398,["itemId"]=3735,["name"]="Hot Lion Chops",["profession"]="Cooking",["requiredSkill"]=125,["refs"]={{3489,"Zargh","Vendor"},{12245,"Vendor-Tron 1000","Vendor"}}},{["spellID"]=7179,["name"]="Elixir of Water Breathing",["profession"]="Alchemy",["requiredSkill"]=90,["refs"]={{3009,"Bena Winterhoof","Trainer"},{1215,"Alchemist Mallory","Trainer"},{1386,"Rogvar","Trainer"},{2132,"Carolai Anise","Trainer"},{3347,"Yelmak","Trainer"},{2391,"Serge Hinott","Trainer"},{3603,"Cyndra Kindwhisper","Trainer"},{1470,"Ghak Healtouch","Trainer"},{2837,"Jaxin Chong","Trainer"},{4160,"Ainethil","Trainer"},{3964,"Kylanna","Trainer"}}},{["spellID"]=25125,["itemId"]=20752,["name"]="Minor Mana Oil",["profession"]="Enchanting",["requiredSkill"]=150,["refs"]={{5757,"Lilly","Vendor"},{1318,"Jessara Cordell","Vendor"},{3012,"Nata Dawnstrider","Vendor"},{4228,"Vaean","Vendor"},{5758,"Leo Sarn","Vendor"},{15419,"Kania","Vendor"},{4617,"Thaddeus Webb","Vendor"},{16635,"Lyna","Vendor"},{3346,"Kithas","Vendor"},{5158,"Tilli Thistlefuzz","Vendor"},{16722,"Egomis","Vendor"}}},{["spellID"]=3766,["name"]="Dark Leather Belt",["profession"]="Leatherworking",["requiredSkill"]=125,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=7643,["itemId"]=6275,["name"]="Greater Adept's Robe",["profession"]="Tailoring",["requiredSkill"]=115,["refs"]={{4577,"Millie Gregorian","Vendor"},{1474,"Rann Flamespinner","Vendor"},{2669,"Sheri Zipstitch","Vendor"},{1454,"Jennabink Powerseam","Vendor"},{3499,"Ranik","Vendor"},{4168,"Elynna","Vendor"}}},{["spellID"]=7755,["itemId"]=6330,["name"]="Bristle Whisker Catfish",["profession"]="Cooking",["requiredSkill"]=100,["refs"]={{4553,"Ronald Burch","Vendor"},{2397,"Derak Nightfall","Vendor"},{3027,"Naal Mistrunner","Vendor"},{2383,"Lindea Rabonne","Vendor"},{3029,"Sewa Mistrunner","Vendor"},{3497,"Kilxx","Vendor"},{5494,"Catherine Leland","Vendor"}}},{["spellID"]=3926,["name"]="Copper Modulator",["profession"]="Engineering",["requiredSkill"]=65,["refs"]={{8736,"Buzzek Bracketswing","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{11017,"Roxxik","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11025,"Mukdrak","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5518,"Lilliam Sparkspindle","Trainer"},{11037,"Jenna Lemkenilli","Trainer"},{11031,"Franklin Lloyd","Trainer"}}},{["spellID"]=3934,["name"]="Flying Tiger Goggles",["profession"]="Engineering",["requiredSkill"]=100,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3942,["name"]="Whirring Bronze Gizmo",["profession"]="Engineering",["requiredSkill"]=125,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3950,["name"]="Big Bronze Bomb",["profession"]="Engineering",["requiredSkill"]=140,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=8758,["name"]="Azure Silk Pants",["profession"]="Tailoring",["requiredSkill"]=140,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=20648,["name"]="Medium Leather",["profession"]="Leatherworking",["requiredSkill"]=100,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=20649,["name"]="Heavy Leather",["profession"]="Leatherworking",["requiredSkill"]=150,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=6412,["itemId"]=5482,["name"]="Kaldorei Spider Kabob",["profession"]="Cooking",["requiredSkill"]=10,["refs"]={{3087,"Crystal Boughman","Trainer"},{1355,"Cook Ghilm","Trainer"},{1382,"Mudduk","Trainer"},{1699,"Gremlock Pilsnor","Trainer"},{3399,"Zamja","Trainer"},{4210,"Alegorn","Trainer"},{2818,"Slagg","Trainer"},{4552,"Eunice Burch","Trainer"},{1430,"Tomas","Trainer"},{3067,"Pyall Silentstride","Trainer"},{5159,"Daryl Riknussun","Trainer"},{4894,"Craig Nollward","Trainer"}}},{["spellID"]=25704,["itemId"]=21099,["name"]="Smoked Sagefish",["profession"]="Cooking",["requiredSkill"]=80,["refs"]={{4223,"Fyldan","Vendor"},{2381,"Micha Yance","Vendor"},{2397,"Derak Nightfall","Vendor"},{3027,"Naal Mistrunner","Vendor"},{4265,"Nyoma","Vendor"},{4553,"Ronald Burch","Vendor"},{3085,"Gloria Femmel","Vendor"},{4894,"Craig Nollward","Vendor"},{2664,"Kelsey Yance","Vendor"},{5483,"Erika Tate","Vendor"},{5160,"Emrul Riknussun","Vendor"}}},{["spellID"]=2159,["name"]="Fine Leather Cloak",["profession"]="Leatherworking",["requiredSkill"]=85,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=2167,["name"]="Dark Leather Boots",["profession"]="Leatherworking",["requiredSkill"]=100,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=8760,["name"]="Azure Silk Hood",["profession"]="Tailoring",["requiredSkill"]=145,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=2399,["name"]="Green Woolen Vest",["profession"]="Tailoring",["requiredSkill"]=85,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=2543,["itemId"]=728,["name"]="Westfall Stew",["profession"]="Cooking",["requiredSkill"]=75,["refs"]={{340,"Kendor Kabonka","Vendor"}}},{["spellID"]=28267,["itemId"]=22647,["name"]="Crunchy Spider Surprise",["profession"]="Cooking",["requiredSkill"]=60,["refs"]={{16253,"Master Chef Mouldier","Vendor"}}},{["spellID"]=24940,["itemId"]=20576,["name"]="Black Whelp Tunic",["profession"]="Leatherworking",["requiredSkill"]=100,["refs"]={{777,"Amy Davenport","Vendor"}}},{["spellID"]=6413,["itemId"]=5483,["name"]="Scorpid Surprise",["profession"]="Cooking",["requiredSkill"]=20,["refs"]={{3881,"Grimtak","Vendor"}}},{["spellID"]=9145,["name"]="Fletcher's Gloves",["profession"]="Leatherworking",["requiredSkill"]=125,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=3319,["name"]="Copper Chain Boots",["profession"]="Blacksmithing",["requiredSkill"]=20,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=3399,["itemId"]=3736,["name"]="Tasty Lion Steak",["profession"]="Cooking",["requiredSkill"]=150,["refs"]={{3087,"Crystal Boughman","Trainer"},{1355,"Cook Ghilm","Trainer"},{1382,"Mudduk","Trainer"},{1699,"Gremlock Pilsnor","Trainer"},{3399,"Zamja","Trainer"},{4210,"Alegorn","Trainer"},{2818,"Slagg","Trainer"},{4552,"Eunice Burch","Trainer"},{1430,"Tomas","Trainer"},{3067,"Pyall Silentstride","Trainer"},{5159,"Daryl Riknussun","Trainer"},{4894,"Craig Nollward","Trainer"}}},{["spellID"]=3447,["name"]="Healing Potion",["profession"]="Alchemy",["requiredSkill"]=110,["refs"]={{3009,"Bena Winterhoof","Trainer"},{1215,"Alchemist Mallory","Trainer"},{1386,"Rogvar","Trainer"},{2132,"Carolai Anise","Trainer"},{3347,"Yelmak","Trainer"},{2391,"Serge Hinott","Trainer"},{3603,"Cyndra Kindwhisper","Trainer"},{1470,"Ghak Healtouch","Trainer"},{2837,"Jaxin Chong","Trainer"},{4160,"Ainethil","Trainer"},{3964,"Kylanna","Trainer"}}},{["spellID"]=3759,["name"]="Embossed Leather Pants",["profession"]="Leatherworking",["requiredSkill"]=75,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=3839,["name"]="Bolt of Silk Cloth",["profession"]="Tailoring",["requiredSkill"]=125,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=3855,["name"]="Spidersilk Boots",["profession"]="Tailoring",["requiredSkill"]=125,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=9146,["itemId"]=7361,["name"]="Herbalist's Gloves",["profession"]="Leatherworking",["requiredSkill"]=135,["refs"]={{6731,"Harlown Darkweave","Vendor"}}},{["spellID"]=6414,["itemId"]=5484,["name"]="Roasted Kodo Meat",["profession"]="Cooking",["requiredSkill"]=35,["refs"]={{3081,"Wunna Darkmane","Vendor"}}},{["spellID"]=9147,["itemId"]=7362,["name"]="Earthen Leather Shoulders",["profession"]="Leatherworking",["requiredSkill"]=135,["refs"]={{3537,"Zixil","Vendor"}}},{["spellID"]=6686,["itemId"]=5771,["name"]="Red Linen Bag",["profession"]="Tailoring",["requiredSkill"]=70,["refs"]={{3005,"Mahu","Vendor"},{3556,"Andrew Hilbert","Vendor"},{843,"Gina MacGregor","Vendor"},{4189,"Valdaron","Vendor"},{16224,"Rathis Tomber","Vendor"}}},{["spellID"]=6702,["itemId"]=5786,["name"]="Murloc Scale Belt",["profession"]="Leatherworking",["requiredSkill"]=90,["refs"]={{843,"Gina MacGregor","Vendor"},{3556,"Andrew Hilbert","Vendor"},{4186,"Mavralyn","Vendor"}}},{["spellID"]=7454,["name"]="Enchant Cloak - Minor Resistance",["profession"]="Enchanting",["requiredSkill"]=45,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=7934,["name"]="Anti-Venom",["profession"]="First Aid",["requiredSkill"]=80,["refs"]={{4211,"Dannelor","Trainer"},{2326,"Thamner Pol","Trainer"},{2327,"Shaina Fuller","Trainer"},{2798,"Pand Stonebinder","Trainer"},{4591,"Mary Edras","Trainer"},{5150,"Nissa Firestone","Trainer"},{3181,"Fremal Doohickey","Trainer"},{5759,"Nurse Neela","Trainer"},{2329,"Michelle Belle","Trainer"},{3373,"Arnok","Trainer"},{5943,"Rawrk","Trainer"},{5939,"Vira Younghoof","Trainer"}}},{["spellID"]=2160,["name"]="Embossed Leather Vest",["profession"]="Leatherworking",["requiredSkill"]=40,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=2168,["name"]="Dark Leather Cloak",["profession"]="Leatherworking",["requiredSkill"]=110,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=2392,["name"]="Red Linen Shirt",["profession"]="Tailoring",["requiredSkill"]=40,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=2544,["name"]="Crab Cake",["profession"]="Cooking",["requiredSkill"]=75,["refs"]={{3067,"Pyall Silentstride","Trainer"},{1355,"Cook Ghilm","Trainer"},{1382,"Mudduk","Trainer"},{1699,"Gremlock Pilsnor","Trainer"},{3087,"Crystal Boughman","Trainer"},{3399,"Zamja","Trainer"},{2818,"Slagg","Trainer"},{4210,"Alegorn","Trainer"},{1430,"Tomas","Trainer"},{3026,"Aska Mistrunner","Trainer"},{4894,"Craig Nollward","Trainer"},{4552,"Eunice Burch","Trainer"}}},{["spellID"]=2664,["name"]="Runed Copper Bracers",["profession"]="Blacksmithing",["requiredSkill"]=90,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=2672,["name"]="Patterned Bronze Bracers",["profession"]="Blacksmithing",["requiredSkill"]=120,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=3176,["name"]="Strong Troll's Blood Potion",["profession"]="Alchemy",["requiredSkill"]=125,["refs"]={{3009,"Bena Winterhoof","Trainer"},{1215,"Alchemist Mallory","Trainer"},{1386,"Rogvar","Trainer"},{2132,"Carolai Anise","Trainer"},{3347,"Yelmak","Trainer"},{2391,"Serge Hinott","Trainer"},{3603,"Cyndra Kindwhisper","Trainer"},{1470,"Ghak Healtouch","Trainer"},{2837,"Jaxin Chong","Trainer"},{4160,"Ainethil","Trainer"},{3964,"Kylanna","Trainer"}}},{["spellID"]=6415,["itemId"]=5485,["name"]="Fillet of Frenzy",["profession"]="Cooking",["requiredSkill"]=50,["refs"]={{4200,"Laird","Vendor"},{3087,"Crystal Boughman","Trainer"},{1355,"Cook Ghilm","Trainer"},{1382,"Mudduk","Trainer"},{1699,"Gremlock Pilsnor","Trainer"},{3399,"Zamja","Trainer"},{4210,"Alegorn","Trainer"},{2818,"Slagg","Trainer"},{4552,"Eunice Burch","Trainer"},{1430,"Tomas","Trainer"},{3067,"Pyall Silentstride","Trainer"},{5159,"Daryl Riknussun","Trainer"},{4894,"Craig Nollward","Trainer"}}},{["spellID"]=3296,["name"]="Heavy Bronze Mace",["profession"]="Blacksmithing",["requiredSkill"]=130,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=3320,["name"]="Rough Grinding Stone",["profession"]="Blacksmithing",["requiredSkill"]=25,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=3328,["name"]="Rough Bronze Shoulders",["profession"]="Blacksmithing",["requiredSkill"]=110,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=6703,["itemId"]=5787,["name"]="Murloc Scale Breastplate",["profession"]="Leatherworking",["requiredSkill"]=95,["refs"]={{843,"Gina MacGregor","Vendor"},{3556,"Andrew Hilbert","Vendor"},{4186,"Mavralyn","Vendor"}}},{["spellID"]=3376,["itemId"]=3682,["name"]="Curiously Tasty Omelet",["profession"]="Cooking",["requiredSkill"]=130,["refs"]={{340,"Kendor Kabonka","Vendor"},{1148,"Nerrist","Vendor"},{2821,"Keena","Vendor"}}},{["spellID"]=7135,["name"]="Dark Leather Pants",["profession"]="Leatherworking",["requiredSkill"]=115,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=3760,["name"]="Hillman's Cloak",["profession"]="Leatherworking",["requiredSkill"]=150,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=3768,["name"]="Hillman's Shoulders",["profession"]="Leatherworking",["requiredSkill"]=130,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=3816,["name"]="Cured Light Hide",["profession"]="Leatherworking",["requiredSkill"]=35,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=3840,["name"]="Heavy Linen Gloves",["profession"]="Tailoring",["requiredSkill"]=35,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=3936,["name"]="Deadly Blunderbuss",["profession"]="Engineering",["requiredSkill"]=105,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3952,["itemId"]=14639,["name"]="Minor Recombobulator",["profession"]="Engineering",["requiredSkill"]=140,["refs"]={{2682,"Fradd Swiftgear","Vendor"},{2683,"Namdo Bizzfizzle","Vendor"},{3495,"Gagsprocket","Vendor"}}},{["spellID"]=13501,["name"]="Enchant Bracer - Lesser Stamina",["profession"]="Enchanting",["requiredSkill"]=130,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=8607,["itemId"]=6892,["name"]="Smoked Bear Meat",["profession"]="Cooking",["requiredSkill"]=40,["refs"]={{1465,"Drac Roughcut","Vendor"},{3556,"Andrew Hilbert","Vendor"}}},{["spellID"]=6624,["itemId"]=5642,["name"]="Free Action Potion",["profession"]="Alchemy",["requiredSkill"]=150,["refs"]={{4226,"Ulthir","Vendor"},{5178,"Soolie Berryfizz","Vendor"}}},{["spellID"]=6688,["itemId"]=5772,["name"]="Red Woolen Bag",["profession"]="Tailoring",["requiredSkill"]=115,["refs"]={{3537,"Zixil","Vendor"},{777,"Amy Davenport","Vendor"},{1454,"Jennabink Powerseam","Vendor"},{3005,"Mahu","Vendor"},{3683,"Kiknikle","Vendor"},{4189,"Valdaron","Vendor"},{3364,"Borya","Vendor"},{4577,"Millie Gregorian","Vendor"},{1474,"Rann Flamespinner","Vendor"},{3485,"Wrahk","Vendor"},{5944,"Yonada","Vendor"}}},{["spellID"]=9983,["name"]="Copper Claymore",["profession"]="Blacksmithing",["requiredSkill"]=30,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=7408,["name"]="Heavy Copper Maul",["profession"]="Blacksmithing",["requiredSkill"]=65,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=2153,["name"]="Handstitched Leather Pants",["profession"]="Leatherworking",["requiredSkill"]=15,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=2161,["name"]="Embossed Leather Boots",["profession"]="Leatherworking",["requiredSkill"]=55,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=8768,["name"]="Iron Buckle",["profession"]="Blacksmithing",["requiredSkill"]=150,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=2337,["name"]="Lesser Healing Potion",["profession"]="Alchemy",["requiredSkill"]=55,["refs"]={{3009,"Bena Winterhoof","Trainer"},{1215,"Alchemist Mallory","Trainer"},{1386,"Rogvar","Trainer"},{2132,"Carolai Anise","Trainer"},{3347,"Yelmak","Trainer"},{2391,"Serge Hinott","Trainer"},{3603,"Cyndra Kindwhisper","Trainer"},{1470,"Ghak Healtouch","Trainer"},{2837,"Jaxin Chong","Trainer"},{4160,"Ainethil","Trainer"},{3964,"Kylanna","Trainer"}}},{["spellID"]=2393,["name"]="White Linen Shirt",["profession"]="Tailoring",["requiredSkill"]=1,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=2401,["name"]="Woolen Boots",["profession"]="Tailoring",["requiredSkill"]=95,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=2545,["itemId"]=2698,["name"]="Cooked Crab Claw",["profession"]="Cooking",["requiredSkill"]=85,["refs"]={{340,"Kendor Kabonka","Vendor"}}},{["spellID"]=2665,["name"]="Coarse Sharpening Stone",["profession"]="Blacksmithing",["requiredSkill"]=65,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=2737,["name"]="Copper Mace",["profession"]="Blacksmithing",["requiredSkill"]=15,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=15935,["itemId"]=12226,["name"]="Crispy Bat Wing",["profession"]="Cooking",["requiredSkill"]=1,["refs"]={{2118,"Abigail Shiel","Vendor"}}},{["spellID"]=3177,["name"]="Elixir of Defense",["profession"]="Alchemy",["requiredSkill"]=130,["refs"]={{3009,"Bena Winterhoof","Trainer"},{1215,"Alchemist Mallory","Trainer"},{1386,"Rogvar","Trainer"},{2132,"Carolai Anise","Trainer"},{3347,"Yelmak","Trainer"},{2391,"Serge Hinott","Trainer"},{3603,"Cyndra Kindwhisper","Trainer"},{1470,"Ghak Healtouch","Trainer"},{2837,"Jaxin Chong","Trainer"},{4160,"Ainethil","Trainer"},{3964,"Kylanna","Trainer"}}},{["spellID"]=6417,["itemId"]=5487,["name"]="Dig Rat Stew",["profession"]="Cooking",["requiredSkill"]=90,["refs"]={{3392,"Prospector Khazgorm","Vendor"},{3443,"Grub","Vendor"}}},{["spellID"]=3337,["name"]="Heavy Grinding Stone",["profession"]="Blacksmithing",["requiredSkill"]=125,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=3377,["itemId"]=3683,["name"]="Gooey Spider Cake",["profession"]="Cooking",["requiredSkill"]=110,["refs"]={{340,"Kendor Kabonka","Vendor"}}},{["spellID"]=13536,["itemId"]=11101,["name"]="Enchant Bracer - Lesser Strength",["profession"]="Enchanting",["requiredSkill"]=140,["refs"]={{3954,"Dalria","Vendor"},{12043,"Kulwia","Vendor"}}},{["spellID"]=9985,["name"]="Bronze Warhammer",["profession"]="Blacksmithing",["requiredSkill"]=125,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=7457,["name"]="Enchant Bracer - Minor Stamina",["profession"]="Enchanting",["requiredSkill"]=50,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=3753,["name"]="Handstitched Leather Belt",["profession"]="Leatherworking",["requiredSkill"]=25,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=3761,["name"]="Fine Leather Tunic",["profession"]="Leatherworking",["requiredSkill"]=85,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=3841,["name"]="Green Linen Bracers",["profession"]="Tailoring",["requiredSkill"]=60,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=7793,["itemId"]=6349,["name"]="Enchant 2H Weapon - Lesser Intellect",["profession"]="Enchanting",["requiredSkill"]=100,["refs"]={{3012,"Nata Dawnstrider","Vendor"},{3346,"Kithas","Vendor"},{5758,"Leo Sarn","Vendor"},{5158,"Tilli Thistlefuzz","Vendor"}}},{["spellID"]=3929,["name"]="Coarse Blasting Powder",["profession"]="Engineering",["requiredSkill"]=75,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3937,["name"]="Large Copper Bomb",["profession"]="Engineering",["requiredSkill"]=105,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3945,["name"]="Heavy Blasting Powder",["profession"]="Engineering",["requiredSkill"]=125,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3953,["name"]="Bronze Framework",["profession"]="Engineering",["requiredSkill"]=145,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=7953,["itemId"]=6474,["name"]="Deviate Scale Cloak",["profession"]="Leatherworking",["requiredSkill"]=90,["refs"]={{5783,"Kalldan Felmoon","Vendor"}}},{["spellID"]=8467,["name"]="White Woolen Dress",["profession"]="Tailoring",["requiredSkill"]=110,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=9986,["name"]="Bronze Greatsword",["profession"]="Blacksmithing",["requiredSkill"]=130,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=14807,["name"]="Greater Magic Wand",["profession"]="Enchanting",["requiredSkill"]=70,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=14293,["name"]="Lesser Magic Wand",["profession"]="Enchanting",["requiredSkill"]=10,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=13628,["name"]="Runed Golden Rod",["profession"]="Enchanting",["requiredSkill"]=150,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=13626,["name"]="Enchant Chest - Minor Stats",["profession"]="Enchanting",["requiredSkill"]=150,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=13622,["name"]="Enchant Bracer - Lesser Intellect",["profession"]="Enchanting",["requiredSkill"]=150,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=13529,["name"]="Enchant 2H Weapon - Lesser Impact",["profession"]="Enchanting",["requiredSkill"]=145,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=13503,["name"]="Enchant Weapon - Lesser Striking",["profession"]="Enchanting",["requiredSkill"]=140,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=13485,["name"]="Enchant Shield - Lesser Spirit",["profession"]="Enchanting",["requiredSkill"]=130,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=13419,["itemId"]=11039,["name"]="Enchant Cloak - Minor Agility",["profession"]="Enchanting",["requiredSkill"]=110,["refs"]={{3954,"Dalria","Vendor"},{12043,"Kulwia","Vendor"}}},{["spellID"]=13378,["name"]="Enchant Shield - Minor Stamina",["profession"]="Enchanting",["requiredSkill"]=105,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=7867,["itemId"]=6377,["name"]="Enchant Boots - Minor Agility",["profession"]="Enchanting",["requiredSkill"]=125,["refs"]={{3012,"Nata Dawnstrider","Vendor"},{3537,"Zixil","Vendor"}}},{["spellID"]=7863,["itemId"]=6376,["name"]="Enchant Boots - Minor Stamina",["profession"]="Enchanting",["requiredSkill"]=125,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=7861,["name"]="Enchant Cloak - Lesser Fire Resistance",["profession"]="Enchanting",["requiredSkill"]=125,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=7857,["name"]="Enchant Chest - Health",["profession"]="Enchanting",["requiredSkill"]=120,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=7788,["name"]="Enchant Weapon - Minor Striking",["profession"]="Enchanting",["requiredSkill"]=90,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=7779,["name"]="Enchant Bracer - Minor Agility",["profession"]="Enchanting",["requiredSkill"]=80,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=7776,["itemId"]=6346,["name"]="Enchant Chest - Lesser Mana",["profession"]="Enchanting",["requiredSkill"]=80,["refs"]={{3346,"Kithas","Vendor"},{5757,"Lilly","Vendor"}}},{["spellID"]=7771,["itemId"]=6345,["name"]="Enchant Cloak - Minor Protection",["profession"]="Enchanting",["requiredSkill"]=90,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=7748,["name"]="Enchant Chest - Lesser Health",["profession"]="Enchanting",["requiredSkill"]=60,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=7745,["name"]="Enchant 2H Weapon - Minor Impact",["profession"]="Enchanting",["requiredSkill"]=100,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=7426,["name"]="Enchant Chest - Minor Absorption",["profession"]="Enchanting",["requiredSkill"]=40,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=7420,["name"]="Enchant Chest - Minor Health",["profession"]="Enchanting",["requiredSkill"]=15,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=6690,["name"]="Lesser Wizard's Robe",["profession"]="Tailoring",["requiredSkill"]=135,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=13538,["name"]="Enchant Chest - Lesser Absorption",["profession"]="Enchanting",["requiredSkill"]=140,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=9987,["name"]="Bronze Battle Axe",["profession"]="Blacksmithing",["requiredSkill"]=135,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=2162,["name"]="Embossed Leather Cloak",["profession"]="Leatherworking",["requiredSkill"]=60,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=9060,["name"]="Light Leather Quiver",["profession"]="Leatherworking",["requiredSkill"]=30,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=2394,["name"]="Blue Linen Shirt",["profession"]="Tailoring",["requiredSkill"]=40,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=2402,["name"]="Woolen Cape",["profession"]="Tailoring",["requiredSkill"]=75,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=7639,["itemId"]=6274,["name"]="Blue Overalls",["profession"]="Tailoring",["requiredSkill"]=100,["refs"]={{1347,"Alexandra Bolero","Vendor"},{2394,"Mallen Swain","Vendor"},{843,"Gina MacGregor","Vendor"},{3364,"Borya","Vendor"},{5944,"Yonada","Vendor"}}},{["spellID"]=2546,["name"]="Dry Pork Ribs",["profession"]="Cooking",["requiredSkill"]=80,["refs"]={{3067,"Pyall Silentstride","Trainer"},{1355,"Cook Ghilm","Trainer"},{1382,"Mudduk","Trainer"},{1699,"Gremlock Pilsnor","Trainer"},{3087,"Crystal Boughman","Trainer"},{3399,"Zamja","Trainer"},{2818,"Slagg","Trainer"},{4210,"Alegorn","Trainer"},{1430,"Tomas","Trainer"},{3026,"Aska Mistrunner","Trainer"},{4894,"Craig Nollward","Trainer"},{4552,"Eunice Burch","Trainer"}}},{["spellID"]=7633,["itemId"]=6272,["name"]="Blue Linen Robe",["profession"]="Tailoring",["requiredSkill"]=70,["refs"]={{3485,"Wrahk","Vendor"},{3499,"Ranik","Vendor"},{1250,"Drake Lindgren","Vendor"},{3556,"Andrew Hilbert","Vendor"},{4168,"Elynna","Vendor"}}},{["spellID"]=7630,["itemId"]=6270,["name"]="Blue Linen Vest",["profession"]="Tailoring",["requiredSkill"]=55,["refs"]={{3364,"Borya","Vendor"},{3485,"Wrahk","Vendor"},{66,"Tharynn Bouden","Vendor"},{3522,"Constance Brisboise","Vendor"},{4189,"Valdaron","Vendor"}}},{["spellID"]=7623,["name"]="Brown Linen Robe",["profession"]="Tailoring",["requiredSkill"]=30,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=3924,["name"]="Copper Tube",["profession"]="Engineering",["requiredSkill"]=50,["refs"]={{8736,"Buzzek Bracketswing","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{11017,"Roxxik","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11025,"Mukdrak","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5518,"Lilliam Sparkspindle","Trainer"},{11037,"Jenna Lemkenilli","Trainer"},{11031,"Franklin Lloyd","Trainer"}}},{["spellID"]=3914,["name"]="Brown Linen Pants",["profession"]="Tailoring",["requiredSkill"]=30,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=2658,["name"]="Smelt Silver",["profession"]="Mining",["requiredSkill"]=75,["refs"]={{3555,"Johan Focht","Trainer"},{1681,"Brock Stoneseeker","Trainer"},{1701,"Dank Drizzlecut","Trainer"},{3137,"Matt Johnson","Trainer"},{4254,"Geofram Bouldertoe","Trainer"},{4598,"Brom Killian","Trainer"},{3175,"Krunn","Trainer"},{5392,"Yarr Hammerstone","Trainer"},{3001,"Brek Stonehoof","Trainer"},{3357,"Makaru","Trainer"},{6297,"Kurdram Stonehammer","Trainer"},{5513,"Gelman Stonehand","Trainer"}}},{["spellID"]=2666,["name"]="Runed Copper Belt",["profession"]="Blacksmithing",["requiredSkill"]=70,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=2674,["name"]="Heavy Sharpening Stone",["profession"]="Blacksmithing",["requiredSkill"]=125,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=3854,["itemId"]=7114,["name"]="Azure Silk Gloves",["profession"]="Tailoring",["requiredSkill"]=145,["refs"]={{2679,"Wenna Silkbeard","Vendor"},{9636,"Kireena","Vendor"}}},{["spellID"]=3848,["name"]="Double-stitched Woolen Shoulders",["profession"]="Tailoring",["requiredSkill"]=110,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=2738,["name"]="Copper Axe",["profession"]="Blacksmithing",["requiredSkill"]=20,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=2386,["name"]="Linen Boots",["profession"]="Tailoring",["requiredSkill"]=65,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=2385,["name"]="Brown Linen Vest",["profession"]="Tailoring",["requiredSkill"]=10,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=7841,["name"]="Swim Speed Potion",["profession"]="Alchemy",["requiredSkill"]=100,["refs"]={{3009,"Bena Winterhoof","Trainer"},{1215,"Alchemist Mallory","Trainer"},{1386,"Rogvar","Trainer"},{2132,"Carolai Anise","Trainer"},{3347,"Yelmak","Trainer"},{2391,"Serge Hinott","Trainer"},{3603,"Cyndra Kindwhisper","Trainer"},{1470,"Ghak Healtouch","Trainer"},{2837,"Jaxin Chong","Trainer"},{4160,"Ainethil","Trainer"},{3964,"Kylanna","Trainer"}}},{["spellID"]=3170,["name"]="Weak Troll's Blood Potion",["profession"]="Alchemy",["requiredSkill"]=15,["refs"]={{3009,"Bena Winterhoof","Trainer"},{1215,"Alchemist Mallory","Trainer"},{1386,"Rogvar","Trainer"},{2132,"Carolai Anise","Trainer"},{3347,"Yelmak","Trainer"},{2391,"Serge Hinott","Trainer"},{3603,"Cyndra Kindwhisper","Trainer"},{1470,"Ghak Healtouch","Trainer"},{2837,"Jaxin Chong","Trainer"},{4160,"Ainethil","Trainer"},{3964,"Kylanna","Trainer"}}},{["spellID"]=6419,["itemId"]=5489,["name"]="Lean Venison",["profession"]="Cooking",["requiredSkill"]=110,["refs"]={{3960,"Ulthaan","Vendor"},{12245,"Vendor-Tron 1000","Vendor"}}},{["spellID"]=6499,["name"]="Boiled Clams",["profession"]="Cooking",["requiredSkill"]=50,["refs"]={{3067,"Pyall Silentstride","Trainer"},{1355,"Cook Ghilm","Trainer"},{1382,"Mudduk","Trainer"},{1699,"Gremlock Pilsnor","Trainer"},{3087,"Crystal Boughman","Trainer"},{3399,"Zamja","Trainer"},{2818,"Slagg","Trainer"},{4210,"Alegorn","Trainer"},{1430,"Tomas","Trainer"},{3026,"Aska Mistrunner","Trainer"},{4894,"Craig Nollward","Trainer"},{4552,"Eunice Burch","Trainer"}}},{["spellID"]=3370,["itemId"]=3678,["name"]="Crocolisk Steak",["profession"]="Cooking",["requiredSkill"]=80,["refs"]={{340,"Kendor Kabonka","Vendor"}}},{["spellID"]=3331,["name"]="Silvered Bronze Boots",["profession"]="Blacksmithing",["requiredSkill"]=130,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=3304,["name"]="Smelt Tin",["profession"]="Mining",["requiredSkill"]=65,["refs"]={{3555,"Johan Focht","Trainer"},{1681,"Brock Stoneseeker","Trainer"},{1701,"Dank Drizzlecut","Trainer"},{3137,"Matt Johnson","Trainer"},{4254,"Geofram Bouldertoe","Trainer"},{4598,"Brom Killian","Trainer"},{3175,"Krunn","Trainer"},{5392,"Yarr Hammerstone","Trainer"},{3001,"Brek Stonehoof","Trainer"},{3357,"Makaru","Trainer"},{6297,"Kurdram Stonehammer","Trainer"},{5513,"Gelman Stonehand","Trainer"}}},{["spellID"]=2659,["name"]="Smelt Bronze",["profession"]="Mining",["requiredSkill"]=65,["refs"]={{3555,"Johan Focht","Trainer"},{1681,"Brock Stoneseeker","Trainer"},{1701,"Dank Drizzlecut","Trainer"},{3137,"Matt Johnson","Trainer"},{4254,"Geofram Bouldertoe","Trainer"},{4598,"Brom Killian","Trainer"},{3175,"Krunn","Trainer"},{5392,"Yarr Hammerstone","Trainer"},{3001,"Brek Stonehoof","Trainer"},{3357,"Makaru","Trainer"},{6297,"Kurdram Stonehammer","Trainer"},{5513,"Gelman Stonehand","Trainer"}}},{["spellID"]=3770,["name"]="Toughened Leather Gloves",["profession"]="Leatherworking",["requiredSkill"]=135,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=3842,["name"]="Handstitched Linen Britches",["profession"]="Tailoring",["requiredSkill"]=70,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=3850,["name"]="Heavy Woolen Pants",["profession"]="Tailoring",["requiredSkill"]=110,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=3866,["name"]="Stylish Red Shirt",["profession"]="Tailoring",["requiredSkill"]=110,["refs"]={{1103,"Eldrin","Trainer"},{1346,"Georgio Bolero","Trainer"},{2627,"Grarnik Goodstitch","Trainer"},{3523,"Bowen Brisboise","Trainer"},{3704,"Mahani","Trainer"},{3004,"Tepa","Trainer"},{2399,"Daryl Stack","Trainer"},{3363,"Magar","Trainer"},{4576,"Josef Gregorian","Trainer"},{4193,"Grondal Moonbreeze","Trainer"}}},{["spellID"]=7795,["name"]="Runed Silver Rod",["profession"]="Enchanting",["requiredSkill"]=100,["refs"]={{5157,"Gimble Thistlefuzz","Trainer"},{1317,"Lucan Cordell","Trainer"},{3011,"Teg Dawnstrider","Trainer"},{3606,"Alanna Raveneye","Trainer"},{5695,"Vance Undergloom","Trainer"},{7949,"Xylinnia Starshine","Trainer"},{4213,"Taladan","Trainer"},{11072,"Kitta Firewind","Trainer"},{3345,"Godan","Trainer"},{4616,"Lavinia Crowe","Trainer"},{11074,"Hgarth","Trainer"},{11073,"Annora","Trainer"}}},{["spellID"]=7827,["itemId"]=6368,["name"]="Rainbow Fin Albacore",["profession"]="Cooking",["requiredSkill"]=50,["refs"]={{5494,"Catherine Leland","Vendor"},{3178,"Stuart Fleming","Vendor"},{3333,"Shankys","Vendor"},{4305,"Kriggon Talsone","Vendor"},{5748,"Killian Sanatha","Vendor"},{5942,"Zansoa","Vendor"},{4307,"Heldan Galesong","Vendor"},{10118,"Nessa Shadowsong","Vendor"},{3497,"Kilxx","Vendor"},{4553,"Ronald Burch","Vendor"}}},{["spellID"]=3930,["name"]="Crafted Heavy Shot",["profession"]="Engineering",["requiredSkill"]=75,["refs"]={{8736,"Buzzek Bracketswing","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{11017,"Roxxik","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11025,"Mukdrak","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5518,"Lilliam Sparkspindle","Trainer"},{11037,"Jenna Lemkenilli","Trainer"},{11031,"Franklin Lloyd","Trainer"}}},{["spellID"]=3938,["name"]="Bronze Tube",["profession"]="Engineering",["requiredSkill"]=105,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3946,["name"]="Heavy Dynamite",["profession"]="Engineering",["requiredSkill"]=125,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=23190,["itemId"]=18731,["name"]="Heavy Leather Ball",["profession"]="Leatherworking",["requiredSkill"]=150,["refs"]={{3366,"Tamar","Vendor"},{5128,"Bombus Finespindle","Vendor"}}},{["spellID"]=9062,["name"]="Small Leather Ammo Pouch",["profession"]="Leatherworking",["requiredSkill"]=30,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=7836,["name"]="Blackmouth Oil",["profession"]="Alchemy",["requiredSkill"]=80,["refs"]={{3009,"Bena Winterhoof","Trainer"},{1215,"Alchemist Mallory","Trainer"},{1386,"Rogvar","Trainer"},{2132,"Carolai Anise","Trainer"},{3347,"Yelmak","Trainer"},{2391,"Serge Hinott","Trainer"},{3603,"Cyndra Kindwhisper","Trainer"},{1470,"Ghak Healtouch","Trainer"},{2837,"Jaxin Chong","Trainer"},{4160,"Ainethil","Trainer"},{3964,"Kylanna","Trainer"}}},{["spellID"]=7817,["name"]="Rough Bronze Boots",["profession"]="Blacksmithing",["requiredSkill"]=95,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=3324,["name"]="Runed Copper Pants",["profession"]="Blacksmithing",["requiredSkill"]=45,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=3323,["name"]="Runed Copper Gauntlets",["profession"]="Blacksmithing",["requiredSkill"]=40,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=2741,["name"]="Bronze Axe",["profession"]="Blacksmithing",["requiredSkill"]=115,["refs"]={{3355,"Saru Steelfury","Trainer"},{514,"Smith Argus","Trainer"},{1241,"Tognus Flintfire","Trainer"},{2998,"Karn Stonehoof","Trainer"},{3478,"Traugh","Trainer"},{3557,"Guillaume Sorouy","Trainer"},{3136,"Clarise Gnarltree","Trainer"},{4258,"Bengus Deepforge","Trainer"},{2836,"Brikk Keencraft","Trainer"},{3174,"Dwukk","Trainer"},{4888,"Marie Holdston","Trainer"},{4596,"James Van Brunt","Trainer"}}},{["spellID"]=3278,["name"]="Heavy Wool Bandage",["profession"]="First Aid",["requiredSkill"]=115,["refs"]={{4211,"Dannelor","Trainer"},{2326,"Thamner Pol","Trainer"},{2327,"Shaina Fuller","Trainer"},{2798,"Pand Stonebinder","Trainer"},{4591,"Mary Edras","Trainer"},{5150,"Nissa Firestone","Trainer"},{3181,"Fremal Doohickey","Trainer"},{5759,"Nurse Neela","Trainer"},{2329,"Michelle Belle","Trainer"},{3373,"Arnok","Trainer"},{5943,"Rawrk","Trainer"},{5939,"Vira Younghoof","Trainer"}}},{["spellID"]=3817,["name"]="Cured Medium Hide",["profession"]="Leatherworking",["requiredSkill"]=100,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}},{["spellID"]=7845,["name"]="Elixir of Firepower",["profession"]="Alchemy",["requiredSkill"]=140,["refs"]={{3009,"Bena Winterhoof","Trainer"},{1215,"Alchemist Mallory","Trainer"},{1386,"Rogvar","Trainer"},{2132,"Carolai Anise","Trainer"},{3347,"Yelmak","Trainer"},{2391,"Serge Hinott","Trainer"},{3603,"Cyndra Kindwhisper","Trainer"},{1470,"Ghak Healtouch","Trainer"},{2837,"Jaxin Chong","Trainer"},{4160,"Ainethil","Trainer"},{3964,"Kylanna","Trainer"}}},{["spellID"]=7837,["name"]="Fire Oil",["profession"]="Alchemy",["requiredSkill"]=130,["refs"]={{3009,"Bena Winterhoof","Trainer"},{1215,"Alchemist Mallory","Trainer"},{1386,"Rogvar","Trainer"},{2132,"Carolai Anise","Trainer"},{3347,"Yelmak","Trainer"},{2391,"Serge Hinott","Trainer"},{3603,"Cyndra Kindwhisper","Trainer"},{1470,"Ghak Healtouch","Trainer"},{2837,"Jaxin Chong","Trainer"},{4160,"Ainethil","Trainer"},{3964,"Kylanna","Trainer"}}},{["spellID"]=3173,["name"]="Lesser Mana Potion",["profession"]="Alchemy",["requiredSkill"]=120,["refs"]={{3009,"Bena Winterhoof","Trainer"},{1215,"Alchemist Mallory","Trainer"},{1386,"Rogvar","Trainer"},{2132,"Carolai Anise","Trainer"},{3347,"Yelmak","Trainer"},{2391,"Serge Hinott","Trainer"},{3603,"Cyndra Kindwhisper","Trainer"},{1470,"Ghak Healtouch","Trainer"},{2837,"Jaxin Chong","Trainer"},{4160,"Ainethil","Trainer"},{3964,"Kylanna","Trainer"}}},{["spellID"]=6500,["name"]="Goblin Deviled Clams",["profession"]="Cooking",["requiredSkill"]=125,["refs"]={{3067,"Pyall Silentstride","Trainer"},{1355,"Cook Ghilm","Trainer"},{1382,"Mudduk","Trainer"},{1699,"Gremlock Pilsnor","Trainer"},{3087,"Crystal Boughman","Trainer"},{3399,"Zamja","Trainer"},{2818,"Slagg","Trainer"},{4210,"Alegorn","Trainer"},{1430,"Tomas","Trainer"},{3026,"Aska Mistrunner","Trainer"},{4894,"Craig Nollward","Trainer"},{4552,"Eunice Burch","Trainer"}}},{["spellID"]=9271,["name"]="Aquadynamic Fish Attractor",["profession"]="Engineering",["requiredSkill"]=150,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=8895,["itemId"]=7192,["name"]="Goblin Rocket Boots",["profession"]="Engineering",["requiredSkill"]=130,["refs"]={{8126,"Nixx Sprocketspring","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{4941,"Caz Twosprocket","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{8738,"Vazario Linkgrease","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5518,"Lilliam Sparkspindle","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3978,["name"]="Standard Scope",["profession"]="Engineering",["requiredSkill"]=110,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3977,["name"]="Crude Scope",["profession"]="Engineering",["requiredSkill"]=60,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3925,["name"]="Rough Boomstick",["profession"]="Engineering",["requiredSkill"]=50,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3923,["name"]="Rough Copper Bomb",["profession"]="Engineering",["requiredSkill"]=30,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=3922,["name"]="Handful of Copper Bolts",["profession"]="Engineering",["requiredSkill"]=30,["refs"]={{5518,"Lilliam Sparkspindle","Trainer"},{1676,"Finbus Geargrind","Trainer"},{1702,"Bronk Guzzlegear","Trainer"},{3494,"Tinkerwiz","Trainer"},{8736,"Buzzek Bracketswing","Trainer"},{10993,"Twizwick Sprocketgrind","Trainer"},{4941,"Caz Twosprocket","Trainer"},{11017,"Roxxik","Trainer"},{3290,"Deek Fizzlebizz","Trainer"},{5174,"Springspindle Fizzlegear","Trainer"},{11031,"Franklin Lloyd","Trainer"},{11025,"Mukdrak","Trainer"}}},{["spellID"]=7954,["itemId"]=6475,["name"]="Deviate Scale Gloves",["profession"]="Leatherworking",["requiredSkill"]=105,["refs"]={{5783,"Kalldan Felmoon","Vendor"}}},{["spellID"]=3818,["name"]="Cured Heavy Hide",["profession"]="Leatherworking",["requiredSkill"]=150,["refs"]={{3605,"Nadyia Maneweaver","Trainer"},{1385,"Brawn","Trainer"},{1632,"Adele Fielder","Trainer"},{3069,"Chaw Stronghide","Trainer"},{3703,"Krulmoo Fullmoon","Trainer"},{3967,"Aayndia Floralwind","Trainer"},{3365,"Karolek","Trainer"},{4212,"Telonis","Trainer"},{3007,"Una","Trainer"},{3549,"Shelene Rhobart","Trainer"},{5127,"Fimble Finespindle","Trainer"},{4588,"Arthur Moore","Trainer"}}}}
F.classicRecipeLeads=#baseline
local function baselineSources()
 local D=ns.ForeverQuestData
 for _,fact in ipairs(baseline)do
  local r=E.recipes[fact.spellID]
  if not r then r=E.IndexRecipe({spellID=fact.spellID,itemId=fact.itemId,learnableItemID=fact.itemId,name=fact.name,profession=fact.profession,requiredSkill=fact.requiredSkill,sources={},locations={},catalogOnly=true,reference='Classic acquisition lead; confirm Forever stock'})end
  for _,ref in ipairs(fact.refs)do
   local found=false;for _,loc in ipairs(r.locations)do if loc.npcID==ref[1]and loc.source==ref[3]then found=true;break end end
   if not found then
    local loc={npcID=ref[1],name=ref[2],source=ref[3],evidence='classic-reference-unconfirmed'}
    for _,v in pairs(D and D.spawns['npc:'..ref[1]]or{})do
     if v.mapID and v.mapID~=1414 and v.mapID~=1415 and v.mapID~=1945 then
      local info=call(C_Map and C_Map.GetMapInfo,v.mapID)
      if info and info.name then loc.mapID=v.mapID;loc.x=v.x;loc.y=v.y;loc.zone=info.name;break end
     end
    end
    for _,v in ipairs(F.trainerRoster or{})do if v.name==ref[2]then loc.zone=v.zone;loc.faction=v.faction end end
    r.locations[#r.locations+1]=loc
    local has=false;for _,v in ipairs(r.sources)do if v==ref[3]then has=true end end;if not has then r.sources[#r.sources+1]=ref[3]end
   end
  end
 end
end
baselineSources()

end)(ADDON,GF)
-- GF_MODULE_BEGIN Observations
;(function(...)
-- Bounded observations refine evidence; they never assert unseen drops or exact spawns.
local _,ns=...
local E,F=ns.Forever,ns.ForeverFacts;local call=E.Call
local snapshot=E.Snapshot
function E.Snapshot()
 local state=snapshot();if E.db and E.db.collect then
  for id,q in pairs(state.quests)do for slot,goal in ipairs(q.objectives or{})do
   local key=id..':'..slot;E.previousObjectives=E.previousObjectives or{};local old=E.previousObjectives[key];local count=goal.numFulfilled
   if old~=count and count~=nil then E.Record('quest-objective',{questID=id,slot=slot,current=count,required=goal.numRequired,text=goal.text});E.previousObjectives[key]=count end
  end end
 end;return state
end
-- Camps can only be recommended from observed camp influence or a client-labelled camp POI.
local campPOIMap,campPOITime
function E.ReadCampPOIs()
 local p=E.CurrentPosition();if not p then return end
 local now=E.Time()
 if campPOIMap==p.mapID and now-campPOITime<10 then return end
 campPOIMap,campPOITime=p.mapID,now
 for i=#E.camps,1,-1 do
  local camp=E.camps[i]
  if camp.expires<=now or camp.mapID==p.mapID and camp.evidence=='client-explicit-camp-poi' then
   table.remove(E.camps,i)
  end
 end
 for _,id in ipairs(call(C_AreaPoiInfo and C_AreaPoiInfo.GetAreaPOIForMap,p.mapID)or{})do
  local info=call(C_AreaPoiInfo and C_AreaPoiInfo.GetAreaPOIInfo,p.mapID,id)
  if info and info.isCamp==true and info.position then local x,y=call(info.position.GetXY,info.position);if x and y then
   local row={mapID=p.mapID,x=x*100,y=y*100,name=info.name or'Client campsite',expires=now+30,evidence='client-explicit-camp-poi'};E.camps[#E.camps+1]=row;if #E.camps>24 then table.remove(E.camps,1)end
  end end
 end
end
function E.RegisterCollection(record)
 if type(record)~='table'or not record.id or not record.source or not record.title then return false end
 for _,r in ipairs(E.collections)do if r.id==record.id then return true end end
 record.category=record.category or'Questing';record.kind='collection';E.collections[#E.collections+1]=record;return true
end
local refreshCatalog=E.RefreshCatalog
function E.RefreshCatalog()
 refreshCatalog()
 for key,r in pairs(E.recipes)do
  if r.learnableItemID then local loc=r.locations and r.locations[1];local dungeon=loc and loc.dungeon and E.dungeons[loc.dungeon]
   E.RegisterCollection({id='collection:recipe:'..key,title='Collect '..(r.learnableName or r.name),recipe=r,profession=r.profession,itemID=r.learnableItemID,minLevel=dungeon and dungeon.minimum,destination=dungeon and dungeon.entrance,source=r.sourceURL or'Forever client catalog',body='Recipe acquisition: '..(r.learnableName or r.name)..'.\n'..(loc and((loc.source or'Source')..': '..(loc.name or'')..' � '..(loc.zone or''))or'Location must be verified.')..'\nRequires '..r.profession..' '..tostring(r.requiredSkill or'(check item)')..' to learn. Drops are not guaranteed. Reputation and quest prerequisites must be satisfied.'})
  end
 end
end
local eligible=E.Eligible
function E.Eligible(row,state)
 state=state or E.state
 if row.kind=='collection'and row.recipe and E.Known(row.recipe)==true then return false end
 if row.kind=='collection'and row.itemID then
  local mount=call(C_MountJournal and C_MountJournal.GetMountFromItem,row.itemID)
  if mount then local values={call(C_MountJournal.GetMountInfoByID,mount)};if values[11]==true then return false end end
  if call(PlayerHasToy,row.itemID)==true then return false end
 end
 return eligible(row,state)
end
local camp=E.CampPlan
function E.CampPlan(state)
 if call(InCombatLockdown)or call(IsInInstance)==true then return end
 return camp(state)
end
-- Ordinary quest-object loot counts as arrival even if the imported hotspot differs.
local destination=ns.ProfessionGuide.Destination
function ns.ProfessionGuide.Destination()
 local row=ns.ProfessionGuide.selected
 if row and(row.kind=='vendor'or row.kind=='sell')then
  local vendors={};for _,v in pairs(E.vendors)do vendors[#vendors+1]=v end
  local near=E.Nearest(vendors);if near then local copy={};for k,v in pairs(near)do copy[k]=v end;copy.name=near.name or'Nearest observed vendor';return copy end
 end
 return destination()
end

end)(ADDON,GF)
-- GF_MODULE_END Observations
-- GF_MODULE_BEGIN Travel
;(function(...)
-- Only observed prices, reachable nodes and measured flight durations are used.
local _,ns=...
local E=ns.Forever;local call=E.Call
function E.ObserveTaxi()
 E.taxiChoices={}
 local map=call(GetTaxiMapID)
 local nodes=map and call(C_TaxiMap and C_TaxiMap.GetAllTaxiNodes,map);local states=Enum and Enum.FlightPathState
 if type(nodes)~='table'or not states then return end
 local current;for _,node in ipairs(nodes)do if node.state==states.Current then current=node end end
 if not current then return end
 local function position(node)local p=node.position;local x,y;if p and p.GetXY then x,y=call(p.GetXY,p)elseif p then x,y=p.x,p.y end;if x and y then return{mapID=map,x=x*100,y=y*100,name=node.name}end end
 local from=position(current);if not from then return end
 for _,node in ipairs(nodes)do if node.state==states.Reachable and node.slotIndex then
  local cost=call(TaxiNodeCost,node.slotIndex);local destination=position(node)
  if type(cost)=='number'and destination then local id=current.nodeID..':'..node.nodeID;local edge={id=id,from=from,to=destination,cost=cost,known=true,seconds=E.db.flightDurations and E.db.flightDurations[id]};E.taxiChoices[node.slotIndex]=edge;local replaced=false;for i,v in ipairs(E.flights)do if v.id==id then E.flights[i]=edge;replaced=true;break end end;if not replaced and #E.flights<120 then E.flights[#E.flights+1]=edge end end
 end end
 E.Record('flight-master-observed',{nodes=#nodes})
end
if hooksecurefunc and TakeTaxiNode then hooksecurefunc('TakeTaxiNode',function(index)
 local edge=E.taxiChoices and E.taxiChoices[index];if edge then E.flightPending={edge=edge,start=E.Time()}end
end)end
function E.CheckFlight()
 local pending=E.flightPending;if not pending then return end
 if call(UnitOnTaxi,'player')then pending.departed=true
 elseif pending.departed then
  pending.edge.seconds=E.Time()-pending.start
  if E.db.collect then E.db.flightDurations=E.db.flightDurations or{};E.db.flightDurations[pending.edge.id]=pending.edge.seconds end
  E.Record('flight-measured',{seconds=pending.edge.seconds,cost=pending.edge.cost});E.flightPending=nil
 elseif E.Time()-pending.start>20 then E.flightPending=nil end
end

end)(ADDON,GF)
-- GF_MODULE_END Travel
-- GF_MODULE_BEGIN Presentation
;(function(...)
-- Hot-compatible local candidate; standalone module scopes preserved.
local hotAddon,hotNS=...
(function(...)
-- Phase B only. No Classic or frozen R1 entry point loads this module.
local _,ns=...
ns.VisualPhaseB=ns.VisualPhaseB or {}
local path="Interface\\AddOns\\GrindingForever\\Media\\Panel"
local T={version=2,approval="local review candidate",
    textures={frame=path.."JoinedFrame",leather=path.."Leather",close=path.."CloseStates"},
    metrics={corner=40,inset=2,outerTop=52,headerInset=12,plateTop=42,plateCorner=16,
        closeHit=44,closeArt=34,closeInset=8,closeGutter=60},
    reference={sheet="642AC8D13937034ACD7C257034BD0B4920D2DE9F77C8855BFA126BF7F50A17C9",
        arrows="D9D192C71ADA270D777267928B02CCA44E0A58BBE7002256FE7569B42797D9C8"}}
-- Rectangles are in padded TGA pixel coordinates. Adjacent slices share cut lines.
-- The full joined source supplies all corner/rail seams; no independently scaled rail widths.
T.frame={x={39,205,1049,1215},y={51,217,1027,1193},width=2048,height=2048}
T.leather={0,1254/2048,0,1254/2048}
T.close={normal={140/4096,677/4096,74/1024,596/1024},
    hover={818/4096,1355/4096,74/1024,596/1024},
    pressed={1496/4096,2033/4096,74/1024,596/1024}}
ns.VisualPhaseB.Theme=T

end)(hotAddon,hotNS);
(function(...)
-- Phase B presentation: no game reads, data changes, hooks or controller ownership.
local _,ns=...
local B=assert(ns.VisualPhaseB);local T=assert(B.Theme);local C={};B.Components=C
local positions={TOPLEFT={1,1},TOP={2,1},TOPRIGHT={3,1},LEFT={1,2},RIGHT={3,2},
    BOTTOMLEFT={1,3},BOTTOM={2,3},BOTTOMRIGHT={3,3}}
function C.Decorate(frame,size)
    if frame.phaseBBorder then return frame.phaseBBorder end
    local layer=CreateFrame("Frame",nil,frame);layer:SetAllPoints(frame);layer:EnableMouse(false)
    if layer.SetFrameLevel and frame.GetFrameLevel then layer:SetFrameLevel(frame:GetFrameLevel()+1) end
    local border={layer=layer,pieces={},size=size or T.metrics.corner}
    for name,index in pairs(positions) do
        local col,row=index[1],index[2];local tex=layer:CreateTexture(nil,"ARTWORK")
        tex:SetTexture(T.textures.frame)
        tex:SetTexCoord(T.frame.x[col]/T.frame.width,T.frame.x[col+1]/T.frame.width,
            T.frame.y[row]/T.frame.height,T.frame.y[row+1]/T.frame.height)
        border.pieces[name]=tex
    end
    frame.phaseBBorder=border;return border
end
function C.LayoutBorder(frame,size)
    local border=C.Decorate(frame,size);local inset=T.metrics.inset
    local w,h=frame:GetWidth(),frame:GetHeight()
    local corner=math.max(1,math.min(size or border.size,(w-2*inset)/2,(h-2*inset)/2))
    border.resolvedCorner=corner
    for name,index in pairs(positions) do
        local col,row=index[1],index[2];local tex=border.pieces[name]
        local left=col==1 and inset or col==2 and inset+corner or w-inset-corner
        local top=row==1 and inset or row==2 and inset+corner or h-inset-corner
        local width=col==2 and math.max(0,w-2*(corner+inset)) or corner
        local height=row==2 and math.max(0,h-2*(corner+inset)) or corner
        tex:ClearAllPoints();tex:SetPoint("TOPLEFT",frame,"TOPLEFT",left,-top);tex:SetSize(width,height)
    end
end
function C.Outer(parent)
    -- Decoration stays on one owner; input-only grips cannot hide or duplicate it.
    local shell=CreateFrame("Frame",nil,parent)
    shell:SetPoint("TOPLEFT",parent,"TOPLEFT",0,-T.metrics.outerTop)
    shell:SetPoint("BOTTOMRIGHT",parent,"BOTTOMRIGHT",0,0);shell:EnableMouse(false)
    parent.phaseBShell=shell;C.Decorate(shell,T.metrics.corner);return shell
end
function C.LayoutOuter(parent)
    if parent.phaseBShell then C.LayoutBorder(parent.phaseBShell,T.metrics.corner) end
end
function C.Header(parent,width,height)
    local m=T.metrics
    local header=CreateFrame("Frame",nil,parent)
    header:SetPoint("TOPLEFT",m.headerInset,-m.headerInset)
    header:SetPoint("TOPRIGHT",-m.headerInset,-m.headerInset);header:SetHeight(height)
    header.phaseBWidth=width;header.phaseBHeight=height
    local plate=CreateFrame("Frame",nil,header);plate:SetPoint("TOPLEFT",0,-m.plateTop)
    plate:SetPoint("TOPRIGHT",0,-m.plateTop);plate:SetHeight(height-m.plateTop)
    if plate.SetFrameLevel and header.GetFrameLevel then plate:SetFrameLevel(header:GetFrameLevel()) end
    -- Original generated pixels are retained. Crop to a wide strip without stretching
    -- the material's aspect ratio; no transparent padding enters the UV rectangle.
    local leather=plate:CreateTexture(nil,"BACKGROUND");leather:SetAllPoints(plate)
    leather:SetTexture(T.textures.leather);header.phaseBLeather=leather
    header.phaseBPlate=plate;C.Decorate(plate,m.plateCorner)
    local capLayer=CreateFrame("Frame",nil,header);capLayer:SetAllPoints(header);capLayer:EnableMouse(false)
    if capLayer.SetFrameLevel and plate.GetFrameLevel then capLayer:SetFrameLevel(plate:GetFrameLevel()+3) end
    local endcaps={}
    for i,side in ipairs({"Left","Right"}) do
        local tex=capLayer:CreateTexture(nil,"ARTWORK")
        tex:SetTexture("Interface\\AddOns\\GrindingForever\\Media\\Wyvern"..side.."_PREVIEW_ONLY")
        tex:SetTexCoord(12/256,243/256,42/256,214/256);tex:SetSize(width,width*172/231)
        local anchor=i==1 and "TOPLEFT" or "TOPRIGHT"
        tex:SetPoint(anchor,header,anchor,i==1 and 0 or -m.closeGutter,0);endcaps[i]=tex
    end
    header.phaseBEndcaps=endcaps;header.phaseBCapLayer=capLayer
    local textLayer=CreateFrame("Frame",nil,header);textLayer:SetAllPoints(header);textLayer:EnableMouse(false)
    if textLayer.SetFrameLevel and capLayer.GetFrameLevel then textLayer:SetFrameLevel(capLayer:GetFrameLevel()+1) end
    header.phaseBText=textLayer
    C.LayoutHeader(header);return header,leather,endcaps
end
function C.LayoutHeader(header)
    local plate=header.phaseBPlate;C.LayoutBorder(plate,T.metrics.plateCorner)
    -- The outer shell owns the top and side architecture. A second full header
    -- border would overlap those rails; the plate owns only its bottom separator.
    for name,texture in pairs(plate.phaseBBorder.pieces) do
        if name=="BOTTOM" then texture:Show() else texture:Hide() end
    end
    local ratio=math.max(1,plate:GetWidth()/math.max(1,plate:GetHeight()))
    local uv=T.leather;local span=(uv[4]-uv[3])/ratio;local center=(uv[3]+uv[4])/2
    header.phaseBLeather:SetTexCoord(uv[1],uv[2],center-span/2,center+span/2)
end
function C.Close(parent,callback)
    local m=T.metrics;local button=CreateFrame("Button",nil,parent)
    button:SetSize(m.closeHit,m.closeHit)
    button:SetPoint("TOPRIGHT",parent,"TOPRIGHT",-m.closeInset,-m.closeInset)
    if button.SetFrameLevel and parent.GetFrameLevel then button:SetFrameLevel(parent:GetFrameLevel()+8) end
    local tex=button:CreateTexture(nil,"ARTWORK");tex:SetSize(m.closeArt,m.closeArt)
    tex:SetPoint("CENTER",button,"CENTER",0,0);tex:SetTexture(T.textures.close)
    local wash=button:CreateTexture(nil,"OVERLAY");wash:SetAllPoints(tex);wash:SetColorTexture(.65,.40,.12,.09);wash:Hide()
    local state={hover=false,pressed=false,enabled=true};button.phaseBClose={texture=tex,state=state,hoverWash=wash}
    local function refresh()
        local key=state.enabled and state.pressed and "pressed" or "normal"
        wash:SetShown(state.enabled and state.hover and not state.pressed)
        tex:SetTexCoord(unpack(T.close[key]));tex:SetAlpha(state.enabled and 1 or .45)
    end
    button:SetScript("OnEnter",function() state.hover=true;refresh() end)
    button:SetScript("OnLeave",function() state.hover=false;state.pressed=false;refresh() end)
    button:SetScript("OnMouseDown",function(_,key) if key=="LeftButton" and state.enabled then state.pressed=true;refresh() end end)
    button:SetScript("OnMouseUp",function() state.pressed=false;refresh() end)
    button:SetScript("OnHide",function() state.hover=false;state.pressed=false;refresh() end)
    button:SetScript("OnClick",function(_,key)
        if state.enabled and (not key or key=="LeftButton") then state.pressed=false;state.hover=false;refresh();callback() end
    end)
    function button:SetVisualEnabled(value) state.enabled=not not value;state.pressed=false;self:EnableMouse(state.enabled);refresh() end
    refresh();return button
end

end)(hotAddon,hotNS);
hotNS.HotBuild='HotPhaseB_542F198464525D94';
-- Normal guide presentation. No sample quests or manufactured destinations.
local _,ns=...
local P=ns.ProfessionGuide
local function liveObjective(node)
 if node and ns.Adaptive then node=ns.Adaptive.DisplayStep(node)end
 if not node or node.kind~='objective' or not node.quest then return node end
 local ok,goals=pcall(function()return C_QuestLog and C_QuestLog.GetQuestObjectives(node.quest)end)
 if not ok or type(goals)~='table' then return node end
 local goal=node.slot and goals[node.slot]
 if not goal and #goals==1 then goal=goals[1] end
 if type(goal)~='table' or type(goal.text)~='string' or goal.text=='' then return node end
 local current,total=tonumber(goal.numFulfilled),tonumber(goal.numRequired)
 local text=goal.text
 if current and total and total>0 and not text:find('%d+%s*/%s*%d+') then text=text..' ('..current..'/'..total..')' end
 local display={};for k,v in pairs(node)do display[k]=v end
 display.title=text
 -- Replace only the copied instruction, preserving route notes and source identity.
 local original=node.body or ''
 if original:sub(1,#(node.title or ''))==node.title then original=original:sub(#node.title+1) end
 display.body=text..'\n\n'..original:gsub('^%s+','')
 return display
end
ns.LiveObjectiveDisplay=liveObjective
local GuideView={}
function GuideView.New()
 local self={steps={},goals={Questing=true,Dungeons=true,Gathering=true,Crafting=true},view="All"}
 function self:Visible()
  self.steps=P.steps
  local out={}
  for _,node in ipairs(self.steps)do
   if not node.complete and not node.deferred and node.category~="Gear Rewards" and self.goals[node.category] and (self.view=="All" or self.view==node.category or self.view=="Questing" and node.category=="Dungeons")then out[#out+1]=node end
  end
  return out
 end
 function self:Current(visible)
  for _,node in ipairs(visible or self:Visible())do if node.id==self.index then return node end end
 end
 function self:Reconcile(visible)
  visible=visible or self:Visible()
  local current=self:Current(visible)
  if not current or current.complete and not self.browsing then
   self.index=nil
   for _,node in ipairs(visible)do if not node.complete then self.index=node.id;break end end
   self.index=self.index or (visible[#visible] and visible[#visible].id)
  end
 end
 function self:Resync()P.Refresh();self.index=P.firstPending;self:Reconcile()end
 function self:SetGoal(category,value)self.goals[category]=not not value;self:Reconcile()end
 function self:SetView(value)self.view=value;self:Reconcile()end
 function self:Move(delta)
  self.browsing=true
  local visible=self:Visible();local at=1
  for i,node in ipairs(visible)do if node.id==self.index then at=i end end
  at=math.max(1,math.min(#visible,at+delta));self.index=visible[at] and visible[at].id or nil
 end
 return self
end
local N={revision="RecipeExplorer_20261025_R1",step=1,view=1}
local session=GuideView.New()
N.model=session;N.goals=session.goals
local viewNames={"All","Questing","Gathering","Crafting"}
local filterLabels={"All","Quests","Gatherables","Crafts"}
local KIT="Interface\\AddOns\\GrindingForever\\Media\\Control"
local saveSession,activate
local refreshing=false
ns.NormalUI=N
local AS="Interface\\AddOns\\GrindingForever\\Media\\Base"
local THEME="Interface\\AddOns\\GrindingForever\\Media\\Banner"
local UIART={panel={u=0.6123046875,v=0.6123046875},button={x={39,100,1563,1624},top=353,bottom=596,width=2048,height=1024}}
local OLD="Interface\\AddOns\\GrindingForever\\Media\\"
local C=assert(ns.VisualPhaseB.Components)
local NEW="Interface\\AddOns\\GrindingForever\\Media\\Bronze"
local FRAME={x={58,244,1006,1198},y={59,244,991,1174},width=2048,height=2048,rail={0.041015625,0.0849609375,0.1220703125,0.4833984375}}
local DECOR="Interface\\AddOns\\GrindingForever\\Media\\Junction"
-- Sample the existing connector's straight NW rim as affine UV quads.
-- No new/recolored art: the rails share the connector's exact material pixels.
 local WORKING="Interface\\AddOns\\GrindingForever\\Media\\Ridged"
 local CLEAR="Interface\\AddOns\\GrindingForever\\Media\\Clear"
 local WINGLESS="Interface\\AddOns\\GrindingForever\\Media\\Crest"
 local EXPLORER="Interface\\AddOns\\GrindingForever\\Media\\"
 -- Repeat the physical motif at a constant aspect; rotate sampling for uprights.
 local function snapArt(frame,size)
  local scale=frame:GetEffectiveScale()
  if not scale or scale<=0 then return size end
  return math.max(1,math.floor(size*UIParent:GetEffectiveScale()+.5))/scale
 end
 local function rail(texture,kind)
  local vertical=kind=="LEFT" or kind=="RIGHT"
  local length=vertical and texture:GetHeight() or texture:GetWidth()

  local repeatCount=length*texture:GetParent():GetEffectiveScale()/(96*UIParent:GetEffectiveScale())
  texture:SetTexture(WINGLESS.."PatinaRail","REPEAT","REPEAT")
  if vertical then texture:SetTexCoord(0,1,repeatCount,1,0,0,repeatCount,0)
  else texture:SetTexCoord(0,repeatCount,0,1) end
  texture:Show()
 end
local TITLEART={u=1.0,v=0.642578125,aspect=6.224924012158055}
local T=ns.VisualPhaseB.Theme
T.textures.frame=NEW.."BronzeFrame";T.frame=FRAME;T.metrics.corner=20
T.textures.close=WORKING.."HexClose"
T.close={normal={0,.25,0,1},hover={.25,.5,0,1},pressed={.5,.75,0,1}}
N.arrowSize=100
local sizeSlider,sizeValue
local syncingSlider=false
local host,root,arrow,arrowTex,arrowText,body,title,stepLabel,status,settings,playMenu,viewMenu
local bodyScroll,bodyContent,zoneMenu,sourceMenu,professionMenu
N.sideMaterial="parchment"
local rows={};local arrowEnabled=true;local target;local pending=true;local elapsed=0
local layingOut=false
local categoryLabels={Questing="Quest",Dungeons="Dungeon",Gathering="Gather",Crafting="Craft",["Gear Rewards"]="Gear"}
local function rowCaption(s)
 return (s.complete and "Done � " or "")..s.title:gsub(" � "," � ").."  ["..categoryLabels[s.category].."]"
end
local normalAspect=1440/1000
N.mode="normal";N.modeDimensions={};N.stepRows=rows
local function measure(f)
 local width=f.GetUnboundedStringWidth and f:GetUnboundedStringWidth();if type(width)~="number" then width=f.GetStringWidth and f:GetStringWidth() end
 return type(width)=="number" and width or #(f:GetText() or "")*select(2,f:GetFont())*.55
end
local function fit(b,padding,maximum)
 local width=math.ceil(measure(b.label)+(padding or 28)+(b.dropdown and 22 or 0))
 b:SetWidth(math.min(maximum or 1000,math.max(40,width)));return b:GetWidth()
end
local function rowContent(row,step,maximum)
 row.label:SetText(step.title:gsub(" � "," � "))
 row.category:SetText("");row.category:Hide()
 row.label:SetWidth(math.max(80,maximum-20));row.label:SetWordWrap(true);row.label:SetHeight(0)
 row:SetWidth(maximum);row:SetHeight(math.max(38,math.ceil(row.label:GetStringHeight())+16))
end
function N.LayoutStepRows(visible,start)
 local y=178;local shown=0;local full=false;local panel=root.panels[1]
 for i,row in ipairs(rows)do
  local step=visible[start+i-1]
  if N.mode=="normal"and step and not full then
   rowContent(row,liveObjective(step),panel:GetWidth()-56)
   if y+row:GetHeight()<=panel:GetHeight()-30 then
    row.stepID=step.id;row:ClearAllPoints();row:SetPoint("TOPLEFT",panel,"TOPLEFT",28,-y)
    row.selected=step.id==session.index;row:SetEnamelTint(row.selected and 1 or .72,row.selected and .94 or .78,row.selected and .68 or .82)
    row:Show();shown=shown+1;y=y+row:GetHeight()+4
   else full=true;row:Hide();row.stepID=nil end
  else row:Hide();row.stepID=nil end
 end
 N.displayedRowCount=shown;return shown
end

local function safeNumber(v,a,b) return ns.Retail.Client.Number(v,a,b) end
local function color(t,r,g,b,a) t:SetColorTexture(r,g,b,a or 1) end
local function text(parent,size,value,dark)
 local f=parent:CreateFontString(nil,"OVERLAY","GameFontNormal")
 local font="Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf";f:SetFont(font,(size)+1,"");f:SetText(value or "");if f.SetShadowOffset then f:SetShadowOffset(0,0)end
 if dark then f:SetTextColor(.18,.105,.045) else f:SetTextColor(.94,.81,.54) end
 f:SetJustifyH("LEFT");f:SetWordWrap(true);return f
end
local function tex(parent,path,layer)
 local t=parent:CreateTexture(nil,layer or "BACKGROUND");t:SetTexture(path);return t
end
local function inset(parent,path,corner)
 local p=CreateFrame("Frame",nil,parent);p:EnableMouse(false)
 local t=tex(p,path);t:SetPoint("TOPLEFT",p,"TOPLEFT",8,-8);t:SetPoint("BOTTOMRIGHT",p,"BOTTOMRIGHT",-8,8)
 p.fill=t;C.Decorate(p,corner or 18);return p
end
local function btn(parent,label,width,callback)
 local b=CreateFrame("Button",nil,parent,"BackdropTemplate");b:SetSize(width,36);b.enamelPieces={}
 local cuts={0,20,492,512}
 for i=1,3 do
  local t=tex(b,KIT.."ButtonNormal","ARTWORK");t:SetTexCoord(cuts[i]/512,cuts[i+1]/512,0,1)
  if i==1 then t:SetPoint("TOPLEFT",b,"TOPLEFT",0,0);t:SetPoint("BOTTOMLEFT",b,"BOTTOMLEFT",0,0);t:SetWidth(7)
  elseif i==3 then t:SetPoint("TOPRIGHT",b,"TOPRIGHT",0,0);t:SetPoint("BOTTOMRIGHT",b,"BOTTOMRIGHT",0,0);t:SetWidth(7)
  else t:SetPoint("TOPLEFT",b,"TOPLEFT",7,0);t:SetPoint("BOTTOMRIGHT",b,"BOTTOMRIGHT",-7,0)end
  b.enamelPieces[i]=t
 end
 function b:ApplyState(state)for _,piece in ipairs(self.enamelPieces)do piece:SetTexture(KIT.."Button"..state)end end
 function b:SetEnamelTint()self:ApplyState(self.selected and "Hover" or "Normal")end
 local f=text(b,17,label);f:SetAllPoints(b);f:SetWordWrap(false);f:SetJustifyH("CENTER");f:SetJustifyV("MIDDLE");b.label=f
 b.hoverWash=tex(b,nil,"OVERLAY");b.hoverWash:Hide()
 b:SetScript("OnClick",function(_,key)if not key or key=="LeftButton"then callback()end end)
 b:SetScript("OnEnter",function()b.hovered=true;b:ApplyState("Hover")end)
 b:SetScript("OnLeave",function()b.hovered=false;b:SetEnamelTint()end)
 b:SetScript("OnMouseDown",function()b:ApplyState("Pressed")end)
 b:SetScript("OnMouseUp",function()b:ApplyState(b.hovered and "Hover"or"Normal")end)
 b:SetScript("OnHide",function()b.hovered=false;b:SetEnamelTint()end)
 fit(b);return b
end
local function dropdown(b)
 b.dropdown=tex(b,WORKING.."Dropdown","OVERLAY");b.dropdown:SetSize(14,14);b.dropdown:SetPoint("RIGHT",b,"RIGHT",-10,0)
 b.label:ClearAllPoints();b.label:SetPoint("LEFT",b,"LEFT",12,0);b.label:SetPoint("RIGHT",b,"RIGHT",-30,0);b.label:SetJustifyH("LEFT")
 fit(b);return b
end
local function arrowButton(b,right)
 b.label:SetText("");b.glyph=tex(b,KIT..(right and "TriangleRight"or"TriangleLeft"),"OVERLAY");b.glyph:SetSize(22,22);b.glyph:SetPoint("CENTER",b,"CENTER",0,0);b:SetWidth(40);return b
end
local function plainMenuOption(b)
 b:SetBackdrop(nil);b.plainMenuOption=true;b:SetWidth(b:GetParent():GetWidth()-8)
 for _,piece in ipairs(b.enamelPieces) do piece:Hide() end
 b.label:ClearAllPoints();b.label:SetPoint("LEFT",b,"LEFT",10,0);b.label:SetPoint("RIGHT",b,"RIGHT",-8,0);b.label:SetJustifyH("LEFT")
 local highlight=tex(b,nil,"BACKGROUND")
 highlight:SetAllPoints(b);color(highlight,.02,.34,.29,.35);highlight:Hide();b.menuHighlight=highlight
 b:SetScript("OnEnter",function() color(highlight,.02,.34,.29,.35);highlight:Show() end)
 b:SetScript("OnLeave",function() highlight:Hide() end)
 b:SetScript("OnHide",function() highlight:Hide() end)
 b:SetScript("OnMouseDown",function() color(highlight,.02,.34,.29,.45) end)
 b:SetScript("OnMouseUp",function() color(highlight,.02,.34,.29,.35) end)
 return b
end
local function plainStepRow(row)
 row:SetBackdrop(nil);row.plainStepRow=true
 for _,piece in ipairs(row.enamelPieces) do piece:Hide() end
 row.separator=tex(row,nil,"BACKGROUND");row.separator:SetPoint("BOTTOMLEFT",row,"BOTTOMLEFT",0,0);row.separator:SetPoint("BOTTOMRIGHT",row,"BOTTOMRIGHT",0,0);row.separator:SetHeight(1);color(row.separator,.40,.24,.09,.20)
 row.stepWash=tex(row,nil,"BACKGROUND");row.stepWash:SetAllPoints(row)
 row.stepMarker=tex(row,nil,"ARTWORK");row.stepMarker:SetSize(2,20);row.stepMarker:SetPoint("LEFT",row,"LEFT",2,0);color(row.stepMarker,.02,.45,.38,1)
 function row:UpdateStepVisual()
  local active=self.selected==true;local hovered=self.stepHovered==true
  if active or hovered then color(self.stepWash,.02,.38,.32,active and .18 or .09);self.stepWash:Show() else self.stepWash:Hide() end
  self.stepMarker:SetShown(active)
  if N.sideMaterial=="parchment" then self.label:SetTextColor(.18,.105,.045) else self.label:SetTextColor(active and 1 or .94,active and .88 or .81,active and .62 or .54) end
 end
 -- Existing refresh/scroll paths still call this hook; it no longer paints enamel.
 function row:SetEnamelTint()self:UpdateStepVisual()end
 row:SetScript("OnEnter",function()row.stepHovered=true;row:UpdateStepVisual()end)
 row:SetScript("OnLeave",function()row.stepHovered=false;row:UpdateStepVisual()end)
 row:SetScript("OnHide",function()row.stepHovered=false;row:UpdateStepVisual()end)
 row:UpdateStepVisual();return row
end
local function checkbox(b,checked)
 plainMenuOption(b)
 local box=CreateFrame("Frame",nil,b);box:SetSize(20,20);box:SetPoint("LEFT",b,"LEFT",9,0);box:EnableMouse(false)
 local frame=tex(box,CLEAR.."CheckboxFrame","BORDER");frame:SetAllPoints(box)
 local shadow=tex(box,"Interface\\Buttons\\UI-CheckBox-Check","ARTWORK");shadow:SetSize(16,16);shadow:SetPoint("CENTER",box,"CENTER",1,-1);shadow:SetVertexColor(.22,.11,.02,1)
 local mark=tex(box,"Interface\\Buttons\\UI-CheckBox-Check","OVERLAY");mark:SetSize(14,14);mark:SetPoint("CENTER",box,"CENTER",0,0);mark:SetVertexColor(.98,.78,.39,1)
 b.label:ClearAllPoints();b.label:SetPoint("LEFT",b,"LEFT",37,0);b.label:SetPoint("RIGHT",b,"RIGHT",-8,0);b.label:SetJustifyH("LEFT")
 function b:SetCheckedVisual(value) if value then mark:Show();shadow:Show() else mark:Hide();shadow:Hide() end end
 b.checkbox={box=box,mark=mark,shadow=shadow,frame=frame};b:SetCheckedVisual(checked);b:SetWidth(b:GetParent():GetWidth()-8)
 b:SetBackdrop(nil);b.plainCheckbox=true
 for _,piece in ipairs(b.enamelPieces) do piece:Hide() end
 return b
end
local function menuSkin(frame)
 frame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1,insets={left=2,right=2,top=2,bottom=2}})
 frame:SetBackdropColor(.008,.009,.011,1);frame:SetBackdropBorderColor(.55,.54,.51,1)
 local fill=tex(frame,THEME.."PewterEnamel");fill:SetPoint("TOPLEFT",frame,"TOPLEFT",2,-2);fill:SetPoint("BOTTOMRIGHT",frame,"BOTTOMRIGHT",-2,2)
 fill:SetTexCoord(0,UIART.panel.u,0,UIART.panel.v);fill:SetVertexColor(.11,.12,.13,1)
end
-- Public world X points north, world Y points west.
function N.Offset(x,y) local step=session:Current();return x+(step and step.dx or 0),y+(step and step.dy or 0) end
function N.Bearing(dx,dy) return math.atan2(dy,dx) end
function N.ArrowAsset() return "Interface\\AddOns\\GrindingForever\\Media\\ForeverArrow" end
function N.ProjectedArrowAsset()return "Interface\\AddOns\\GrindingForever\\Media\\ForeverArrow"end
function N.PaintProjectedArrow(texture,angle)
 if texture.gfYawIndex~=angle then
  texture:SetRotation(angle)
  texture.gfYawIndex=angle
 end
 return angle
end
function N.RenderArrow()
 if not arrowTex or N.angle==nil then return end
 local index=N.PaintProjectedArrow(arrowTex,N.angle)
 -- One silhouette at a time: no displaced afterimage at the rear points.
 if N.arrowBlend then N.arrowBlend:SetAlpha(0)end
 N.yawFrame=index;N.yawMix=0
end

function N.SetArrowSize(value)
 local v=safeNumber(value,11,66);if not v then return false end
 v=math.floor(v+.5);N.arrowSize=v
 if ns.db then ns.db.normalArrowSize=v end
 if arrow then local side=126.3652*v/100;arrow:SetSize(side,side) end
 if sizeValue then sizeValue:SetText("") end
 if sizeSlider and sizeSlider:GetValue()~=v then syncingSlider=true;sizeSlider:SetValue(v);syncingSlider=false end
 return true
end
saveSession=function()
 if not ns.db then return end
 local state={version=1,goals={},view=N.view}
 for k,v in pairs(session.goals)do state.goals[k]=v end
 ns.db.normalGuidePreferences=state
end
function N.Anchor()target=nil;N.target=nil;N.yards=nil;pending=false;return false end
activate=function()N.step=0;N.Anchor();saveSession()end
local function defaultArrowPosition()
 arrow:ClearAllPoints();arrow:SetPoint("TOP",UIParent,"TOP",0,-30)
end
local startupRecovery=true
local function repairArrowPlacement()
 if not arrow then return end
 local l,r,b,t=arrow:GetLeft(),arrow:GetRight(),arrow:GetBottom(),arrow:GetTop()
 local width,height=UIParent:GetWidth(),UIParent:GetHeight()
 if not l or not r or not b or not t or r<=0 or l>=width or t<=0 or b>=height then
  defaultArrowPosition();if ns.db then ns.db.normalArrowPoint=nil end
  N.arrowPlacementRepaired=true
 end
end
function N.RecoverArrow()
 if not arrow then return end
 N.Anchor();repairArrowPlacement()
 arrow:SetAlpha(1);arrowTex:SetAlpha(1);arrowTex:SetTexture(N.ProjectedArrowAsset());arrowTex.gfYawIndex=nil;N.RenderArrow()
 startupRecovery=true
end
local function showArrow()if arrow then arrow:SetShown(arrowEnabled and not N.areaNavigation and N.angle~=nil and target~=nil)end end
function N.SetArrow(value)
 arrowEnabled=not not value
 if ns.db then ns.db.normalArrow=arrowEnabled end
 if N.arrowToggle then N.arrowToggle:SetCheckedVisual(arrowEnabled)end
 showArrow()
end
function N.Tick()
 target=nil;N.target=nil;N.yards=nil;N.angle=nil;N.bearing=nil;N.areaNavigation=nil;N.navigation="No guide destination"
 local destination=(P.active or ns.FarmingPlanner and ns.FarmingPlanner.route)and P.Destination()
 if destination then
  local client=ns.Retail.Client;local pos=client.PlayerPosition()
  if pos.status=="available"then
   local instance,x,y=client.WorldPosition(pos.mapID,pos.x*100,pos.y*100)
   local ti,tx,ty=client.WorldPosition(destination.mapID,destination.x,destination.y)
   local facing=client.Facing()
   if instance and ti==instance and x and y and tx and ty and facing then
    target={instance=ti,x=tx,y=ty,mapID=destination.mapID};N.target=target
    local dx,dy=tx-x,ty-y;N.yards=math.sqrt(dx*dx+dy*dy)
    N.bearing=N.Bearing(dx,dy);N.angle=N.bearing-facing;N.navigation="Destination: "..destination.name
    N.RenderArrow()
   else N.navigation="Route position unavailable"end
  else N.navigation="Position unavailable - waiting for outdoor position"end
 end
 if arrowText then arrowText:SetText(N.angle and (N.navigation.."\n"..string.format("%.0f yd - straight line",N.yards)) or "")end
 if status then status:SetText(destination and (N.angle and (N.navigation.." - "..string.format("%.0f yd",N.yards)) or N.navigation) or "")end
 showArrow()
end
-- Independent of guide refresh: smooth facing changes at the render cadence.
function N.UpdateHeading()
 if not target or N.bearing==nil then return end
 local facing=ns.Retail.Client.Facing()
 if facing==nil then N.angle=nil;showArrow();return end
 N.angle=N.bearing-facing
 N.RenderArrow()
 showArrow()
end
local function ensureArrow()
 if arrow then return end
 arrow=CreateFrame("Frame","GrindingForeverArrow",UIParent)
 arrow:SetSize(126.3652,126.3652);defaultArrowPosition();arrow:SetFrameStrata("HIGH")
 arrow:SetClampedToScreen(true);arrow:EnableMouse(true);arrow:SetMovable(true);arrow:RegisterForDrag("LeftButton")
 arrow:SetScript("OnDragStart",function(self) self:StartMoving() end)
 arrow:SetScript("OnDragStop",function(self)
  self:StopMovingOrSizing();local p,_,rp,x,y=self:GetPoint(1)
  x=safeNumber(x,-10000,10000);y=safeNumber(y,-10000,10000)
  if ns.db and x and y then ns.db.normalArrowPoint={p,rp,x,y} end
 end)
 arrowTex=tex(arrow,N.ProjectedArrowAsset(),"ARTWORK");arrowTex:SetAllPoints(arrow)
 local blend=tex(arrow,N.ProjectedArrowAsset(),"OVERLAY");blend:SetAllPoints(arrow);blend:SetAlpha(0);N.arrowBlend=blend
 arrowText=text(arrow,13,"");N.arrowCaption=arrowText;arrowText:SetPoint("TOP",arrow,"BOTTOM",0,-3);arrowText:SetWidth(290);arrowText:SetJustifyH("CENTER")
 N.arrowFrame=arrow;N.arrowTexture=arrowTex
end
local function reflowBody()
 if not bodyScroll then return end
 body:SetHeight(0)
 local height=math.max(1,body:GetStringHeight()+8);body:SetHeight(height)
 local compact=N.mode=="compact"
 if root and root.heading then
  root.heading:SetHeight(0);bodyScroll:ClearAllPoints();bodyScroll:SetPoint("TOPLEFT",root.heading,"BOTTOMLEFT",0,compact and -12 or -22)
 end
 local contentHeight=height
 local headingExtra=root and root.heading and math.max(0,root.heading:GetStringHeight()-30)or 0
 if compact then
  -- The next-step line belongs to the scrolled content, never below the fixed controls.
  if root.compactNext.SetParent then root.compactNext:SetParent(bodyContent)end
  if root.compactNextHit.SetParent then root.compactNextHit:SetParent(bodyContent)end
  root.compactNext:ClearAllPoints();root.compactNext:SetPoint("TOPLEFT",body,"BOTTOMLEFT",0,-12);root.compactNext:SetHeight(0)
  contentHeight=height+12+math.max(20,root.compactNext:GetStringHeight())
  N.maxBodyHeight=math.max(20,root.panels[2]:GetHeight()-24-root.heading:GetStringHeight()-12-180)
 end
 bodyContent:SetHeight(contentHeight)
 bodyScroll:SetHeight(math.min(contentHeight,math.max(compact and 20 or 60,(N.maxBodyHeight or 300)-(compact and 0 or headingExtra))))
 if status and root then
  status:ClearAllPoints();status:SetPoint("TOPLEFT",bodyScroll,"BOTTOMLEFT",0,compact and -12 or -16)
  status:SetWidth(bodyScroll:GetWidth());status:SetHeight(24);status:SetJustifyH("CENTER")
  if root.done and root.skip then
   root.done:ClearAllPoints();root.skip:ClearAllPoints()
   if root.done:IsShown()then
    local groupWidth=root.done:GetWidth()+root.skip:GetWidth()+12
    root.done:SetPoint("TOPLEFT",status,"BOTTOM",-groupWidth/2,-12);root.skip:SetPoint("TOPLEFT",root.done,"TOPRIGHT",12,0)
   else root.skip:SetPoint("TOP",status,"BOTTOM",0,-12)end
  end
 end
 bodyScroll:SetVerticalScroll(math.min(bodyScroll:GetVerticalScroll(),math.max(0,contentHeight-bodyScroll:GetHeight())))
end
local function layout()
 if not root or layingOut then return end
 layingOut=true
 local baseAspect=N.mode=="compact"and 496/640 or 1205.04/1000
 -- Clamp elongation at the readable minimum width, before fitting to the screen.
 local readable=(N.mode=="compact"and 210 or 563.625)/(UIParent:GetEffectiveScale()or 1)
 local screenMinimum=math.min(readable,UIParent:GetWidth()*.94)
 local heightLimit=UIParent:GetHeight()*.94*baseAspect/screenMinimum
 N.heightRatio=math.min(N.heightRatio or 1,heightLimit)
 local minimumRatio=N.mode=="compact" and N.fieldGuideMinimumHeight and N.fieldGuideMinimumHeight/640 or .7
 N.heightRatio=math.max(math.min(minimumRatio,heightLimit),math.min(heightLimit,N.mode=="compact"and 2.4 or 2.8,N.heightRatio or 1));normalAspect=baseAspect/N.heightRatio
 local maxW=math.min(UIParent:GetWidth()*.94,UIParent:GetHeight()*.94*normalAspect)
 -- Normal mode keeps its three-column layout; prevent unreadable whole-scene shrink.
 local uiScale=safeNumber(UIParent.GetEffectiveScale and UIParent:GetEffectiveScale(),.1,5) or 1
 if N.mode~="compact"then maxW=math.min(maxW,845.4375/uiScale)end
 local minW=math.min((N.mode=="compact"and 210 or 563.625)/uiScale,maxW)
 N.minimumWidthPixels=N.mode=="compact"and 210 or 563.625;N.minimumWidth=minW;N.readabilityScreenLimited=maxW*uiScale<N.minimumWidthPixels
 local visibleWidth=math.min(maxW,math.max(minW,N.dimensions and N.dimensions[1] or math.min((N.mode=="compact"and 496 or 563.625)/uiScale,UIParent:GetWidth()*.90)))
 local visibleHeight=visibleWidth/normalAspect
 if visibleWidth*uiScale<(N.mode=="compact"and 200 or 420) or visibleHeight*uiScale<(N.mode=="compact"and 130 or 200) then host:Hide();layingOut=false;return false end
 host:SetSize(visibleWidth,visibleHeight)
 if N.dimensions then
  N.dimensions={visibleWidth,visibleHeight}
  if ns.db then ns.db.normalFrameSize={visibleWidth,visibleHeight} end
 end
 if host.SetResizeBounds then host:SetResizeBounds(minW,minW/normalAspect,maxW,maxW/normalAspect) end
 local w=N.mode=="compact"and 496 or 1205.04;local h=w/normalAspect
 root:SetSize(w,h);root:SetScale(visibleWidth/w);N.layoutScale=visibleWidth/w
 root:ClearAllPoints();root:SetPoint("TOPLEFT",host,"TOPLEFT",0,0)
 local gap=0;local left=388;local right=484;local center=w-(left-4)-(right-4)-16
 if N.mode=="compact"then left=4;right=4;center=w-16 end
 local top=N.mode=="compact"and 145 or 170;local bh=h-top-10
 local p=root.panels
 p[1]:ClearAllPoints();p[1]:SetPoint("TOPLEFT",root,"TOPLEFT",8,-top);p[1]:SetSize(left-4,bh)
 p[2]:ClearAllPoints();p[2]:SetPoint("TOPLEFT",p[1],"TOPRIGHT",gap,0);p[2]:SetSize(center,bh)
 p[3]:ClearAllPoints();p[3]:SetPoint("TOPLEFT",p[2],"TOPRIGHT",gap,0);p[3]:SetSize(right-4,bh)
 p[1]:SetShown(N.mode=="normal");p[3]:SetShown(N.mode=="normal")
 if N.mode=="compact"then p[2]:ClearAllPoints();p[2]:SetPoint("TOPLEFT",root,"TOPLEFT",8,-top)end
 for _,panel in ipairs(p) do
  C.LayoutBorder(panel,14)
  panel.fill:ClearAllPoints();panel.fill:SetPoint("TOPLEFT",panel,"TOPLEFT",3,-3);panel.fill:SetPoint("BOTTOMRIGHT",panel,"BOTTOMRIGHT",-3,3)
 end
 -- End side-panel backgrounds strictly inside the bevels, never under/outside them.
 p[1].fill:ClearAllPoints();p[1].fill:SetPoint("TOPLEFT",p[1],"TOPLEFT",8,-13);p[1].fill:SetPoint("BOTTOMRIGHT",p[1],"BOTTOMRIGHT",-7,6)
 p[3].fill:ClearAllPoints();p[3].fill:SetPoint("TOPLEFT",p[3],"TOPLEFT",7,-13);p[3].fill:SetPoint("BOTTOMRIGHT",p[3],"BOTTOMRIGHT",-8,6)
 -- Hide adjoining rails: each junction has one shared continuous metal divider.
 p[1].phaseBBorder.pieces.RIGHT:Hide();p[2].phaseBBorder.pieces.LEFT:Hide()
 p[2].phaseBBorder.pieces.RIGHT:Hide();p[3].phaseBBorder.pieces.LEFT:Hide()
 for i,divider in ipairs(root.dividers) do
  divider:ClearAllPoints();divider:SetPoint("TOP",p[i],"TOPRIGHT",0,0);divider:SetSize(9.34875,bh-4)
  for _,piece in pairs(divider.phaseBBorder.pieces) do piece:Hide() end
  divider.rail:SetAllPoints(divider);divider.rail:SetTexCoord(unpack(FRAME.rail))
 end
 root.phaseBShell:ClearAllPoints();root.phaseBShell:SetPoint("TOPLEFT",root,"TOPLEFT",0,-top+2)
 root.phaseBShell:SetPoint("BOTTOMRIGHT",root,"BOTTOMRIGHT",0,0)
 C.LayoutOuter(root)
 -- Junction caps own the corner appearance; avoid duplicate old corner art.
 for _,name in ipairs({"TOPLEFT","TOPRIGHT","BOTTOMLEFT","BOTTOMRIGHT"}) do
  root.phaseBShell.phaseBBorder.pieces[name]:Hide()
  for _,panel in ipairs(p) do panel.phaseBBorder.pieces[name]:Hide() end
 end
 -- Continue horizontal strips behind the smaller connector caps.
 for _,panel in ipairs(p) do
  for _,name in ipairs({"TOP","BOTTOM"}) do
   local strip=panel.phaseBBorder.pieces[name];strip:ClearAllPoints()
   strip:SetPoint(name=="TOP" and "TOPLEFT" or "BOTTOMLEFT",panel,name=="TOP" and "TOPLEFT" or "BOTTOMLEFT",6,name=="TOP" and -2 or 2)
   strip:SetWidth(panel:GetWidth()-12)
  end
 end
 local junction=snapArt(root,15);N.junctionSize=junction
 if N.close then N.close.phaseBClose.texture:SetSize(junction,junction) end
 local junctionX={9,p[1]:GetWidth()+8,p[1]:GetWidth()+p[2]:GetWidth()+8,w-9}
 local index=1
 for row=1,2 do for column=1,4 do
  if not (row==1 and column==4) then
   local connector=root.connectors[index];connector:SetSize(junction,junction);connector:ClearAllPoints()
   connector:SetPoint("CENTER",root,"TOPLEFT",junctionX[column],row==1 and -top-6 or -h+9)
   connector.junctionRow=row;connector.junctionColumn=column;index=index+1
  end
 end end
 -- Identical component geometry at each matching junction; no outboard arms.
 local shoulder=1
 for row=1,2 do for column=1,4 do
  local isCorner=column==1 or column==4
  local directions={}
  if column>1 then directions[#directions+1]="LEFT" end
  if column<4 then directions[#directions+1]="RIGHT" end
  directions[#directions+1]=row==1 and "DOWN" or "UP"
  for _,direction in ipairs(directions) do
   local t=root.shoulders[shoulder];shoulder=shoulder+1
   local length=isCorner and 21.5 or 12.5;local depth=isCorner and 4.5 or 3.25
   t:SetTexture(WORKING..(isCorner and "TripleShoulder" or "SingleShoulder"))
   local x,y=junctionX[column],row==1 and -top-6 or -h+9
   t:ClearAllPoints()
   if direction=="RIGHT" then t:SetSize(length,depth);t:SetPoint("LEFT",root,"TOPLEFT",x,y);t:SetTexCoord(0,1,0,1)
   elseif direction=="LEFT" then t:SetSize(length,depth);t:SetPoint("RIGHT",root,"TOPLEFT",x,y);t:SetTexCoord(1,0,0,1)
   elseif direction=="DOWN" then t:SetSize(depth,length);t:SetPoint("TOP",root,"TOPLEFT",x,y);t:SetTexCoord(0,1,1,1,0,0,1,0)
   else t:SetSize(depth,length);t:SetPoint("BOTTOM",root,"TOPLEFT",x,y);t:SetTexCoord(1,0,0,0,1,1,0,1) end
   t.junctionRow=row;t.junctionColumn=column;t.direction=direction;t.shoulderType=isCorner and "triple" or "single"
  end
 end end
 -- Use one continuous rim on each edge; remove duplicate inner rail outlines.
 for _,panel in ipairs(p) do for _,piece in pairs(panel.phaseBBorder.pieces) do piece:Hide() end end
 local outer=root.phaseBShell.phaseBBorder.pieces
 local function strip(name,x,y,width,height)
  local t=outer[name];t:ClearAllPoints();t:SetPoint("TOPLEFT",root,"TOPLEFT",x,y);t:SetSize(width,height);rail(t,name)
 end
 local depth=snapArt(root,6)
 strip("TOP",9,-top-6+depth/2,w-18,depth)
 strip("BOTTOM",9,-h+9+depth/2,w-18,depth)
 strip("LEFT",9-depth/2,-top-6,depth,h-top-15)
 strip("RIGHT",w-9-depth/2,-top-6,depth,h-top-15)
 for _,divider in ipairs(root.dividers) do rail(divider.rail,"LEFT") end
 -- Source alpha/proportions preserved: complete sculptures sit above the rail.
 local cw=N.mode=="compact"and 160 or 194;local capHeight=cw*282/482
 -- Clamp the visible sculpture tops, not the obsolete transparent header space.
 -- Clamp offsets use host units; artwork dimensions above use canonical scene units.
 local topBlank=math.max(0,top+4-capHeight)*N.layoutScale
 N.visibleTopInset=topBlank
 if host.SetClampRectInsets then host:SetClampRectInsets(0,0,-topBlank,0) end
 for i,cap in ipairs(root.endcaps) do
  cap:SetSize(cw,capHeight);cap:ClearAllPoints()
  if N.mode=="compact"then cap:SetPoint("BOTTOM",p[2],i==1 and "TOPLEFT"or "TOPRIGHT",i==1 and cw/2 or -cw/2,-4)
  else cap:SetPoint("BOTTOM",p[i==1 and 1 or 2],"TOPRIGHT",0,-4)end
 end
 -- Lower the wood behind the lower bodies, rather than compressing the animals.
 local woodInset=cw*.15;local headerHeight=40
 root.wood:ClearAllPoints();root.wood:SetPoint("TOPLEFT",p[2],"TOPLEFT",woodInset,headerHeight-3)
 root.wood:SetPoint("BOTTOMRIGHT",p[2],"TOPRIGHT",-woodInset,-3)
 root.bannerFrame:ClearAllPoints();root.bannerFrame:SetPoint("TOPLEFT",root.wood,"TOPLEFT",-2,2)
 root.bannerFrame:SetPoint("BOTTOMRIGHT",root.wood,"BOTTOMRIGHT",2,-2)
 C.LayoutBorder(root.bannerFrame,7)
 for name,piece in pairs(root.bannerFrame.phaseBBorder.pieces) do
  piece:Hide()
 end
 root.headerTopRail:ClearAllPoints();root.headerTopRail:SetPoint("BOTTOMLEFT",root.wood,"TOPLEFT",0,-2.325625)
 root.headerTopRail:SetPoint("BOTTOMRIGHT",root.wood,"TOPRIGHT",0,-2.325625);root.headerTopRail:SetHeight(9.34875);rail(root.headerTopRail,"TOP")
 root.titleMetal:Hide();root.foreverCrest:Hide();title:Hide()
 local titleSize=math.min(38,headerHeight*.62)
 for _,f in ipairs({root.titleLeft,root.titleRight})do f:SetFont("Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf",titleSize,"");f:SetTextColor(.93,.73,.37);f:SetHeight(headerHeight);f:SetWidth(230)end
 root.headerEmblem:ClearAllPoints();root.headerEmblem:SetPoint("CENTER",root.wood,"CENTER",0,0);root.headerEmblem:SetSize(headerHeight*.88,headerHeight*.88)
 root.titleLeft:ClearAllPoints();root.titleLeft:SetPoint("RIGHT",root.headerEmblem,"LEFT",-8,0);root.titleLeft:SetJustifyH("RIGHT")
 root.titleRight:ClearAllPoints();root.titleRight:SetPoint("LEFT",root.headerEmblem,"RIGHT",8,0)
 N.headerHeight=headerHeight;root.headerDrag:ClearAllPoints();root.headerDrag:SetHeight(headerHeight);root.headerDrag:SetAllPoints(root.wood)
 root.backdrop:ClearAllPoints();root.backdrop:SetPoint("TOPLEFT",root,"TOPLEFT",9,-top-6)
 root.backdrop:SetPoint("BOTTOMRIGHT",root,"BOTTOMRIGHT",-9,9)
 -- Keep the supplied fine grain near native pixel scale across one shared material field.
 local bw,bh=w-18,h-top-15;local tileW,tileH=534,534;local tileIndex=0
 local u0,u1=48/2048,1206/2048;local v0,v1=48/2048,1206/2048
 root.leatherTiles=root.leatherTiles or {}
 for row=0,math.ceil(bh/tileH)-1 do for column=0,math.ceil(bw/tileW)-1 do
  tileIndex=tileIndex+1;local piece=root.leatherTiles[tileIndex]
  if not piece then piece=tex(root,"Interface\\AddOns\\GrindingForever\\Media\\BaseParchment","BACKGROUND");piece:SetDrawLayer("BACKGROUND",1);root.leatherTiles[tileIndex]=piece end
  local width,height=math.min(tileW,bw-column*tileW),math.min(tileH,bh-row*tileH)
  local us=column%2==0 and u0 or u1;local vs=row%2==0 and v0 or v1
  local ue=us+(column%2==0 and 1 or -1)*(u1-u0)*width/tileW
  local ve=vs+(row%2==0 and 1 or -1)*(v1-v0)*height/tileH
  piece:ClearAllPoints();piece:SetPoint("TOPLEFT",root,"TOPLEFT",9+column*tileW,-top-6-row*tileH);piece:SetSize(width,height)
  piece:SetTexCoord(us,ue,vs,ve);piece:SetVertexColor(.88,.76,.85,1);piece:Show()
 end end
 for i=tileIndex+1,#root.leatherTiles do root.leatherTiles[i]:Hide() end
 N.close:ClearAllPoints();N.close:SetPoint("CENTER",root,"TOPLEFT",w-9,-top-6)
 root.controls:ClearAllPoints();root.controls:SetPoint("BOTTOMLEFT",p[2],"BOTTOMLEFT",30,32)
 root.controls:SetPoint("BOTTOMRIGHT",p[2],"BOTTOMRIGHT",-30,32);root.controls:SetHeight(40)
 root.modeButton.label:SetText(N.mode=="compact"and "Normal"or "Compact")
 local controlList={root.back,root.stepButton,root.forward,root.reset,root.settings,root.modeButton}
 local total=0
 for _,b in ipairs(controlList) do
  b:SetHeight(36);if b.glyph then b:SetWidth(42) else fit(b,28) end
  total=total+b:GetWidth()+6
 end
 local x=(center-60-total+6)/2
 for _,b in ipairs(controlList) do b:ClearAllPoints();b:SetPoint("LEFT",root.controls,"LEFT",x,0);x=x+b:GetWidth()+6 end
 root.viewButton:Hide();viewMenu:Hide()
 local available=p[1]:GetWidth()-56-18;local minimum=0
 for _,b in ipairs(root.filterButtons)do minimum=minimum+fit(b,22)end
 local extra=math.max(0,(available-minimum)/4);local fx=28
 for _,b in ipairs(root.filterButtons)do b:SetWidth(b:GetWidth()+extra);b:SetHeight(38);b:ClearAllPoints();b:SetPoint("TOPLEFT",p[1],"TOPLEFT",fx,-116);fx=fx+b:GetWidth()+6 end
 N.rowCount=13
 local bodyWidth=math.max(100,center-80)
 body:SetWidth(bodyWidth);bodyContent:SetWidth(bodyWidth)
 bodyScroll:SetWidth(bodyWidth);N.maxBodyHeight=math.max(60,bh-(N.mode=="compact"and 350 or 360));bodyScroll:SetHeight(N.maxBodyHeight)
 root.infoTitle:SetShown(N.mode=="normal");stepLabel:SetShown(N.mode=="normal")
 root.compactDetails:SetShown(N.mode=="compact");root.compactDetails:ClearAllPoints();root.compactDetails:SetPoint("TOPRIGHT",p[2],"TOPRIGHT",-40,N.mode=="compact"and -20 or -36)
 root.heading:ClearAllPoints();root.heading:SetPoint("TOPLEFT",p[2],"TOPLEFT",40,N.mode=="compact"and -24 or -112);root.heading:SetPoint("RIGHT",p[2],"RIGHT",N.mode=="compact"and -132 or -40,0)
 root.compactNext:SetShown(N.mode=="compact");root.compactNextHit:SetShown(N.mode=="compact");root.compactNext:SetWidth(bodyWidth)
 for _,divider in ipairs(root.dividers)do divider:SetShown(N.mode=="normal")end
 if N.mode=="compact"then
  for i,c in ipairs(root.connectors)do c:SetShown(i==1 or i==3 or i==4)end
  root.connectors[1]:ClearAllPoints();root.connectors[1]:SetPoint("CENTER",root,"TOPLEFT",9,-top-6)
  root.connectors[3]:ClearAllPoints();root.connectors[3]:SetPoint("CENTER",root,"TOPLEFT",9,-h+9)
  root.connectors[4]:ClearAllPoints();root.connectors[4]:SetPoint("CENTER",root,"TOPLEFT",w-9,-h+9)
  for _,t in ipairs(root.shoulders)do t:Hide()end
 else for _,c in ipairs(root.connectors)do c:Show()end;for _,t in ipairs(root.shoulders)do t:Show()end end
 if root.heading.SetMaxLines then root.heading:SetMaxLines(N.mode=="compact"and 2 or 0)end;local headingFont=select(1,root.heading:GetFont());root.heading:SetFont(headingFont,(math.max(18,math.min(26,bodyWidth/24)))+1,"")
 reflowBody()
 for _,b in ipairs(root.leftButtons or {}) do fit(b,24,left-44) end
 if root.leftButtons[1]then root.leftButtons[1]:SetWidth(math.min(240,left-56))end
 for _,b in ipairs(root.playOptions or {}) do b:SetWidth(playMenu:GetWidth()-8) end
 for _,b in ipairs(root.viewOptions or {}) do b:SetWidth(viewMenu:GetWidth()-8) end
 if root.zoneButton then root.zoneButton:SetWidth(p[3]:GetWidth()-56)end
 if root.sourceButton and root.professionButton then
  local usable=p[3]:GetWidth()-56-10;root.sourceButton:SetWidth(math.floor(usable*.46));root.professionButton:SetWidth(usable-math.floor(usable*.46))
  root.professionButton:ClearAllPoints();root.professionButton:SetPoint("LEFT",root.sourceButton,"RIGHT",10,0)
 end
 if root.actionDivider then
  root.actionDivider:ClearAllPoints();root.actionDivider:SetPoint("BOTTOMLEFT",root.controls,"TOPLEFT",0,12);root.actionDivider:SetPoint("BOTTOMRIGHT",root.controls,"TOPRIGHT",0,12);root.actionDivider:SetHeight(1)
 end
 if root.recipeMap then root.recipeMap:SetHeight(math.max(100,math.min((p[3]:GetWidth()-72)/1.5+16,bh*.44)));C.LayoutBorder(root.recipeMap,14) end
 if N.RefreshRecipes then N.RefreshRecipes();N.UpdateMapView() end
 if N.Refresh then N.Refresh(true) end
 if ns.ForeverUI and ns.ForeverUI.Layout then ns.ForeverUI.Layout()end
 layingOut=false
 return true
end
function N.SetMode(mode)
 if mode~="normal"and mode~="compact"then return false end
 if mode==N.mode then return true end
 N.modeDimensions[N.mode]={host:GetWidth(),host:GetHeight()};N.modeHeights=N.modeHeights or {};N.modeHeights[N.mode]=N.heightRatio or 1
 N.heightRatio=N.modeHeights[mode]or 1;N.mode=mode;N.dimensions=N.modeDimensions[mode]
 if ns.db then ns.db.normalWindowMode=mode end
 layout();return true
end
local function centerRoot()
 host:ClearAllPoints();host:SetPoint("CENTER",UIParent,"CENTER",0,-10)
end
function N.CompactSummary(node)
 if not node then return ""end
 local skill=node.profession and P.skills[node.profession]
 if node.profession=="Fishing"and skill and skill.rank<skill.cap and node.destination then
  local d=node.destination
  return string.format("Fish near %s (%.2f, %.2f). Skill %d/%d; aim for %d. Basic Fishing Pole, no lure. This is an approach anchor: confirm a clear, accessible shore. Fish may escape; keep useful catches for Cooking.",d.name,d.x,d.y,skill.rank,skill.cap,node.target)
 end
 local value=(node.body or ""):gsub("\n+"," "):gsub("%s+"," ")
 if #value>360 then value=value:sub(1,360):match("^(.*)%s")or value:sub(1,360);value=value.." ..."end
 return value
end
function N.Refresh(skipTick)
 if not root or refreshing then return end
 refreshing=true
 local visible=session:Visible();session:Reconcile(visible);N.visible=visible;N.step=session.index or 0
 local selected=1
 for i,s in ipairs(visible) do if s.id==session.index then selected=i end end
 local count=N.rowCount or 8
 N.rowStart=math.max(1,math.min(N.rowStart or 1,math.max(1,#visible-count+1)))
 if selected<N.rowStart then N.rowStart=selected elseif selected>=N.rowStart+count then N.rowStart=selected-count+1 end
 local shown=N.LayoutStepRows(visible,N.rowStart)
 if N.mode=="normal"and selected>=N.rowStart+shown and shown>0 then N.rowStart=selected;N.LayoutStepRows(visible,N.rowStart)end
 local nextNode=visible[selected+1]
 root.compactNextID=nextNode and nextNode.id;root.compactNextHit:EnableMouse(nextNode~=nil)
 root.compactNext:SetText(nextNode and("Next: "..liveObjective(nextNode).title)or "No next step in this view")

 for i,b in ipairs(root.filterButtons)do b.selected=i==N.view;b:SetEnamelTint()end
 local node=session:Current(visible);P.selected=node;node=liveObjective(node)
 if P.active or ns.FarmingPlanner and ns.FarmingPlanner.route then
  root.listNote:SetText((ns.FarmingPlanner and ns.FarmingPlanner.route and "Farming circuit - "or "")..#visible.." remaining steps")
  stepLabel:SetText("Forever - level "..tostring(P.character.level).." - "..(node and node.kind or "route"))
  root.heading:SetText(node and node.title or "No remaining steps in this view")
  if N.compactStep~=session.index then N.compactExpanded=false;N.compactStep=session.index end
  body:SetText(node and(N.mode=="compact"and not N.compactExpanded and N.CompactSummary(node)or node.body)or "Choose All or another filter to see remaining steps.")
  root.compactDetails.label:SetText(N.compactExpanded and "Less"or "Details")
 else
  root.listNote:SetText("Forever guide preparation")
  stepLabel:SetText("Quest guide authoring")
  root.heading:SetText("Guide unavailable for this character")
  body:SetText("Your Forever Factoruide guide is pending. Profession and collection recommendations use verified Forever sources.")
 end
 for _,b in ipairs({root.back,root.stepButton,root.forward})do b:EnableMouse(P.active or ns.FarmingPlanner and ns.FarmingPlanner.route~=nil);b:SetAlpha((P.active or ns.FarmingPlanner and ns.FarmingPlanner.route)and 1 or .45)end
 if root.done then root.done:SetShown(node~=nil and node.kind~='objective' and node.kind~='accept' and node.kind~='turnin') end
 reflowBody();showArrow();refreshing=false
 if not skipTick then N.Tick() end
end
local zoneNames={};for name in pairs(ns.ForeverData.zones)do zoneNames[#zoneNames+1]=name end;table.sort(zoneNames)
N.zones=zoneNames;N.zoneStart=1
local mapCatalog=ns.ForeverData.zones
N.mapCatalog=mapCatalog
local sourceNames={"Drop","Treasure","Vendor","Quest","Trainer"}
N.sourceNames=sourceNames;N.sourceFilters={};for _,name in ipairs(sourceNames) do N.sourceFilters[name]=true end
local professionNames={"Alchemy","Blacksmithing","Cooking","Enchanting","Engineering","First Aid","Fishing","Herbalism","Leatherworking","Mining","Skinning","Tailoring"}
N.professionNames=professionNames;N.professionFilters={};for _,name in ipairs(professionNames) do N.professionFilters[name]=true end
N.recipeRecords={}
function N.ShowInfoTooltip(owner,message)
 if not root or not root.infoTooltip then return end
 local tip=root.infoTooltip;tip:ClearAllPoints();tip:SetPoint("BOTTOM",owner,"TOP",0,8);tip.text:SetText(message);tip:SetHeight(tip.text:GetStringHeight()+20);tip:Show()
end
function N.HideInfoTooltip()if root and root.infoTooltip then root.infoTooltip:Hide()end end
function N.SourceFactionAllowed(loc,record,kind,faction)
 -- Enemy creatures may still drop recipes; faction gates apply to friendly interactions.
 if kind~="Vendor" and kind~="Trainer" and kind~="Quest" then return true end
 local restriction=loc.faction or record.faction
 if restriction=="Alliance" or restriction=="Horde" then return restriction==(faction or ns.Faction()) end
 if restriction=="Hostile" then return false end
 return true
end
function N.MatchingRecipes(records,zone,allZones)
 local out={};local faction=ns.Faction()
 for _,record in ipairs(records or {}) do
  if (allZones or record.zone==zone) and (record.profession==nil or N.professionFilters[record.profession]) then
   local matches=false
   if record.locations then
    for _,loc in ipairs(record.locations) do if N.sourceFilters[loc.source] and N.SourceFactionAllowed(loc,record,loc.source,faction) then matches=true;break end end
   else
    for _,source in ipairs(record.sources or {record.source or "Unknown"}) do if N.sourceFilters[source] and N.SourceFactionAllowed(record,record,source,faction) then matches=true;break end end
   end
   if matches then out[#out+1]=record end
  end
 end
 return out
end
function N.RecipeLocation(record)
 if not record then return nil end
 local faction=ns.Faction()
 if record.locations then for _,loc in ipairs(record.locations) do if N.sourceFilters[loc.source] and N.SourceFactionAllowed(loc,record,loc.source,faction) and loc.x and loc.y then return loc end end;return nil end
 for _,source in ipairs(record.sources or {record.source or "Unknown"}) do if N.sourceFilters[source] and N.SourceFactionAllowed(record,record,source,faction) and record.x and record.y then return record end end
end
function N.SetProfession(name,value)
 if N.professionFilters[name]==nil then return false end
 N.professionFilters[name]=not not value
 if ns.db then ns.db.normalRecipeProfessions=ns.db.normalRecipeProfessions or {};ns.db.normalRecipeProfessions[name]=not not value end
 for _,b in ipairs(root.professionOptions or {}) do b:SetCheckedVisual(N.professionFilters[b.professionName]) end
 N.RefreshRecipes();return true
end
function N.CloseMenusOutside(over)
 over=over or function(frame)
  -- The former MouseIsOver global is absent on current clients. Never
  -- interpret a missing hit-test API as an outside click.
  if InputUtil and type(InputUtil.IsMouseOver)=="function" then return InputUtil.IsMouseOver(frame) end
  if type(frame.IsMouseOver)=="function" then return frame:IsMouseOver() end
  if type(MouseIsOver)=="function" then return MouseIsOver(frame) end
  if type(GetCursorPosition)=="function" then
   local x,y=GetCursorPosition();local scale=frame:GetEffectiveScale();local left,bottom=frame:GetLeft(),frame:GetBottom()
   if type(x)=="number" and type(y)=="number" and type(scale)=="number" and scale>0 and type(left)=="number" and type(bottom)=="number" then
    x=x/scale;y=y/scale;return x>=left and x<=left+frame:GetWidth() and y>=bottom and y<=bottom+frame:GetHeight()
   end
  end
  return nil
 end
 for _,entry in ipairs(N.dropdownMenus or {}) do
  if entry[1]:IsShown() then
   local menuOver,buttonOver=over(entry[1]),over(entry[2])
   if menuOver==false and buttonOver==false then entry[1]:Hide();if entry[1]==N.searchMenu and root.recipeSearch then root.recipeSearch:ClearFocus() end end
  end
 end
 if root and root.recipeSearch and root.recipeSearch:HasFocus() then
  local popupOver=root.searchPopup:IsShown() and over(root.searchPopup) or false
  if over(root.recipeSearch)==false and popupOver==false then root.recipeSearch:ClearFocus();root.searchPopup:Hide() end
 end
end
local requestedRecipeItems={}
local function recipeIcon(record)
 local icon=record.icon and ("Interface\\Icons\\"..record.icon) or "Interface\\Icons\\INV_Misc_QuestionMark"
 if record.productID then
  local itemIcon
  if C_Item and C_Item.GetItemIconByID then itemIcon=C_Item.GetItemIconByID(record.productID) elseif type(GetItemIcon)=="function" then itemIcon=GetItemIcon(record.productID) end
  if itemIcon then icon=itemIcon
  elseif C_Item and C_Item.RequestLoadItemDataByID and not requestedRecipeItems[record.productID] then requestedRecipeItems[record.productID]=true;C_Item.RequestLoadItemDataByID(record.productID) end
 end
 return icon
end
function N.RefreshRecipeIcons()
 for _,row in ipairs(root and root.recipeRows or {}) do if row.record and row:IsShown() then row.icon:SetTexture(recipeIcon(row.record)) end end
end
N.mapZoom=1;N.mapCenterX=.5;N.mapCenterY=.5
function N.MapToViewport(x,y)
 return .5+(x-N.mapCenterX)*N.mapZoom,.5+(y-N.mapCenterY)*N.mapZoom
end
function N.UpdateMapView()
 if not root or not root.mapViewport then return end
 local entry=N.selectedZone and mapCatalog[N.selectedZone]
 if not entry then root.recipePin:Hide();return end
 local sx,sy=1,1;if N.MapScales then sx,sy=N.MapScales()else sx=N.mapZoom;sy=N.mapZoom end
 local hx,hy=.5/sx,.5/sy
 N.mapCenterX=math.max(hx,math.min(1-hx,N.mapCenterX));N.mapCenterY=math.max(hy,math.min(1-hy,N.mapCenterY))
 ns.RenderForeverMap(N,root)
 local record=N.selectedRecipe;local loc=N.RecipeLocation(record)
 if record and record.zone==N.selectedZone and loc then
  local x,y=N.MapToViewport(loc.x/100,loc.y/100)
  if x>=0 and x<=1 and y>=0 and y<=1 then
   root.recipePin:ClearAllPoints();root.recipePin:SetPoint("BOTTOM",root.mapViewport,"TOPLEFT",x*root.mapViewport:GetWidth(),-y*root.mapViewport:GetHeight());root.recipePin:Show()
  else root.recipePin:Hide() end
 else root.recipePin:Hide() end
end
function N.ZoomMap(value,u,v)
 if not (N.selectedZone and mapCatalog[N.selectedZone]) then return false end
 value=safeNumber(value,1,8);if not value then return false end
 u=u or .5;v=v or .5
 local x=N.mapCenterX+(u-.5)/N.mapZoom;local y=N.mapCenterY+(v-.5)/N.mapZoom
 N.mapZoom=value;N.mapCenterX=x-(u-.5)/value;N.mapCenterY=y-(v-.5)/value;N.UpdateMapView();return true
end
function N.PanMap(dx,dy)
 N.mapCenterX=N.mapCenterX-dx/N.mapZoom;N.mapCenterY=N.mapCenterY-dy/N.mapZoom;N.UpdateMapView()
end
local function mapCursor()
 if type(GetCursorPosition)~="function" then return .5,.5 end
 local x,y=GetCursorPosition();local viewport=root.mapViewport;local scale=viewport:GetEffectiveScale()
 return math.max(0,math.min(1,(x/scale-viewport:GetLeft())/viewport:GetWidth())),math.max(0,math.min(1,1-(y/scale-viewport:GetBottom())/viewport:GetHeight()))
end
function N.SelectRecipe(key)
 if N.selectedRecipe and (N.selectedRecipe.id or N.selectedRecipe.name)==key then N.selectedRecipe=nil
 else N.selectedRecipe=nil;for _,record in ipairs(N.visibleRecipes or {}) do if (record.id or record.name)==key then N.selectedRecipe=record;break end end end
 local loc=N.RecipeLocation(N.selectedRecipe);if loc then N.mapCenterX=loc.x/100;N.mapCenterY=loc.y/100 end
 N.RefreshRecipes();N.UpdateMapView()
end
local function recipeDetails(record)
 local function price(copper)
  if copper==nil then return "Price not verified" end
  local gold=math.floor(copper/10000);local silver=math.floor(copper/100)%100;local coins=copper%100
  return (gold>0 and gold.."g " or "")..(silver>0 and silver.."s " or "")..coins.."c"
 end
 local lines={record.profession or "Recipe",record.confidence or "Source details not connected."};local faction=ns.Faction()
 if record.requirement then lines[#lines+1]="Requires: "..record.requirement end
 if record.locations then
  local pin=N.RecipeLocation(record);if pin then lines[#lines+1]="Map pin: "..pin.name end
  for _,loc in ipairs(record.locations) do if N.sourceFilters[loc.source] and N.SourceFactionAllowed(loc,record,loc.source,faction) then
   lines[#lines+1]="";lines[#lines+1]=loc.source..": "..loc.name..((loc.faction or record.faction) and (" ["..(loc.faction or record.faction).."]") or ((loc.source=="Vendor" or loc.source=="Trainer" or loc.source=="Quest") and " [Faction not verified]" or ""))
   if loc.quest then lines[#lines+1]="Quest: "..loc.quest end
   lines[#lines+1]=loc.x and string.format("%.2f, %.2f",loc.x,loc.y) or "Coordinates not verified � no pin"
   if loc.source=="Vendor" or loc.source=="Trainer" then lines[#lines+1]="Listed price: "..(loc.costText or price(loc.costCopper)) end
  end end
 elseif record.vendor then
  lines[#lines+1]="Vendor: "..record.vendor;lines[#lines+1]=record.place.." � "..string.format("%.1f, %.1f",record.x,record.y);lines[#lines+1]="Listed price: "..price(record.costCopper)
 elseif record.acquisition then lines[#lines+1]=record.acquisition;lines[#lines+1]="Price and coordinates not verified � no pin" end
 lines[#lines+1]="";lines[#lines+1]="Prices and stock may vary."
 if record.sourceURL then lines[#lines+1]=record.sourceURL:find("wowhead",1,true) and "Reference: Forever (see source)" or record.sourceURL:find("undrwrldcub",1,true) and "Source: Forever Wiki report" or "Source: verified Forever record" end
 return table.concat(lines,"\n")
end
N.unlocatedRecipes={}
ns.BindForeverRecipes(N)
local recipeSearchCache={}
local function searchWords(value)
 local words={};for word in string.lower(value or ""):gmatch("[%w]+") do words[#words+1]=word end;return words
end
local function matchesSearch(words,tokens)
 for _,token in ipairs(tokens) do local found=false;for _,word in ipairs(words) do if word:sub(1,#token)==token then found=true;break end end;if not found then return false end end
 return #tokens>0
end
function N.SearchRecipes(query)
 local tokens=searchWords(query);if #tokens==0 then return {} end
 local groups={};local results={}
 local candidates=N.MatchingRecipes(N.recipeRecords,nil,true)
 if false then for _,r in ipairs(N.unlocatedRecipes) do if N.professionFilters[r.profession] then candidates[#candidates+1]=r end end end
 for _,record in ipairs(candidates) do
  local cached=recipeSearchCache[record]
  if not cached then local name=record.name:gsub("^Recipe: ","");cached={name=name,words=searchWords(name)};recipeSearchCache[record]=cached end
  if matchesSearch(cached.words,tokens) then
   local key=(record.profession or "Recipe")..":"..tostring(record.productID or record.spellID or cached.name)
   local result=groups[key]
   if not result then result={name=cached.name,profession=record.profession or "Recipe",records={},zones={},zoneCount=0};groups[key]=result;results[#results+1]=result end
   result.records[#result.records+1]=record
   if record.zone and not result.zones[record.zone] then result.zones[record.zone]=true;result.zoneCount=result.zoneCount+1 end
  end
 end
 table.sort(results,function(a,b)if a.name==b.name then return a.profession<b.profession end;return a.name<b.name end)
 for _,result in ipairs(results) do table.sort(result.records,function(a,b)return (a.zone or "~")<(b.zone or "~") end) end
 return results
end
function N.RefreshSearchMenu(force)
 if not root or not root.searchPopup then return end
 local menu=root.searchPopup;local query=N.searchQuery or "";local tokens=searchWords(query)
 root.searchPlaceholder:SetShown(query=="")
 N.searchMatches=N.SearchRecipes(query)
 if #tokens==0 then menu:Hide();return end
 local count=#N.searchMatches;N.searchActiveIndex=math.max(1,math.min(N.searchActiveIndex or 1,math.max(1,count)));local start=math.max(1,math.min(N.searchStart or 1,math.max(1,count-6)));N.searchStart=start
 local visible=math.min(7,count);menu:SetHeight(visible*38+30)
 for i,b in ipairs(root.searchRows) do
  local index=start+i-1;local result=N.searchMatches[index];b.resultIndex=index;b.result=result
  if result and i<=visible then
   b:SetWidth(menu:GetWidth()-8);b.label:SetText(result.name)
   b.meta:SetText(result.profession.." � "..(result.zoneCount==0 and "Location not recorded" or result.zoneCount==1 and result.records[1].zone or result.zoneCount.." zones"))
   b.menuHighlight:SetShown(index==(N.searchActiveIndex or 1));b:Show()
  else b:Hide() end
 end
 root.searchNote:SetWidth(menu:GetWidth()-20);root.searchNote:SetText(count==0 and "No matching recipes for these filters." or count.." matching recipes"..(count>7 and " � Scroll for more" or ""))
 if force or menu:IsShown() or root.recipeSearch:HasFocus() then menu:Show() end
end
function N.SetSearchQuery(query)
 N.searchQuery=type(query)=="string" and query:sub(1,120) or "";N.searchStart=1;N.searchActiveIndex=1
 if N.searchQuery=="" and N.unlocatedRecipe then N.unlocatedRecipe=nil;N.selectedRecipe=nil;N.RefreshRecipeMap();N.RefreshRecipes() end
 N.RefreshSearchMenu(true)
end
function N.ScrollSearch(delta)
 N.searchStart=math.max(1,math.min((N.searchStart or 1)+delta,math.max(1,#(N.searchMatches or {})-6)));N.searchActiveIndex=N.searchStart;N.RefreshSearchMenu(true)
end
function N.MoveSearchSelection(delta)
 local count=#(N.searchMatches or {});if count==0 then return end
 N.searchActiveIndex=math.max(1,math.min(count,(N.searchActiveIndex or 1)+delta))
 if N.searchActiveIndex<(N.searchStart or 1) then N.searchStart=N.searchActiveIndex elseif N.searchActiveIndex>(N.searchStart or 1)+6 then N.searchStart=N.searchActiveIndex-6 end
 N.RefreshSearchMenu(true)
end
function N.ChooseSearchResult(index)
 local result=(N.searchMatches or {})[index];if not result then return false end
 local record=result.records[1];for _,r in ipairs(result.records) do if r.zone==N.selectedZone then record=r;break end end
 if record.unlocated then N.unlocatedRecipe=record;N.selectedRecipe=record;N.RefreshRecipeMap();N.RefreshRecipes() else N.SetZone(record.zone);N.selectedRecipe=nil;N.SelectRecipe(record.id) end
 for _,row in ipairs(root.recipeRows or {}) do if row.record==record then
  local offset=root.recipeContent:GetTop()-row:GetTop();root.recipeScroll:SetVerticalScroll(math.max(0,math.min(offset,math.max(0,root.recipeContent:GetHeight()-root.recipeScroll:GetHeight()))));break
 end end
 root.recipeSearch:ClearFocus();root.searchPopup:Hide();return true
end
function N.RefreshRecipes()
 if not root or not root.recipesText then return end
 if N.unlocatedRecipe and not (false and N.professionFilters[N.unlocatedRecipe.profession]) then N.unlocatedRecipe=nil;N.selectedRecipe=nil;N.RefreshRecipeMap() end
 local records=N.unlocatedRecipe and {N.unlocatedRecipe} or N.MatchingRecipes(N.recipeRecords,N.selectedZone);N.visibleRecipes=records
 local enabled=0;for _,source in ipairs(sourceNames) do if N.sourceFilters[source] then enabled=enabled+1 end end
 local selectionVisible=false;for _,record in ipairs(records) do if record==N.selectedRecipe then selectionVisible=true end end
 if not selectionVisible then N.selectedRecipe=nil end
 local professionsEnabled=0;for _,name in ipairs(professionNames) do if N.professionFilters[name] then professionsEnabled=professionsEnabled+1 end end
 local message=N.unlocatedRecipe and "Search result � Location not recorded" or "Recipes in this zone � "..#records
 if professionsEnabled==0 then message=message.."\nNo professions selected."
 elseif enabled==0 then message=message.."\nNo source types selected."
 elseif #records==0 then message=message.."\nNo located recipes match these filters." end
 root.recipesText:SetText(message)
 if not root.recipeContent then return end
 local width=root.panels[3]:GetWidth()-64;root.recipeContent:SetWidth(width)
 local y=0
 root.recipeRows=root.recipeRows or {}
 for i,record in ipairs(records) do
  local b=root.recipeRows[i]
  if not b then
   b=CreateFrame("Button",nil,root.recipeContent,"BackdropTemplate");b.enamelPieces={};b.label=text(b,14,"");b=plainMenuOption(b);root.recipeRows[i]=b
   b.icon=tex(b,nil,"ARTWORK");b.icon:SetSize(26,26);b.icon:SetPoint("TOPLEFT",b,"TOPLEFT",4,-3)
   b.detail=text(b,13,"",N.sideMaterial=="parchment");b.detail:SetPoint("TOPLEFT",b,"TOPLEFT",36,-38)
   b:SetScript("OnClick",function() if b.record then N.SelectRecipe(b.record.id or b.record.name) end end)
  end
  b.record=record;b:SetWidth(width);b:ClearAllPoints();b:SetPoint("TOPLEFT",root.recipeContent,"TOPLEFT",0,-y)
  b.label:ClearAllPoints();b.label:SetPoint("TOPLEFT",b,"TOPLEFT",36,-7);b.label:SetWidth(width-40);b.label:SetHeight(22);b.label:SetFont("Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf",17,"");b.label:SetText(record.name);if N.sideMaterial=="parchment" then b.label:SetTextColor(.18,.105,.045) end
  b.icon:SetTexture(recipeIcon(record))
  b.menuHighlight:ClearAllPoints();b.menuHighlight:SetPoint("TOPLEFT",b,"TOPLEFT",0,0);b.menuHighlight:SetPoint("TOPRIGHT",b,"TOPRIGHT",0,0);b.menuHighlight:SetHeight(32)
  local height=36
  if record==N.selectedRecipe then b.detail:SetWidth(width-40);b.detail:SetText(recipeDetails(record));b.detail:Show();height=height+b.detail:GetStringHeight()+16 else b.detail:Hide() end
  b:SetHeight(height);b:Show();y=y+height+4
 end
 for i=#records+1,#root.recipeRows do root.recipeRows[i]:Hide() end
 root.recipeContent:SetHeight(math.max(1,y));root.recipeScroll:SetVerticalScroll(math.min(root.recipeScroll:GetVerticalScroll(),math.max(0,y-root.recipeScroll:GetHeight())))
 N.UpdateMapView();N.RefreshSearchMenu()
end
function N.SetSource(name,value)
 if N.sourceFilters[name]==nil then return false end
 N.sourceFilters[name]=not not value
 if ns.db then ns.db.normalRecipeSources=ns.db.normalRecipeSources or {};ns.db.normalRecipeSources[name]=not not value end
 for _,b in ipairs(root.sourceOptions or {}) do b:SetCheckedVisual(N.sourceFilters[b.sourceName]) end
 N.RefreshRecipes();return true
end
function N.RefreshRecipeMap()
 if not root or not root.mapImage then return end
 if N.unlocatedRecipe then root.mapViewport:Hide();root.mapImage:Hide();root.recipePin:Hide();root.mapLabel:SetText("Source location not recorded\n\n"..N.unlocatedRecipe.name);root.mapLabel:Show();return end
 local entry=N.selectedZone and mapCatalog[N.selectedZone]
 if entry then
  root.mapImage:SetTexture(ns.ForeverMapTexture(entry.mapID));root.mapImage:SetTexCoord(0,1,0,entry.v);root.mapViewport:Show();root.mapImage:Show();root.mapLabel:Hide();N.UpdateMapView()
 else
  root.mapViewport:Hide();root.mapImage:Hide();root.mapLabel:SetText((N.selectedZone and N.selectedZone.."\n\n" or "")..(N.selectedZone and "Map not available from Wowhead" or "Select a zone"));root.mapLabel:Show()
 end
end
function N.RefreshZoneMenu()
 if not root or not root.zoneOptions then return end
 N.zoneStart=math.max(1,math.min(N.zoneStart or 1,#zoneNames-9))
 for i,b in ipairs(root.zoneOptions) do b.zoneName=zoneNames[N.zoneStart+i-1];b.label:SetText(b.zoneName or "");b.menuHighlight:Hide() end
 root.zoneScrollNote:SetText(N.zoneStart.."�"..math.min(#zoneNames,N.zoneStart+9).." / "..#zoneNames.." � Scroll")
end
function N.SetZone(name)
 local found=false;for _,zone in ipairs(zoneNames) do if zone==name then found=true;break end end
 if not found and not (mapCatalog[name] and mapCatalog[name].instance) then return false end
 N.unlocatedRecipe=nil
 if N.selectedZone~=name then N.mapZoom=1;N.mapCenterX=.5;N.mapCenterY=.5;N.selectedRecipe=nil end
 N.selectedZone=name;if ns.db then ns.db.normalRecipeZone=name end
 root.zoneButton.label:SetText(name);root.zoneButton:SetWidth(root.panels[3]:GetWidth()-56)
 N.RefreshRecipeMap();N.RefreshRecipes()
 if zoneMenu then zoneMenu:Hide() end
 return true
end
function N.ScrollZones(delta)
 N.zoneStart=math.max(1,math.min((N.zoneStart or 1)+delta,#zoneNames-9));N.RefreshZoneMenu()
end
function N.Resync()
 session.browsing=false
 session:Resync()
 local first=session:Visible()[1]
 if first and first.localQuestPickup then
  session.index=first.id
  local workflow=ns.WindowWorkflow
  if workflow then workflow.selection='step' end
 end
 N.rowStart=1
 N.Refresh()
end
function N.Step(value)
 local visible=session:Visible();local at=math.max(1,math.min(#visible,math.floor(value)))
 session.index=visible[at] and visible[at].id or nil;activate();N.Refresh()
end
function N.Move(delta) session:Move(delta);activate();N.Refresh() end
function N.SetView(value)
 N.view=(value-1)%#viewNames+1;session:SetView(viewNames[N.view]);N.rowStart=1;activate();N.Refresh()
end
function N.SetGoal(name,value)
 session:SetGoal(name,value);N.goals=session.goals;N.rowStart=1;activate();N.Refresh()
end
function N.RecoverQuestWindow()
 N.dimensions=nil;layout();centerRoot();defaultArrowPosition()
end
function N.Reset()
 N.dimensions=nil;layout()
 session=GuideView.New();N.model=session;N.goals=session.goals;N.view=1;N.rowStart=1
 for i,name in ipairs({"Questing","Dungeons","Gathering","Crafting"}) do root.playOptions[i]:SetCheckedVisual(N.goals[name]) end
 centerRoot();defaultArrowPosition()
 if ns.db then ns.db.normalFramePoint=nil;ns.db.normalArrowPoint=nil;ns.db.normalFrameSize=nil end
 local mini=_G.GrindingForeverMinimapButton
 if mini then
  if ns.db and ns.db.minimap then ns.db.minimap.minimapPos=140 end
  mini:ClearAllPoints();mini:SetPoint('CENTER',Minimap,'CENTER',math.cos(math.rad(140))*(Minimap:GetWidth()/2+6),math.sin(math.rad(140))*(Minimap:GetHeight()/2+6))
  if ns.db and ns.db.minimap then ns.db.minimap.point=nil end
 end
 if playMenu then playMenu:Hide() end
 if viewMenu then viewMenu:Hide() end
 if settings then settings:Hide() end
 N.SetArrow(true);N.SetArrowSize(100)
 if arrowTex then arrowTex:SetTexture(N.ProjectedArrowAsset());arrowTex.gfYawIndex=nil;N.RenderArrow()end
 activate();N.Refresh()
end
local function ensure()
 if root then return end
 host=CreateFrame("Frame","GrindingForeverFrame",UIParent)
 N.ApplyWindowLayer(host,"steps");host:SetToplevel(true);host:SetClampedToScreen(true);host:SetMovable(true);host:SetResizable(true);host:EnableMouse(true)
 root=CreateFrame("Frame",nil,host);N.root=root;root:SetPoint("TOPLEFT",host,"TOPLEFT",0,0);root:EnableMouse(false)
 centerRoot();C.Outer(root)
 local backdrop=root:CreateTexture(nil,"BACKGROUND");backdrop:SetPoint("TOPLEFT",root,"TOPLEFT",10,-60)
 root.backdrop=backdrop
 backdrop:SetPoint("BOTTOMRIGHT",root,"BOTTOMRIGHT",-10,10);color(backdrop,.16,.095,.055,1) -- Dark-brown fallback beneath the native-scale shared leather tiles.
 root.wood=tex(root,AS.."Wood");root.wood:SetTexCoord(0,1254/2048,0,1254/2048)
 root.bannerFrame=CreateFrame("Frame",nil,root);root.bannerFrame:EnableMouse(false);C.Decorate(root.bannerFrame,14)
 root.headerTopRail=tex(root,NEW.."BronzeFrame","ARTWORK");root.headerTopRail:SetTexCoord(250/2048,1000/2048,84/2048,174/2048)
 root.titleMetal=tex(root,DECOR.."MetalTitle","OVERLAY");root.titleMetal:SetTexCoord(0,TITLEART.u,0,TITLEART.v)
 local junctionLayer=CreateFrame("Frame",nil,root);junctionLayer:SetAllPoints(root);junctionLayer:SetFrameLevel(root:GetFrameLevel()+8);junctionLayer:EnableMouse(false)
 root.shoulders={}
 for i=1,20 do root.shoulders[i]=tex(junctionLayer,WORKING.."SingleShoulder","ARTWORK") end
 root.connectors={}
 for i=1,7 do root.connectors[i]=tex(junctionLayer,WORKING.."FacetedHex","OVERLAY") end
 root.foreverCrest=tex(junctionLayer,WINGLESS.."Infinity","OVERLAY");root.foreverCrest:SetTexCoord(0,1,0,0.84765625)
 root.endcaps={}
 local capsLayer=CreateFrame("Frame",nil,root);capsLayer:SetAllPoints(root);capsLayer:EnableMouse(false)
 capsLayer:SetFrameLevel(root:GetFrameLevel()+5)
 for i,side in ipairs({"Left","Right"}) do
  local cap=tex(capsLayer,THEME..(i==1 and "AllianceGryphon" or "HordeWyvern"),"OVERLAY")
  cap:SetTexCoord(i==1 and 0 or 482/512,i==1 and 482/512 or 0,0,282/512)
  cap:SetVertexColor(1,1,1,1) -- Original clean-source pixels; bronze/gold shading only, right source mirrored by UV.
  root.endcaps[i]=cap
 end
 title=text(root,34,"Grinding Forever");title:SetJustifyH("CENTER")
 local drag=CreateFrame("Frame",nil,root);root.headerDrag=drag;drag:SetPoint("TOPLEFT",root,"TOPLEFT",190,-60)
 drag:SetPoint("TOPRIGHT",root,"TOPRIGHT",-190,-60);drag:SetHeight(100);drag:EnableMouse(true);drag:RegisterForDrag("LeftButton")
 drag:SetScript("OnDragStart",function() host:StartMoving() end)
 drag:SetScript("OnDragStop",function()
  host:StopMovingOrSizing();local p,_,rp,x,y=host:GetPoint(1)
  x=safeNumber(x,-10000,10000);y=safeNumber(y,-10000,10000)
  if ns.db and x and y then ns.db.normalFramePoint={p,rp,x,y} end
 end)
 local close=C.Close(root,function() host:Hide() end)
 close:ClearAllPoints();close:SetPoint("TOPRIGHT",root,"TOPRIGHT",-3,-128);close:SetSize(47,47)
 close.phaseBClose.texture:SetSize(15,15);close:SetFrameLevel(root:GetFrameLevel()+12);N.close=close
 local left=inset(root,AS.."Parchment")
 left.fill:SetTexCoord(48/2048,1206/2048,48/2048,1206/2048)
 local middle=inset(root,AS.."Parchment")
 middle.fill:SetTexCoord(48/2048,1206/2048,48/2048,1206/2048)
 local right=inset(root,AS.."Parchment")
 right.fill:SetTexCoord(48/2048,1206/2048,48/2048,1206/2048)
 for _,panel in ipairs({left,right}) do local lift=tex(panel,nil,"BACKGROUND",1);lift:SetDrawLayer("ARTWORK",1);panel.fill:SetDrawLayer("ARTWORK",0);lift:SetAllPoints(panel.fill);color(lift,.60,.40,.25,.12);panel.leatherLift=lift end
 left.fill:Hide();right.fill:Hide();left.leatherLift:Hide();right.leatherLift:Hide() -- One shared chestnut surface continues beneath the parchment alpha.
 if N.sideMaterial=="parchment" then for _,panel in ipairs({left,right}) do panel.fill:SetTexture(AS.."Parchment");panel.fill:SetTexCoord(48/2048,1206/2048,48/2048,1206/2048);panel.fill:SetVertexColor(1,1,1,1);panel.fill:Show() end end
 root.panels={left,middle,right}
 root.titleLeft=text(root,36,"Grinding");root.titleRight=text(root,36,"Forever")
 root.headerEmblem=tex(root,KIT.."ForeverEmblem","OVERLAY")
 root.dividers={}
 for i=1,2 do local d=CreateFrame("Frame",nil,root);d:EnableMouse(false);d:SetFrameLevel(root:GetFrameLevel()+4);C.Decorate(d,9);d.rail=tex(d,NEW.."BronzeFrame","ARTWORK");root.dividers[i]=d end
 local play=dropdown(btn(left,"Playstyle",150,function() if playMenu:IsShown() then playMenu:Hide() else playMenu:Show() end end))
 play:SetPoint("TOPLEFT",left,"TOPLEFT",28,-30)
 playMenu=CreateFrame("Frame",nil,left,"BackdropTemplate");playMenu:SetPoint("TOPLEFT",play,"BOTTOMLEFT",0,-4)
 playMenu:SetWidth(180);playMenu:SetHeight(152)
 playMenu:SetFrameStrata("TOOLTIP");playMenu:SetFrameLevel(host:GetFrameLevel()+40);menuSkin(playMenu)
 root.playOptions={}
 for i,name in ipairs({"Questing","Dungeons","Gathering","Crafting"}) do
  local b
  b=btn(playMenu,name,180,function()
   N.SetGoal(name,not N.goals[name]);b:SetCheckedVisual(N.goals[name])
  end);checkbox(b,N.goals[name]);b:SetPoint("TOPLEFT",playMenu,"TOPLEFT",4,-4-(i-1)*36)
  root.playOptions[i]=b
 end
 playMenu:Hide()
 root.listNote=text(left,12,"",N.sideMaterial=="parchment");root.listNote:SetPoint("TOPLEFT",left,"TOPLEFT",28,-112);root.listNote:Hide();root.listNote:SetPoint("RIGHT",left,"RIGHT",-20,0)
 for i=1,13 do
  local row
  row=btn(left,"",180,function() if row.stepID then session.index=row.stepID;activate();N.Refresh() end end);plainStepRow(row)
  row:SetHeight(39)
  row.label:ClearAllPoints();row.label:SetPoint("LEFT",row,"LEFT",10,0);row.label:SetJustifyH("LEFT")
  local font=select(1,row.label:GetFont());row.label:SetFont("Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf",18,"");row.label:SetWordWrap(true);row.category=text(row,15,"",N.sideMaterial=="parchment");row.category:SetWordWrap(false);row.category:SetHeight(26);row.category:SetJustifyV("MIDDLE");rows[i]=row
 end
 left:EnableMouseWheel(true);left:SetScript("OnMouseWheel",function(_,delta)
  -- Browse without changing the active step or its destination.
  local visible=session:Visible();local count=N.displayedRowCount or 8
  local start=math.max(1,math.min((N.rowStart or 1)-delta,math.max(1,#visible-count+1)))
  N.rowStart=start
  N.LayoutStepRows(visible,start)
 end)
 root.viewButton=dropdown(btn(left,"All",100,function() if viewMenu:IsShown() then viewMenu:Hide() else viewMenu:Show() end end))
 root.viewButton:SetPoint("BOTTOMLEFT",left,"BOTTOMLEFT",16,16);root.viewButton:Hide()
 root.leftButtons={play};root.filterButtons={}
 for i,label in ipairs(filterLabels)do local index=i;root.filterButtons[i]=btn(left,label,80,function()N.SetView(index)end)end
 viewMenu=CreateFrame("Frame",nil,left,"BackdropTemplate");viewMenu:SetPoint("BOTTOMLEFT",root.viewButton,"TOPLEFT",0,4);viewMenu:SetSize(190,188);viewMenu:SetFrameStrata("TOOLTIP");viewMenu:SetFrameLevel(host:GetFrameLevel()+40);menuSkin(viewMenu)
 root.viewOptions={}
 for i,name in ipairs(viewNames) do
  local viewIndex=i
  local b=plainMenuOption(btn(viewMenu,name,160,function() N.SetView(viewIndex);viewMenu:Hide() end))
  b:SetPoint("TOPLEFT",viewMenu,"TOPLEFT",4,-4-(i-1)*36);b:SetWidth(viewMenu:GetWidth()-8);root.viewOptions[i]=b
 end
 viewMenu:Hide();N.viewMenu=viewMenu;N.playMenu=playMenu
 local info=text(middle,20,"Step Information",true);root.infoTitle=info;info:SetPoint("TOPLEFT",middle,"TOPLEFT",40,-40)
 stepLabel=text(middle,13,"",true);stepLabel:SetPoint("TOPLEFT",middle,"TOPLEFT",40,-72)
 root.heading=text(middle,26,"",true);root.heading:SetPoint("TOPLEFT",middle,"TOPLEFT",40,-112)
 root.heading:SetPoint("RIGHT",middle,"RIGHT",-40,0)
 bodyScroll=CreateFrame("ScrollFrame",nil,middle);bodyScroll:SetClipsChildren(true);bodyScroll:SetPoint("TOPLEFT",middle,"TOPLEFT",40,-170)
 bodyContent=CreateFrame("Frame",nil,bodyScroll);bodyContent:SetSize(300,1);bodyScroll:SetScrollChild(bodyContent)
 body=text(bodyContent,N.fieldGuideMinimumHeight and 16 or 18,"",true);body:SetPoint("TOPLEFT",bodyContent,"TOPLEFT",0,0);body:SetJustifyV("TOP")
 bodyScroll:EnableMouseWheel(true);bodyScroll:SetScript("OnMouseWheel",function(_,delta)
  bodyScroll:SetVerticalScroll(math.max(0,math.min(bodyScroll:GetVerticalScroll()-delta*28,math.max(0,bodyContent:GetHeight()-bodyScroll:GetHeight()))))
 end)
 N.bodyScroll=bodyScroll
 status=text(middle,14,"");N.destinationStatus=status;status:SetTextColor(.23,.14,.055);status:SetPoint("BOTTOMLEFT",middle,"BOTTOMLEFT",40,82)
 root.compactNext=text(middle,19,"",true);root.compactNext:Hide()
 root.compactDetails=btn(middle,"Details",74,function()N.compactExpanded=not N.compactExpanded;N.Refresh(true)end);root.compactDetails:SetHeight(28);root.compactDetails:Hide()
 root.compactNextHit=CreateFrame("Button",nil,middle);root.compactNextHit:SetAllPoints(root.compactNext);root.compactNextHit:EnableMouse(true)
 local nextWash=tex(root.compactNextHit,nil,"BACKGROUND");nextWash:SetAllPoints(root.compactNextHit);color(nextWash,.16,.10,.035,.12);nextWash:Hide()
 root.compactNextHit:SetScript("OnEnter",function()nextWash:Show()end);root.compactNextHit:SetScript("OnLeave",function()nextWash:Hide()end)
 root.compactNextHit:SetScript("OnClick",function()if root.compactNextID then session.index=root.compactNextID;activate();N.Refresh()end end)
 root.controls=CreateFrame("Frame",nil,middle)
 root.actionDivider=tex(middle,nil,"ARTWORK");color(root.actionDivider,.60,.38,.14,.55)
 root.done=btn(middle,"Done",90,function()P.Done();N.Resync()end);root.done:SetPoint("BOTTOMLEFT",middle,"BOTTOMLEFT",16,60)
 root.skip=btn(middle,"Skip",90,function()P.Skip();N.Resync()end);root.skip:SetPoint("LEFT",root.done,"RIGHT",8,0)
 root.back=arrowButton(btn(root.controls,"",38,function() N.Move(-1) end),false);root.back:SetPoint("LEFT",root.controls,"LEFT",0,0)
 root.stepButton=btn(root.controls,"Step",90,N.Resync);root.stepButton:SetPoint("LEFT",root.back,"RIGHT",4,0)
 local enter=root.stepButton:GetScript("OnEnter");local leave=root.stepButton:GetScript("OnLeave")
 root.stepButton:SetScript("OnEnter",function(self)
  if enter then enter(self) end
  N.ShowInfoTooltip(self,"Resync completed and upcoming steps")
 end)
 root.stepButton:SetScript("OnLeave",function(self) if leave then leave(self) end;N.HideInfoTooltip() end)
 root.forward=arrowButton(btn(root.controls,"",38,function() N.Move(1) end),true);root.forward:SetPoint("LEFT",root.stepButton,"RIGHT",4,0)
 root.reset=btn(root.controls,"Reset",76,N.Reset);root.reset:SetPoint("LEFT",root.forward,"RIGHT",6,0)
 root.settings=btn(root.controls,"Settings",102,function() if settings:IsShown() then settings:Hide() else settings:Show() end end)
 root.settings:SetPoint("RIGHT",root.controls,"RIGHT",0,0)
 root.modeButton=btn(root.controls,"Compact",100,function()N.SetMode(N.mode=="compact"and "normal"or "compact")end)
 settings=CreateFrame("Frame",nil,middle,"BackdropTemplate");settings:SetSize(340,396)
 settings:SetPoint("BOTTOMRIGHT",root.settings,"TOPRIGHT",0,8);settings:SetFrameStrata("TOOLTIP");settings:SetFrameLevel(host:GetFrameLevel()+40)
 menuSkin(settings)
 local sh=text(settings,20,"Settings");sh:SetPoint("TOPLEFT",settings,"TOPLEFT",16,-14)
 for _,v in ipairs({{'autoFlightToggle','Automatically Take Guide Flights','autoFlights'},{'autoAcceptToggle','Automatically Accept Quests','autoAcceptQuests'},{'autoTurninToggle','Automatically Turn In Quests','autoTurnInQuests'}})do
  local key=v[3];local b=checkbox(btn(settings,v[2],308,function()local d=ns.Forever.db;d[key]=not d[key];N[v[1]]:SetCheckedVisual(d[key]==true)end),ns.Forever.db and ns.Forever.db[key]==true);N[v[1]]=b
 end
 local farming=btn(settings,"Plan farming route",308,function()local f=ns.FarmingPlanner;if f then if f.route then f.Stop("Quest guide resumed.")else local ok,why=f.StartCurrent();if not ok then ns.Print(why)end end end end)
 farming:SetPoint("BOTTOMLEFT",settings,"BOTTOMLEFT",16,58);N.farmButton=farming
 settings:Hide();N.settingsFrame=settings;N.sizeSlider=sizeSlider
 local search=CreateFrame("EditBox",nil,right,"BackdropTemplate");root.recipeSearch=search
 search:SetPoint("BOTTOMLEFT",right,"BOTTOMLEFT",28,32);search:SetPoint("BOTTOMRIGHT",right,"BOTTOMRIGHT",-28,32);search:SetHeight(32)
 search:SetAutoFocus(false);search:SetMaxLetters(120);search:SetTextInsets(10,10,0,0);search:SetFont(select(1,title:GetFont()),(15)+1,"");search:SetTextColor(.94,.81,.54)
 search:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8",edgeFile="Interface\\Buttons\\WHITE8X8",edgeSize=1});search:SetBackdrop(nil);local searchFrame=tex(search,KIT.."SearchFrame","BACKGROUND");searchFrame:SetAllPoints(search)
 root.searchPlaceholder=text(search,14,"Search recipes or crafted items...");root.searchPlaceholder:SetPoint("LEFT",search,"LEFT",10,0);root.searchPlaceholder:SetTextColor(.65,.56,.41)
 local popup=CreateFrame("Frame",nil,right,"BackdropTemplate");root.searchPopup=popup;N.searchMenu=popup;popup:SetPoint("BOTTOMLEFT",search,"TOPLEFT",0,4);popup:SetPoint("BOTTOMRIGHT",search,"TOPRIGHT",0,4);popup:SetHeight(296);popup:SetFrameStrata("TOOLTIP");popup:SetFrameLevel(host:GetFrameLevel()+40);menuSkin(popup)
 root.searchRows={}
 for i=1,7 do
  local b=CreateFrame("Button",nil,popup,"BackdropTemplate");b.enamelPieces={};b.label=text(b,14,"");plainMenuOption(b);b:SetHeight(38);b:SetPoint("TOPLEFT",popup,"TOPLEFT",4,-4-(i-1)*38)
  b.label:ClearAllPoints();b.label:SetPoint("TOPLEFT",b,"TOPLEFT",10,-4);b.label:SetPoint("TOPRIGHT",b,"TOPRIGHT",-8,-4);b.label:SetHeight(17);b.label:SetWordWrap(false)
  b.meta=text(b,11,"");b.meta:SetPoint("BOTTOMLEFT",b,"BOTTOMLEFT",10,4);b.meta:SetTextColor(.72,.64,.48)
  b:SetScript("OnClick",function() N.ChooseSearchResult(b.resultIndex) end);root.searchRows[i]=b
 end
 root.searchNote=text(popup,11,"");root.searchNote:SetPoint("BOTTOMLEFT",popup,"BOTTOMLEFT",10,7)
 popup:EnableMouseWheel(true);popup:SetScript("OnMouseWheel",function(_,delta)N.ScrollSearch(-delta*3)end);popup:Hide()
 search:SetScript("OnTextChanged",function(self)N.SetSearchQuery(self:GetText() or "")end)
 search:SetScript("OnEditFocusGained",function()N.RefreshSearchMenu(true)end)
 search:SetScript("OnEscapePressed",function(self)self:ClearFocus();popup:Hide()end)
 search:SetScript("OnEnterPressed",function(self)if not N.ChooseSearchResult(N.searchActiveIndex or 1) then self:ClearFocus();popup:Hide()end end)
 search:SetScript("OnArrowPressed",function(_,key)if key=="UP" then N.MoveSearchSelection(-1)elseif key=="DOWN" then N.MoveSearchSelection(1)end end)
 local zone=dropdown(btn(right,"Select zone",180,function()
  if zoneMenu:IsShown() then zoneMenu:Hide() else N.RefreshZoneMenu();zoneMenu:Show() end
 end))
 root.zoneButton=zone
 root.sourceButton=dropdown(btn(right,"Sources",110,function() if sourceMenu:IsShown() then sourceMenu:Hide() else sourceMenu:Show() end end))
 root.sourceButton:SetPoint("TOPLEFT",right,"TOPLEFT",28,-116)
 sourceMenu=CreateFrame("Frame",nil,right,"BackdropTemplate");sourceMenu:SetPoint("TOPLEFT",root.sourceButton,"BOTTOMLEFT",0,-4);sourceMenu:SetSize(180,188);sourceMenu:SetFrameStrata("TOOLTIP");sourceMenu:SetFrameLevel(host:GetFrameLevel()+40);menuSkin(sourceMenu)
 root.sourceOptions={}
 for i,name in ipairs(sourceNames) do
  local b=checkbox(btn(sourceMenu,name,172,function() N.SetSource(name,not N.sourceFilters[name]) end),N.sourceFilters[name]);b:SetPoint("TOPLEFT",sourceMenu,"TOPLEFT",4,-4-(i-1)*36);b.sourceName=name;root.sourceOptions[i]=b
 end
 sourceMenu:Hide();N.sourceMenu=sourceMenu
 root.professionButton=dropdown(btn(right,"Professions",130,function() if professionMenu:IsShown() then professionMenu:Hide() else professionMenu:Show() end end))
 root.professionButton:SetPoint("LEFT",root.sourceButton,"RIGHT",12,0)
 professionMenu=CreateFrame("Frame",nil,right,"BackdropTemplate");professionMenu:SetPoint("TOPRIGHT",root.professionButton,"BOTTOMRIGHT",0,-4);professionMenu:SetSize(240,8+#professionNames*28);professionMenu:SetClampedToScreen(true);professionMenu:SetFrameStrata("TOOLTIP");professionMenu:SetFrameLevel(host:GetFrameLevel()+40);menuSkin(professionMenu)
 root.professionOptions={}
 for i,name in ipairs(professionNames) do
  local b=checkbox(btn(professionMenu,name,202,function() N.SetProfession(name,not N.professionFilters[name]) end),N.professionFilters[name]);b:SetHeight(28);b:SetPoint("TOPLEFT",professionMenu,"TOPLEFT",4,-4-(i-1)*28);b.professionName=name;root.professionOptions[i]=b
 end
 professionMenu:Hide();N.professionMenu=professionMenu

 zoneMenu=CreateFrame("Frame",nil,right,"BackdropTemplate");zoneMenu:SetPoint("TOPLEFT",zone,"BOTTOMLEFT",0,-4);zoneMenu:SetSize(280,316);zoneMenu:SetFrameStrata("TOOLTIP");zoneMenu:SetFrameLevel(host:GetFrameLevel()+40);menuSkin(zoneMenu)
 root.zoneOptions={}
 for i=1,10 do
  local b
  b=plainMenuOption(btn(zoneMenu,"",272,function() if b.zoneName then N.SetZone(b.zoneName) end end));b:SetSize(272,28);b:SetPoint("TOPLEFT",zoneMenu,"TOPLEFT",4,-4-(i-1)*28);root.zoneOptions[i]=b
 end
 root.zoneScrollNote=text(zoneMenu,11,"");root.zoneScrollNote:SetPoint("BOTTOMLEFT",zoneMenu,"BOTTOMLEFT",12,9)
 zoneMenu:EnableMouseWheel(true);zoneMenu:SetScript("OnMouseWheel",function(_,delta) N.ScrollZones(-delta*3) end);zoneMenu:Hide();N.zoneMenu=zoneMenu
 N.RefreshZoneMenu()
 zone:SetPoint("TOPLEFT",right,"TOPLEFT",28,-30)
 local map=inset(right,AS.."Parchment",14);map.fill:SetTexCoord(0,1254/2048,0,1254/2048);map:SetPoint("TOPLEFT",right,"TOPLEFT",28,-124)
 map:SetPoint("TOPRIGHT",right,"TOPRIGHT",-28,-124);root.recipeMap=map
 local mapLabel=text(map,15,"Zone map unavailable\n\nNo recipe source selected",true);mapLabel:SetPoint("TOPLEFT",map,"TOPLEFT",18,-24)
 mapLabel:SetPoint("BOTTOMRIGHT",map,"BOTTOMRIGHT",-18,18);mapLabel:SetJustifyH("CENTER");root.mapLabel=mapLabel
 root.mapViewport=CreateFrame("Frame",nil,map);root.mapViewport:SetPoint("TOPLEFT",map,"TOPLEFT",8,-8);root.mapViewport:SetPoint("BOTTOMRIGHT",map,"BOTTOMRIGHT",-8,8);root.mapViewport:SetClipsChildren(true);root.mapViewport:EnableMouse(true);root.mapViewport:EnableMouseWheel(true);root.mapViewport:RegisterForDrag("LeftButton")
 root.mapImage=tex(root.mapViewport,nil,"ARTWORK");root.mapImage:SetAllPoints(root.mapViewport);root.mapImage:Hide()
 root.recipePin=CreateFrame("Button",nil,root.mapViewport);root.recipePin:SetSize(18,27);root.recipePin:SetFrameLevel(root.mapViewport:GetFrameLevel()+5)
 local pinArt=tex(root.recipePin,EXPLORER.."RecipePin","OVERLAY");pinArt:SetAllPoints(root.recipePin);pinArt:SetTexCoord(0,1,0,.75);root.recipePin:Hide()
 root.recipePin:SetScript("OnEnter",function(self) if N.selectedRecipe then local loc=N.RecipeLocation(N.selectedRecipe);if loc then N.ShowInfoTooltip(self,(loc.name or N.selectedRecipe.vendor or N.selectedRecipe.name).."\n"..loc.x..", "..loc.y) end end end)
 root.recipePin:SetScript("OnLeave",N.HideInfoTooltip)
 root.mapViewport:SetScript("OnMouseWheel",function(_,delta) local u,v=mapCursor();N.ZoomMap(math.max(1,math.min(8,N.mapZoom*1.25^delta)),u,v) end)
 root.mapViewport:SetScript("OnDragStart",function() if type(GetCursorPosition)=="function" then N.mapDragging=true;N.dragX,N.dragY=GetCursorPosition() end end)
 local function stopMapDrag() N.mapDragging=false end
 root.mapViewport:SetScript("OnDragStop",stopMapDrag);root.mapViewport:SetScript("OnMouseUp",stopMapDrag);root.mapViewport:SetScript("OnHide",stopMapDrag)
 root.mapViewport:SetScript("OnUpdate",function(self)
  if N.mapDragging and type(GetCursorPosition)=="function" then local x,y=GetCursorPosition();local scale=self:GetEffectiveScale();N.PanMap((x-N.dragX)/scale/self:GetWidth(),-(y-N.dragY)/scale/self:GetHeight());N.dragX,N.dragY=x,y end
 end)
 local hint=text(right,10,"Scroll to zoom � Drag to pan",true);hint:SetPoint("TOPLEFT",map,"BOTTOMLEFT",0,-6);hint:SetPoint("TOPRIGHT",map,"BOTTOMRIGHT",0,-6);hint:SetJustifyH("CENTER");root.mapHint=hint

 local recipes=text(right,15,"",N.sideMaterial=="parchment");root.recipesText=recipes
 root.recipeScroll=CreateFrame("ScrollFrame",nil,right);root.recipeScroll:SetClipsChildren(true);root.recipeScroll:SetPoint("TOPLEFT",map,"BOTTOMLEFT",4,-64);root.recipeScroll:SetPoint("BOTTOMRIGHT",right,"BOTTOMRIGHT",-28,86)
 root.recipeContent=CreateFrame("Frame",nil,root.recipeScroll);root.recipeContent:SetSize(300,1);root.recipeScroll:SetScrollChild(root.recipeContent)
 root.recipeScroll:EnableMouseWheel(true);root.recipeScroll:SetScript("OnMouseWheel",function(_,delta) root.recipeScroll:SetVerticalScroll(math.max(0,math.min(root.recipeScroll:GetVerticalScroll()-delta*30,math.max(0,root.recipeContent:GetHeight()-root.recipeScroll:GetHeight())))) end)
 N.recipeScroll=root.recipeScroll;N.RefreshRecipes();N.RefreshRecipeMap()
 recipes:SetPoint("TOPLEFT",map,"BOTTOMLEFT",4,-24);recipes:SetPoint("RIGHT",right,"RIGHT",-20,0)
 local rnote=text(right,12,"",true);rnote:Hide()
 root.infoTooltip=CreateFrame("Frame",nil,root,"BackdropTemplate");root.infoTooltip:SetSize(280,40);root.infoTooltip:SetFrameStrata("TOOLTIP");root.infoTooltip:SetFrameLevel(host:GetFrameLevel()+80);root.infoTooltip:SetClampedToScreen(true);menuSkin(root.infoTooltip)
 root.infoTooltip.text=text(root.infoTooltip,14,"");root.infoTooltip.text:SetPoint("TOPLEFT",root.infoTooltip,"TOPLEFT",10,-10);root.infoTooltip.text:SetPoint("TOPRIGHT",root.infoTooltip,"TOPRIGHT",-10,-10);root.infoTooltip:Hide()
 N.dropdownMenus={{root.searchPopup,root.recipeSearch},{playMenu,play},{viewMenu,root.viewButton},{zoneMenu,zone},{sourceMenu,root.sourceButton},{professionMenu,root.professionButton}}
 ensureArrow();N.frame=host;N.scene=root;layout();C.LayoutBorder(map,14)
 N.resizeHandles={}
 local function finishResize()
  host:StopMovingOrSizing();N.resizing=false
  N.dimensions={host:GetWidth(),host:GetHeight()};N.modeDimensions[N.mode]=N.dimensions
  if ns.db then
   ns.db.normalModeSizes=ns.db.normalModeSizes or {};ns.db.normalModeSizes[N.mode]={host:GetWidth(),host:GetHeight()};ns.db.normalModeHeightRatios=ns.db.normalModeHeightRatios or {};ns.db.normalModeHeightRatios[N.mode]=N.heightRatio or 1
   local p,_,rp,x,y=host:GetPoint(1)
   x=safeNumber(x,-10000,10000);y=safeNumber(y,-10000,10000)
   if x and y then ns.db.normalFramePoint={p,rp,x,y} end
  end
 end
 for _,side in ipairs({"BOTTOMLEFT","BOTTOMRIGHT"}) do
  local grip=CreateFrame("Button",nil,host);grip:SetSize(42,42);grip:SetPoint(side,host,side,0,0)
  grip:SetFrameStrata(host:GetFrameStrata());grip:SetFrameLevel(host:GetFrameLevel()+15);grip:EnableMouse(true);grip:RegisterForDrag("LeftButton")
  if N.fieldGuideMinimumHeight then
   local handle=grip:CreateTexture(nil,"ARTWORK")
   handle:SetTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up");handle:SetSize(16,16)
   handle:SetPoint(side,grip,side,side=="BOTTOMLEFT" and 5 or -5,5)
   if side=="BOTTOMLEFT" then handle:SetTexCoord(1,0,0,1) end
  end
  local function beginResize()
   if N.resizing then return end
   local x=side=="BOTTOMLEFT" and host:GetRight() or host:GetLeft();local y=host:GetTop()
   local ratio=host:GetEffectiveScale()/UIParent:GetEffectiveScale()
   x=safeNumber(x,-10000,10000);y=safeNumber(y,-10000,10000)
   if x and y then
    host:ClearAllPoints();host:SetPoint(side=="BOTTOMLEFT" and "TOPRIGHT" or "TOPLEFT",UIParent,"BOTTOMLEFT",x*ratio,y*ratio)
   end
   N.resizeStart={host:GetWidth(),host:GetHeight()};N.resizing=true
   local cx,cy=GetCursorPosition();N.resizeCursor={cx,cy};N.resizeSide=side
  end
  grip:SetScript("OnDragStart",beginResize)
  grip:SetScript("OnMouseDown",function(_,button)if button=="LeftButton"then beginResize()end end)
  grip:SetScript("OnUpdate",function()
   if not N.resizing or N.resizeSide~=side or not N.resizeCursor then return end
   local cx,cy=GetCursorPosition();local start=N.resizeStart;local scale=host:GetEffectiveScale()
   if not cx or not cy or not scale or scale<=0 then return end
   local dx=(cx-N.resizeCursor[1])/scale;local dy=(N.resizeCursor[2]-cy)/scale
   local width=start[1]+(side=="BOTTOMLEFT"and -dx or dx)
   local height=start[2]+dy
   local baseAspect=N.mode=="compact"and 496/640 or 1205.04/1000
   local minimum=(N.mode=="compact"and 210 or 563.625)/(UIParent:GetEffectiveScale()or 1)
   width=math.max(minimum,width)
   local minimumRatio=N.mode=="compact" and N.fieldGuideMinimumHeight and N.fieldGuideMinimumHeight/640 or .7
   N.heightRatio=math.max(minimumRatio,math.min(N.mode=="compact"and 2.4 or 2.8,height/(width/baseAspect)))
   N.dimensions={width,(width/baseAspect)*N.heightRatio};layout()
  end)
  grip:SetScript("OnDragStop",finishResize);grip:SetScript("OnMouseUp",function() if N.resizing then finishResize() end end)
  N.resizeHandles[side]=grip
 end
 host:SetScript("OnSizeChanged",function(_,w,h)
  if layingOut or not N.resizing then return end
  local start=N.resizeStart
  if not N.resizeCursor then return end
  N.dimensions={w,w/normalAspect};layout()
 end)
 host:SetScript("OnHide",function() playMenu:Hide();viewMenu:Hide();settings:Hide();if zoneMenu then zoneMenu:Hide() end;if sourceMenu then sourceMenu:Hide() end;if professionMenu then professionMenu:Hide() end;if root.searchPopup then root.searchPopup:Hide();root.recipeSearch:ClearFocus() end;N.HideInfoTooltip() end)
end
local function anchorMini(icon)
 if not icon or not Minimap then return end
 ns.db=ns.db or {};ns.db.minimap=ns.db.minimap or {}
 local db=ns.db.minimap;db.point=nil
 local angle=tonumber(db.minimapPos)or 140
 local r=math.rad(angle)
 icon:ClearAllPoints();icon:SetPoint('CENTER',Minimap,'CENTER',math.cos(r)*(Minimap:GetWidth()/2+6),math.sin(r)*(Minimap:GetHeight()/2+6))
end
local function configureMini(icon)
 icon:SetSize(32,32);icon:SetMovable(false)
 local regions={icon:GetRegions()}
 for i,region in ipairs(regions)do
  if i==1 then region:ClearAllPoints();region:SetPoint('CENTER',icon,'CENTER',0,0);region:SetSize(30,30)
  elseif region.GetTexture then region:Hide()end -- Remove offset Blizzard tracking-border atlas; logo has its own rim.
 end
 anchorMini(icon)
 icon:SetScript('OnDragStart',function(self)self.gfOrbitDrag=true end)
 icon:SetScript('OnDragStop',function(self)self.gfOrbitDrag=false;anchorMini(self)end)
 icon:SetScript('OnUpdate',function(self)
  if self.gfOrbitDrag then
   local x,y=GetCursorPosition();local cx,cy=Minimap:GetCenter();local scale=Minimap:GetEffectiveScale()
   if x and cx and scale then local dx,dy=x/scale-cx,y/scale-cy
    local a;if math.atan2 then a=math.atan2(dy,dx)else a=math.atan(dy/(dx==0 and .00001 or dx));if dx<0 then a=a+math.pi end end
    ns.db.minimap.minimapPos=math.deg(a)
   end
  end
  local width,height=Minimap:GetWidth(),Minimap:GetHeight()
  if self.gfOrbitDrag or self.gfMiniWidth~=width or self.gfMiniHeight~=height then
   anchorMini(self);self.gfMiniWidth=width;self.gfMiniHeight=height
  end
 end)
end
local function updateMini()
 local icon=_G.GrindingForeverMinimapButton
 if icon and icon.GetRegions then
  configureMini(icon)
  local region=select(1,icon:GetRegions())
  if region and region.SetTexture then region:SetTexture(KIT.."ForeverEmblem");region:SetTexCoord(0,1,0,1) end
 end
 if LibStub then
  local ldb=LibStub("LibDataBroker-1.1",true)
  local object=ldb and ldb.GetDataObjectByName and ldb:GetDataObjectByName("GrindingForever")
  if object then object.icon=KIT.."ForeverEmblem";object.iconCoords={0,1,0,1} end
 end
end
local S={active=true};ns.UI.Showcase=S
function S.Show() ensure();layout();host:Show();N.Refresh() end
function S.Hide() if root then host:Hide() end end
function S.Toggle() if host and host:IsShown() then S.Hide() else S.Show() end end
function S.Login()
 if not ns.Retail.ready then return true end
 P.Refresh();session:Reconcile()
 ensure();arrowEnabled=not ns.db or ns.db.normalArrow~=false
 if ns.db then
  N.modeDimensions=type(ns.db.normalModeSizes)=="table"and ns.db.normalModeSizes or {}
  N.mode=ns.db.normalWindowMode=="compact"and "compact"or "normal"
  if ns.db.normalResizeRevision~=13 then
   local scale=safeNumber(UIParent.GetEffectiveScale and UIParent:GetEffectiveScale(),.1,5)or 1
   local old=N.modeDimensions.normal
   if type(old)=='table'and safeNumber(old[1],420,10000)and old[1]>1180/scale then N.modeDimensions.normal={1180/scale,(1180/scale)/(1440/1000)}end
   ns.db.normalModeSizes=N.modeDimensions;ns.db.normalResizeRevision=13
  end
  N.modeHeights=type(ns.db.normalModeHeightRatios)=="table"and ns.db.normalModeHeightRatios or {};N.heightRatio=N.modeHeights[N.mode]or 1
  local size=N.modeDimensions[N.mode];N.dimensions=type(size)=="table"and safeNumber(size[1],250,10000)and size or nil
  layout()
 end
 local function restore(frame,p)
  if type(p)~="table" then return end
  local anchors={TOP=true,BOTTOM=true,LEFT=true,RIGHT=true,CENTER=true,TOPLEFT=true,TOPRIGHT=true,BOTTOMLEFT=true,BOTTOMRIGHT=true}
  local x=safeNumber(p[3],-10000,10000);local y=safeNumber(p[4],-10000,10000)
  if anchors[p[1]] and anchors[p[2]] and x and y then frame:ClearAllPoints();frame:SetPoint(p[1],UIParent,p[2],x,y) end
 end
 if ns.db then restore(host,ns.db.normalFramePoint);restore(arrow,ns.db.normalArrowPoint) end
 if ns.db then
  local saved=ns.db.normalGuidePreferences
  ns.db.normalDummy=nil
  if type(saved)=="table" and saved.version==1 then
   if type(saved.goals)=="table" then for name in pairs(session.goals)do if type(saved.goals[name])=="boolean"then session.goals[name]=saved.goals[name]end end end
   local v=safeNumber(saved.view,1,#viewNames);N.view=v and math.floor(v)or 1;session.view=viewNames[N.view]
  end
 end
 for i,name in ipairs({"Questing","Dungeons","Gathering","Crafting"}) do root.playOptions[i]:SetCheckedVisual(N.goals[name]) end
 if ns.db then ns.db.normalArrowType=nil end -- Retired choice; size and enabled preference remain.
 N.SetArrowSize(math.max(11,math.min(66,safeNumber(ns.db and ns.db.normalArrowSize,11,200) or 55)))
 if ns.db and type(ns.db.normalRecipeSources)=="table" then for _,name in ipairs(sourceNames) do if type(ns.db.normalRecipeSources[name])=="boolean" then N.SetSource(name,ns.db.normalRecipeSources[name]) end end end
 if ns.db and type(ns.db.normalRecipeProfessions)=="table" then for _,name in ipairs(professionNames) do if type(ns.db.normalRecipeProfessions[name])=="boolean" then N.SetProfession(name,ns.db.normalRecipeProfessions[name]) end end end
 if ns.db and ns.db.normalRecipeZone then N.SetZone(ns.db.normalRecipeZone) end
 activate();N.SetArrow(arrowEnabled);N.RecoverArrow();S.Show();updateMini();return true
end
function S.Command(message)
 if message=="hide" then S.Hide() elseif message=="reset" then N.Reset()
 elseif message=="arrowstatus" then ns.Print("Arrow: enabled="..tostring(arrowEnabled)..", frame="..tostring(arrow and arrow:IsShown())..", texture="..tostring(arrowTex and arrowTex:IsShown())..", target="..tostring(target~=nil)..", heading="..tostring(N.angle~=nil)..", "..tostring(N.navigation))
 else S.Show() end
end
function S.Original() S.Show() end -- Retired presentation command stays harmless.
-- Retire the old public waypoint/target controls without changing Classic files.
ns.Map.SetWaypoint=nil;ns.Map.SetCurrentWaypoint=nil;ns.Map.SetDestination=nil
ns.Map.UpdateFromStep=nil;ns.Targeting=nil
ns.Map.ShowArrow=function() N.SetArrow(true) end
ns.Map.HideArrow=function() N.SetArrow(false) end
ns.Map.ToggleArrow=function() N.SetArrow(not arrowEnabled) end
ns.Map.GetNavigationSnapshot=function() return {status=N.navigation,distanceYards=N.yards,arrowShown=arrow and arrow:IsShown() or false,hasDestination=target~=nil} end
ns.UI.Refresh=N.Refresh;ns.UI.Show=S.Show;ns.UI.Hide=S.Hide;ns.UI.Toggle=S.Toggle
ns.UI.SetCompactPresentationVisible=function(visible) if visible then S.Show() else S.Hide() end end
ns.Guide.StepPrev=function() N.Move(-1) end;ns.Guide.StepNext=function() N.Move(1) end
local events=CreateFrame("Frame")
events:RegisterEvent("PLAYER_ENTERING_WORLD");events:RegisterEvent("DISPLAY_SIZE_CHANGED");events:RegisterEvent("UI_SCALE_CHANGED");events:RegisterEvent("UNIT_FACTION");events:RegisterEvent("GLOBAL_MOUSE_DOWN");events:RegisterEvent("ITEM_DATA_LOAD_RESULT")
events:SetScript("OnEvent",function(_,event,unit)
 if event=="GLOBAL_MOUSE_DOWN" then N.CloseMenusOutside()
 elseif event=="ITEM_DATA_LOAD_RESULT" then N.RefreshRecipeIcons()
 elseif event=="PLAYER_ENTERING_WORLD" then N.RecoverArrow();N.Tick();N.RefreshRecipes()
 elseif event=="UNIT_FACTION" then if unit==nil or unit=="player" then if arrowTex then arrowTex:SetTexture(N.ProjectedArrowAsset());arrowTex.gfYawIndex=nil;N.RenderArrow() end;N.RefreshRecipes() end
 else layout();startupRecovery=true end
end)
ns.RegisterMessage("GF_LOADED",updateMini)

local professionEvents=CreateFrame("Frame")
local professionDirty=true;local professionElapsed=0
for _,event in ipairs({"TRADE_SKILL_DATA_SOURCE_CHANGED","NEW_RECIPE_LEARNED"})do pcall(professionEvents.RegisterEvent,professionEvents,event)end
professionEvents:SetScript("OnEvent",function()professionDirty=true end)
local navigationElapsed=0
professionEvents:SetScript("OnUpdate",function(_,delta)
 if not ns.Retail.ready then return end
 local compass=ns.NavigationCompass
 local compassMode=compass and compass.Mode()=='Compass'
 if not compassMode then N.UpdateHeading()end
 local interval=compassMode and .15 or .05
 navigationElapsed=navigationElapsed+delta
 if navigationElapsed>=interval then navigationElapsed=navigationElapsed%interval;N.Tick()end
 professionElapsed=professionElapsed+delta
 if professionElapsed<.5 then return end
 elapsed=elapsed+professionElapsed;professionElapsed=0
 if professionDirty or P.dirty or elapsed>=30 then
  professionDirty=false;P.dirty=false;elapsed=0;P.Refresh();session:Reconcile();N.Refresh(true)
 end
end)

ns.RegisterMessage("GF_LOGIN",function()P.Refresh();session:Reconcile();N.Refresh()end)

ns.RegisterMessage("GF_LOGIN",function()ns.BindForeverRecipes(N);N.RefreshRecipes()end)
local recipeRetry=CreateFrame('Frame');local recipeElapsed=0
recipeRetry:SetScript('OnUpdate',function(_,dt)
 if N.foreverBound then recipeRetry:SetScript('OnUpdate',nil);return end
 recipeElapsed=recipeElapsed+dt;if recipeElapsed<5 then return end;recipeElapsed=0
 ns.BindForeverRecipes(N);if N.root then N.RefreshRecipes()end
end)


N.MakeButton=btn;N.MakeText=text;N.PlainOption=plainMenuOption;N.MakeCheckbox=checkbox
function N.ControlArrow(parent,direction,side)
 local glyph=tex(parent,"Interface\\AddOns\\GrindingForever\\Media\\ControlTriangleRight","OVERLAY")
 glyph:SetSize(11,11)
 glyph:SetPoint(side or "RIGHT",parent,side or "RIGHT",side=="LEFT" and 10 or -10,0)
 glyph:SetVertexColor(.96,.83,.54)
 glyph:SetRotation(direction=="left" and math.pi or direction=="down" and -math.pi/2 or 0)
 return glyph
end
function N.ButtonArrow(button,direction,side)
 local arrow=N.ControlArrow(button,direction,side)
 button.label:ClearAllPoints()
 button.label:SetPoint("LEFT",button,"LEFT",side=="LEFT" and 23 or 7,0)
 button.label:SetPoint("RIGHT",button,"RIGHT",side=="LEFT" and -7 or -23,0)
 return arrow
end

local panelDefaults={}
function N.RecoverPanels()
 if ns.db then ns.db.normalFramePoint=nil;ns.db.normalFrameSize=nil;ns.db.normalArrowPoint=nil end
 N.RecoverQuestWindow()
 for panel,defaults in pairs(panelDefaults) do
  panel:StopMovingOrSizing()
  panel:ClearAllPoints()
  if defaults.compass then panel:SetPoint("TOP",UIParent,"TOP",0,-55)
  else panel:SetPoint("CENTER",UIParent,"CENTER") end
  panel:SetSize(math.min(defaults.width,UIParent:GetWidth()-32),math.min(defaults.height,UIParent:GetHeight()-60))
  if defaults.resize then defaults.resize() end
 end
end
local windowLevels={dungeons=20,farming=40,recipes=60,steps=80}
function N.ApplyWindowLayer(frame,role)
 frame:SetFrameStrata("DIALOG")
 frame:SetFrameLevel(windowLevels[role])
end
function N.LiveLayout(frame, callback)
 local pending=false
 frame:HookScript("OnSizeChanged",function()
  if pending or not frame:IsShown() then return end
  if C_Timer and C_Timer.After then
   pending=true
   C_Timer.After(0,function()
    pending=false
    if frame:IsShown() then callback() end
   end)
  else callback() end
 end)
end
function N.BronzeRectangle(parent)
 local trim=CreateFrame("Frame",nil,parent)
 trim:SetAllPoints(parent)
 trim:SetFrameLevel(parent:GetFrameLevel()+1)
 trim:EnableMouse(false)
 for _,side in ipairs({"TOP","BOTTOM","LEFT","RIGHT"}) do
  local edge=trim:CreateTexture(nil,"OVERLAY")
  local horizontal=side=="TOP" or side=="BOTTOM"
  if horizontal then
   edge:SetPoint(side.."LEFT");edge:SetPoint(side.."RIGHT");edge:SetHeight(2)
  else
   edge:SetPoint("TOP"..side,trim,"TOP"..side,0,-2)
   edge:SetPoint("BOTTOM"..side,trim,"BOTTOM"..side,0,2)
   edge:SetWidth(2)
  end
  local light=side=="TOP" or side=="LEFT"
  edge:SetColorTexture(light and .83 or .53,light and .60 or .32,light and .33 or .14,1)
 end
 return trim
end
function N.PanelChrome(frame, title, minimumWidth, minimumHeight, resize)
 if minimumWidth then panelDefaults[frame]={width=frame:GetWidth(),height=frame:GetHeight(),resize=resize,compass=not title} end
 local compass=not title
 if compass then
  local fill=frame:CreateTexture(nil,"BACKGROUND",nil,-1)
  fill:SetPoint("TOPLEFT",5,-5);fill:SetPoint("BOTTOMRIGHT",-5,5);fill:SetColorTexture(.18,.095,.05,.25)
 end
 local base=tex(frame,EXPLORER..(compass and "BaseWood" or "BaseParchment"),"BACKGROUND")
 if compass then base:SetPoint("TOPLEFT",5,-5);base:SetPoint("BOTTOMRIGHT",-5,5) else base:SetPoint("TOPLEFT",0,-39);base:SetPoint("BOTTOMRIGHT",0,0)end
 if compass then base:SetTexCoord(0,1254/2048,0,1254/2048)else base:SetTexCoord(0,1254/2048,0,1254/2048)end
 if compass then base:SetAlpha(.82) else base:SetVertexColor(.57,.43,.32) end
 local layer=CreateFrame("Frame",nil,frame)
 layer:SetAllPoints();layer:SetFrameLevel(frame:GetFrameLevel()+2);layer:EnableMouse(false)
 local edges,hexagons={},{}
 local topInset=compass and 5 or 39
 for _,corner in ipairs({"TOPLEFT","TOPRIGHT","BOTTOMLEFT","BOTTOMRIGHT"})do
  local t=tex(layer,WORKING.."FacetedHex","OVERLAY")
  t:SetPoint("CENTER",frame,corner,corner:find("LEFT") and 5 or -5,corner:find("TOP") and -topInset or 5)
  hexagons[#hexagons+1]=t
 end
 for _,side in ipairs({"TOP","BOTTOM","LEFT","RIGHT"})do
  local t=tex(layer,nil,"ARTWORK")
  edges[side]=t
  if side=="TOP" then
   t:SetPoint("LEFT",hexagons[1],"CENTER");t:SetPoint("RIGHT",hexagons[2],"CENTER")
  elseif side=="BOTTOM" then
   t:SetPoint("LEFT",hexagons[3],"CENTER");t:SetPoint("RIGHT",hexagons[4],"CENTER")
  elseif side=="LEFT" then
   t:SetPoint("TOP",hexagons[1],"CENTER");t:SetPoint("BOTTOM",hexagons[3],"CENTER")
  else
   t:SetPoint("TOP",hexagons[2],"CENTER");t:SetPoint("BOTTOM",hexagons[4],"CENTER")
  end
 end
 local function trim()
  local hex=snapArt(frame,15)
  local depth=snapArt(frame,6)
  for _,t in ipairs(hexagons)do t:SetSize(hex,hex)end
  for side,t in pairs(edges)do
   if side=="TOP" or side=="BOTTOM" then t:SetHeight(depth)else t:SetWidth(depth)end
   rail(t,side)
  end
 end
 frame:HookScript("OnSizeChanged",trim);trim()
 if compass then
  if not minimumWidth then return end
  frame:SetResizable(true)
  if frame.SetResizeBounds then frame:SetResizeBounds(minimumWidth,minimumHeight,math.max(minimumWidth,UIParent:GetWidth()-48),104) end
  local grip=CreateFrame("Button",nil,frame)
  grip:SetSize(18,18);grip:SetFrameLevel(layer:GetFrameLevel()+1);grip:SetPoint("CENTER",hexagons[4],"CENTER")
  grip:SetScript("OnMouseDown",function(_,button)if button=="LeftButton" then frame:StartSizing("BOTTOMRIGHT") end end)
  grip:SetScript("OnMouseUp",function()frame:StopMovingOrSizing() end)
  grip:SetScript("OnHide",function()frame:StopMovingOrSizing() end)
  return
 end

 -- Keep the full text area on the light surface, inside the metal rails.
 local under=frame:CreateTexture(nil,"BACKGROUND",nil,1)
 under:SetPoint("TOPLEFT",5,-39);under:SetPoint("BOTTOMRIGHT",-5,5)
 under:SetColorTexture(.92,.75,.50,1)
 local paper=frame:CreateTexture(nil,"BACKGROUND",nil,2)
 paper:SetAllPoints(under);paper:SetTexture(AS.."Parchment")
 paper:SetTexCoord(48/2048,1206/2048,48/2048,1206/2048)
 local header=CreateFrame("Frame",nil,frame)
 header:SetPoint("TOPLEFT",7,0);header:SetPoint("TOPRIGHT",-7,0);header:SetHeight(39)
 local wood=tex(header,AS.."Wood","BACKGROUND")
 wood:SetPoint("TOPLEFT",header,"TOPLEFT",56,0);wood:SetPoint("BOTTOMRIGHT",header,"BOTTOMRIGHT",-56,0)
 local crown=tex(header,nil,"BORDER")
 crown:SetPoint("TOPLEFT",wood,"TOPLEFT",0,0);crown:SetPoint("TOPRIGHT",wood,"TOPRIGHT",0,0)
 local function trimCrown() crown:SetHeight(snapArt(frame,6));rail(crown,"TOP") end
 frame:HookScript("OnSizeChanged",trimCrown);trimCrown()
 wood:SetTexCoord(0,1254/2048,0,1254/2048)
 for index, asset in ipairs({"AllianceGryphon","HordeWyvern"}) do
  local left=index==1
  local cap=tex(header,THEME..asset,"OVERLAY")
  local side=left and "BOTTOMLEFT" or "BOTTOMRIGHT"
  cap:SetPoint(side,header,side,0,0)
  cap:SetSize(148,148*282/482)
  cap:SetTexCoord(left and 0 or 482/512,left and 482/512 or 0,0,282/512)
 end
 local titleText=text(header,20,type(title)=="table" and "" or title)
 titleText:SetPoint("LEFT",92,0);titleText:SetPoint("RIGHT",-92,0)
 titleText:SetJustifyH("CENTER");titleText:SetTextColor(.93,.73,.37);titleText:SetWordWrap(false)
 if type(title)=="table" then
  local emblem=tex(header,KIT.."ForeverEmblem","OVERLAY")
  emblem:SetPoint("CENTER",header,"CENTER");emblem:SetSize(32,32)
  for index, label in ipairs(title) do
   local part=text(header,20,label)
   part:SetTextColor(.93,.73,.37)
   if index==1 then part:SetPoint("RIGHT",emblem,"LEFT",-8,0)
   else part:SetPoint("LEFT",emblem,"RIGHT",8,0) end
  end
 end
 header:EnableMouse(true);header:RegisterForDrag("LeftButton")
 frame:SetMovable(true);frame:SetResizable(true);frame:SetClampedToScreen(true)
 header:SetScript("OnDragStart",function()frame:StartMoving()end)
 header:SetScript("OnDragStop",function()frame:StopMovingOrSizing()end)

 if frame.SetResizeBounds then
  frame:SetResizeBounds(minimumWidth,minimumHeight,math.max(minimumWidth,math.min(1150,UIParent:GetWidth()-32)),math.max(minimumHeight,math.min(940,UIParent:GetHeight()-32)))
 elseif frame.SetMinResize then
  frame:SetMinResize(minimumWidth,minimumHeight)
 end
 local handle=CreateFrame("Button",nil,frame)
 handle:SetSize(22,22);handle:SetPoint("BOTTOMRIGHT",0,0);handle:SetFrameLevel(frame:GetFrameLevel()+10)
 handle:ClearAllPoints();handle:SetPoint("CENTER",hexagons[4],"CENTER")
 handle:SetScript("OnMouseDown",function(_,button)
  if button=="LeftButton"then frame:StartSizing("BOTTOMRIGHT")end
 end)
 handle:SetScript("OnMouseUp",function(_,button)
  if button=="LeftButton"then frame:StopMovingOrSizing();if resize then resize()end end
 end)
 handle:SetScript("OnHide",function()frame:StopMovingOrSizing()end)
 local close=C.Close(frame,function()frame:Hide()end)
 close:ClearAllPoints();close:SetPoint("CENTER",hexagons[2],"CENTER");close:SetSize(22,22)
 hexagons[2]:Hide()
 local function sizeClose()
  local size=hexagons[2]:GetWidth()
  close.phaseBClose.texture:SetSize(size,size)
 end
 frame:HookScript("OnSizeChanged",sizeClose);sizeClose()
 return titleText, header
end
N.WorkflowBody=function()return body,bodyScroll,stepLabel,bodyContent,status end
N.WorkflowLive=liveObjective
N.WorkflowRelayout=layout

end)(ADDON,GF)
-- GF_MODULE_END Presentation
-- GF_MODULE_BEGIN Browser
;(function(...)
-- Shared reviewed presentation; all records and maps here are Forever-specific.
local _,ns=...
local E,F,N=ns.Forever,ns.ForeverFacts,ns.NormalUI;local call=E.Call
local U={pane='Recipes',floor=1,expanded={}};ns.ForeverUI=U
local AS='Interface\\AddOns\\GrindingForever\\Media\\'
local function text(parent,size,value,dark)return N.MakeText(parent,size,value,dark)end
local function switch(parent,labels,callback)
 local f=CreateFrame('Frame',nil,parent);f:SetSize(300,32);f.buttons={}
 local track=CreateFrame('Button',nil,f);track:SetSize(64,28);track:SetPoint('CENTER');track:SetFrameLevel(f:GetFrameLevel()+2)
 local function circle(parent,diameter,layer,path,color)
  local t=parent:CreateTexture(nil,layer);t:SetSize(diameter,diameter)
  if path then t:SetTexture(path);t:SetTexCoord(.45,.55,0,1)else t:SetColorTexture(unpack(color))end
  local mask=parent.CreateMaskTexture and parent:CreateMaskTexture(nil,'ARTWORK');if mask and t.AddMaskTexture then mask:SetTexture('Interface\\CharacterFrame\\TempPortraitAlphaMask');mask:SetAllPoints(t);t:AddMaskTexture(mask)end
  return t
 end
 local outer=track:CreateTexture(nil,'BACKGROUND');outer:SetPoint('LEFT',14,0);outer:SetSize(36,28);outer:SetColorTexture(.57,.36,.13,1)
 for _,side in ipairs({'LEFT','RIGHT'})do local cap=circle(track,28,'BACKGROUND',nil,{.57,.36,.13,1});cap:SetPoint(side,track,side,0,0)end
 local inner=track:CreateTexture(nil,'BORDER');inner:SetPoint('LEFT',14,0);inner:SetSize(36,24);inner:SetTexture(AS..'CrestPatinaRail');inner:SetVertexColor(.22,.18,.12,1)
 for _,side in ipairs({'LEFT','RIGHT'})do local cap=circle(track,24,'BORDER',AS..'CrestPatinaRail');cap:SetVertexColor(.22,.18,.12,1);cap:SetPoint(side,track,side,side=='LEFT'and 2 or-2,0)end
 f.thumb=circle(track,24,'OVERLAY',AS..'CrestPatinaRail');f.thumb:SetVertexColor(1,.87,.59,1)
 for i,label in ipairs(labels)do local b=CreateFrame('Button',nil,f);b:SetHeight(32);b:SetPoint(i==1 and'LEFT'or'RIGHT',f,i==1 and'LEFT'or'RIGHT',0,0);b.label=text(b,17,label,true);b.label:SetWordWrap(false);b.label:SetJustifyH('CENTER');b.label:SetPoint('CENTER');b:SetScript('OnClick',function()callback(label);f:Select(label)end);b:SetScript('OnEnter',function()b.label:SetTextColor(.02,.22,.20,1)end);b:SetScript('OnLeave',function()f:Select(f.value)end);f.buttons[i]=b end
 function f:Select(value)self.value=value;self.thumb:ClearAllPoints();self.thumb:SetPoint('CENTER',track,'LEFT',value==labels[1]and 14 or 50,0);for i,b in ipairs(self.buttons)do b.label:SetTextColor(labels[i]==value and .09 or .25,labels[i]==value and .055 or .15,labels[i]==value and .025 or .075,1)end end
 function f:Fit(width)self:SetWidth(width);for _,b in ipairs(self.buttons)do b:SetWidth(math.max(35,(width-80)/2))end end
 track:SetScript('OnClick',function()local value=f.value==labels[1]and labels[2]or labels[1];callback(value);f:Select(value)end)
 f.track=track;f.pill=true;return f
end

local function resetList()N.rowStart=1;N.Resync()end
local function ensure()
 local root=N.root;if not root or root.journeySwitch then return end
 root.journeySwitch=switch(root.panels[1],{'Leveling','Completionist'},function(value)E.db.journey=value;resetList()end)
 root.paceSwitch=switch(root.panels[1],{'Grinding','Relaxed'},function(value)E.db.pace=value;resetList()end)
 root.browserSwitch=switch(root.panels[3],{'Recipes','Dungeons'},function(value)U.SetPane(value)end)
 root.floorButton=N.MakeButton(root.recipeMap,'Floor 1',76,function()local d=E.dungeons[N.selectedZone];local floors=d and d.map and d.map.floors;if floors and #floors>1 then U.floor=U.floor%#floors+1;N.RefreshRecipeMap()end end)
 root.floorButton:SetPoint('BOTTOMRIGHT',root.recipeMap,'BOTTOMRIGHT',-12,12);root.floorButton:SetFrameLevel(root.mapViewport:GetFrameLevel()+9);root.floorButton:SetHeight(24);root.floorButton:Hide()

end
function U.Layout()
 ensure();local root=N.root;if not root then return end
 local p=root.panels
 root.leftButtons[1]:Hide();for _,b in ipairs(root.playOptions or{})do b:Hide()end
 root.journeySwitch:SetPoint('TOPLEFT',p[1],'TOPLEFT',28,-30);root.journeySwitch:Fit(p[1]:GetWidth()-56);root.journeySwitch:Select(E.db and E.db.journey or'Leveling')
 root.paceSwitch:SetPoint('TOPLEFT',p[1],'TOPLEFT',28,-70);root.paceSwitch:Fit(p[1]:GetWidth()-56);root.paceSwitch:Select(E.db and E.db.pace or'Grinding')
 root.browserSwitch:SetPoint('TOPLEFT',p[3],'TOPLEFT',28,-30);root.browserSwitch:Fit(p[3]:GetWidth()-56);root.browserSwitch:Select(U.pane)
 root.zoneButton:ClearAllPoints();root.zoneButton:SetPoint('TOPLEFT',p[3],'TOPLEFT',28,-74)
 root.sourceButton:ClearAllPoints();root.sourceButton:SetPoint('TOPLEFT',p[3],'TOPLEFT',28,-116)
 root.recipeMap:ClearAllPoints();root.recipeMap:SetPoint('TOPLEFT',p[3],'TOPLEFT',28,-164);root.recipeMap:SetPoint('TOPRIGHT',p[3],'TOPRIGHT',-28,-164)
 if N.recordStatus then N.recordStatus:SetText('One toggle records quests, professions and gathering locally.')end
end
function U.SetPane(value)
 if value~='Recipes'and value~='Dungeons'then return end
 U.pane=value;U.floor=1;U.expanded={};if E.db then E.db.pane=value end
 for i=#N.zones,1,-1 do table.remove(N.zones,i)end
 for name,z in pairs(ns.ForeverData.zones)do if value=='Recipes'or z.instance then N.zones[#N.zones+1]=name end end;table.sort(N.zones)
 N.zoneStart=1;N.selectedRecipe=nil
 if N.root then
  N.root.sourceButton:SetShown(value=='Recipes');N.root.professionButton:SetShown(value=='Recipes');N.root.recipeSearch:SetShown(value=='Recipes');U.Layout()
  local valid=false;for _,name in ipairs(N.zones)do if name==N.selectedZone then valid=true end end
  if valid then N.RefreshRecipeMap();N.RefreshRecipes()elseif N.zones[1]then N.SetZone(N.zones[1])else N.root.mapLabel:SetText('No verified dungeon catalog is loaded.');N.root.mapLabel:Show();N.root.mapViewport:Hide();N.RefreshRecipes()end
 end
end
local function part(viewport,index,path,x0,y0,x1,y1,uv)
 viewport.foreverTiles=viewport.foreverTiles or{};local t=viewport.foreverTiles[index];if not t then t=viewport:CreateTexture(nil,'BACKGROUND');viewport.foreverTiles[index]=t end
 local a,b=N.MapToViewport(x0,y0);local c,d=N.MapToViewport(x1,y1);t:ClearAllPoints();t:SetPoint('TOPLEFT',viewport,'TOPLEFT',a*viewport:GetWidth(),-b*viewport:GetHeight());t:SetSize((c-a)*viewport:GetWidth(),(d-b)*viewport:GetHeight());t:SetTexture(path);t:SetTexCoord(uv and uv[1]or 0,uv and uv[2]or 1,uv and uv[3]or 0,uv and uv[4]or 1);t:Show();return t
end
function ns.RenderForeverMap(_,root)
 local viewport=root.mapViewport;local d=E.dungeons[N.selectedZone];local map=d and d.map;local floor=map and map.floors and map.floors[U.floor];local outdoor=F.maps[N.selectedZone];local count=0
 if floor and floor.texture then count=1;part(viewport,count,floor.texture,0,0,1,1,{0,1,0,floor.texBottom or 1})
 elseif floor and floor.tiles then
  for x=0,3 do for y=0,2 do count=count+1;part(viewport,count,floor.tiles..(x*3+y+1),x*256/1002,y*256/668,math.min((x+1)*256/1002,1),math.min((y+1)*256/668,1),{0,math.min(256,1002-x*256)/256,0,math.min(256,668-y*256)/256})end end
  for _,patch in ipairs(floor.patches or{})do count=count+1;part(viewport,count,patch.tex,patch.x0,patch.y0,patch.x1,patch.y1)end
 elseif outdoor then count=1;part(viewport,count,outdoor.path,0,0,1,1,{0,outdoor.u,0,outdoor.v})end
 for i=count+1,#(viewport.foreverTiles or{})do viewport.foreverTiles[i]:Hide()end
 root.mapImage:Hide();root.mapLabel:SetShown(count==0);if count==0 then root.mapLabel:SetText((N.selectedZone or'Zone')..'\nMap asset not verified.');E.issues['map:'..tostring(N.selectedZone)]='Map required'end
 -- Initial map refresh precedes browser control creation during login.
 if root.floorButton then root.floorButton:SetShown(floor and #map.floors>1 or false);root.floorButton.label:SetText('Floor '..U.floor)end
 U.Pins(root,d,map);return count>0
end
ns.ForeverMapTexture=function()return nil end
function N.RefreshRecipeMap()
 local root=N.root;if not root or not root.mapViewport then return end
 root.mapViewport:Show();N.UpdateMapView()
end
function U.Pins(root,d,map)
 root.bossPins=root.bossPins or{};local count=0
 if U.pane=='Dungeons'and map then for _,position in ipairs(map.bosses or{})do if(position.floor or 1)==U.floor then
  local boss;for _,b in ipairs(d.bosses)do if b.name==position.name then boss=b;break end end
  if boss then count=count+1;local b=root.bossPins[count];if not b then b=CreateFrame('Button',nil,root.mapViewport);b:SetSize(24,24);b.icon=b:CreateTexture(nil,'ARTWORK');b.icon:SetAllPoints();b:SetFrameLevel(root.mapViewport:GetFrameLevel()+6);root.bossPins[count]=b end
   b.boss=boss;b:SetScript('OnClick',function(self)U.expanded[self.boss.name]=not U.expanded[self.boss.name];N.RefreshRecipes()end)
   b:SetScript('OnEnter',function(self)GameTooltip:SetOwner(self,'ANCHOR_RIGHT');GameTooltip:AddLine(self.boss.name);GameTooltip:Show()end);b:SetScript('OnLeave',function()GameTooltip:Hide()end)
   local display=E.journal and E.journal.STATIC_DISPLAY_IDS and E.journal.STATIC_DISPLAY_IDS[boss.npcID];if display and SetPortraitTextureFromCreatureDisplayID then call(SetPortraitTextureFromCreatureDisplayID,b.icon,display)else b.icon:SetTexture(boss.customIcon or'Interface\\Icons\\INV_Misc_QuestionMark')end
   local x,y=N.MapToViewport(position.x,position.y);b:ClearAllPoints();b:SetPoint('CENTER',root.mapViewport,'TOPLEFT',x*root.mapViewport:GetWidth(),-y*root.mapViewport:GetHeight());b:SetShown(x>=0 and x<=1 and y>=0 and y<=1)
  end
 end end end
 for i=count+1,#root.bossPins do root.bossPins[i]:Hide()end
end
local function details(r)
 local lines={r.profession..(r.requiredSkill and' � Requires '..r.requiredSkill or'')}
 if E.Known(r)==true then lines[#lines+1]='Already known'end
 if r.learnableItemID then lines[#lines+1]=(r.learnableName or r.name)..' [item '..r.learnableItemID..']'end
 for _,loc in ipairs(r.locations or{})do if E.Eligible(loc)then local label=(loc.source or'Source')..': '..(loc.name or loc.zone or'');if loc.zone then label=label..' � '..loc.zone end;if loc.x and loc.y then label=label..string.format(' (%.2f, %.2f)',loc.x,loc.y)end;if loc.price then label=label..' � '..math.floor(loc.price/100)..'s '..loc.price%100 ..'c'end;lines[#lines+1]=label end end
 return table.concat(lines,'\n')
end
function N.RefreshRecipes()
 local root=N.root;if not root or not root.recipeContent then return end
 local records={};local d=E.dungeons[N.selectedZone]
 if U.pane=='Dungeons'then
  for _,boss in ipairs(d and d.bosses or{})do records[#records+1]={kind='boss',name=boss.name,boss=boss};if U.expanded[boss.name]then for _,loot in ipairs(E.BossLoot(boss))do records[#records+1]={kind='loot',name=loot[2],itemID=loot[1],quality=loot[4]}end end end
 else
  local query=root.recipeSearch:GetText();query=query and query:match('%S')and query or nil
  local rows=E.KnownRecipeRows(query and nil or N.selectedZone,query)
  for _,r in ipairs(rows)do
   if r.kind=='trainer'then
    local recipes={};for _,recipe in ipairs(r.recipes)do if N.professionFilters[recipe.profession]then recipes[#recipes+1]=recipe end end
    if N.sourceFilters.Trainer and N.professionFilters[r.profession]and(#recipes>0 or r.unobserved)then records[#records+1]=r;if U.expanded[r.id]then if #recipes==0 then records[#records+1]={kind='notice',name='Visit trainer to record available recipes.'}end;for _,recipe in ipairs(recipes)do records[#records+1]=recipe end end end
   else
    local allowed=false;for _,loc in ipairs(r.locations or{})do if(query or loc.zone==N.selectedZone)and N.sourceFilters[loc.source]and E.Eligible(loc)then allowed=true end end
    if allowed and N.professionFilters[r.profession]then records[#records+1]=r end
   end
  end
 end
 root.recipesText:SetText((U.pane=='Dungeons'and'Bosses' or'Recipes and trainers')..' � '..#records);N.visibleRecipes=records
 local width=math.max(100,root.panels[3]:GetWidth()-64);root.recipeContent:SetWidth(width);local y=0;root.recipeRows=root.recipeRows or{}
 for i,r in ipairs(records)do
  local b=root.recipeRows[i];if not b then b=CreateFrame('Button',nil,root.recipeContent,'BackdropTemplate');b.enamelPieces={};b.label=text(b,16,'',true);N.PlainOption(b);b.icon=b:CreateTexture(nil,'ARTWORK');b.icon:SetSize(26,26);b.icon:SetPoint('TOPLEFT',4,-3);b.detail=text(b,13,'',true);b.detail:SetPoint('TOPLEFT',36,-38);b.farm=N.MakeButton(b,'Farm',68,function()if b.record then local key=b.record.spellID or b.record.learnableItemID;E.FlagRecipe(b.record,not E.farmFlags[key]);N.RefreshRecipes();resetList()end end);root.recipeRows[i]=b end
  b.record=r;b:ClearAllPoints();b:SetPoint('TOPLEFT',root.recipeContent,'TOPLEFT',0,-y);b:SetWidth(width);b.label:ClearAllPoints();b.label:SetPoint('TOPLEFT',36,-7);b.label:SetWidth(width-40);b.label:SetHeight(22);b.label:SetText(r.name);b.label:SetTextColor(.18,.105,.045)
  b.icon:SetTexture(call(C_Item and C_Item.GetItemIconByID or GetItemIcon,r.itemID or r.learnableItemID or r.productID)or'Interface\\Icons\\INV_Misc_Book_09')
  b.detail:Hide();b.farm:Hide();local height=38
  if r.kind=='trainer'then b.label:SetText(r.name..' � '..(r.rank or r.profession or'')..' >')
  elseif not r.kind and N.selectedRecipe==r then b.detail:SetWidth(width-40);b.detail:SetText(details(r));b.detail:Show();height=height+b.detail:GetStringHeight()+12
   local farm=false;for _,loc in ipairs(r.locations or{})do if loc.source=='Drop'or loc.source=='Treasure'then farm=true end end
   if farm then b.farm:ClearAllPoints();b.farm:SetPoint('TOPLEFT',36,-height);b.farm.label:SetText(E.farmFlags[r.spellID or r.learnableItemID]and'Unflag'or'Farm');b.farm:Show();height=height+36 end
  end
  b:SetHeight(height);b:SetScript('OnClick',function(self)local row=self.record;if row.kind=='trainer'then U.expanded[row.id]=not U.expanded[row.id]elseif row.kind=='boss'then U.expanded[row.name]=not U.expanded[row.name]elseif not row.kind then N.selectedRecipe=N.selectedRecipe~=row and row or nil end;N.RefreshRecipes()end)
  b:SetScript('OnEnter',function(self)self.menuHighlight:Show();local row=self.record;local itemID=row.itemID or row.learnableItemID or row.productID;if itemID and GameTooltip.SetItemByID then GameTooltip:SetOwner(self,'ANCHOR_RIGHT');GameTooltip:SetItemByID(itemID);GameTooltip:Show()end end);b:SetScript('OnLeave',function(self)self.menuHighlight:Hide();GameTooltip:Hide()end)
  b:Show();y=y+height+4
 end
 for i=#records+1,#root.recipeRows do root.recipeRows[i]:Hide()end
 root.recipeContent:SetHeight(math.max(1,y));root.recipeScroll:SetVerticalScroll(math.min(root.recipeScroll:GetVerticalScroll(),math.max(0,y-root.recipeScroll:GetHeight())));N.UpdateMapView()
end
-- Unlocated records remain searchable, but do not invent map pins.
function N.RecipeLocation(r)
 if not r then return end
 local rows={};for _,loc in ipairs(r.locations or{})do if loc.mapID and loc.x and loc.y and E.Eligible(loc)then rows[#rows+1]=loc end end
 return E.Nearest(rows)or rows[1]
end
local oldTick=N.Tick
N.Tick=function(...)
 oldTick(...);local row=ns.ProfessionGuide.selected;local area=E.objectiveArea
 if row and area and area.key==row.id then local distance=E.Distance(E.CurrentPosition(),area.position);if distance and distance<=100 then N.areaNavigation=true;N.navigation='In objective area';N.angle=nil;N.bearing=nil;N.target=nil;if N.arrowFrame then N.arrowFrame:Hide()end;if N.destinationStatus then N.destinationStatus:SetText('In objective area')end end end
end

end)(ADDON,GF)
-- GF_MODULE_END Browser
-- GF_MODULE_BEGIN Runtime
;(function(...)
-- Forever bootstrap and bounded, event-driven local observations.
local _,ns=...
local E,F=ns.Forever,ns.ForeverFacts;local call=E.Call
local frame=CreateFrame('Frame');local dirty=true;local waited=0;local started=false;local refreshTrigger='startup'
local function refresh()
 if not started then return end
 E.ObserveCamp();E.ReadCampPOIs()
 if ns.NormalUI and ns.NormalUI.root then
  ns.ProfessionGuide.dirty=false;ns.NormalUI.Resync()
 else ns.ProfessionGuide.dirty=true end
end
ns.GatheringObserver={ready=true,enabled=false,Initialize=function()end,Update=function()end}
local function initialize()
 if started then return end
 local version,build,_,interface=call(GetBuildInfo)
 if interface~=16001 or type(version)~='string'or not version:match('^1%.60%.')then ns.Print('This package is for the Forever 1.60 client. It is inactive on this client.');return end
 GrindingForeverLiveCharacterDB=type(GrindingForeverLiveCharacterDB)=='table'and GrindingForeverLiveCharacterDB or{}
 local d=GrindingForeverLiveCharacterDB;d.version=1;d.manual=d.manual or{};d.deferred={};d.recipeDeferred=d.recipeDeferred or{};d.farmFlags=d.farmFlags or{};d.journey=d.journey=='Completionist'and'Completionist'or'Leveling';d.pace=d.pace=='Relaxed'and'Relaxed'or'Grinding';d.collect=false;d.performanceEnabled=false;d.focusFishingPools=false
 E.db=d;ns.db=d;E.farmFlags=d.farmFlags
 local function copy(value,depth)if type(value)~='table'then return value end;if depth>12 then return nil end;local out={};for k,v in pairs(value)do out[k]=copy(v,depth+1)end;return out end
 E.materialSites=copy(d.materialSites or{},0);E.mobDrops=copy(d.mobDrops or{},0);E.vendors=copy(d.vendors or{},0);E.trainers=copy(d.trainers or{},0);E.known=copy(d.known or{},0)
 for _,r in pairs(copy(d.recipes or{},0))do E.IndexRecipe(r)end
 E.ReadZones();E.RefreshCatalog();E.Snapshot();started=true;ns.Retail.ready=true;ns.Retail.storageWritable=true
 ns.UI.Showcase.Login();ns.SendMessage('GF_LOADED');ns.SendMessage('GF_LOGIN');if ns.ForeverUI then ns.ForeverUI.Layout();ns.ForeverUI.SetPane(d.pane or'Recipes')end
 ns.Print('Forever tester build 37 loaded.')
 E.Record('login',{client=version,build=build})
end
local function save()
 if not E.db then return end
 E.db.known=E.known;E.db.mobDrops=E.mobDrops;E.db.materialSites=E.materialSites;E.db.vendors=E.vendors;E.db.trainers=E.trainers
 local observations={}
 for id,r in pairs(E.recipes)do if r.observed then observations[id]=r end end
 E.db.recipes=observations
end
local function hookTooltips()
 if not GameTooltip then return end
 local function unit(t)
  if t~=GameTooltip then return end
  local _,u=call(t.GetUnit,t);if not E.Public(u)or type(u)~='string'then return end
  local id=E.NPCID(call(UnitGUID,u));if not id then return end
  for _,line in ipairs(E.DropLines(id))do t:AddLine(line,.78,.66,.43)end
  local recipes=E.RecipeTooltipLines and E.RecipeTooltipLines(id,true)
  for _,line in ipairs(recipes or{})do t:AddLine(line,.78,.66,.43,true)end
 end
 local function itemTooltip(t)
  if t~=GameTooltip then return end
  local _,link=call(t.GetItem,t);local id=E.ItemID(link);if not id then return end
  local values={call(GetItemInfo,id)};local questClass=E.Public(values[12])and values[12]==12
  for _,line in ipairs(E.UsageLines(id,questClass))do t:AddLine(line,.78,.66,.43,true)end
  local sources=E.RecipeTooltipLines and E.RecipeTooltipLines(id,false)
  for _,line in ipairs(sources or{})do t:AddLine(line,.78,.66,.43,true)end
 end
 if TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall and Enum and Enum.TooltipDataType then
  call(TooltipDataProcessor.AddTooltipPostCall,Enum.TooltipDataType.Unit,unit)
  call(TooltipDataProcessor.AddTooltipPostCall,Enum.TooltipDataType.Item,itemTooltip)
 else
  for _,v in ipairs({{'OnTooltipSetUnit',unit},{'OnTooltipSetItem',itemTooltip}})do
   if not GameTooltip.HasScript or call(GameTooltip.HasScript,GameTooltip,v[1])then call(GameTooltip.HookScript,GameTooltip,v[1],v[2])end
  end
 end
end
for _,event in ipairs({'PLAYER_LOGIN','PLAYER_ENTERING_WORLD','PLAYER_LOGOUT','ADDON_LOADED','QUEST_ACCEPTED','QUEST_TURNED_IN','QUEST_REMOVED','GOSSIP_SHOW','GOSSIP_CLOSED','QUEST_DETAIL','QUEST_LOG_UPDATE','UNIT_QUEST_LOG_CHANGED','SKILL_LINES_CHANGED','TRADE_SKILL_SHOW','TRADE_SKILL_LIST_UPDATE','CRAFT_SHOW','CRAFT_UPDATE','TRAINER_SHOW','TRAINER_UPDATE','MERCHANT_SHOW','LOOT_OPENED','CHAT_MSG_LOOT','UNIT_SPELLCAST_SUCCEEDED','UNIT_AURA','PLAYER_LEVEL_UP','BAG_UPDATE_DELAYED','UPDATE_FACTION','PLAYER_TALENT_UPDATE','TAXIMAP_OPENED'})do call(frame.RegisterEvent,frame,event)end
frame:SetScript('OnEvent',function(_,event,...)
 if event=='PLAYER_LOGIN'then initialize();hookTooltips();return end
 if event=='PLAYER_LOGOUT'then save();return end
 if not started then return end
 if event=='ADDON_LOADED'then local name=...;if name=='ForeverDungeonJournal'or name=='AtlasLootClassic'then E.RefreshCatalog();if ns.ForeverUI then ns.ForeverUI.SetPane(E.db.pane or'Recipes')end end;return end
 if event=='UNIT_AURA'or event=='UNIT_SPELLCAST_SUCCEEDED'then local unit=...;if unit~='player'then return end end
 if event=='LOOT_OPENED'and E.db.collect then E.ObserveLoot()
 elseif event=='TRAINER_SHOW'or event=='TRAINER_UPDATE'then E.ObserveTrainer()
 elseif event=='MERCHANT_SHOW'then E.ObserveMerchant()
 elseif event=='TRADE_SKILL_SHOW'or event=='TRADE_SKILL_LIST_UPDATE'or event=='CRAFT_SHOW'or event=='CRAFT_UPDATE'then E.ReadBook()
 elseif event=='QUEST_ACCEPTED'then local a,b=...;E.Record('quest-accepted',{questID=b or a})
 elseif event=='QUEST_TURNED_IN'then local id=...;E.Record('quest-turned-in',{questID=id})
 elseif event=='TAXIMAP_OPENED'then E.ObserveTaxi();if E.AutoGuideFlight then E.AutoGuideFlight()end
 elseif event=='CHAT_MSG_LOOT'then local message=...;local id=E.ItemID(message);local gathering=E.lastGather and E.Time()-E.lastGather.time<20;E.Record(gathering and'gathered-item'or'loot-message',{itemID=id,profession=gathering and E.lastGather.profession or nil,quantity=type(message)=='string'and tonumber(message:match('x(%d+)'))or nil})
 elseif event=='UNIT_SPELLCAST_SUCCEEDED'then local _,_,id=...;local profession=({[7620]='Fishing',[2575]='Mining',[2366]='Herbalism',[8613]='Skinning'})[id];if profession then E.lastGather={time=E.Time(),profession=profession};E.Record('gather-success',{spellID=id,profession=profession})elseif E.known[id]then E.Record('craft-completed',{spellID=id})end
 end
 -- Loot observations are recorded above. Inventory changes queue their own refresh.
 if event=='LOOT_OPENED'or event=='CHAT_MSG_LOOT'or event=='UNIT_AURA'then return end
 if event=='UNIT_SPELLCAST_SUCCEEDED'then local _,_,id=...;if not E.known[id]and not({[7620]=true,[2575]=true,[2366]=true,[8613]=true})[id]then return end end
 dirty=true;refreshTrigger=event
end)
frame:SetScript('OnUpdate',function(_,dt)
 if started and E.flightPending then E.CheckFlight()end
 if not started or not dirty then return end;waited=waited+dt;if waited<.5 then return end;waited=0;dirty=false
 E.WithSnapshot(refresh)
end)
SLASH_GRINDINGFOREVERLIVE1='/gfp';SlashCmdList.GRINDINGFOREVERLIVE=function(message)
 message=(message or''):lower()
 if message=='recover windows'then if ns.NormalUI and ns.NormalUI.RecoverPanels then ns.NormalUI.RecoverPanels();ns.Print('GF windows recovered.')end
 elseif message=='diagnose'then local count=0;for _ in pairs(E.recipes)do count=count+1 end;ns.Print('Forever build 2 | recipes '..count..' | route '..#E.route..' | journal '..tostring(E.journal~=nil));for key,value in pairs(E.issues)do ns.Print(tostring(key)..': '..tostring(value))end
 else ns.UI.Showcase.Command(message)end
end
E.Initialize=initialize;E.Save=save

end)(ADDON,GF)
-- GF_MODULE_END Runtime

;(function(...)
-- GF-owned adaptive planning. Data is separate; no third-party addon runtime required.
local _,ns=...;local E,D=ns.Forever,ns.ForeverQuestData
local Q={data=D,revision=1};ns.ForeverQuestPlanner=Q
-- Calvin Montague: prefer the catalog spawn corroborated by live acceptance.
for _,a in pairs(D.actions)do
 if a.quest==8 and a.kind=='accept'and a.target and a.target.id==6784 then
  for _,loc in ipairs(D.spawns['npc:6784']or{})do if loc.mapID==1420 then a.map={ui_map=loc.mapID,x=loc.x,y=loc.y};break end end
 end
end
-- Forever quest 96899 opens after The Cult of the Damned is turned in.
local bandarion=D.quests[96899]
if bandarion and D.quests[96897] and not next(bandarion.prerequisites or {})then
 bandarion.prerequisites={{pre=96897,mode='all'}}
end
Q.breadcrumbs={}
for id,q in pairs(D.quests)do for _,pre in ipairs(q.prerequisites or{})do if pre.breadcrumb and pre.pre>0 then Q.breadcrumbs[pre.pre]=Q.breadcrumbs[pre.pre]or{};table.insert(Q.breadcrumbs[pre.pre],id)end end end
local raceBits={Human=1,Orc=2,Dwarf=4,NightElf=8,Scourge=16,Undead=16,Tauren=32,Gnome=64,Troll=128}
local classBits={WARRIOR=1,PALADIN=2,HUNTER=4,ROGUE=8,PRIEST=16,SHAMAN=64,MAGE=128,WARLOCK=256,DRUID=1024}
local function mask(m,b)return not m or m==0 or b and math.floor(m/b)%2==1 end
local function norm(s)return tostring(s or''):lower():gsub('[^%a]',''):gsub('scourge','undead')end
local function qs(id,s)
 if Q.stateOwner~=s then Q.stateOwner=s;Q.states={}end
 if not Q.states[id]then Q.states[id]=s.quests[id]or(s.completed[id]and{rewarded=true})or E.QuestState(id)or{}end
 return Q.states[id]
end
-- Profession introductions are relevant only after learning that profession.
Q.professionQuests={}
for id,q in pairs(D.quests)do local name=q.title and q.title:match('^Camping 101:%s*(.-)%s*$');if name then Q.professionQuests[id]=name end end
-- The shipped facts omit holiday categories. Track known event quest IDs.
Q.seasonalQuests={}
for _,id in ipairs({6961,6962,6963,6984,7021,7022,7023,7024,7025,7042,7045,7061,7063,
 8311,8312,8744,8746,8762,8767,8788,8803,8827,8828,8860,8861,8862,8863,8864,8865,8866,8867,8868,
 8870,8871,8872,8873,8874,8875,8876,8877,8878,8879,8880,8881,8882,8883})do
 Q.seasonalQuests[id]=true
end
for id,q in pairs(D.quests)do
 if id>=8619 and id<=8727 and q.title and q.title:match(' the Elder$')then Q.seasonalQuests[id]=true end
end
function Q.AllowsQuest(id,faction,fact)
 local q=D.quests[id]
 if Q.seasonalQuests[id] then return false end
 if q and (q.side==1 and faction~='Alliance' or q.side==2 and faction~='Horde') then return false end
 if fact and (fact.faction=='Alliance' or fact.faction=='Horde') and fact.faction~=faction then return false end
 return not fact or not(fact.side==1 and faction~='Alliance' or fact.side==2 and faction~='Horde')
end
local function offeredNow(id)
 for _,q in ipairs(E.Call(C_GossipInfo and C_GossipInfo.GetAvailableQuests)or{})do
  if E.Public(q.questID)and q.questID==id then return true end
 end
 return false
end
local pvpZones={ [3277]=true,[3358]=true,[2597]=true,[3820]=true,[4384]=true,[4710]=true,[5031]=true }
local function isPvPQuest(q)
 if not q then return false end
 if pvpZones[q.zone_area] then return true end
 for _,source in ipairs(q.starts or {}) do
  if source.kind=='npc' and (source.id==15350 or source.id==15351) then return true end
 end
 return false
end
function Q.Eligible(id,s)
 local q=D.quests[id];if not q or isPvPQuest(q) or not Q.AllowsQuest(id,s.faction) then return false end
 local live=qs(id,s);if live.rewarded==true or live.rewarded==1 or s.completed[id]then return false end
 -- Live acceptance is stronger evidence than incomplete custom-race metadata.
 if live.inLog==true then return true end
 local profession=Q.professionQuests[id]
 if profession then local skill=s.skills and s.skills[profession];if not skill or not E.Public(skill.rank)or type(skill.rank)~='number'or skill.rank<=0 or not offeredNow(id)then return false end end
 if (id==76156 or id==76160 or id==76240) and s.class~='ROGUE' and not offeredNow(id) then return false end
 if not mask(q.classes,classBits[s.class])then return false end
 local rb=raceBits[s.race]
 if rb then if not mask(q.races,rb)then return false end
 elseif q.races and q.races~=0 then
  local profile=Q.Profile(s);if not(profile and Q.profileQuests[profile]and Q.profileQuests[profile][id])then return false end
 end
 for _,later in ipairs(Q.breadcrumbs[id]or{})do local nextState=qs(later,s);if nextState.inLog or nextState.rewarded==true or nextState.rewarded==1 or s.completed[later]then return false end end
 if q.min_level and q.min_level>s.level then return false end
 local any,all,hasAny=false,true,false
 for _,p in ipairs(q.prerequisites or{})do if not p.breadcrumb then
  local previous=qs(math.abs(p.pre),s)
  local done=p.pre<0 and previous.inLog==true or p.pre>0 and(previous.rewarded==true or previous.rewarded==1 or s.completed[p.pre]==true)
  if p.mode=='all'then all=all and done else hasAny=true;any=any or done end
 end end
 return all and(not hasAny or any)and not q.repeatable
end
function Q.Profile(s)
 local race=norm(s.race)
 for _,p in ipairs(D.profiles)do
  local match=norm(p.race)==race or race:find('skyborne',1,true)and p.race:find('skyborne',1,true)
  if match and p.class==s.class and p.faction==s.faction then return p end
 end
end
local function point(m,t,zone)
 if not m or not m.ui_map or not m.x or not m.y then return end
 return{mapID=m.ui_map,x=m.x,y=m.y,name=t and t.name or zone or'Quest area',npcID=t and t.kind=='npc'and t.id or nil,zone=zone}
end
-- Reference guides supply locations, never the player's quest sequence.
Q.actionIndex={};Q.profileQuests={};Q.zoneCandidates={}
for _,p in ipairs(D.profiles)do
 local set={};Q.profileQuests[p]=set
 for _,ref in ipairs(p.refs)do local a=D.actions[ref]
  if a and a.quest then
   set[a.quest]=true
   local bucket=Q.actionIndex[a.quest]or{};Q.actionIndex[a.quest]=bucket
   if not bucket[ref]then bucket[ref]=a end
   if a.kind=='accept'and a.map and a.map.ui_map then
    local zone=Q.zoneCandidates[a.map.ui_map]or{};Q.zoneCandidates[a.map.ui_map]=zone;zone[a.quest]=true
   end
  end
 end
end
function Q.Ready(live)
 if not live or live.inLog~=true then return false end
 local required,finished=0,true
 for _,o in ipairs(live.objectives or{})do if not o.isOptional then
  required=required+1
  local done=o.finished==true or type(o.numRequired)=='number'and o.numRequired>0 and type(o.numFulfilled)=='number'and o.numFulfilled>=o.numRequired
  if not done then finished=false end
 end end
 if required>0 then return finished end
 return live.ready==true or live.ready==1 or live.complete==true or live.complete==1
end
function Q.NearestSource(sources,s)
 local best,score
 for _,src in ipairs(sources or{})do for _,pos in ipairs(D.spawns[src.kind..':'..src.id]or{})do
  local loc={mapID=pos.mapID,x=pos.x,y=pos.y,name=D.names[src.kind..':'..src.id]or'Quest source',npcID=src.kind=='npc'and src.id or nil}
  local distance=E.Distance(s.position,loc)
  local value=distance or(s.position and s.position.mapID==pos.mapID and math.sqrt((pos.x-s.position.x)^2+(pos.y-s.position.y)^2)*50)or 1e8
  if not score or value<score then best,score=loc,value end
 end end
 return best
end
local function actionLocation(id,kind,slot,s)
 local best,value,ref
 for n,a in pairs(Q.actionIndex[id]or{})do
  if a.kind==kind and(kind~='objective'or a.slot==slot)then
   local loc=point(a.map,a.target,a.zone)
   if loc then
    local d=E.Distance(s.position,loc)or(s.position and loc.mapID==s.position.mapID and 1e5 or 1e8)
    if not value or d<value or d==value and n<ref then best,value,ref=loc,d,n end
   end
  end
 end
 return best,ref
end
local function objectiveLocation(id,slot,s)
 local loc,ref=actionLocation(id,'objective',slot,s)
 if loc then return loc,ref end
 local q=D.quests[id]
 for _,o in ipairs(q and q.objectives or{})do if o.n==slot then
  if o.kind=='item'then return Q.NearestSource(D.itemSources[o.target],s)end
  local kind=(o.kind=='kill'or o.kind=='talk')and'npc'or o.kind=='object'and'object'
  if kind and o.target then return Q.NearestSource({{kind=kind,id=o.target}},s)end
 end end
end
function Q.Anchor(s)
 local current=s.position and s.position.mapID
 local anchor=E.db and E.db.questAnchor
 local function zone(id)
  if not id or id==1414 or id==1415 or id==1945 or id==947 then return false end
  local info=E.Call(C_Map and C_Map.GetMapInfo,id)
  if info and E.Public(info.mapType)and type(info.mapType)=='number'and info.mapType<3 then return false end
  return(next(D.zoneQuests[id]or{})or next(Q.zoneCandidates[id]or{}))~=nil
 end
 if not zone(anchor)and zone(current)then anchor=current;if E.db then E.db.questAnchor=current end end
 return anchor or current
end
local ownsExcitableSlime
local function journalHasExcitableSlime()
 if ownsExcitableSlime then return true end
 local api=C_PetJournal
 if not api then return false end
 local count=E.Call(api.GetNumPets)
 if not E.Public(count) or type(count)~='number' then return false end
 for index=1,count do
  local _,_,owned,_,_,_,_,name,_,_,creature=E.Call(api.GetPetInfoByIndex,index)
  if E.Public(owned) and (owned==true or owned==1) and
   (E.Public(creature) and creature==266735 or E.Public(name) and name=='Excitable Slime') then
   ownsExcitableSlime=true
   return true
  end
 end
 return false
end
function Q.Build(s)
 local anchor=Q.Anchor(s)
 local current=s.position and s.position.mapID or anchor
 local preferred=Q.Profile(s);Q.own=preferred and Q.profileQuests[preferred]or{}
 local candidates={}
 local function addZone(mapID)
  for _,id in ipairs(D.zoneQuests[mapID]or{})do candidates[id]=true end
  -- Some class chains have no zone index. Their reference locations still count.
  for id in pairs(Q.zoneCandidates[mapID]or{})do candidates[id]=true end
 end
 addZone(current)
 if anchor~=current then addZone(anchor)end
 for id in pairs(s.quests or{})do candidates[id]=true end
 if current==1458 then candidates[97583]=true end
 local out,keys={},{}
 local function add(id,kind,slot,loc,title,ref)
  local key=id..':'..kind..':'..tostring(slot or 0)
  if keys[key]then return end;keys[key]=true
  local q=D.quests[id]or{};local live=qs(id,s)
  local mobs,seen={},{};local function mob(n)if type(n)=='number'and not seen[n]then seen[n]=true;mobs[#mobs+1]=n end end
  if kind=='objective'and slot then
   local a=ref and D.actions[ref]
   for _,n in ipairs(a and a.mob_ids or{})do mob(n)end
   if a and a.target and a.target.kind=='npc'then mob(a.target.id)end
   for _,o in ipairs(q.objectives or{})do if o.n==slot then
    if o.kind=='kill'or o.kind=='talk'then mob(o.target)
    elseif o.kind=='item'then for _,src in ipairs(D.itemSources[o.target]or{})do if src.kind=='npc'then mob(src.id)end end end
   end end
  end
  out[#out+1]={id='fq:'..key,quest=id,kind=kind,slot=slot,title=title,body=title,category='Questing',destination=loc,zone=loc and loc.zone,mobIDs=mobs,
   level=q.level,minLevel=not live.inLog and q.min_level or nil,routeAction=ref or'database',areaTask=kind=='objective',source='Bundled quest facts',xp=q.xp}
 end
 local function wriggle(live)
  local have=E.Call(GetItemCount,278265,false)
  local ready=Q.Ready(live)
  local kind=live.inLog and (ready and 'turnin' or 'objective') or 'accept'
  local loc
  if not ready and (not E.Public(have) or type(have)~='number' or have<1)then
   loc={mapID=1458,x=55.4,y=64.1,name='Boyle',npcID=4612,zone='Undercity'}
  end
  local title=ready and 'Turn in WRIGGLE.' or loc and 'Get Nutritious Slime Sludge' or 'Dance with an Excitable Slime'
  add(97583,kind,nil,loc,title)
  out[#out].body=[[1. Find Boyle on the wooden pier in Undercity (55.4, 64.1). Buy Nutritious Slime Sludge if you have none. Five cost 26 copper before reputation discounts.
2. Target an Excitable Slime in the canal while standing on solid ground.
3. Type /dance until the slime wriggles while facing you and the game prompts you to inspect it.
4. Click the slime to give it the sludge. Keep the sludge in your bags.
5. Right-click the Excitable Slime reward in your bags to learn it. Open the Pet Journal and click Summon.]]
 end
 -- Same-title quests can have different IDs at the same giver. Keep the
 -- accepted objective in front until it is turned in or abandoned.
 local activeAtGiver={}
 for id,live in pairs(s.quests or {})do
  local q=D.quests[id]
  if q and live.inLog then
   for _,start in ipairs(q.starts or {})do
    activeAtGiver[q.title..':'..start.kind..':'..start.id]=true
   end
  end
 end
 local function hasActiveAtGiver(q)
  for _,start in ipairs(q.starts or {})do
   if activeAtGiver[q.title..':'..start.kind..':'..start.id] then return true end
  end
  return false
 end
 local function emit(id,remote)
  local q=D.quests[id];local live=qs(id,s)
  if not q then
   if live.inLog then add(id,Q.Ready(live)and'turnin'or'objective',nil,nil,(Q.Ready(live)and'Turn in 'or'Continue ')..(live.title or('quest '..id)))end
   return
  end
  if not Q.Eligible(id,s)then return end
  if id==97583 then
   local complete=E.Call(C_QuestLog and C_QuestLog.IsQuestFlaggedCompleted or IsQuestFlaggedCompleted,id)
   local reward=E.Call(C_Item and C_Item.GetItemCount or GetItemCount,275682,false)
   local learned=E.Call(IsPlayerSpell,1297608)
   local known=E.Call(IsSpellKnown,1297608)
   if journalHasExcitableSlime() or E.Public(complete) and (complete==true or complete==1)
    or E.Public(reward) and type(reward)=='number' and reward>0
    or E.Public(learned) and learned==true or E.Public(known) and known==true then return end
   if live.inLog or current==1458 then wriggle(live)end
   return
  end
  if live.inLog then
   if Q.Ready(live)then
    local loc,ref=actionLocation(id,'turnin',nil,s);loc=loc or Q.NearestSource(q.ends,s)
    add(id,'turnin',nil,loc,'Turn in '..q.title,ref)
   else
    if id==97485 then
     local function hasItem(item)
      local count=E.Call(GetItemCount,item,false)
      return E.Public(count) and type(count)=='number' and count>0
     end
     if not hasItem('Prepared Incense') then
      for index,step in ipairs({
       {'Bundle of Herbs','Nida Winterhoof',49.6,39.6},
       {'Bundle of Cedar Twigs','Nata Dawnstrider',45,38.8},
       {'Sinew Thread','Mahu',43.8,45.1},
       {'Ceremonial Flint and Tinder','Naal Mistrunner',51,52.5},
      })do
       if not hasItem(step[1])then
        add(id,'objective',index+100,{mapID=1456,x=step[3],y=step[4],name=step[2],zone='Thunder Bluff'},
         'Buy '..step[1]..' from '..step[2]..' (0/1)')
        return
       end
      end
      add(id,'objective',105,nil,'Combine the four components to make Prepared Incense')
      return
     end
     local loc=objectiveLocation(id,1,s)
     add(id,'objective',106,loc,"Spread the incense at the south-facing cliff of Hunter's Rise")
     return
    end
    local slots={};for i in ipairs(live.objectives or{})do slots[i]=true end
    if not next(slots)then
     for _,o in ipairs(q.objectives or{})do if o.n then slots[o.n]=true end end
     for _,a in pairs(Q.actionIndex[id]or{})do if a.kind=='objective'and a.slot then slots[a.slot]=true end end
    end
    local count=0;for slot in pairs(slots)do
     local goal=live.objectives and live.objectives[slot]
     local finished=goal and(goal.finished==true or type(goal.numRequired)=='number'and goal.numRequired>0 and type(goal.numFulfilled)=='number'and goal.numFulfilled>=goal.numRequired)
     if not finished then
      local loc,ref=objectiveLocation(id,slot,s);local a=ref and D.actions[ref]
      add(id,'objective',slot,loc,goal and goal.text or a and a.title or('Complete '..q.title),ref);count=count+1
     end
    end
    if count==0 then
     -- A delivery/talk quest may have no leaderboard. Its known contact is a
     -- destination, not evidence that the quest has already been completed.
     local loc,ref=actionLocation(id,'turnin',nil,s);loc=loc or Q.NearestSource(q.ends,s)
     add(id,'objective',nil,loc,'Continue '..q.title,ref)
    end
   end
  elseif not hasActiveAtGiver(q) and not q.catalogOnly and q.min_level and(q.type or 0)==0 and(q.level or q.min_level)<=s.level+2 then
   local loc,ref=actionLocation(id,'accept',nil,s);loc=loc or Q.NearestSource(q.starts,s)
   if loc and(remote or loc.mapID==current or loc.mapID==anchor)then add(id,'accept',nil,loc,'Accept '..q.title,ref)end
  end
 end
 local ids={};for id in pairs(candidates)do ids[#ids+1]=id end;table.sort(ids)
 for _,id in ipairs(ids)do emit(id,false)end
 local localWork=false;for _,r in ipairs(out)do if r.destination and(r.destination.mapID==current or r.destination.mapID==anchor)then localWork=true;break end end
 if not localWork then
  -- Exhaust local work before suggesting one reachable next-zone hub. Never
  -- offer the entire remaining reference guide or a different continent.
  local nextZone,best
  for id,q in pairs(D.quests)do if not candidates[id]and q.min_level and not q.catalogOnly and(q.type or 0)==0 and q.min_level<=s.level and(q.level or q.min_level)<=s.level+2 and(q.level or q.min_level)>=s.level-3 and Q.Eligible(id,s)then
   local loc=actionLocation(id,'accept',nil,s);loc=loc or Q.NearestSource(q.starts,s)
   local d=loc and E.Distance(s.position,loc)
   if d and(not best or d<best)then nextZone,best=loc.mapID,d end
  end end
  if nextZone then for _,id in ipairs(D.zoneQuests[nextZone]or{})do emit(id,true)end end
 end
 local grouped,byQuest={},{}
 for _,row in ipairs(out)do
  if row.kind=='objective'then
   local group=byQuest[row.quest]
   if not group then group={};for k,v in pairs(row)do group[k]=v end;group.id='fq:'..row.quest..':objective:all';group.slot=nil;group.objectives={};group.mobIDs={};group.title=(D.quests[row.quest]or{}).title or row.title;group.body='';byQuest[row.quest]=group;grouped[#grouped+1]=group end
   group.objectives[#group.objectives+1]=row
   group.body=group.body..(group.body~=''and'\n'or'')..(row.quest==97583 and row.body or row.title)
   for _,id in ipairs(row.mobIDs or{})do local found=false;for _,old in ipairs(group.mobIDs)do if old==id then found=true end end;if not found then group.mobIDs[#group.mobIDs+1]=id end end
   local d=row.destination and E.Distance(s.position,row.destination)
   if d and(not group.nearestDistance or d<group.nearestDistance)then group.destination=row.destination;group.nearestDistance=d end
   group.questDestination=group.destination
  else grouped[#grouped+1]=row end
 end
 out=grouped
 return out
end
-- The builder already covers both reference coordinates and the standalone DB.
function Q.AddDatabaseQuests()end
local eligible=E.Eligible
E.Eligible=function(row,s)
 s=s or E.state or E.Snapshot()
 if row.quest and(row.kind=='accept'or row.kind=='objective'or row.kind=='turnin')then
  if isPvPQuest(D.quests[row.quest]) or not Q.AllowsQuest(row.quest,s.faction) then return false end
  local live=qs(row.quest,s)
  if not live.inLog and not Q.Eligible(row.quest,s)then return false end
  if row.kind=='accept'and live.inLog then return false end
  if(row.kind=='objective'or row.kind=='turnin')and not(s.quests and s.quests[row.quest]and s.quests[row.quest].inLog==true)then return false end
  if row.kind=='turnin'and not Q.Ready(live)then return false end
 end
 return eligible(row,s)
end
local priority=E.Priority
local raceFactions={
 Alliance={1,4,8,64},
 Horde={2,16,32,128},
}
local function priorityQuest(q,s)
 if q.classes and q.classes~=0 then return true end
 local races=q.races
 local faction=raceFactions[s.faction]
 if not races or races==0 or not faction then return false end
 -- Catalog masks that cover the original faction races also represent faction-wide quests.
 for _,bit in ipairs(faction)do if not mask(races,bit)then return true end end
 return false
end
E.Priority=function(row,s)
 if row.urgentBags then return 10000 end
 if row.kind=='train'or row.professionChoice then return 1200 end
 row.localQuestPickup=nil
 if not row.routeAction then return priority(row,s)end
 if row.questDestination then row.destination=row.questDestination;row.zone=row.destination.zone end
 local loc=row.destination
 local localZone=loc and s.position and loc.mapID==s.position.mapID
 local d=E.Distance(s.position,loc)
 local q=D.quests[row.quest]or{}
 row._questDistance=d
 row._questPriority=loc and priorityQuest(q,s) or false
 row._questCluster=nil
 row.recommendationReason=nil
 -- Pick up quests within a short walk before leaving for a class objective.
 if row.kind=='accept' and localZone and d and d<=120 then
  row.localQuestPickup=true
  row.recommendationReason='Pick this up while you are nearby.'
  return 1180-d/10
 end
 if row._questPriority then return d and 1150-75*d/(d+250) or 1075 end
 if row.kind=='turnin'and d and d<=60 then return 1050-d/2 end
 if row.kind=='accept'and d and d<=250 then return 1000-d/6 end
 if d and d<=250 then return 740-d/4 end
 local v
 if d then v=600+(localZone and 40 or 0)-360*d/(d+600)
 else v=localZone and 230 or 100 end
 -- XP distinguishes longer trips with similar travel scores.
 if E.db and E.db.journey=='Leveling'and E.db.pace=='Grinding'then
  local remaining=0
  for _,o in ipairs(qs(row.quest,s).objectives or{})do
   if type(o.numRequired)=='number'and type(o.numFulfilled)=='number'and E.Public(o.numRequired)and E.Public(o.numFulfilled)then
    remaining=remaining+math.max(0,o.numRequired-o.numFulfilled)
   end
  end
  local seconds=45+remaining*12+(d or 1200)/7
  v=v+math.min(30,math.max(0,(q.xp or 0)/seconds))
 end
 return v
end

-- Check the actual separation between eligible, unfinished quest objectives.
-- Restrict the pass to nearby objectives so a dense distant cluster cannot
-- pull the player out of the current questing area.
local clusterRange=150
local function clusterObjectives(rows,s)
 local nearby={}
 local player=s.position
 if not player then return end
 local playerWorld,playerX,playerY=E.World(player.mapID,player.x,player.y)
 if not playerWorld then return end
 for _,row in ipairs(rows)do
  local d=row._questDistance
  if row.routeAction and row.kind=='objective'and d and d<=650 then
   for _,goal in ipairs(row.objectives or {row})do
    local p=goal.destination
    if p then
     local world,x,y=E.World(p.mapID,p.x,p.y)
     if world==playerWorld then
      local distance=math.sqrt((x-playerX)^2+(y-playerY)^2)
      if distance<=math.min(650,d+clusterRange)then
       nearby[#nearby+1]={row=row,point=p,x=x,y=y,distance=distance}
      end
     end
    end
   end
  end
 end
 for i,a in ipairs(nearby)do
  for j=i+1,#nearby do
   local b=nearby[j]
   if a.row.quest~=b.row.quest and (a.x-b.x)^2+(a.y-b.y)^2<=clusterRange^2 then
    a.matches=a.matches or {};a.matches[b.row.quest]=true
    b.matches=b.matches or {};b.matches[a.row.quest]=true
   end
  end
  if a.matches and not a.row._questPriority then
   local count=0;for _ in pairs(a.matches)do count=count+1 end
   local score=860+math.min(32,count*8)-a.distance/12
   if score>a.row._priority then
    a.row._questCluster=true;a.row._priority=score;a.row._questDistance=a.distance
    a.row.recommendationReason='This objective is near other unfinished quests.'
    a.row.destination=a.point;a.row.zone=a.point.zone
   end
  end
 end
end

local order=E.Order
E.Order=function(rows,s)
 local out=order(rows,s,clusterObjectives)
 local held=Q.held or E.db and E.db.questHeld;local heldRow,heldIndex
 for i,r in ipairs(out)do if r.id==held then heldRow,heldIndex=r,i;break end end
 local first=out[1];local service=first and(first.urgentBags or first.kind=='train'or first.professionChoice or first.kind=='farm')
 -- Keep the current objective only when both choices are comparable and
 -- close together. It must yield to a higher tier or a new local hub.
 if heldIndex and heldIndex>1 and first.routeAction and first.kind=='objective'and heldRow.routeAction and heldRow.kind=='objective'
    and first._questPriority==heldRow._questPriority and first._questCluster==heldRow._questCluster
    and first._questDistance and heldRow._questDistance and heldRow._questDistance<=first._questDistance+40 then
  local between=E.Distance(first.destination,heldRow.destination)
  if between and between<=clusterRange then table.remove(out,heldIndex);table.insert(out,1,heldRow)end
 end
 if not service then Q.held=out[1]and out[1].kind=='objective'and out[1].id or nil;if E.db then E.db.questHeld=Q.held end end
 return out
end

local refresh=ns.ProfessionGuide.Refresh
ns.ProfessionGuide.Refresh=function(...) return E.WithSnapshot(function(...)
 local s=E.Snapshot();if E.db and not E.db.questAnchor and s.position then E.db.questAnchor=s.position.mapID end;E.route=Q.Build(s);ns.ForeverData.steps=E.route
 -- Completionist uses the same eligible quest facts in the current zone plus collections.
 local collections=E.collections
 if E.db and E.db.journey=='Completionist'then local merged={};for _,r in ipairs(collections)do merged[#merged+1]=r end;for _,r in ipairs(E.route)do if r.destination and r.destination.mapID==E.db.questAnchor then merged[#merged+1]=r end end;E.collections=merged end
 local out=refresh(...);E.collections=collections
 local free=0;local valid=false;for bag=0,4 do local n=E.Call(C_Container and C_Container.GetContainerNumFreeSlots or GetContainerNumFreeSlots,bag);if type(n)=='number'then free=free+n;valid=true end end
 if valid and free<=2 and not(E.db and E.db.deferred['urgent-bags']and E.db.deferred['urgent-bags']>E.Time())then
  local loc=E.Nearest(E.vendors,s);local r={id='urgent-bags',kind='sell',category='Questing',title='Make room in your bags',body='Two or fewer bag spaces remain. Visit a vendor or remove unwanted items.',destination=loc,urgentBags=true,priority=10000}
  table.insert(ns.ProfessionGuide.steps,1,r)
  ns.ProfessionGuide.firstPending=r.id
  if ns.NormalUI and ns.NormalUI.model then ns.NormalUI.model.index=r.id;ns.NormalUI.model.browsing=false end
 end
 local root=ns.NormalUI and ns.NormalUI.root
 if root and root.stepButton and not root.stepButton.gfFreshSteps then root.stepButton.gfFreshSteps=true;root.stepButton.label:SetText('Fresh Steps');root.stepButton:SetScript('OnClick',function()Q.Fresh()end)end
 return ns.ProfessionGuide.steps
end,...)end
function Q.Fresh()
 local p=E.CurrentPosition();if E.db then if p then E.db.questAnchor=p.mapID end;E.db.questHeld=nil end;Q.held=nil
 if ns.NormalUI then ns.NormalUI.Resync()else ns.ProfessionGuide.Refresh()end
end
local skip=ns.ProfessionGuide.Skip
ns.ProfessionGuide.Skip=function(...)Q.held=nil;if E.db then E.db.questHeld=nil end;return skip(...)end
Q.Source='Polestar forever-db + user Factoruide exports + LibQuestDB harvest'

end)(ADDON,GF)


-- Forever UX bridge: presentation only; the Forever engine remains authoritative.
;(function(...)
local _,ns=...;local N,E,U=ns.NormalUI,ns.Forever,ns.ForeverUI
ns.SharedUI=U;ns.SharedExplorer=E
local setPane=U.SetPane
function U.SetPane(value)if E.db then E.db.pane=value end;return setPane(value)end
function N.FreshSteps()return ns.ForeverQuestPlanner.Fresh()end
end)(...)
-- GF_WORKFLOW56_BEGIN: reuse the approved component artwork; no new textures.
;(function(...)
local _,ns=...;local N,E,U,P=ns.NormalUI,ns.SharedExplorer,ns.SharedUI,ns.ProfessionGuide
-- SharedExplorerUI is exposed by the established browser module below.
U=ns.SharedUI or U
local W={};ns.WindowWorkflow=W
local function text(parent,size,value)return N.MakeText(parent,size,value,true)end
local function point(f,parent,x,y,w,h)
 f:ClearAllPoints();f:SetPoint('TOPLEFT',parent,'TOPLEFT',x,-y);if w then f:SetWidth(math.max(1,w))end;if h then f:SetHeight(math.max(1,h))end
end
local function isDungeon()return ns.SharedExplorer and ns.SharedExplorer.db and ns.SharedExplorer.db.pane=='Dungeons'end
function W.ZoneFor(loc)
 if not loc then return end
 if loc.zone and N.mapCatalog[loc.zone]then return loc.zone end
 for name,z in pairs(N.mapCatalog or{})do if z.mapID==loc.mapID then return name end end
end
local trainerIcons={['Alchemy']='Interface\\Icons\\Trade_Alchemy',['Blacksmithing']='Interface\\Icons\\Trade_BlackSmithing',['Enchanting']='Interface\\Icons\\Trade_Engraving',['Engineering']='Interface\\Icons\\Trade_Engineering',['Herbalism']='Interface\\Icons\\Trade_Herbalism',['Jewelcrafting']='Interface\\Icons\\INV_Misc_Gem_01',['Leatherworking']='Interface\\Icons\\Trade_LeatherWorking',['Mining']='Interface\\Icons\\Trade_Mining',['Skinning']='Interface\\Icons\\INV_Misc_Pelt_Wolf_01',['Tailoring']='Interface\\Icons\\Trade_Tailoring',['Cooking']='Interface\\Icons\\INV_Misc_Food_15',['First Aid']='Interface\\Icons\\Spell_Holy_SealOfSacrifice',['Fishing']='Interface\\Icons\\Trade_Fishing'}
function W.TrainerIcon(record)return trainerIcons[record.profession]or'Interface\\Icons\\INV_Misc_Book_09'end
function W.GPSPlace(d)
 if not d then return end
 -- The user verified this district/underground distinction while testing.
 if d.npcID==4596 or d.name=='James Van Brunt'then return 'The War Quarter, Undercity','Underground · Enter Undercity first'end
 return d.subzone or d.district or d.zone or W.ZoneFor(d),d.underground and'Underground'or nil
end
function W.SelectMap(loc)
 if not loc or not loc.x or not loc.y then W.mapLocation=nil;N.UpdateMapView();return false end
 local zone=W.ZoneFor(loc);if not zone then W.mapLocation=nil;N.UpdateMapView();return false end
 if U and U.pane=='Dungeons'then U.SetPane('Recipes')end
 W.mapLocation=loc;W.settingZone=true;N.SetZone(zone);W.settingZone=false
 N.mapCenterX=loc.x/100;N.mapCenterY=loc.y/100;N.mapZoom=1;N.UpdateMapView();return true
end
function W.Tooltip(owner,itemID,heading,addLines)
 local root=N.root;if not root then return end
 if not W.tooltip then
  W.tooltip=CreateFrame('GameTooltip','GrindingForeverRecipeTooltip',UIParent,'GameTooltipTemplate');W.tooltip:SetClampedToScreen(true)
 end
 local t=W.tooltip;t:SetOwner(owner,'ANCHOR_NONE');t:SetFrameStrata('TOOLTIP');t:SetFrameLevel(N.frame:GetFrameLevel()+220);t:ClearLines()
 if itemID then t:SetHyperlink('item:'..tostring(itemID))elseif heading then t:AddLine(heading,1,.84,.52)end
 if addLines then addLines(t)end
 t:Show();t:ClearAllPoints()
 local scale=t:GetEffectiveScale();local screen=UIParent:GetWidth()*UIParent:GetEffectiveScale()/scale
 local right=(N.frame:GetRight()or 0)*N.frame:GetEffectiveScale()/scale
 local left=(N.frame:GetLeft()or 0)*N.frame:GetEffectiveScale()/scale
 if screen-right>=t:GetWidth()+14 then t:SetPoint('LEFT',N.frame,'RIGHT',12,0)
 elseif left>=t:GetWidth()+14 then t:SetPoint('RIGHT',N.frame,'LEFT',-12,0)
 else t:SetPoint('BOTTOMRIGHT',owner,'TOPRIGHT',0,8)end
end
local function hideTip()if W.tooltip then W.tooltip:Hide()end end
local function makeScrollPair(parent,up,down)
 local pair={};for i,label in ipairs({'up','down'})do
  local b=N.MakeButton(parent,'',24,i==1 and up or down);b:SetSize(24,28)
  local tri=b:CreateTexture(nil,'OVERLAY');tri:SetTexture('Interface\\AddOns\\GrindingForever\\Media\\ControlTriangleRight');tri:SetSize(11,11);tri:SetPoint('CENTER',b,'CENTER',0,0);tri:SetRotation(i==1 and math.pi/2 or -math.pi/2)
  pair[i]=b
 end;return pair
end
W.MakeScrollPair=makeScrollPair
function W.Ensure()
 local r=N.root;if not r or W.ready then return end
 r.inlineFarm=N.MakeButton(r,'Farm Route',100,function()local ok,why=W.StartStepFarm();if not ok then ns.Print(why)end end);r.inlineFarm:Hide()
 r.inlineSearch=N.MakeButton(r,'Next Spot',100,function()ns.NPCSearch.Next()end);r.inlineSearch:Hide()
 r.workflowGrip=N.MakeButton(r,'',22,function()W.collapsed=not W.collapsed;N.WorkflowRelayout();N.Refresh(true);N.RefreshRecipes()end);r.workflowGrip:SetSize(22,58)
 r.workflowGrip:SetFrameLevel(r:GetFrameLevel()+30)
 r.workflowGrip.label:SetText('');r.workflowGrip.glyph=r.workflowGrip:CreateTexture(nil,'OVERLAY');r.workflowGrip.glyph:SetTexture(r.back.glyph:GetTexture());r.workflowGrip.glyph:SetSize(16,16);r.workflowGrip.glyph:SetPoint('CENTER')
 r.workflowStepIndicators=makeScrollPair(r.panels[1],function()N.rowStart=math.max(1,(N.rowStart or 1)-1);N.LayoutStepRows(N.visible or{},N.rowStart)end,function()local count=#(N.visible or{});N.rowStart=math.min(count,(N.rowStart or 1)+1);N.LayoutStepRows(N.visible or{},N.rowStart)end)
 r.workflowRecipeIndicators=makeScrollPair(r.panels[3],function()local f=r.recipeScroll;f:SetVerticalScroll(math.max(0,f:GetVerticalScroll()-120));W.ScrollState()end,function()local f=r.recipeScroll;f:SetVerticalScroll(math.min(math.max(0,r.recipeContent:GetHeight()-f:GetHeight()),f:GetVerticalScroll()+120));W.ScrollState()end)
 r.workflowBodyIndicators=makeScrollPair(r.panels[1],function()local f=N.bodyScroll;f:SetVerticalScroll(math.max(0,f:GetVerticalScroll()-55));W.Layout()end,function()local f=N.bodyScroll;local _,_,_,c=N.WorkflowBody();f:SetVerticalScroll(math.min(math.max(0,c:GetHeight()-f:GetHeight()),f:GetVerticalScroll()+55));W.Layout()end)
 r.recipeScroll:HookScript('OnVerticalScroll',function()W.ScrollState()end)
 r.recipeScroll:HookScript('OnMouseWheel',function()W.ScrollState()end)
 for _,row in ipairs(N.stepRows)do
  row:HookScript('OnClick',function()
   W.selection='step';W.activeSource=nil;W.activeTrainer=nil;W.expandedRecipe=nil;N.selectedRecipe=nil
   for i,n in ipairs(N.visible or{})do if n.id==row.stepID then N.rowStart=i;break end end
   local n=N.model:Current();local loc=n and n.destination
   if not loc and P.Destination then loc=P.Destination()end
   W.SelectMap(loc);N.Refresh(true);N.RefreshRecipes()
  end)
 end
 N.frame:HookScript('OnHide',hideTip)
 W.ready=true
end
function W.ScrollState()
 local r=N.root;if not W.ready then return end
 local f=r.recipeScroll;local maximum=math.max(0,r.recipeContent:GetHeight()-f:GetHeight());local offset=f:GetVerticalScroll()
 for i,b in ipairs(r.workflowRecipeIndicators)do b:SetShown(maximum>2 and N.mode~='compact');b:SetAlpha((i==1 and offset<1 or i==2 and offset>=maximum-1)and .35 or 1)end
end
function W.Layout()
 local r=N.root;if not r or not r.panels then return end;W.Ensure()
 local compact=N.mode=='compact';if compact and not N.fieldGuideMinimumHeight and r:GetHeight()<(W.recipeCompact and 820 or 560)then r:SetHeight(W.recipeCompact and 820 or 560)end;local collapsed=W.collapsed and not compact;local p=r.panels
 local width=r:GetWidth();local top=compact and 145 or 170;local height=r:GetHeight()-top-10
 local stepW=compact and width-16 or collapsed and 4 or (width-16)*(.255/.835)
 local mapW=collapsed and (width-16)/2 or (width-16)*(.34/.835)
 local recipeW=collapsed and mapW or width-16-stepW-mapW
 point(p[1],r,8,top,stepW,height);p[1]:SetShown(not collapsed)
 point(p[2],r,8+(collapsed and 0 or stepW),top,mapW,height);p[2]:SetShown(not compact)
 point(p[3],r,8+(collapsed and mapW or stepW+mapW),top,recipeW,height);p[3]:SetShown(not compact)
 if compact then for _,d in ipairs(r.dividers)do d:Hide()end else
  for i,d in ipairs(r.dividers)do d:ClearAllPoints();d:SetPoint('TOP',p[i],'TOPRIGHT',0,0);d:SetHeight(height-4);d:SetShown(not collapsed or i==2)end
 end
 local x={9,8+stepW,8+stepW+mapW,width-9}
 if collapsed then x={9,9,8+mapW,width-9}end
 for _,c in ipairs(r.connectors)do
  local col=c.junctionColumn or 1;local row=c.junctionRow or 1
  if compact then c:SetShown((col==1 or col==4)and not(row==1 and col==4));point(c,r,col==1 and 2 or width-17,row==1 and top-1 or r:GetHeight()-16)
  else c:ClearAllPoints();c:SetPoint('CENTER',r,'TOPLEFT',x[col],row==1 and -top-6 or -r:GetHeight()+9);c:SetShown(not collapsed or col~=2)end
 end
 for _,s in ipairs(r.shoulders)do
  if compact then s:Hide()else
   local col=s.junctionColumn or 1;local row=s.junctionRow or 1;local sx=x[col];local sy=row==1 and -top-6 or -r:GetHeight()+9
   s:ClearAllPoints();local dir=s.direction
   if dir=='RIGHT'then s:SetPoint('LEFT',r,'TOPLEFT',sx,sy)elseif dir=='LEFT'then s:SetPoint('RIGHT',r,'TOPLEFT',sx,sy)elseif dir=='DOWN'then s:SetPoint('TOP',r,'TOPLEFT',sx,sy)else s:SetPoint('BOTTOM',r,'TOPLEFT',sx,sy)end
   s:SetShown(not collapsed or col~=2)
  end
 end
 local headerW=compact and stepW*.75 or width*.75
 local headerCenter=compact and 8+stepW/2 or width/2
 r.wood:ClearAllPoints();r.wood:SetPoint('BOTTOM',r,'TOPLEFT',headerCenter,-top-3);r.wood:SetSize(headerW,40)
 for i,cap in ipairs(r.endcaps)do local cw=compact and 160 or 194;cap:SetSize(cw,cw*282/482);cap:ClearAllPoints();cap:SetPoint('BOTTOM',r.wood,i==1 and 'BOTTOMLEFT'or'BOTTOMRIGHT',i==1 and -cw*.08 or cw*.08,0)end
 for _,f in ipairs({r.titleLeft,r.titleRight})do f:SetFont('Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf',compact and 23 or 26,'');f:SetWidth(headerW*.38)end
 r.headerEmblem:SetSize(32,32)
 r.workflowGrip:ClearAllPoints();r.workflowGrip:SetPoint('CENTER',collapsed and p[2]or p[1],'LEFT',0,0);r.workflowGrip.glyph:SetTexture((collapsed and r.forward.glyph or r.back.glyph):GetTexture());r.workflowGrip:SetShown(not compact)
 r.modeButton:SetParent(p[1]);point(r.modeButton,p[1],stepW-104,20,80,28);r.modeButton:Show()
 if N.settingsFrame then N.settingsFrame:SetParent(p[1])end
 local short=compact and height<420;W.shortCompact=short
 if r.journeySwitch then point(r.journeySwitch,p[1],28,57,stepW-56,32);r.journeySwitch:Fit(stepW-56);r.journeySwitch:SetShown(not short)end
 if r.paceSwitch then point(r.paceSwitch,p[1],28,97,stepW-56,32);r.paceSwitch:Fit(stepW-56);r.paceSwitch:SetShown(not short and E.db.journey~='Completionist')end
 local filterY=short and 20 or E.db and E.db.journey=='Completionist'and 59 or 99;local fx=28
 local filterLabels={'All','Quests','Gatherables','Crafts'};local fractions={.16,.21,.37,.26};local usable=stepW-74
 for i,b in ipairs(r.filterButtons)do local fw=usable*fractions[i];point(b,p[1],fx,filterY,fw,36);b.label:SetFont('Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf',16,'');fx=fx+fw+6;b:Hide() end
 r.controls:SetParent(p[1]);point(r.controls,p[1],28,height-66,stepW-56,38)
 r.back:Hide();r.forward:Hide();r.stepButton.label:SetText('Fresh Steps');r.stepButton:SetScript('OnClick',function()if N.FreshSteps then N.FreshSteps()end end)
 local buttons={r.stepButton,r.reset,r.settings};local widths={112,68,82};local total=274;local bx=math.max(0,(stepW-56-total)/2)
 for i,b in ipairs(buttons)do point(b,r.controls,bx,0,widths[i],36);b.label:SetFont('Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf',16,'');bx=bx+widths[i]+6 end
 r.actionDivider:SetParent(p[1]);r.actionDivider:ClearAllPoints();r.actionDivider:SetPoint('BOTTOMLEFT',p[1],'BOTTOMLEFT',28,82);r.actionDivider:SetPoint('BOTTOMRIGHT',p[1],'BOTTOMRIGHT',-28,82);r.actionDivider:SetHeight(1)
 if N.farmButton then N.farmButton:SetParent(p[2]);point(N.farmButton,p[2],math.max(28,(mapW-200)/2),height-64,200,34);N.farmButton:SetShown(not compact)end
 r.infoTitle:Hide();r.heading:Hide();local _,_,stepLabel=N.WorkflowBody();stepLabel:Hide();r.compactNext:Hide();r.compactNextHit:Hide();r.compactDetails:Hide()
 for _,b in ipairs({r.browserSwitch,r.zoneButton,r.sourceButton,r.professionButton,r.recipeMap,r.mapHint})do if b then b:SetParent(p[2])end end
 if r.browserSwitch then point(r.browserSwitch,p[2],28,30,mapW-56,30);r.browserSwitch:Fit(mapW-56)end
 point(r.zoneButton,p[2],28,76,mapW-56,36);point(r.sourceButton,p[2],28,120,(mapW-66)*.46,36);point(r.professionButton,p[2],38+(mapW-66)*.46,120,(mapW-66)*.54,36)
 r.recipeMap:ClearAllPoints();r.recipeMap:SetPoint('TOPLEFT',p[2],'TOPLEFT',28,-172);r.recipeMap:SetPoint('TOPRIGHT',p[2],'TOPRIGHT',-28,-172);r.recipeMap:SetHeight(math.max(90,math.min((mapW-56)/1.25,height-285)))
 W.FitMap();r.mapHint:ClearAllPoints();r.mapHint:SetPoint('TOPLEFT',r.recipeMap,'BOTTOMLEFT',0,-6);r.mapHint:SetPoint('TOPRIGHT',r.recipeMap,'BOTTOMRIGHT',0,-6);r.mapHint:SetJustifyH('CENTER');r.mapHint:SetText('Scroll to zoom · Drag to pan')
 r.recipesText:ClearAllPoints();r.recipesText:SetPoint('TOPLEFT',p[3],'TOPLEFT',28,-30);r.recipesText:SetWidth(recipeW-56)
 r.recipeScroll:ClearAllPoints();r.recipeScroll:SetPoint('TOPLEFT',p[3],'TOPLEFT',28,-65);r.recipeScroll:SetPoint('BOTTOMRIGHT',p[3],'BOTTOMRIGHT',-42,82)
 r.recipeSearch:ClearAllPoints();r.recipeSearch:SetPoint('BOTTOMLEFT',p[3],'BOTTOMLEFT',28,30);r.recipeSearch:SetPoint('BOTTOMRIGHT',p[3],'BOTTOMRIGHT',-28,30)
 for i,b in ipairs(r.workflowStepIndicators)do point(b,p[1],stepW-29,i==1 and filterY+50 or height-110,22,26)end
 for i,b in ipairs(r.workflowRecipeIndicators)do point(b,p[3],recipeW-29,i==1 and 65 or height-110,22,26)end
 if r.updateRouteHere then r.updateRouteHere:SetParent(p[1]);point(r.updateRouteHere,p[1],28,height-112,180,28)end
 N.LayoutStepRows(N.visible or{},N.rowStart or 1);W.ScrollState()
end
N.WorkflowLayout=W.Layout
local stepDetails
local function addCraftTile(details)
 local tile=CreateFrame('Frame',nil,details)
 tile:EnableMouse(true)
 tile.back=tile:CreateTexture(nil,'BACKGROUND')
 tile.back:SetAllPoints()
 tile.icon=tile:CreateTexture(nil,'ARTWORK')
 tile.icon:SetSize(32,32)
 tile.icon:SetPoint('TOP',0,-4)
 tile.quantity=text(tile,12)
 tile.quantity:SetPoint('BOTTOMRIGHT',tile.icon,'BOTTOMRIGHT',8,-3)
 tile.quantity:SetFont('Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf',13,'OUTLINE')
 tile.quantity:SetTextColor(1,.93,.72)
 tile.label=text(tile,12)
 tile.label:SetPoint('TOPLEFT',2,-40)
 tile.label:SetPoint('BOTTOMRIGHT',-2,2)
 tile.label:SetJustifyH('CENTER')
 tile.label:SetJustifyV('TOP')
 tile:SetScript('OnEnter',function(self)
  local info=self.info
  if not info then return end
  W.Tooltip(self,nil,info.name,function(tip)
   if info.details then
    tip:AddLine('Ingredients',1,.84,.52)
    for _,input in ipairs(info.details)do tip:AddLine(input,1,1,1,true)end
   else
    tip:AddLine(info.quantity..' in bags / needed',1,1,1)
   end
  end)
 end)
 local function hideTooltip(self)
  if W.tooltip and W.tooltip:GetOwner()==self then W.tooltip:Hide()end
 end
 tile:SetScript('OnLeave',hideTooltip)
 tile:SetScript('OnHide',hideTooltip)
 return tile
end
local function layoutStepDetails(step,visible,nextIndex,body,content,width)
 local nextQuest
 if step.quest then
  local quests=ns.ForeverQuestData and ns.ForeverQuestData.quests
  for i=nextIndex,#visible do
   local candidate=visible[i]
   if candidate.quest and candidate.quest~=step.quest then
    local quest=quests and quests[candidate.quest]
    nextQuest=quest and quest.title or candidate.title
    break
   end
  end
 end
 local sections=step.craftingSections
 local description=sections and step.craftingBody or step.body or ''
 body:SetWidth(width)
 body:SetText(description)
 body:SetHeight(0)
 local bodyHeight=description~='' and body:GetStringHeight()+4 or 0
 if not sections and not nextQuest then
  if stepDetails then stepDetails:Hide()end
  return math.max(1,bodyHeight)
 end
 if not stepDetails then
  stepDetails=CreateFrame('Frame',nil,content)
  stepDetails.texts,stepDetails.tiles={},{}
 end
 local details=stepDetails
 local textCount,tileCount,y=0,0,0
 local function line(value,size)
  textCount=textCount+1
  local label=details.texts[textCount]
  if not label then
   label=text(details,size)
   details.texts[textCount]=label
  end
  label:SetFont('Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf',size,'')
  label:SetText(value)
  point(label,details,0,y,width)
  label:SetHeight(0)
  label:Show()
  y=y+label:GetStringHeight()+4
 end
 local columns=math.max(1,math.floor((width+6)/88))
 local tileWidth=math.min(96,(width-6*(columns-1))/columns)
 for _,section in ipairs(sections or {})do
  line(section.title,16)
  if section.tiles then
   for index,info in ipairs(section.tiles)do
    tileCount=tileCount+1
    local tile=details.tiles[tileCount]
    if not tile then
     tile=addCraftTile(details)
     details.tiles[tileCount]=tile
    end
    tile.info=info
    local icon=info.itemID and E.Call(C_Item and C_Item.GetItemIconByID or GetItemIcon,info.itemID)
    if not icon and info.spellID then icon=E.Call(C_Spell and C_Spell.GetSpellTexture or GetSpellTexture,info.spellID)end
    tile.icon:SetTexture(icon or 'Interface\\Icons\\INV_Misc_Book_09')
    if info.missing then
     tile.back:SetColorTexture(.65,.18,.085,.28)
     tile.label:SetTextColor(.49,.12,.045)
    else
     tile.back:SetColorTexture(.40,.26,.10,.13)
     tile.label:SetTextColor(.18,.105,.045)
    end
    tile.label:SetText(info.name)
    tile.quantity:SetText(info.quantity)
    point(tile,details,((index-1)%columns)*(tileWidth+6),y+math.floor((index-1)/columns)*74,tileWidth,68)
    tile:Show()
   end
   y=y+math.ceil(#section.tiles/columns)*74
  else
   for _,value in ipairs(section.lines)do line(value,14)end
   y=y+4
  end
 end
 if nextQuest then
  line('Next quest',16)
  line(nextQuest,14)
 end
 for i=textCount+1,#details.texts do details.texts[i]:Hide()end
 for i=tileCount+1,#details.tiles do details.tiles[i]:Hide()end
 local gap=bodyHeight>0 and 6 or 0
 point(details,content,0,bodyHeight+gap,width,y)
 details:Show()
 return math.max(1,bodyHeight+gap+y)
end
local function nearbyOpportunity(step,visible)
 local counter=step.resourceCounters and step.resourceCounters[1]
 if counter then return 'Gather nearby',counter.text..'\nGather alongside your current quest.' end
 for _,row in ipairs(visible)do
  if row.id~=step.id and (row.kind=='recipe' or row.id=='camp:visit') then
   return row.kind=='recipe' and 'Recipe vendor nearby' or 'Camp nearby',row.title..'\n'..(row.body or ''),row.id
  end
 end
end
local function objectiveHeadline(step)
 if step.kind~='objective' or not step.quest or step.quest==97583 or not step.actionHeadline then return end
 return step.actionHeadline,step.actionContext,step.actionLine
end
function N.LayoutStepRows(visible,start)
 local r=N.root;if not r then return 0 end
 local panel=r.panels[1];local compact=N.mode=='compact';local hidden=W.collapsed and not compact
 local body,bodyScroll,stepLabel,bodyContent,status=N.WorkflowBody()
 bodyScroll:Hide();r.done:Hide();r.skip:Hide();status:Hide();if r.inlineFarm then r.inlineFarm:Hide()end;if r.inlineSearch then r.inlineSearch:Hide()end
 if r.stepContext then r.stepContext:Hide()end
 if r.opportunityStrip then r.opportunityStrip:Hide();r.opportunityDetail:Hide()end
 local y=compact and 118 or E.db and E.db.journey=='Completionist'and 105 or 145;local shown=0;local selected=N.model.index;local room=panel:GetHeight()-92;local width=panel:GetWidth()-72
 for _,b in ipairs(r.workflowBodyIndicators or{})do b:Hide()end
 for i,row in ipairs(N.stepRows)do
  local step=visible[start+i-1];row:Hide();row.stepID=nil
  if step and not hidden and y+40<room then
   step=N.WorkflowLive(step)
   local active=step.id==selected
   local headline,context,actionLine
   if active then headline,context,actionLine=objectiveHeadline(step)end
   row.label:SetText(headline or step.title or'');row.label:SetWidth(width-20);row.label:SetHeight(0);row.label:SetWordWrap(true);row.label:SetFont('Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf',20,'');row.category:Hide()
   local h=math.max(38,row.label:GetStringHeight()+16)
   row.selected=active and W.selection~='source';row:SetEnamelTint();row.stepID=step.id;point(row,panel,28,y,width,h);row.label:ClearAllPoints();row.label:SetPoint('TOPLEFT',row,'TOPLEFT',10,-8)
   if active then
    if context then
     if not r.stepContext then
      r.stepContext=text(row,13)
      r.stepContext:SetTextColor(.35,.22,.10)
     end
     r.stepContext:SetParent(row);r.stepContext:SetText(context)
     point(r.stepContext,row,10,h-2,width-20)
     r.stepContext:SetHeight(0);r.stepContext:Show()
     h=h+math.max(16,r.stepContext:GetStringHeight()+3)
     if actionLine and step.body and step.body:sub(1,#actionLine)==actionLine then
      step.body=step.body:sub(#actionLine+1):gsub('^%s+','')
     end
     if actionLine and step.craftingBody and step.craftingBody:sub(1,#actionLine)==actionLine then
      step.craftingBody=step.craftingBody:sub(#actionLine+1):gsub('^%s+','')
     end
    end
    local opportunity,opportunityBody,opportunityID=nearbyOpportunity(step,visible)
    local bodyY=h+34
    local available=math.max(1,math.min(250,room-y-bodyY-40-(opportunity and 32 or 0)))
    status:SetParent(row);point(status,row,10,h+4,width-20,26);status:Show()
    bodyScroll:SetParent(row)
    bodyContent:SetWidth(width-20)
    local contentHeight=layoutStepDetails(step,visible,start+i,body,bodyContent,width-38)
    bodyContent:SetHeight(contentHeight)
    local bh=math.min(available,math.max(1,contentHeight))
    point(bodyScroll,row,10,bodyY,width-20,bh)
    local scroll=step.id==W.detailStepID and bodyScroll:GetVerticalScroll() or 0
    W.detailStepID=step.id
    bodyScroll:SetVerticalScroll(math.min(scroll,math.max(0,contentHeight-bh)))
    bodyScroll:Show()
    if W.ready then for j,b in ipairs(r.workflowBodyIndicators)do b:SetParent(row);point(b,row,width-24,j==1 and bodyY or bodyY+bh-26,20,24);b:SetShown(contentHeight>bh+2)end end
    local manual=step.kind~='profession'and step.kind~='farm'and step.kind~='grind'and step.kind~='objective'and step.kind~='accept'and step.kind~='turnin'
    r.done:SetParent(row);r.skip:SetParent(row);local by=bodyY+bh+8;local farm=W.StepFarmable and W.StepFarmable(step);local search=ns.NPCSearch and ns.NPCSearch.Active(step);local total=(farm or search)and 186 or manual and 164 or 78;local bx=math.max(10,(width-total)/2)
    local prep=ns.DungeonPrep
    local offer=step.kind=='dungeonPrepOffer'
    local preparing=prep and prep.active~=nil
    r.done.label:SetText(offer and 'Get Quests for Dungeon' or 'Done')
    r.skip.label:SetText(preparing and 'Cancel Dungeon Prep' or 'Skip')
    if offer then
     bx=math.max(4,(width-310)/2)
     point(r.done,row,bx,by,220,30);point(r.skip,row,bx+228,by,78,30)
    elseif preparing then
     point(r.skip,row,math.max(4,(width-180)/2),by,180,30)
    else
     point(r.done,row,bx,by,78,30);point(r.skip,row,manual and bx+86 or bx,by,78,30)
    end
    r.done:SetShown(manual and not preparing);r.skip:Show()
    if farm and r.inlineFarm then r.inlineFarm:SetParent(row);point(r.inlineFarm,row,bx+86,by,120,30);r.inlineFarm:Show()end
    if search and r.inlineSearch then r.inlineSearch:SetParent(row);point(r.inlineSearch,row,bx+86,by,100,30);r.inlineSearch:Show()end
    h=by+38
    if opportunity and y+h+28<=room then
     if not r.opportunityStrip then
      local strip=N.MakeButton(row,'',width-20)
      r.opportunityStrip=strip
      r.opportunityArrow=N.ButtonArrow(strip,'right','RIGHT')
      r.opportunityDetail=text(row,13)
      r.opportunityDetail:SetTextColor(.28,.16,.065)
      strip:SetScript('OnClick',function()
       if W.openOpportunity==W.currentOpportunity then W.openOpportunity=nil else W.openOpportunity=W.currentOpportunity end
       N.Refresh(true)
      end)
     end
     local strip,detail=r.opportunityStrip,r.opportunityDetail
     local key=step.id..':'..(opportunityID or opportunity)
     W.currentOpportunity=key
     local expanded=W.openOpportunity==key
     strip:SetParent(row)
     strip.label:SetText(opportunity)
     r.opportunityArrow:SetRotation(expanded and -math.pi/2 or 0)
     point(strip,row,10,h,width-20,25)
     strip:Show();h=h+29
     if expanded and opportunityBody and opportunityBody~='' then
      detail:SetParent(row);detail:SetText(opportunityBody)
      point(detail,row,10,h,width-20)
      detail:SetHeight(0)
      local height=detail:GetStringHeight()
      if y+h+height<=room then detail:Show();h=h+height+4 end
     end
    end
    row:SetHeight(h)
   end
   row:Show();shown=shown+1;y=y+h+4
  end
 end
 N.displayedRowCount=shown
 if W.ready then local overflow=start>1 or start+shown-1<#visible;for i,b in ipairs(r.workflowStepIndicators)do b:SetShown(overflow and not hidden);b:SetAlpha((i==1 and start<=1 or i==2 and start+shown-1>=#visible)and .35 or 1)end end
 return shown
end
-- A source remains a distinct selectable record even when several share a zone.
function W.SourceRows(records,query)
 local out={};local seen={}
 for _,r in ipairs(records or{})do
  if r.kind=='trainer'then
   if N.sourceFilters.Trainer and N.professionFilters[r.profession]then local c={};for k,v in pairs(r)do c[k]=v end;c.workflowSource='Trainer';out[#out+1]=c end
  elseif not r.kind and N.professionFilters[r.profession]~=false and E.Eligible(r)then
   for _,loc in ipairs(r.locations or{})do
    if N.sourceFilters[loc.source]and E.Eligible(loc)and(query or loc.zone==N.selectedZone)then
     local key=tostring(r.spellID or r.id or r.name)..':'..tostring(loc.source)..':'..tostring(loc.npcID or loc.name)..':'..tostring(loc.mapID)..':'..tostring(loc.x)..':'..tostring(loc.y)
     if not seen[key]then seen[key]=true;local c={};for k,v in pairs(r)do c[k]=v end;c.locations={loc};c.workflowSource=loc.source;c.workflowKey=key;c.workflowBase=r;out[#out+1]=c end
    end
   end
  end
 end
 local order={Vendor=1,Drop=2,Treasure=3,Quest=4,Trainer=5}
 table.sort(out,function(a,b)local x,y=order[a.workflowSource]or 9,order[b.workflowSource]or 9;if x~=y then return x<y end;if a.kind=='trainer'and b.kind=='trainer'then local skills=E.state and E.state.skills or{};local aa,bb=skills[a.profession]~=nil,skills[b.profession]~=nil;if aa~=bb then return aa end end;if a.name~=b.name then return a.name<b.name end;return tostring(a.workflowKey or a.id)<tostring(b.workflowKey or b.id)end)
 return out
end
function W.CatalogRows(query)
 if not query then local rows=E.KnownRecipeRows(N.selectedZone,nil);for _,r in ipairs(rows)do if r.kind=='trainer'and not r.locations then r.locations={r.location}end end;return rows end
 local out={};query=query:lower()
 for _,r in pairs(E.recipes or{})do
  local fact=r;local id=tostring(fact.itemId or'');local product=tostring(fact.craftedItemId or'')
  if (r.name or''):lower():find(query,1,true)or query==id or query==product then
   r.requiredSkill=fact.requiredSkill;r.learnableItemID=fact.itemId or r.learnableItemID;r.reagents=fact.reagents;out[#out+1]=r
  end
 end
 return out
end
local legacyRecipes=N.RefreshRecipes
function N.RefreshRecipes()
 local r=N.root;if not r or not r.recipeContent then return end
 if U and U.pane=='Dungeons'then
  for _,h in ipairs(r.workflowHeaders or{})do h:Hide()end
  local v=legacyRecipes();W.Layout()
  for _,b in ipairs(r.recipeRows or{})do if b:IsShown()then b:SetScript('OnEnter',function(self)self.menuHighlight:Show();local q=self.record;W.Tooltip(self,q and(q.itemID or q.learnableItemID or q.productID),q and q.name)end);b:SetScript('OnLeave',function(self)self.menuHighlight:Hide();hideTip()end)end end
  return v
 end
 local query=r.recipeSearch:GetText();query=query and query:match('%S')and query or nil
 local sources=W.SourceRows(W.CatalogRows(query),query);local records={}
 for _,r in ipairs(sources)do records[#records+1]=r;if r.kind=='trainer'and W.activeTrainer==r.id then
  for _,recipe in ipairs(r.recipes or{})do if N.professionFilters[recipe.profession]and E.Known(recipe)~=true then local c={};for k,v in pairs(recipe)do c[k]=v end;c.kind='trainerRecipe';c.workflowSource='Trainer';c.workflowKey=r.id..':'..tostring(c.spellID);c.locations={r.location or(r.locations and r.locations[1])};records[#records+1]=c end end
 end end;N.visibleRecipes=records
 local width=math.max(100,r.panels[3]:GetWidth()-72);r.recipeContent:SetWidth(width);local y=0;local group;local headers=0;r.workflowHeaders=r.workflowHeaders or{};r.recipeRows=r.recipeRows or{}
 W.sourceCollapsed=W.sourceCollapsed or{}
 local function header(label,key)
  headers=headers+1;local f=r.workflowHeaders[headers]
  if not f then f=CreateFrame('Button',nil,r.recipeContent);f.label=text(f,18,'');f.label:SetPoint('LEFT',24,0);f.arrow=f:CreateTexture(nil,'ARTWORK');f.arrow:SetTexture('Interface\\AddOns\\GrindingForever\\Media\\ControlTriangleRight');f.arrow:SetSize(14,14);f.arrow:SetPoint('LEFT',3,0);r.workflowHeaders[headers]=f end
  point(f,r.recipeContent,0,y,width,28);f.label:SetText(label);f.arrow:SetRotation(key and W.sourceCollapsed[key]and 0 or-math.pi/2)
  f:SetScript('OnClick',key and function()W.sourceCollapsed[key]=not W.sourceCollapsed[key];N.RefreshRecipes()end or nil)
  f:Show();y=y+32
 end
 for i,record in ipairs(records)do
  if group~=record.workflowSource then group=record.workflowSource;header(group=='Trainer'and'Trainers'or group,group)end
  if not W.sourceCollapsed[record.workflowSource]then
  local b=r.recipeRows[i]
  if not b then b=CreateFrame('Button',nil,r.recipeContent,'BackdropTemplate');b.enamelPieces={};b.label=text(b,17,'');N.PlainOption(b);b.icon=b:CreateTexture(nil,'ARTWORK');b.icon:SetSize(26,26);b.icon:SetPoint('TOPLEFT',4,-5);b.detail=text(b,13,'');r.recipeRows[i]=b end
  b.record=record;b.farm=b.farm or N.MakeButton(b,'Farm',68,function()local q=b.record;E.FlagRecipe(q,not E.farmFlags[q.spellID or q.learnableItemID]);N.RefreshRecipes()end);b.farm:Hide();if b.learnable then b.learnable:Hide()end
  local loc=record.locations and record.locations[1];local key=record.workflowKey or record.id;local active=W.activeSource==key
  point(b,r.recipeContent,0,y,width,60);point(b.label,b,36,5,width-40);b.label:SetHeight(0);b.label:SetWordWrap(true);b.label:SetText(record.name);local detailY=math.max(22,b.label:GetStringHeight())+10
  point(b.detail,b,36,detailY,width-40);b.detail:SetText(loc and ((loc.name or'')..' · '..(loc.zone or''))or(record.rank or record.profession or'Trainer'));b.detail:Show();local h=math.max(62,b.detail:GetStringHeight()+detailY+7)
  if record.kind=='trainer'then b.icon:SetTexture(W.TrainerIcon(record))else b.icon:SetTexture((C_Item and C_Item.GetItemIconByID or GetItemIcon)(record.productID or record.itemID or record.learnableItemID or record.itemId or 0)or'Interface\\Icons\\INV_Misc_Book_09')end
  if active then
   local extra=''
   if record.kind=='trainer'then for _,v in ipairs(record.recipes or{})do extra=extra..'\n'..v.name..' · '..(v.requirement or'')end;if extra==''then extra='\nVisit trainer to record available recipes.'end
   else extra='\n'..(record.profession or'')..' · '..(record.requirement or'')
    if loc and loc.source=='Vendor'then extra=extra..'\n'..(loc.costText or(loc.costCopper and GetMoneyString and GetMoneyString(loc.costCopper))or'Price not verified')end
    if record.learnableItemID or record.itemId then local id=record.learnableItemID or record.itemId;extra=extra..'\n'..(GetItemInfo(id)or('Recipe item # '..tostring(id)))end
   end
   b.detail:SetText(b.detail:GetText()..extra);h=math.max(h,b.detail:GetStringHeight()+detailY+10)
   if loc and(loc.source=='Drop'or loc.source=='Treasure')then point(b.farm,b,36,h,68,30);b.farm:Show();h=h+36 end
  end
  b:SetHeight(h);b.menuHighlight:SetShown(active)
  b:SetScript('OnClick',function(self)W.selection='source';W.activeSource=key;if record.kind=='trainer'then W.activeTrainer=W.activeTrainer~=record.id and record.id or nil end;W.expandedRecipe=key;N.selectedRecipe=record;W.SelectMap(loc);N.selectedRecipe=record;N.RefreshRecipes();W.Layout()end)
  b:SetScript('OnEnter',function(self)self.menuHighlight:Show();W.Tooltip(self,record.learnableItemID or record.itemId or record.itemID or record.productID,record.name)end)
  b:SetScript('OnLeave',function(self)self.menuHighlight:SetShown(W.activeSource==key);hideTip()end)
  b:Show();y=y+h+5
  elseif r.recipeRows[i]then r.recipeRows[i]:Hide()end
 end
 for i=#records+1,#r.recipeRows do r.recipeRows[i]:Hide()end;for i=headers+1,#r.workflowHeaders do r.workflowHeaders[i]:Hide()end
 r.recipesText:SetText(query and'Search results · All zones'or'Recipes & trainers');r.recipeContent:SetHeight(math.max(y,1));r.recipeScroll:SetVerticalScroll(math.min(r.recipeScroll:GetVerticalScroll(),math.max(0,y-r.recipeScroll:GetHeight())))
 if #records==0 then header(query and'No matching acquisition sources'or'No matching recipes in this zone')end
 W.ScrollState();N.UpdateMapView()
end
local chooseSearch=N.ChooseSearchResult
function N.ChooseSearchResult(index)
 local result=(N.searchMatches or{})[index];if not result then return false end
 -- Keep all matching acquisition records; the player chooses a source next.
 W.activeSource=nil;N.selectedRecipe=nil;W.mapLocation=nil;N.root.recipeSearch:SetText(result.name);N.root.recipeSearch:ClearFocus();N.root.searchPopup:Hide();N.RefreshRecipes();N.root.recipeScroll:SetVerticalScroll(0);return true
end
local updateMap=N.UpdateMapView
function N.UpdateMapView(...)
 local old=N.selectedRecipe
 if W.mapLocation then N.selectedRecipe={zone=W.ZoneFor(W.mapLocation),locations={W.mapLocation}}end
 local result=updateMap(...);N.selectedRecipe=old;return result
end
local setZone=N.SetZone
function N.SetZone(...)
 if not W.settingZone then W.mapLocation=nil;W.activeSource=nil end
 local result=setZone(...);if N.root then W.Layout()end;return result
end
local refresh=N.Refresh
function N.Refresh(...)
 local result=refresh(...);if N.root then
  W.Layout();local n=N.model:Current();local id=n and n.id
  if id~=W.currentStep then W.currentStep=id;if W.selection~='source'and n and(not U or U.pane~='Dungeons')then W.SelectMap(n.destination or(P.Destination and P.Destination()))end end
 end;return result
end
local setMode=N.SetMode
function N.SetMode(...)local v=setMode(...);if N.root then W.Layout();N.Refresh(true)end;return v end
local move=N.Move
N.Move=function(...)W.selection='step';W.activeSource=nil;return move(...)end
if U then local layout=U.Layout;U.Layout=function(...)local value=layout(...);W.Layout();return value end end
local tick=N.Tick
function N.Tick(...)
 local value=tick(...);local d=N.gpsDestination
 local caption=''
 if d and N.angle and not N.gpsSuppressed and not N.areaNavigation and N.arrowFrame and N.arrowFrame:IsShown()then
  local place,note=W.GPSPlace(d);local label=d.name or'Destination'
  if place and place~=label then label=label..'\n'..place end
  if note then label=label..'\n'..note end
  caption=label..'\n'..string.format('%.0f yd',N.yards or 0)
 end
 if N.arrowCaption and N.gpsCaptionText~=caption then N.gpsCaptionText=caption;N.arrowCaption:SetText(caption)end
 return value
end
end)(...)
-- GF_WORKFLOW56_END
-- GF_VIEWPORT57_BEGIN: fit actual map artwork and usable scrollbar controls.
;(function(...)
local _,ns=...;local N,W=ns.NormalUI,ns.WindowWorkflow
local function bounds(pair)
 local upper,lower=pair[1],pair[2]
 return math.max(1,(upper:GetBottom()or 0)-(lower:GetTop()or 0))
end
function W.ScrollRail(pair,value,maximum,visible,changed)
 if not pair.rail then
  local rail=CreateFrame('Slider',nil,pair[1]:GetParent());pair.rail=rail
  rail:SetOrientation('VERTICAL');rail:SetValueStep(1);rail:SetMinMaxValues(0,1)
  rail.track=rail:CreateTexture(nil,'BACKGROUND')
  rail.track:SetPoint('TOP',rail,'TOP',0,0);rail.track:SetPoint('BOTTOM',rail,'BOTTOM',0,0)
  rail.track:SetWidth(3.5);rail.track:SetColorTexture(.34,.19,.07,1)
  rail:SetThumbTexture('Interface\\AddOns\\GrindingForever\\Media\\RidgedFacetedHex')
  rail:GetThumbTexture():SetSize(15,15)
  rail:EnableMouse(true)
  rail:SetScript('OnValueChanged',function(self,v)if not self.syncing and self.changed then self.changed(v)end end)
 end
 local rail=pair.rail;rail:SetParent(pair[1]:GetParent());rail:ClearAllPoints();rail:SetPoint('TOP',pair[1],'BOTTOM',0,-3);rail:SetPoint('BOTTOM',pair[2],'TOP',0,3);rail:SetWidth(17);rail.changed=changed
 rail.syncing=true;rail:SetMinMaxValues(0,math.max(1,maximum));rail:SetValue(math.min(maximum,math.max(0,value)));rail.syncing=false
 rail:SetShown(visible and bounds(pair)>16);rail:SetFrameLevel(pair[1]:GetFrameLevel()+1)
end
function N.PanelScroll(parent, viewport, get, set, maximum, step)
 local pair
 local function sync()
  local cap=math.max(0,maximum())
  W.ScrollRail(pair,get() or 0,cap,cap>0,function(value)
   if value~=(get() or 0)then set(value)end
   sync()
  end)
  for i,button in ipairs(pair)do
   button:SetShown(cap>0)
   button:SetAlpha((i==1 and (get() or 0)<=0 or i==2 and (get() or 0)>=cap)and .4 or 1)
  end
 end
 local function scroll(delta)
  local value=math.max(0,math.min(maximum(),(get()or 0)+delta))
  if value~=(get()or 0)then set(value)end
  sync()
 end
 pair=W.MakeScrollPair(parent,function()scroll(-step)end,function()scroll(step)end)
 for i,button in ipairs(pair)do
  local edge=i==1 and 'TOP' or 'BOTTOM'
  button:ClearAllPoints();button:SetSize(21,24);button:SetPoint(edge,viewport,edge..'RIGHT',12,i==1 and -3 or 3)
  button:SetFrameLevel(viewport:GetFrameLevel()+5)
 end
 viewport:EnableMouseWheel(true)
 viewport:SetScript('OnMouseWheel',function(_,delta)scroll(-delta*step)end)
 return sync
end
local scrollState=W.ScrollState
function W.ScrollState()
 scrollState();local r=N.root;if not W.ready then return end
 local f=r.recipeScroll;local maximum=math.max(0,r.recipeContent:GetHeight()-f:GetHeight())
 W.ScrollRail(r.workflowRecipeIndicators,f:GetVerticalScroll(),maximum,maximum>2 and N.mode~='compact',function(v)f:SetVerticalScroll(v);W.ScrollState()end)
 local count=#(N.visible or{});local shown=N.displayedRowCount or 0;local maxStart=math.max(0,count-math.max(1,shown))
 W.ScrollRail(r.workflowStepIndicators,(N.rowStart or 1)-1,maxStart,r.workflowStepIndicators[1]:IsShown(),function(v)N.rowStart=math.floor(v+.5)+1;N.LayoutStepRows(N.visible or{},N.rowStart);W.ScrollState()end)
 local _,body,_,content=N.WorkflowBody();local bm=math.max(0,content:GetHeight()-body:GetHeight())
 W.ScrollRail(r.workflowBodyIndicators,body:GetVerticalScroll(),bm,r.workflowBodyIndicators[1]:IsShown(),function(v)body:SetVerticalScroll(v);W.ScrollState()end)
end
function W.FitMap()
 local r=N.root;local map=r.recipeMap;local v=r.mapViewport
 v:ClearAllPoints();v:SetPoint('TOPLEFT',map,'TOPLEFT',8,-8);v:SetPoint('BOTTOMRIGHT',map,'BOTTOMRIGHT',-8,8);v:SetClipsChildren(true)
 ns.VisualPhaseB.Components.LayoutBorder(map,14)
 N.UpdateMapView()
end
-- Full-map textures are cropped in UV space as well as clipped. This keeps the
-- same geography/pin transform without drawing beyond the viewport.
local query=N.SetSearchQuery
function N.SetSearchQuery(value)
 local clear=not tostring(value or''):match('%S')
 if clear then W.mapLocation=nil;W.activeSource=nil;W.activeTrainer=nil;W.expandedRecipe=nil;N.selectedRecipe=nil;N.unlocatedRecipe=nil;if N.root then N.root.recipeScroll:SetVerticalScroll(0)end end
 local result=query(value)
 if clear and N.root then N.RefreshRecipes();N.RefreshRecipeMap();W.Layout()end
 return result
end
local rows=N.LayoutStepRows
function N.LayoutStepRows(...)local result=rows(...);if W.ready then W.ScrollState()end;return result end
local ensure=W.Ensure
function W.Ensure()
 if ns.db and not ns.db.compactTracker57 then
  ns.db.compactTracker57=true
  local saved=ns.db.normalModeSizes and ns.db.normalModeSizes.compact
  local seen={};for _,v in pairs({saved=saved,modes=N.modeDimensions and N.modeDimensions.compact,current=N.mode=='compact'and N.dimensions or nil})do if type(v)=='table'and not seen[v]then seen[v]=true;v[1]=v[1]*.8 end end
 end
 return ensure()
end
end)(...)
-- GF_VIEWPORT57_END

;(function(...)
local _,ns=...;local N,W,E,U=ns.NormalUI,ns.WindowWorkflow,ns.Forever,ns.ForeverUI
function W.CatalogRows(query)
 local rows=E.KnownRecipeRows(query and nil or N.selectedZone,query)
 for _,r in ipairs(rows)do if r.kind=='trainer'and not r.locations then r.locations={r.location}end end
 return rows
end
function W.StepFarmable(s)return s and(s.kind=='farm'or s.kind=='profession'and(s.profession=='Skinning'or s.profession=='Mining'or s.profession=='Herbalism'or s.profession=='Fishing'))end
function W.StartStepFarm()return E.FarmSelected()end
-- A rectangular viewport crops geography rather than stretching it.
local function aspect()
 local d=E.dungeons[N.selectedZone];local f=d and d.map and d.map.floors[U.floor]
 if f then return f.aspect or 1002/668 end
 return 1002/668
end
function N.MapScales()
 local v=N.root and N.root.mapViewport;local ratio=v and v:GetWidth()/math.max(1,v:GetHeight())or aspect()
 return (N.mapZoom or 1)*math.max(1,aspect()/ratio),(N.mapZoom or 1)*math.max(1,ratio/aspect())
end
function N.MapToViewport(x,y)local sx,sy=N.MapScales();return .5+(x-N.mapCenterX)*sx,.5+(y-N.mapCenterY)*sy end
function N.PanMap(dx,dy)local sx,sy=N.MapScales();N.mapCenterX=N.mapCenterX-dx/sx;N.mapCenterY=N.mapCenterY-dy/sy;N.UpdateMapView()end
function N.ZoomMap(value,u,v)
 value=tonumber(value);if not value then return false end;value=math.max(1,math.min(8,value));u=u or .5;v=v or .5
 local sx,sy=N.MapScales();local x=N.mapCenterX+(u-.5)/sx;local y=N.mapCenterY+(v-.5)/sy
 N.mapZoom=value;sx,sy=N.MapScales();N.mapCenterX=x-(u-.5)/sx;N.mapCenterY=y-(v-.5)/sy;N.UpdateMapView();return true
end
local render=ns.RenderForeverMap
function ns.RenderForeverMap(a,r)
 local sx,sy=N.MapScales();local hx,hy=.5/sx,.5/sy
 N.mapCenterX=math.max(hx,math.min(1-hx,N.mapCenterX));N.mapCenterY=math.max(hy,math.min(1-hy,N.mapCenterY))
 return render(a,r)
end
local layout=W.Layout
function W.Layout(...)
 local result=layout(...);local r=N.root;if not r then return result end
 r.listNote:Hide();if r.leftButtons then r.leftButtons[1]:Hide()end
 if r.paceSwitch then r.paceSwitch:SetShown(N.mode~='compact'and E.db.journey~='Completionist'or N.mode=='compact'and not W.shortCompact and E.db.journey~='Completionist')end
 if N.farmButton then N.farmButton:Show();N.farmButton:SetShown(N.mode~='compact')end
 return result
end
N.WorkflowLayout=W.Layout
local ensure=W.Ensure
function W.Ensure()
 ensure();local r=N.root;if not r or W.foreverReady then return end
 if not N.farmButton then N.farmButton=N.MakeButton(r.panels[2],'Plan Farming Route',200,function()local ok,why=E.FarmSelected();if not ok then ns.Print(why or'Select a recipe with missing materials or a gathering step.')end end)end
 if N.draftButton then N.draftButton:SetHeight(32)end
 if N.settingsFrame then N.settingsFrame:SetFrameStrata('TOOLTIP');N.settingsFrame:SetFrameLevel(N.frame:GetFrameLevel()+80)end
 W.foreverReady=true
end
local tick=N.Tick

-- Shift-click links target the focused recipe search, without stealing chat links.
if type(hooksecurefunc)=='function'then hooksecurefunc('ChatEdit_InsertLink',function(link)
 local box=N.root and N.root.recipeSearch;if not box or not box:HasFocus()then return end
 local name=type(link)=='string'and(link:match('%[(.-)%]')or GetItemInfo(link));if name then box:SetText(name);N.SetSearchQuery(name)end
end)end
end)(...)

-- GF_SERVICE_CAMPS4_BEGIN
;(function(...)
local _,ns=...;local E=ns.Forever;local call=E.Call
function E.CraftingStop(profession,state)
 if not state or not state.position or call(UnitAffectingCombat,'player')or call(UnitIsDeadOrGhost,'player')or call(UnitOnTaxi,'player')then return end
 local tools=profession=='Blacksmithing'or profession=='Engineering'
 local function eligible(p,radius)
  if not p or p.faction and p.faction~=state.faction and p.faction~='Neutral'then return false end
  local d=E.Distance(state.position,p);return type(d)=='number'and d<=radius
 end
 -- Never infer forge/anvil availability from an unrelated camp decoration.
 if tools then
  for _,p in pairs(E.trainers or{})do if p.profession==profession and p.toolsObserved and eligible(p,40)then return 'service' end end
  for _,p in ipairs(E.camps or{})do if p.expires and p.expires>E.Time()and p.toolsObserved and eligible(p,40)then return 'camp' end end
  return
 end
 for _,p in pairs(E.vendors or{})do if eligible(p,180)then return 'service' end end
 for _,p in pairs(E.trainers or{})do if(not p.profession or p.profession==profession)and eligible(p,180)then return 'service' end end
 -- Current welcoming-campfire influence is stronger evidence than a map icon.
 if state.auras and state.auras[1229739]then return 'camp' end
 for _,p in ipairs(E.camps or{})do
  if p.expires and p.expires>E.Time()and p.evidence=='player-inside-welcoming-campfire-aura'and eligible(p,40)then return 'camp' end
 end
end
local crafting=E.CraftingCatchup
function E.CraftingCatchup(state,route)
 local out={}
 for _,row in ipairs(crafting(state,route)or{})do
  local stop=E.CraftingStop(row.profession,state)
  if stop then row.craftingStop=stop;row.body=(row.body or'')..'\n\nCrafting stop: '..(stop=='camp'and'active observed campsite' or'nearby services')..'. Check required supplies and equipment before crafting.';out[#out+1]=row end
 end
 return out
end
end)(ADDON,GF)
-- GF_SERVICE_CAMPS4_END

local _,ns=ADDON,GF;ns.ClassicGatheringMeta={
[401]={kind="Herbalism",skill=1,item=2447,name="Peacebloom"},
[405]={kind="Herbalism",skill=70,item=2450,name="Briarthorn"},
[409]={kind="Herbalism",skill=125,item=3355,name="Wild Steelbloom"},
[413]={kind="Herbalism",skill=160,item=3818,name="Fadeleaf"},
[417]={kind="Herbalism",skill=205,item=4625,name="Firebloom"},
[421]={kind="Herbalism",skill=230,item=8838,name="Sungrass"},
[425]={kind="Herbalism",skill=260,item=13464,name="Golden Sansam"},
[429]={kind="Herbalism",skill=290,item=13467,name="Icecap"},
[402]={kind="Herbalism",skill=1,item=765,name="Silverleaf"},
[204]={kind="Mining",skill=75,item=2775,name="Silver Vein"},
[206]={kind="Mining",skill=175,item=3858,name="Mithril Deposit"},
[414]={kind="Herbalism",skill=170,item=3821,name="Goldthorn"},
[418]={kind="Herbalism",skill=210,item=8831,name="Purple Lotus"},
[422]={kind="Herbalism",skill=235,item=8839,name="Blindweed"},
[426]={kind="Herbalism",skill=270,item=13463,name="Dreamfoil"},
[403]={kind="Herbalism",skill=15,item=2449,name="Earthroot"},
[407]={kind="Herbalism",skill=85,item=3820,name="Stranglekelp"},
[411]={kind="Herbalism",skill=125,item=3356,name="Kingsblood"},
[415]={kind="Herbalism",skill=185,item=3358,name="Khadgar's Whisker"},
[423]={kind="Herbalism",skill=245,item=8845,name="Ghost Mushroom"},
[427]={kind="Herbalism",skill=280,item=13465,name="Mountain Silversage"},
[431]={kind="Herbalism",skill=300,item=13468,name="Black Lotus"},
[205]={kind="Mining",skill=155,item=2776,name="Gold Vein"},
[412]={kind="Herbalism",skill=150,item=3357,name="Liferoot"},
[210]={kind="Mining",skill=155,item=2776,name="Ooze Covered Gold Vein"},
[211]={kind="Mining",skill=230,item=7911,name="Ooze Covered Truesilver Deposit"},
[110]={kind="Fishing",skill=205,item=13422,name="Stonescale Eel Swarm"},
[212]={kind="Mining",skill=275,item=10620,name="Ooze Covered Rich Thorium Vein"},
[213]={kind="Mining",skill=245,item=10620,name="Ooze Covered Thorium Vein"},
[214]={kind="Mining",skill=245,item=10620,name="Small Thorium Vein"},
[215]={kind="Mining",skill=275,item=10620,name="Rich Thorium Vein"},
[428]={kind="Herbalism",skill=285,item=13466,name="Plaguebloom"},
[105]={kind="Fishing",skill=100,item=6359,name="Firefin Snapper School"},
[107]={kind="Fishing",skill=1,item=6358,name="Oily Blackmouth School"},
[203]={kind="Mining",skill=125,item=2772,name="Iron Deposit"},
[201]={kind="Mining",skill=1,item=2770,name="Copper Vein"},
[404]={kind="Herbalism",skill=50,item=785,name="Mageroyal"},
[408]={kind="Herbalism",skill=100,item=2453,name="Bruiseweed"},
[207]={kind="Mining",skill=175,item=3858,name="Ooze Covered Mithril Deposit"},
[209]={kind="Mining",skill=75,item=2775,name="Ooze Covered Silver Vein"},
[106]={kind="Fishing",skill=175,item=21153,name="Greater Sagefish School"},
[424]={kind="Herbalism",skill=250,item=8846,name="Gromsblood"},
[108]={kind="Fishing",skill=75,item=21071,name="Sagefish School"},
[109]={kind="Fishing",skill=1,item=6522,name="School of Deviate Fish"},
[112]={kind="Fishing",skill=330,item=27437,name="Highland Mixed School"},
[416]={kind="Herbalism",skill=195,item=3819,name="Wintersbite"},
[114]={kind="Fishing",skill=280,item=27439,name="Bluefish School"},
[115]={kind="Fishing",skill=305,item=27435,name="Brackish Mixed School"},
[116]={kind="Fishing",skill=305,item=27438,name="Mudfish School"},
[117]={kind="Fishing",skill=305,item=27437,name="School of Darter"},
[118]={kind="Fishing",skill=305,item=27422,name="Sporefish School"},
[202]={kind="Mining",skill=65,item=2771,name="Tin Vein"},
[120]={kind="Fishing",skill=1,item=19807,name="School of Tastyfish"},
[208]={kind="Mining",skill=230,item=7911,name="Truesilver Deposit"},
}

local _,ns=ADDON,GF;ns.FarmingRouteReferences={{["kind"]="Herbalism",["zone"]="Durotar",["minSkill"]=1,["maxSkill"]=70,["minLevel"]=5,["points"]={{45.0,15.0},{42.0,23.0},{37.0,25.0},{37.0,37.0},{44.0,39.0},{37.0,52.0},{46.0,46.0},{51.0,54.0},{50.0,66.0},{53.0,81.0},{57.0,70.0},{57.0,55.0},{61.0,57.0},{59.0,47.0},{55.0,40.0},{55.0,29.0},{57.0,22.0},{54.0,12.0}},["mode"]="loop",["faction"]="Horde",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="Mulgore",["minSkill"]=1,["maxSkill"]=70,["minLevel"]=5,["points"]={{34.0,35.0},{30.0,28.0},{37.0,18.0},{48.0,14.0},{58.0,16.0},{62.0,25.0},{60.0,33.0},{48.0,34.0},{46.0,47.0},{38.0,57.0},{36.0,71.0},{33.0,73.0},{32.0,56.0}},["mode"]="loop",["faction"]="Horde",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="Tirisfal Glades",["minSkill"]=1,["maxSkill"]=70,["minLevel"]=5,["points"]={{38.0,48.0},{33.0,43.0},{41.0,41.0},{44.0,33.0},{50.0,33.0},{54.0,29.0},{52.0,23.0},{48.0,23.0},{46.0,31.0},{44.0,39.0},{47.0,45.0},{49.0,49.0},{53.0,46.0},{58.0,45.0},{62.0,38.0},{59.0,33.0},{60.0,27.0},{65.0,30.0},{66.0,41.0},{62.0,48.0},{55.0,53.0},{51.0,65.0},{45.0,65.0},{42.0,57.0}},["mode"]="loop",["faction"]="Horde",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="Elwynn Forest",["minSkill"]=1,["maxSkill"]=70,["minLevel"]=5,["points"]={{25.0,65.0},{31.0,58.0},{37.0,59.0},{40.0,54.0},{46.0,53.0},{51.0,59.0},{62.0,56.0},{62.0,68.0},{71.0,62.0},{79.0,67.0},{85.0,57.0},{87.0,66.0},{87.0,81.0},{77.0,74.0},{69.0,81.0},{56.0,76.0},{48.0,80.0},{37.0,80.0},{27.0,85.0},{24.0,76.0}},["mode"]="loop",["faction"]="Alliance",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="Teldrassil",["minSkill"]=1,["maxSkill"]=70,["minLevel"]=5,["points"]={{39.0,64.0},{40.0,54.0},{44.0,54.0},{49.0,58.0},{48.0,64.0},{54.0,64.0},{60.0,61.0},{66.0,54.0},{67.0,57.0},{64.0,66.0},{60.0,73.0},{51.0,76.0},{43.0,76.0},{46.0,70.0}},["mode"]="loop",["faction"]="Alliance",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="Dun Morogh",["minSkill"]=1,["maxSkill"]=70,["minLevel"]=5,["points"]={{28.0,40.0},{32.0,35.0},{40.0,34.0},{47.0,37.0},{48.0,45.0},{49.0,50.0},{46.0,59.0},{40.0,58.0},{35.0,61.0},{29.0,55.0},{26.0,47.0}},["mode"]="loop",["faction"]="Alliance",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="The Barrens",["minSkill"]=70,["maxSkill"]=115,["minLevel"]=14,["points"]={{40.0,14.0},{48.0,10.0},{61.0,8.0},{61.0,18.0},{57.0,30.0},{61.0,38.0},{57.0,46.0},{49.0,46.0},{49.0,56.0},{47.0,67.0},{51.0,76.0},{46.0,85.0},{40.0,83.0},{44.0,76.0},{45.0,63.0},{43.0,49.0},{41.0,40.0},{43.0,32.0},{40.0,26.0},{48.0,25.0},{48.0,20.0},{39.0,20.0}},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="Silverpine Forest",["minSkill"]=70,["maxSkill"]=115,["minLevel"]=14,["points"]={{65.0,9.0},{54.0,15.0},{52.0,23.0},{45.0,28.0},{51.0,34.0},{49.0,46.0},{49.0,58.0},{57.0,62.0},{60.0,71.0},{56.0,78.0},{49.0,79.0},{47.0,69.0},{42.0,74.0},{39.0,74.0},{42.0,64.0},{47.0,57.0},{47.0,40.0},{49.0,29.0},{57.0,18.0}},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="Loch Modan",["minSkill"]=70,["maxSkill"]=115,["minLevel"]=14,["points"]={{46.0,20.0},{55.0,20.0},{58.0,27.0},{64.0,35.0},{69.0,43.0},{67.0,49.0},{69.0,59.0},{73.0,57.0},{77.0,46.0},{74.0,35.0},{66.0,32.0},{63.0,20.0},{58.0,19.0},{56.0,31.0},{57.0,39.0},{51.0,39.0},{50.0,30.0},{47.0,28.0}},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="Darkshore",["minSkill"]=70,["maxSkill"]=115,["minLevel"]=14,["points"]={{38.0,84.0},{41.0,73.0},{42.0,60.0},{44.0,52.0},{47.0,48.0},{46.0,37.0},{49.0,32.0},{52.0,25.0},{57.0,21.0},{59.0,13.0},{57.0,20.0},{53.0,26.0},{50.0,29.0},{46.0,30.0},{45.0,41.0},{41.0,50.0},{41.0,65.0},{38.0,75.0}},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="Hillsbrad Foothills",["minSkill"]=115,["maxSkill"]=170,["minLevel"]=24,["points"]={{21.0,51.0},{28.0,45.0},{32.0,51.0},{36.0,46.0},{42.0,48.0},{49.0,45.0},{51.0,36.0},{55.0,31.0},{62.0,34.0},{66.0,44.0},{78.0,45.0},{73.0,53.0},{65.0,52.0},{62.0,64.0},{68.0,73.0},{67.0,83.0},{61.0,72.0},{56.0,59.0},{49.0,56.0},{42.0,53.0},{40.0,62.0},{34.0,66.0},{32.0,57.0},{27.0,59.0}},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="Wetlands",["minSkill"]=115,["maxSkill"]=170,["minLevel"]=24,["points"]={{12.0,57.0},{14.0,37.0},{20.0,24.0},{30.0,21.0},{41.0,25.0},{56.0,31.0},{62.0,36.0},{71.0,34.0},{78.0,41.0},{78.0,52.0},{65.0,56.0},{60.0,72.0},{53.0,67.0},{47.0,58.0},{42.0,44.0},{34.0,37.0},{30.0,45.0},{36.0,50.0},{31.0,55.0},{22.0,52.0},{17.0,61.0}},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="Stonetalon Mountains",["minSkill"]=115,["maxSkill"]=170,["minLevel"]=24,["points"]={{45.0,12.0},{39.0,17.0},{35.0,20.0},{32.0,16.0},{34.0,10.0},{44.0,7.0},{46.0,13.0},{43.0,31.0},{47.0,40.0},{45.0,47.0},{38.0,49.0},{34.0,61.0},{30.0,67.0},{27.0,63.0},{29.0,53.0},{39.0,45.0},{39.0,34.0},{48.0,42.0},{58.0,45.0},{65.0,40.0},{67.0,48.0},{61.0,52.0},{58.0,58.0},{65.0,68.0},{75.0,69.0},{73.0,75.0},{62.0,73.0},{53.0,66.0},{49.0,56.0},{53.0,50.0}},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="Stranglethorn Vale",["minSkill"]=170,["maxSkill"]=205,["minLevel"]=32,["points"]={{28.0,8.0},{34.0,8.0},{38.0,16.0},{45.0,14.0},{48.0,7.0},{50.0,12.0},{48.0,25.0},{43.0,31.0},{39.0,37.0},{34.0,33.0},{28.0,36.0},{30.0,27.0},{33.0,22.0},{28.0,15.0}},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="Arathi Highlands",["minSkill"]=170,["maxSkill"]=205,["minLevel"]=32,["points"]={{24.0,23.0},{28.0,29.0},{39.0,34.0},{47.0,38.0},{59.0,34.0},{64.0,42.0},{73.0,35.0},{78.0,37.0},{78.0,45.0},{69.0,49.0},{70.0,64.0},{65.0,70.0},{61.0,65.0},{56.0,65.0},{52.0,76.0},{47.0,64.0},{42.0,65.0},{37.0,72.0},{38.0,59.0},{29.0,58.0},{29.0,47.0},{22.0,42.0}},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="Tanaris",["minSkill"]=205,["maxSkill"]=230,["minLevel"]=42,["points"]={{42.0,28.0},{45.0,22.0},{50.0,25.0},{54.0,29.0},{62.0,27.0},{63.0,37.0},{67.0,41.0},{65.0,49.0},{59.0,51.0},{62.0,56.0},{58.0,60.0},{50.0,63.0},{43.0,70.0},{34.0,73.0},{32.0,62.0},{33.0,53.0},{42.0,48.0},{46.0,44.0},{43.0,42.0},{40.0,42.0},{39.0,37.0},{40.0,34.0}},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="Searing Gorge",["minSkill"]=205,["maxSkill"]=230,["minLevel"]=43,["points"]={{34.0,44.0},{39.0,33.0},{39.0,27.0},{34.0,27.0},{25.0,33.0},{24.0,45.0},{30.0,53.0},{32.0,66.0},{24.0,72.0},{23.0,78.0},{31.0,80.0},{38.0,76.0},{45.0,63.0},{54.0,65.0},{64.0,61.0},{69.0,48.0},{73.0,39.0},{71.0,27.0},{75.0,19.0},{73.0,17.0},{66.0,36.0},{63.0,37.0},{58.0,52.0},{52.0,46.0},{56.0,35.0},{54.0,32.0},{50.0,42.0},{44.0,43.0},{42.0,47.0}},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="The Hinterlands",["minSkill"]=230,["maxSkill"]=270,["minLevel"]=47,["points"]={{17.0,49.0},{28.0,45.0},{34.0,49.0},{42.0,44.0},{48.0,39.0},{57.0,42.0},{64.0,48.0},{74.0,48.0},{80.0,54.0},{73.0,61.0},{66.0,65.0},{56.0,63.0},{50.0,65.0},{45.0,60.0},{36.0,61.0},{31.0,65.0},{24.0,61.0},{26.0,56.0},{19.0,55.0}},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Herbalism",["zone"]="Felwood",["minSkill"]=270,["maxSkill"]=300,["minLevel"]=50,["points"]={{49.0,17.0},{48.0,10.0},{53.0,12.0},{56.0,8.0},{60.0,9.0},{61.0,18.0},{63.0,22.0},{60.0,26.0},{57.0,28.0},{55.0,37.0},{53.0,44.0},{54.0,50.0},{50.0,54.0},{51.0,55.0},{51.0,62.0},{49.0,69.0},{46.0,78.0},{47.0,83.0},{46.0,89.0},{39.0,88.0},{41.0,81.0},{44.0,79.0},{46.0,73.0},{48.0,64.0},{47.0,55.0},{44.0,52.0},{42.0,45.0},{40.0,41.0},{43.0,38.0},{41.0,33.0},{43.0,27.0}},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Durotar",["minSkill"]=1,["maxSkill"]=65,["minLevel"]=5,["points"]={{43.0,15.0},{43.0,22.0},{39.0,25.0},{45.0,30.0},{40.0,31.0},{41.0,36.0},{47.0,36.0},{50.0,32.0},{46.0,29.0},{51.0,22.0},{54.0,17.0},{57.0,23.0},{55.0,31.0},{58.0,43.0},{60.0,51.0},{54.0,53.0},{53.0,46.0},{48.0,42.0},{44.0,46.0},{41.0,44.0},{41.0,54.0},{48.0,50.0},{52.0,55.0},{56.0,62.0},{60.0,62.0},{58.0,52.0}},["materials"]={"Copper Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Mulgore",["minSkill"]=1,["maxSkill"]=65,["minLevel"]=5,["points"]={{33.0,62.0},{32.0,45.0},{33.0,29.0},{39.0,15.0},{47.0,12.0},{54.0,13.0},{60.0,24.0},{62.0,32.0},{59.0,40.0},{61.0,49.0},{65.0,60.0},{63.0,69.0},{50.0,73.0},{38.0,82.0},{32.0,77.0}},["materials"]={"Copper Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Tirisfal Glades",["minSkill"]=1,["maxSkill"]=65,["minLevel"]=5,["points"]={{48.0,65.0},{45.0,72.0},{36.0,75.0},{35.0,59.0},{29.0,52.0},{32.0,47.0},{38.0,48.0},{39.0,38.0},{47.0,38.0},{47.0,31.0},{58.0,30.0},{59.0,34.0},{54.0,37.0},{51.0,46.0},{55.0,51.0},{52.0,58.0}},["materials"]={"Copper Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Elwynn Forest",["minSkill"]=1,["maxSkill"]=65,["minLevel"]=5,["points"]={{27.0,65.0},{33.0,57.0},{39.0,52.0},{44.0,57.0},{46.0,60.0},{51.0,61.0},{55.0,54.0},{61.0,50.0},{61.0,56.0},{67.0,62.0},{68.0,71.0},{61.0,72.0},{54.0,77.0},{46.0,82.0},{48.0,65.0},{36.0,71.0},{39.0,75.0},{35.0,72.0},{31.0,79.0},{25.0,81.0},{25.0,73.0},{28.0,68.0}},["materials"]={"Copper Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Darkshore",["minSkill"]=1,["maxSkill"]=65,["minLevel"]=12,["points"]={{36.0,44.0},{39.0,40.0},{39.0,27.0},{44.0,25.0},{47.0,24.0},{50.0,18.0},{55.0,16.0},{58.0,9.0},{58.0,23.0},{54.0,27.0},{52.0,30.0},{50.0,31.0},{51.0,34.0},{49.0,36.0},{44.0,39.0},{42.0,43.0},{42.0,49.0},{39.0,50.0},{38.0,47.0}},["materials"]={"Copper Ore","Tin Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Dun Morogh",["minSkill"]=1,["maxSkill"]=65,["minLevel"]=5,["points"]={{25.0,43.0},{28.0,38.0},{31.0,40.0},{34.0,35.0},{38.0,34.0},{35.0,44.0},{37.0,48.0},{32.0,55.0},{30.0,53.0},{30.0,47.0},{26.0,50.0},{24.0,57.0}},["materials"]={"Copper Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Dun Morogh",["minSkill"]=1,["maxSkill"]=65,["minLevel"]=7,["points"]={{48.0,53.0},{53.0,49.0},{59.0,49.0},{60.0,55.0},{66.0,55.0},{65.0,59.0},{61.0,60.0},{56.0,60.0},{55.0,57.0},{53.0,59.0},{51.0,57.0},{54.0,54.0},{52.0,57.0}},["materials"]={"Copper Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Hillsbrad Foothills",["minSkill"]=65,["maxSkill"]=125,["minLevel"]=22,["points"]={{25.0,53.0},{27.0,31.0},{33.0,31.0},{41.0,41.0},{47.0,36.0},{47.0,17.0},{51.0,14.0},{52.0,20.0},{57.0,18.0},{60.0,10.0},{61.0,16.0},{57.0,25.0},{62.0,27.0},{62.0,34.0},{69.0,33.0},{63.0,24.0},{60.0,21.0},{59.0,32.0},{57.0,40.0},{60.0,47.0},{62.0,55.0},{68.0,69.0},{65.0,77.0},{60.0,72.0},{56.0,61.0},{50.0,56.0},{44.0,58.0},{35.0,60.0},{28.0,61.0},{21.0,57.0}},["materials"]={"Copper Ore","Tin Ore","Silver Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Redridge Mountains",["minSkill"]=65,["maxSkill"]=125,["minLevel"]=20,["points"]={{19.0,41.0},{23.0,27.0},{27.0,25.0},{38.0,43.0},{47.0,21.0},{34.0,9.0},{47.0,10.0},{52.0,24.0},{52.0,44.0},{70.0,46.0},{78.0,39.0},{82.0,60.0},{82.0,70.0},{78.0,70.0},{82.0,82.0},{73.0,84.0},{68.0,74.0},{62.0,82.0},{47.0,81.0},{56.0,69.0},{61.0,57.0},{72.0,57.0},{65.0,49.0},{58.0,50.0}},["materials"]={"Copper Ore","Tin Ore","Silver Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Ashenvale",["minSkill"]=65,["maxSkill"]=125,["minLevel"]=22,["points"]={{28.0,14.0},{24.0,30.0},{19.0,39.0},{20.0,49.0},{25.0,36.0},{29.0,34.0},{34.0,24.0},{32.0,18.0},{34.0,27.0},{32.0,32.0},{32.0,45.0},{39.0,48.0},{47.0,52.0},{44.0,56.0},{38.0,51.0},{32.0,49.0},{28.0,55.0},{26.0,42.0},{30.0,39.0},{35.0,34.0}},["materials"]={"Copper Ore","Tin Ore","Silver Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="The Barrens",["minSkill"]=65,["maxSkill"]=125,["minLevel"]=18,["points"]={{39.0,14.0},{43.0,16.0},{46.0,13.0},{47.0,17.0},{50.0,16.0},{51.0,20.0},{54.0,19.0},{56.0,26.0},{51.0,26.0},{51.0,29.0},{45.0,27.0},{44.0,31.0},{41.0,29.0},{41.0,23.0},{40.0,21.0},{41.0,18.0},{39.0,21.0}},["materials"]={"Copper Ore","Tin Ore","Silver Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="The Barrens",["minSkill"]=65,["maxSkill"]=125,["minLevel"]=23,["points"]={{44.0,38.0},{53.0,43.0},{47.0,47.0},{46.0,54.0},{44.0,59.0},{45.0,67.0},{46.0,76.0},{49.0,82.0},{46.0,85.0},{41.0,82.0},{40.0,73.0},{42.0,67.0},{42.0,59.0},{43.0,51.0},{41.0,47.0},{43.0,44.0}},["materials"]={"Copper Ore","Tin Ore","Silver Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Arathi Highlands",["minSkill"]=125,["maxSkill"]=175,["minLevel"]=30,["points"]={{33.0,46.0},{45.0,26.0},{33.0,17.0},{23.0,20.0},{24.0,28.0},{17.0,23.0},{20.0,33.0},{15.0,30.0},{17.0,48.0},{22.0,60.0},{31.0,64.0},{40.0,82.0},{50.0,82.0},{54.0,70.0},{60.0,73.0},{61.0,65.0},{69.0,74.0},{72.0,58.0},{80.0,40.0},{65.0,36.0},{65.0,28.0},{78.0,28.0}},["materials"]={"Iron Ore","Tin Ore","Gold Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Desolace",["minSkill"]=125,["maxSkill"]=175,["minLevel"]=32,["points"]={{39.0,22.0},{42.0,16.0},{43.0,24.0},{50.0,26.0},{47.0,34.0},{47.0,40.0},{57.0,42.0},{61.0,33.0},{70.0,32.0},{72.0,40.0},{61.0,43.0},{59.0,55.0},{55.0,58.0},{60.0,65.0},{64.0,66.0},{60.0,75.0},{55.0,72.0},{52.0,82.0},{48.0,83.0},{47.0,75.0},{41.0,78.0},{39.0,72.0},{47.0,65.0},{45.0,58.0},{39.0,65.0},{37.0,61.0},{44.0,53.0},{47.0,49.0},{44.0,46.0},{39.0,52.0},{40.0,39.0},{40.0,29.0}},["materials"]={"Iron Ore","Tin Ore","Gold Ore","Mithril Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Thousand Needles",["minSkill"]=125,["maxSkill"]=175,["minLevel"]=30,["points"]={{10.0,12.0},{11.0,22.0},{16.0,30.0},{14.0,34.0},{21.0,31.0},{26.0,35.0},{28.0,42.0},{31.0,40.0},{34.0,46.0},{34.0,51.0},{40.0,49.0},{42.0,54.0},{47.0,54.0},{53.0,65.0},{58.0,62.0},{61.0,74.0},{68.0,70.0},{69.0,84.0},{75.0,92.0},{82.0,88.0},{86.0,74.0},{90.0,63.0},{85.0,53.0},{76.0,60.0},{81.0,61.0},{84.0,68.0},{77.0,68.0},{69.0,61.0},{57.0,56.0},{46.0,50.0},{41.0,42.0},{31.0,40.0},{29.0,32.0},{25.0,34.0},{21.0,26.0},{15.0,26.0},{12.0,22.0}},["materials"]={"Iron Ore","Tin Ore","Gold Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="The Hinterlands",["minSkill"]=175,["maxSkill"]=245,["minLevel"]=45,["points"]={{58.0,43.0},{48.0,55.0},{46.0,57.0},{46.0,49.0},{40.0,51.0},{36.0,46.0},{32.0,47.0},{32.0,42.0},{29.0,54.0},{22.0,56.0},{20.0,65.0},{24.0,74.0},{28.0,70.0},{33.0,74.0},{31.0,67.0},{33.0,58.0},{36.0,61.0},{40.0,69.0},{46.0,69.0},{46.0,62.0},{49.0,65.0},{52.0,65.0},{56.0,71.0},{62.0,68.0},{68.0,72.0},{69.0,66.0},{71.0,59.0},{77.0,62.0},{74.0,65.0},{69.0,65.0},{64.0,62.0},{59.0,53.0},{60.0,49.0}},["materials"]={"Mithril Ore","Truesilver Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Tanaris",["minSkill"]=175,["maxSkill"]=245,["minLevel"]=43,["points"]={{51.0,24.0},{44.0,23.0},{40.0,25.0},{40.0,29.0},{45.0,29.0},{39.0,38.0},{38.0,46.0},{35.0,51.0},{34.0,62.0},{33.0,69.0},{38.0,74.0},{41.0,71.0},{46.0,70.0},{53.0,71.0},{56.0,69.0},{54.0,61.0},{59.0,55.0},{56.0,51.0},{60.0,48.0},{61.0,43.0},{64.0,39.0},{63.0,34.0},{60.0,32.0},{57.0,33.0},{56.0,29.0}},["materials"]={"Mithril Ore","Truesilver Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Un'Goro Crater",["minSkill"]=245,["maxSkill"]=275,["minLevel"]=50,["points"]={{45.0,14.0},{38.0,21.0},{48.0,30.0},{40.0,31.0},{34.0,35.0},{35.0,39.0},{34.0,46.0},{36.0,65.0},{52.0,66.0},{50.0,72.0},{45.0,77.0},{42.0,88.0},{52.0,92.0},{52.0,88.0},{57.0,94.0},{61.0,83.0},{64.0,79.0},{61.0,69.0},{58.0,70.0},{57.0,65.0},{61.0,64.0},{73.0,66.0},{70.0,59.0},{78.0,64.0},{81.0,55.0},{79.0,42.0},{74.0,36.0},{76.0,33.0},{72.0,23.0},{64.0,20.0},{60.0,13.0},{54.0,13.0}},["materials"]={"Mithril Ore","Thorium Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Blasted Lands",["minSkill"]=245,["maxSkill"]=275,["minLevel"]=50,["points"]={{61.0,44.0},{62.0,36.0},{54.0,31.0},{49.0,29.0},{55.0,42.0},{51.0,44.0},{48.0,42.0},{47.0,46.0},{40.0,47.0},{42.0,52.0},{49.0,51.0},{54.0,56.0},{50.0,59.0},{44.0,57.0},{45.0,64.0},{58.0,71.0},{62.0,60.0},{66.0,56.0},{63.0,52.0},{58.0,49.0}},["materials"]={"Mithril Ore","Thorium Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Felwood",["minSkill"]=245,["maxSkill"]=275,["minLevel"]=50,["points"]={{64.0,22.0},{64.0,13.0},{61.0,14.0},{59.0,14.0},{57.0,16.0},{55.0,12.0},{54.0,15.0},{47.0,15.0},{45.0,23.0},{45.0,29.0},{42.0,35.0},{42.0,40.0},{43.0,44.0},{39.0,46.0},{38.0,52.0},{42.0,62.0},{46.0,66.0},{45.0,73.0},{42.0,77.0},{41.0,84.0},{46.0,88.0},{49.0,82.0},{54.0,82.0},{52.0,73.0},{49.0,65.0},{54.0,58.0},{52.0,53.0},{55.0,48.0},{55.0,42.0},{58.0,33.0},{58.0,27.0},{60.0,29.0},{58.0,21.0}},["materials"]={"Mithril Ore","Thorium Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Un'Goro Crater",["minSkill"]=275,["maxSkill"]=300,["minLevel"]=52,["points"]={{45.0,14.0},{35.0,28.0},{22.0,31.0},{19.0,44.0},{23.0,48.0},{20.0,52.0},{29.0,58.0},{26.0,65.0},{33.0,75.0},{40.0,75.0},{43.0,88.0},{51.0,92.0},{52.0,87.0},{57.0,94.0},{61.0,84.0},{64.0,79.0},{62.0,68.0},{56.0,65.0},{52.0,58.0},{51.0,49.0},{48.0,43.0},{48.0,36.0},{51.0,33.0},{55.0,38.0},{56.0,43.0},{60.0,43.0},{60.0,51.0},{62.0,61.0},{71.0,64.0},{69.0,57.0},{76.0,62.0},{81.0,54.0},{79.0,43.0},{74.0,36.0},{76.0,32.0},{72.0,23.0},{64.0,20.0},{60.0,13.0},{54.0,13.0}},["materials"]={"Thorium Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Eastern Plaguelands",["minSkill"]=275,["maxSkill"]=300,["minLevel"]=55,["points"]={{58.0,9.0},{65.0,6.0},{65.0,9.0},{59.0,13.0},{58.0,17.0},{56.0,21.0},{61.0,26.0},{63.0,34.0},{66.0,37.0},{74.0,34.0},{76.0,29.0},{81.0,30.0},{83.0,35.0},{79.0,41.0},{71.0,42.0},{69.0,37.0},{64.0,36.0},{72.0,50.0},{73.0,56.0},{70.0,58.0},{70.0,62.0},{67.0,65.0},{65.0,75.0},{60.0,76.0},{56.0,79.0},{45.0,78.0},{42.0,72.0},{37.0,68.0},{36.0,61.0},{33.0,61.0},{33.0,65.0},{27.0,65.0},{23.0,63.0},{25.0,58.0},{31.0,56.0},{33.0,51.0},{38.0,54.0},{38.0,60.0},{46.0,65.0},{47.0,72.0},{53.0,68.0},{56.0,57.0},{58.0,48.0},{52.0,40.0},{59.0,34.0},{53.0,30.0},{48.0,32.0},{45.0,30.0},{50.0,24.0},{53.0,24.0}},["materials"]={"Thorium Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Winterspring",["minSkill"]=275,["maxSkill"]=300,["minLevel"]=55,["points"]={{66.0,37.0},{63.0,31.0},{61.0,21.0},{54.0,20.0},{48.0,16.0},{46.0,24.0},{51.0,30.0},{48.0,35.0},{54.0,39.0},{53.0,46.0},{57.0,51.0},{55.0,57.0},{57.0,62.0},{62.0,62.0},{61.0,55.0},{63.0,46.0},{63.0,39.0}},["materials"]={"Thorium Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Mining",["zone"]="Burning Steppes",["minSkill"]=275,["maxSkill"]=300,["minLevel"]=53,["points"]={{73.0,64.0},{78.0,57.0},{83.0,58.0},{85.0,47.0},{84.0,38.0},{77.0,36.0},{74.0,43.0},{72.0,50.0},{70.0,42.0},{71.0,26.0},{70.0,18.0},{67.0,30.0},{65.0,40.0},{64.0,49.0},{60.0,52.0},{60.0,40.0},{62.0,22.0},{57.0,38.0},{54.0,43.0},{53.0,34.0},{48.0,43.0},{47.0,56.0},{35.0,53.0},{28.0,39.0},{23.0,38.0},{23.0,51.0},{20.0,47.0},{20.0,36.0},{16.0,38.0},{14.0,31.0},{15.0,43.0},{11.0,44.0},{16.0,61.0},{16.0,67.0},{24.0,71.0},{28.0,66.0},{36.0,63.0},{36.0,70.0},{43.0,61.0},{50.0,64.0},{52.0,58.0},{59.0,65.0},{63.0,63.0},{68.0,69.0}},["materials"]={"Thorium Ore"},["mode"]="loop",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Skinning",["zone"]="Durotar",["minSkill"]=1,["maxSkill"]=75,["minLevel"]=5,["points"]={{54.0,70.0},{51.0,60.0},{50.0,51.0},{47.0,47.0},{42.0,46.0},{45.0,39.0},{44.0,35.0},{37.0,34.0},{36.0,28.0},{39.0,20.0},{43.0,18.0},{45.0,12.0}},["mode"]="backtrack",["faction"]="Horde",["note"]="Kill, loot and skin suitable beasts along this corridor.",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Skinning",["zone"]="Dun Morogh",["minSkill"]=1,["maxSkill"]=50,["minLevel"]=5,["points"]={{34.0,39.0},{34.0,32.0},{30.0,29.0},{27.0,30.0},{24.0,32.0},{23.0,37.0},{24.0,44.0},{29.0,42.0},{36.0,41.0},{40.0,36.0},{43.0,29.0}},["mode"]="backtrack",["faction"]="Alliance",["note"]="Kill, loot and skin suitable beasts along this corridor.",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Skinning",["zone"]="Dun Morogh",["minSkill"]=50,["maxSkill"]=75,["minLevel"]=10,["points"]={{37.0,43.0},{43.0,47.0},{48.0,54.0},{56.0,54.0},{61.0,51.0},{64.0,56.0},{69.0,56.0},{70.0,51.0},{73.0,51.0}},["mode"]="backtrack",["faction"]="Alliance",["note"]="Kill, loot and skin suitable beasts along this corridor.",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Skinning",["zone"]="Loch Modan",["minSkill"]=75,["maxSkill"]=85,["minLevel"]=14,["points"]={{34.0,46.0},{40.0,45.0},{45.0,51.0},{48.0,61.0},{55.0,63.0},{62.0,57.0},{65.0,46.0}},["mode"]="backtrack",["note"]="Kill, loot and skin suitable beasts along this corridor.",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Skinning",["zone"]="Loch Modan",["minSkill"]=85,["maxSkill"]=115,["minLevel"]=18,["points"]={{65.0,46.0},{76.0,49.0},{79.0,44.0},{79.0,30.0},{75.0,27.0},{72.0,35.0},{68.0,31.0},{64.0,39.0},{61.0,34.0},{63.0,26.0},{61.0,22.0}},["mode"]="backtrack",["note"]="Kill, loot and skin suitable beasts along this corridor.",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Skinning",["zone"]="The Barrens",["minSkill"]=75,["maxSkill"]=125,["minLevel"]=15,["points"]={{50.0,33.0},{49.0,43.0},{45.0,48.0},{47.0,52.0},{44.0,57.0},{45.0,61.0}},["mode"]="backtrack",["note"]="Kill, loot and skin suitable beasts along this corridor.",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Skinning",["zone"]="The Barrens",["minSkill"]=125,["maxSkill"]=165,["minLevel"]=23,["points"]={{45.0,61.0},{45.0,69.0},{45.0,74.0},{49.0,76.0},{46.0,81.0},{47.0,85.0}},["mode"]="backtrack",["note"]="Kill, loot and skin suitable beasts along this corridor.",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Skinning",["zone"]="Thousand Needles",["minSkill"]=165,["maxSkill"]=205,["minLevel"]=30,["points"]={{11.0,10.0},{11.0,27.0},{22.0,39.0},{32.0,44.0},{41.0,35.0},{50.0,40.0},{59.0,46.0},{64.0,59.0},{65.0,70.0},{73.0,75.0},{76.0,80.0},{70.0,85.0}},["mode"]="backtrack",["note"]="Kill, loot and skin suitable beasts along this corridor.",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Skinning",["zone"]="Arathi Highlands",["minSkill"]=155,["maxSkill"]=170,["minLevel"]=29,["points"]={{44.0,54.0},{53.0,49.0},{59.0,43.0},{71.0,35.0},{77.0,31.0},{79.0,36.0},{77.0,41.0},{68.0,47.0},{58.0,50.0},{48.0,53.0},{39.0,53.0},{29.0,54.0}},["mode"]="backtrack",["note"]="Kill, loot and skin suitable beasts along this corridor.",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Skinning",["zone"]="Arathi Highlands",["minSkill"]=170,["maxSkill"]=205,["minLevel"]=33,["points"]={{29.0,58.0},{36.0,65.0},{44.0,68.0},{53.0,65.0},{62.0,66.0},{63.0,75.0},{57.0,83.0},{53.0,78.0},{51.0,72.0},{42.0,72.0},{34.0,68.0}},["mode"]="backtrack",["note"]="Kill, loot and skin suitable beasts along this corridor.",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Skinning",["zone"]="Feralas",["minSkill"]=205,["maxSkill"]=230,["minLevel"]=40,["points"]={{68.0,43.0},{71.0,38.0},{80.0,39.0},{85.0,35.0},{89.0,38.0},{92.0,38.0},{94.0,45.0},{91.0,55.0},{83.0,58.0},{77.0,55.0},{71.0,58.0},{65.0,55.0}},["mode"]="backtrack",["note"]="Kill, loot and skin suitable beasts along this corridor.",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Skinning",["zone"]="Feralas",["minSkill"]=230,["maxSkill"]=260,["minLevel"]=46,["points"]={{47.0,54.0},{46.0,64.0},{44.0,73.0},{44.0,84.0}},["mode"]="backtrack",["note"]="Kill, loot and skin suitable beasts along this corridor.",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Skinning",["zone"]="Feralas",["minSkill"]=260,["maxSkill"]=280,["minLevel"]=50,["points"]={{41.0,39.0},{38.0,31.0},{40.0,22.0},{43.0,21.0},{45.0,26.0},{45.0,34.0},{42.0,41.0},{44.0,46.0}},["mode"]="backtrack",["note"]="Kill, loot and skin suitable beasts along this corridor.",["provenance"]="User-supplied route image; approximate trace; native verification pending"},{["kind"]="Skinning",["zone"]="Un'Goro Crater",["minSkill"]=280,["maxSkill"]=300,["minLevel"]=53,["points"]={{30.0,27.0},{36.0,27.0},{40.0,32.0},{40.0,42.0},{37.0,47.0},{28.0,47.0},{23.0,44.0},{23.0,36.0},{26.0,30.0}},["mode"]="backtrack",["note"]="Kill, loot and skin suitable beasts along this corridor.",["provenance"]="User-supplied route image; approximate trace; native verification pending"}}

local _,ns=ADDON,GF;ns.ClassicGatheringLocations5={
["Arathi Highlands"]={["Mining"]={{35.5,21.8,203},{61.6,31.4,203},{54.3,50.4,203},{35.3,42.8,203},{67.4,74.1,203},{70.9,58.4,203},{24.2,17.7,203},{38.8,23.5,203},{54.2,80.6,203},{69.2,76.7,203},{82.7,38.9,203},{58.1,71,203},{31.5,19.9,203},{21.8,77.9,203},{72.6,62.7,203},{66.4,80.2,203},{29.1,15.2,203},{21.3,82.7,204},{72.3,53.3,203},{79,36.7,203},{71.5,70.1,203},{30.2,16.8,203},{39,22.1,203},{57.9,74.8,203},{67.7,76.4,203},{31.5,18,203},{30.8,18.2,203},{18.3,89.4,203},{41.7,31.5,203},{27,18.5,203},{87,31.8,203},{13.4,42.6,203},{33.9,20.8,203},{32,65,203},{83.6,32.4,203},{32.7,21,203},{6,54.5,203},{35,68.1,203},{53.9,79.4,203},{53.5,70.8,203},{34.6,21.4,203},{31.9,22.8,204},{20.1,36,203},{31.5,46.2,203},{70.7,52.6,203},{70.6,52.4,203},{38.2,23.1,203},{22.8,70.6,203},{24.7,73.2,203},{54.8,75,203},{56.3,72.1,203},{39.8,25.4,203},{31.9,44.8,203},{68.8,74.7,203},{84.2,27.5,203},{69.2,27.6,203},{69.8,27.9,203},{40.8,28.2,204},{22.8,90.6,203},{66.7,73.9,203},{77.5,43.2,203},{83.9,29,203},{21.6,18.7,204},{58.9,72.7,203},{62.2,44.2,203},{57.5,46.9,203},{26.4,30.2,203},{24.7,92.8,202},{28.4,88.2,203},{73.8,63.7,203},{26.3,30.3,203},{70.8,30.7,203},{34.1,44.8,203},{50.1,81.6,203},{66.6,81.9,203},{44.6,31,203},{78.1,31.2,203},{25.6,31.7,203},{23.9,85.4,203},{45,65.9,203},{85.6,31.8,203},{57.5,49.2,203},{30.7,32.6,204},{32.6,45.3,203},{63.3,73.9,203},{55.2,32.7,203},{46.9,32.7,203},{39,24.6,203},{73.3,59,203},{72.6,66.9,203},{19,32.9,203},{48.6,33,203},{38.6,61.7,203},{22.6,90,203},{68.8,76.6,203},{59.5,33.2,203},{48.2,33.2,203},{37.6,34.9,203},{55,70.2,203},{71.4,70.9,203},{64.3,33.4,203},{19.2,33.5,203},{36.1,45.8,203},{82.8,33.5,203},{57.1,76.7,203},{19.4,33.6,203},{73.8,64,203},{38.2,33.7,203},{37.4,65.9,203},{55.8,76.4,204},{85.8,33.7,203},{38.1,34.5,203},{32.8,43.3,203},{34.1,68.7,203},{57.2,70.4,203},{49.7,34.9,203},{64.4,35,203},{49.8,35.5,203},{69.6,81.6,203},{47.6,67.6,203},{47.8,35.7,203},{70.3,67.8,203},{19.2,83.9,203},{81.1,36.4,203},{47.5,82.9,203},{24.7,36.5,203},{30.2,44.1,203},{21.3,75.4,203},{50.3,76.4,203},{73,51.9,203},{79.2,37.2,203},{78.9,38.2,203},{12.1,40.7,203},{82.8,39.1,203},{49.7,47.8,203},{34,41.9,203},{34.3,42.2,203},{33,42.8,203},{37,57.1,203},{51.5,75.9,203},{38.7,43.1,203},{32.9,43.2,203},{25.7,85.8,203},{77.2,28.8,203},{52.3,77.4,203},{77,43.6,203},{61.6,44,203},{34.6,44.1,203},{33,46.2,203},{80.2,36.8,203},{34,44.4,203},{33.1,44.5,203},{35.4,56.8,203},{66,26.9,203},{70.1,57.2,203},{24.8,87.9,203},{76,45.6,203},{76.8,45.7,203},{65.3,75.2,203},{66.9,73.9,203},{31.5,45.8,203},{33.8,45.9,203},{19.2,93.3,202},{29.7,69,203},{75.5,46.2,203},{33,46.3,203},{33.5,46.4,203},{20.8,71.5,203},{42.5,78.8,203},{54.5,81.9,203},{33.3,46.6,203},{33.9,46.9,203},{35.3,46.9,203},{70,29.7,203},{69.1,74.1,203},{74.9,47.5,203},{74,47.6,203},{50.3,47.9,203},{50.5,35.9,203},{71,71.2,203},{73,48.7,203},{6.1,55.2,204},{44,70.2,203},{70.9,71.2,203},{47.5,32.2,203},{56.1,49.4,203},{70.8,49.5,203},{30.6,69.5,203},{23.5,72.4,203},{54.7,79.5,203},{15.8,66.8,203},{72.6,61.6,203},{16.3,32.9,204},{77.5,28.7,203},{66,74.7,203},{51.8,76.9,203},{28.9,69.1,203},{68.8,80.6,203},{80.2,32.8,203},{53.2,80.2,203},{72,69.8,203},{9.3,52.4,203},{34.9,61.9,203},{37,22.9,203},{54.4,48.9,203},{54.5,82.1,203},{67.4,69.5,203},{11,43.6,203},{49.2,33.6,203},{77,44.8,203},{71.6,57.8,203},{53.6,79.8,203},{26.7,12.7,203},{33.9,45.1,203},{65.3,65.7,203},{69.8,70.9,203},{69.5,74.6,203},{38.7,71.6,203},{58.8,70.9,203},{54.3,78.7,203},{67.8,79,203},{41.1,64.5,203},{70.5,74.1,203},{79.7,43,203},{54.4,77.9,203},{21.5,87.9,203},{54.8,64.6,203},{33.8,65,203},{74,61.3,203},{51.1,80.5,203},{54.1,77.6,203},{54.7,78,203},{54.9,81.7,203},{72.7,49.8,203},{29.9,70.2,203},{55.5,73.3,204},{53.6,71.3,203},{12.2,43.3,203},{55.5,71,203},{54.4,81.8,203},{54.9,78.3,203},{71.1,68.5,203},{29.5,15.6,203},{74.2,48.1,203},{68.3,81.9,203},{48.6,85.2,203},{73.9,65.7,203},{11.4,41.2,203},{72.2,50.6,203},{48.9,82.6,203},{54.6,78.9,203},},["Herbalism"]={{4.4,62,407},{37.1,70.2,409},{67.2,50.7,411},{22.7,84.6,407},{40.5,61.1,415},{31.6,26.5,408},{31.7,48.1,411},{73.3,58,409},{52.4,47.6,411},{52.1,34.5,409},{33.2,20.8,409},{29,33.8,414},{44.7,69.6,412},{55,31.6,409},{55,35.9,408},{62.3,39.5,411},{21.6,34.4,413},{17.8,62.7,414},{7.1,64.4,407},{23.4,28.8,414},{75.6,28.8,414},{39.5,41.1,411},{31.6,26.4,408},{18.6,71.7,414},{22.5,15.4,405},{69.3,68.7,412},{60.8,34.3,415},{50.7,37.9,414},{43.1,29.8,409},{55.7,66.2,413},{59.6,50.9,411},{53.6,39.3,408},{21.7,75.3,409},{41.2,31.1,414},{56.3,75.1,409},{36.5,46,415},{25.5,66.4,408},{14.6,68.6,414},{50.7,37.8,414},{56.4,32,415},{45.7,78.4,412},{63.7,74.4,409},{49.6,32.9,409},{69,68.4,412},{31.8,30.7,408},{46.2,31.2,409},{66,66.9,412},{19.1,33.1,414},{72.5,65.8,415},{29,33.6,414},{49.3,32.7,409},{62.7,65.2,415},{50.5,80.7,414},{53,77.6,415},{70.4,69,415},{49.2,71.4,414},{39.6,25.9,409},{46.4,70,412},{65,27.5,414},{53.1,64.7,411},{35.1,21.5,409},{79.1,43.1,409},{51.5,38,414},{50.1,76.1,414},{43.9,29.9,415},{70.6,25.9,409},{26.6,19.4,414},{50.4,76.2,414},{18.8,71.7,414},{41.7,31.2,414},{64.1,44.2,411},{46.4,31.1,409},{22.2,36.6,413},{73.6,48.9,414},{63.2,69.6,415},{70.7,25.9,409},{66.9,62.8,415},{72,65.3,415},{63.1,30.7,415},{27.3,19.7,414},{40,26,409},{51.6,37.9,414},{46.6,31.1,409},{73.8,48.9,414},{25.5,66.2,408},{35.3,45.2,409},{17.7,66.8,408},{72.6,65.5,415},{27.4,19.7,414},{22.9,73.5,409},{41.9,50.6,411},{5.5,54.9,407},{39.2,47.1,411},{22.8,99.3,407},{46,39.3,411},{25.1,63.8,408},{56.7,40.3,408},{56,70.1,411},{45.1,81.9,412},{43.1,42.1,414},{5,65.2,407},{70.1,55.5,415},{17.4,72,409},{78.5,33.8,409},{39.9,71.1,413},{36.7,26.4,413},{29.4,55.1,412},{67.5,62.8,412},{69.5,68.1,412},{19.2,57.8,414},{81.4,35.2,409},{15.7,44.2,415},{19.5,21.3,405},{16.5,68.3,409},{63.6,73.7,415},{34.3,42.4,409},{58.8,67,413},{28.9,54.8,412},{48.5,36,415},{66.9,71,415},{69.3,76.5,409},{26.5,34.2,414},{65.3,70.2,415},{30.9,25.6,408},{39.7,66.6,413},{52.8,38.1,408},{35.5,21.4,409},{7.5,53.7,407},{21.7,98.6,407},{35.6,66.7,413},{26.1,70.6,409},{60.2,33.1,409},{69.9,46.5,411},{37.8,61.3,413},{45,68.6,412},{58.3,75.2,409},{29.6,52.9,412},{34.7,61.9,414},{67.3,62.4,412},{45.6,77.5,412},{62.4,72.9,415},{59,75.5,409},{42,65.5,414},{76.8,32.6,414},{53.4,72.7,414},{56.9,74.4,409},{76.7,32.5,409},{34.8,66.2,413},{42.1,61.2,415},{42.3,61.3,415},{65.3,69.9,415},{46.1,69,414},{24.1,50.1,412},{58.8,45.1,411},{23.4,51.9,412},{81.5,34.8,409},{48.4,39.9,411},{58.6,70.8,409},{26.8,36.3,414},{66.5,74.7,409},{42.3,28.9,409},{50.8,36.7,414},{7.2,53.5,407},{66.6,74.7,409},{75.1,27.2,414},{67.7,62.3,412},{61.5,50.6,411},{60.6,37.2,415},{69.3,76,409},{15.4,43.9,415},{62.3,72.5,415},{15,43.7,415},{57.3,31.2,415},{54.9,64.5,414},{75.3,27.2,414},{68,40.8,415},{36.3,66.8,413},{31,38.3,411},{59.8,32.4,409},{57.2,31.1,409},{78,41.4,409},{27.1,19.1,414},{60.5,71.5,415},{66,65.6,412},{34.4,61.5,414},{79.5,37.8,414},{71.3,63.9,412},{63.5,25.5,409},{17.8,47.2,414},{69.4,67.2,412},{39.5,25.2,409},{12.8,30.7,405},{51.4,36.7,414},{38.9,24.9,409},{26.8,66.3,408},{63.2,68.4,415},{53.3,72.1,414},{45.8,81.3,412},{42.7,63.4,414},{79,37.4,414},{68,62.1,412},{78.6,41.5,409},{21.2,75.8,409},{53.4,50.5,414},{29.4,54.6,412},{51.5,36.6,414},{67.4,61.7,412},{21.4,36,413},{82.7,39.1,409},{24.5,62.9,408},{21.2,59.6,408},{58.8,66,413},{60.6,36.7,415},{71.2,59.2,415},{51.8,32.3,415},{68.5,62.1,412},{35.4,42.4,409},{14.9,68.3,414},{66.2,39.4,411},{20.6,38.8,414},{53.2,71.7,414},{77,44.7,414},{73.7,64.6,415},{54.9,33.7,415},{61.2,32.5,415},{66.7,69.7,412},{18.3,67.8,408},{27.5,19,414},{62.1,71.7,415},{55.7,68.5,415},{51.5,66.4,411},{20.1,57.9,414},{32.3,62.3,413},{45.9,33.4,409},{56.2,73,414},{54.4,76.4,415},{52.4,32.3,409},{42.7,30.8,415},{77,44.5,409},{24.9,39.2,414},{36.3,42.7,409},{70.1,62.6,415},{67.7,70,412},{18.6,48.5,414},{48.3,34.5,409},{42.2,65,414},{30.7,44.2,414},{62.3,28.5,409},{51.6,36.1,415},{20.7,75.4,409},{16.6,47.5,415},{16.1,68.8,409},{17.6,62,414},{70.7,62.8,415},{35,22.6,409},{60.2,31.7,409},{80,32.9,409},{24.5,49.7,412},{33.4,30.4,408},{55.1,55,411},{23.1,53.3,412},{66.6,65,412},{30.2,48.2,409},{35.7,22.9,409},{55.9,33.8,415},{17.5,63,414},{68.9,70.4,412},{26.4,70,409},{60,31.5,414},{73.5,46.8,411},{16,64.4,409},{29.4,21.9,413},{54.1,58.7,413},{52.6,36.4,415},{24.3,60.3,408},{63.6,28.9,409},{72.1,63.3,415},{46.4,80.7,414},{55.9,46.6,411},{66.3,64.7,412},{57.2,73.1,409},{60.6,40.3,413},{65.3,34,411},{19.4,20.8,405},{68.2,61.3,412},{77.2,44.2,414},{66.8,69.2,412},{70,75.1,409},{36.8,44.9,415},{35.1,46.2,409},{60.2,31.4,409},{52.3,36.1,415},{33.1,25.8,414},{46.9,76.5,414},{65.9,34.2,413},{29.9,63,408},{58.3,64.9,413},{67.6,26.4,409},{18.4,42.9,411},{64.6,72.3,415},{27.3,46.6,409},{66,34.2,413},{53.1,75.2,415},{60.8,31.6,414},{41.3,40.6,414},{29.7,41.3,413},{70,27.5,414},{55.9,67.9,415},{70.1,53.4,415},{66.2,25.6,409},{20.3,97.7,407},{35.7,22.7,409},{56.3,72.4,414},{45.6,75.7,412},{79.7,40.9,409},{45.9,28.4,409},{68.9,35.5,411},{8.8,54.1,409},{29.6,41.2,413},{35.1,54.7,413},{57.6,47.1,414},{31,26.8,408},{69,70,412},{17.7,71.6,409},{66.4,68.7,412},{72.7,28.7,414},{51.5,31.1,409},{52.9,79.2,409},{42.9,65,414},{68.7,74.1,415},{64,50.2,415},{35.2,54.7,413},{69.4,65.8,412},{24.6,36.5,414},{40.3,48.6,414},{52.1,65.8,413},{53.3,31.9,415},{66,42.5,413},{28.3,34,413},{66.5,64.3,412},{46.7,71.7,412},{32.3,44.6,409},{51.5,48.2,413},{35.3,54.7,413},{15.1,44.4,415},{38.1,21.6,409},{40.7,70.3,413},{36.4,22.9,409},{54.5,32.4,409},{59.4,30.5,409},{83.7,19,418},{33.7,22.8,413},{13.9,38.4,405},{51.7,78.4,409},{59.6,34.9,409},{22.4,46.1,411},{27.5,18.9,414},{26.5,19.5,414},{23.9,29.6,414},{73,28.6,414},{29.7,23.2,413},{26.4,20.2,414},{31.6,22.6,414},{5.2,57.6,407},{51.8,35.3,415},{20.8,47.2,415},{78.9,35.1,414},{24.2,59.9,408},{65.9,27.4,414},{70.9,62,415},{70,27.4,414},{69.2,27.4,414},{64.8,27.4,414},{65.7,27.4,414},{75.5,28,414},{66,42.3,413},{73.6,28.3,414},{72.9,28.3,414},{29.8,41.1,413},{29,41.7,413},{50.8,36.2,414},{64.3,71.6,415},{17.3,47.6,414},{56.1,68.2,415},{65.9,42.2,413},{54.3,58,413},{23.5,28.9,414},{17.5,62.2,414},{28.5,32.4,414},{16.1,47,415},{36.2,22.7,409},{29.1,64,408},{20.2,33.9,414},{78.3,35.4,414},{38.1,34.1,414},{26.5,34.1,414},{48.2,33.2,409},{29.4,53.8,412},{66.8,42.6,413},{60.2,63.5,413},{51.2,79.9,409},{31.9,22.7,414},{73.8,67.6,409},{30,62.7,408},{64.6,26,409},{74,28.9,414},{41.8,77.1,409},{77.6,39.3,409},{67.2,64.3,412},{35.1,46.3,409},{81.6,37.2,409},{32.2,44.4,409},{24.9,48.8,412},{56.3,67.5,413},{37.5,23.3,409},{38.6,26,409},{55.2,49.7,415},{43.5,30.5,409},{73.5,28.6,414},{32.4,18.6,409},{65.9,25.5,409},{66.5,38.1,413},{28.5,33.9,413},{25.4,49,412},{64.4,41.3,415},{52.8,65.7,413},{32.5,44.5,409},{32.5,18.9,409},{23.5,50.8,412},{46.3,36.7,414},{37.7,23.1,409},{55.4,31.3,409},{51.6,31.8,409},{69.6,25.9,409},{22.1,73.8,409},{38.4,43.1,414},{21.3,37.5,414},{42.3,75.2,414},{17.6,71.4,409},{82.1,39.9,409},{67.2,26.1,409},{21.3,37.7,414},{63.3,49.3,415},{45.4,69.1,412},{54.2,57.7,413},{23,85,407},{32.7,23,413},{26,37.7,414},{58.8,29.8,415},{48.5,37.6,414},{68.9,73.6,415},{72,62.2,415},{79.6,37.9,414},{69,66.7,412},{33.7,19.6,409},{15.2,69.1,414},{23.3,52.8,412},{42.9,27.9,409},{84.4,20.9,418},{54.5,65.2,414},{79.6,32.7,409},{18.9,50.8,411},{25.6,38.3,411},{34.2,22.2,409},{21.4,39.2,414},{44.4,31.2,409},{46.4,36.5,414},{24.6,59.8,408},{34.3,68.6,409},{61.6,69.5,415},{65.2,41.5,415},{61.6,43.7,414},{42.9,58.9,411},{75.2,29.2,415},{55,32.1,415},{16.6,64.4,409},{59.8,38.8,415},{29.3,21.6,413},{40.8,44.1,414},{19.3,56.2,414},{26,96.9,408},{50.2,80.5,414},{38.3,21.4,409},{44.3,70.4,412},{21.8,75.7,409},{58.1,47.5,414},{73.9,28.5,414},{61.9,44.1,414},{32.4,43.3,409},{19.2,56.2,414},{71.4,65.3,415},{6.4,52.8,409},{19.5,57.2,414},{36.7,23.7,409},{34,59.7,414},{39.8,37.2,411},{66.7,34.6,413},{45.6,78.4,412},{41,61.5,415},{48.7,37.5,414},{75.2,29.1,414},{57.1,40.1,408},{80.4,38.6,409},{63.7,75.1,409},{54.6,64.8,414},{28.9,44.7,409},{42.1,65,414},{6.8,67,407},{56.1,67,413},{37.5,23.1,409},{42.1,34,411},{78.9,35.2,409},{30.3,70.1,409},{69.8,33,413},{49.8,72.7,414},{58.1,70.4,409},{36.6,45.9,415},{21.9,59.7,408},{59,68.4,413},{30.1,53.9,412},{79,35.2,414},{20.7,39,414},{66.1,71.9,415},{73.7,49.8,414},{55.4,32.1,415},{58,31.5,409},{18.5,24.1,411},{60.6,40.7,413},{27,20,414},{20.2,33.8,414},{81.1,36.2,409},{22,36.5,413},{61.4,67.5,411},{39,66.9,413},{79.7,35.5,414},{44.3,69.7,412},{51.7,34.3,415},{50.8,35.5,415},{51.3,36.4,415},{38.1,20.4,409},{59.2,37.2,415},{66.4,39.8,413},{69.3,71.2,415},{79.6,35.4,409},{28.5,35.8,413},{14.3,28.7,411},{37.3,45.4,415},{79.2,35.2,414},{29.1,38.3,411},{63,50,415},{25.5,97.1,408},{16,65.1,409},{69.6,26.1,409},{36,66.7,413},{59.9,32.7,409},{29.6,47.1,409},{34.9,42.6,409},{68.7,32.5,413},{12.1,41.6,409},{23.5,54.8,412},{30.9,25.4,408},},["Fishing"]={{30.9,81.9,105},{32.9,80.6,105},{28.6,89.7,105},{6.4,55.9,107},{24.7,96.9,107},{27.8,85.4,105},{23.5,98.2,107},{27.3,87.2,105},},},
["Un'Goro Crater"]={["Mining"]={{53.7,69.8,208},{49.2,80.2,213},{43.4,80.9,213},{49.8,81.2,213},{36,19.4,208},{77.1,54.6,208},{76.8,57.3,208},{41.7,19.4,208},{46.7,82.8,213},{50.2,52.6,208},{49.5,83,213},{47.3,47.4,208},{48,56,208},{23.8,57.1,208},{45,83.5,213},{46.4,84.6,213},{48.2,85,213},{75.4,60.3,208},{47.9,87.2,213},{52.4,66.1,208},{82.6,73.8,208},{43.8,12.2,208},{67.6,16.7,208},{10.2,73.1,206},{55.4,13.4,208},{77.4,57.3,208},{48.6,12.7,208},{59.7,14.7,208},{74.2,31.1,208},{59,15.4,208},{60.4,16.2,208},{36.5,19.9,208},{46.1,50.9,208},{76.6,56.5,208},{75.7,85.1,208},{42.5,91.5,208},{76.3,40.3,208},{42.1,84.7,208},{79.9,42.7,208},{78,41,208},{60.4,67.8,208},{76.9,43.6,208},{27.3,31.5,208},{46.7,53.8,208},{26.1,67,208},{30.3,48.5,208},{74.4,69.1,208},{24.7,49.8,208},{72.8,20.4,208},{31.5,50.8,208},{48.3,81.7,213},{63.9,80.9,208},{37,64.9,208},{74.2,69.9,208},{46.5,87.5,208},{82.5,66.4,208},{84.2,46.2,208},{31,71.6,208},{57.7,85.8,208},{45.1,70.4,208},{75.6,63.7,208},{24.9,61.1,208},{84.3,51.8,208},{84.1,53.8,208},},["Herbalism"]={{34,28.1,425},{63.1,32.6,426},{55.4,16.1,425},{21,40.3,421},{52.7,19.3,422},{45,86.2,427},{50,64.2,421},{23,67.9,427},{60.6,20.6,425},{38.7,23.3,425},{22.2,61.9,427},{46.4,79.7,426},{64.7,70.8,426},{52.9,58.6,426},{44.8,36.7,425},{54.4,65.9,426},{69.7,55.2,426},{30.4,76.2,426},{64.3,32.2,425},{61.6,58.4,426},{22.7,66.1,427},{31.5,81.3,427},{38.7,54.3,425},{56,61.3,426},{51.4,28.8,422},{47.2,29.5,425},{67,47.7,426},{75.4,57.5,425},{28.5,64,421},{68.9,79.1,425},{68.5,78.5,425},{60.1,30.2,422},{63.5,57.7,426},{59.6,24.4,422},{25,32.6,427},{28.8,33.7,425},{48.5,53.6,427},{69.5,80.5,427},{44.9,85.7,427},{46.1,47.9,427},{60.6,69.7,425},{51,74.7,425},{37.9,57.9,426},{64.4,31.5,425},{64.8,80.2,427},{47.2,30,425},{50.2,75.1,425},{46.4,79.6,426},{51,19.6,426},{37.5,75.2,421},{70.4,65,425},{60.8,73.2,426},{54,21.9,426},{50.1,75.2,425},{38.8,54.4,425},{47,15.8,422},{52.3,34.1,425},{33.4,23.4,425},{33.4,24.2,425},{34.7,65.7,421},{45.4,48.7,427},{72.2,42.5,426},{67.6,23.9,425},{58.7,73,426},{55.3,84.5,425},{43,72.4,426},{36.4,65,426},{54.5,53.9,427},{36.6,16.9,427},{64,81.1,427},{75.5,33.2,427},{44.4,36.5,425},{60.5,24.3,422},{69.3,55,426},{29.6,57.3,425},{39.7,84.6,427},{35.5,54.3,426},{24,67.7,427},{48.1,26.2,426},{31.1,67,426},{48.1,18.7,422},{68.7,49.3,425},{35.1,29.9,425},{71.4,72.8,426},{26.3,32.6,421},{53.3,66,426},{51,74.6,425},{26.8,29.6,427},{47.5,33.3,422},{53.6,65.6,426},{51.7,17.6,425},{23.3,66.9,427},{36.5,60.3,426},{55.8,72.6,425},{70.3,65,425},{35.9,30,426},{53.8,52,427},{41.4,48.6,426},{50,87.5,427},{39.1,58.8,426},{48,33.2,422},{75.5,66.8,427},{64.3,76.4,425},{51.7,25.6,426},{53.6,50.6,427},{66.2,75.7,426},{36.5,70.7,425},{25.2,57.4,425},{67.3,23.6,425},{72.6,68.1,426},{44.3,36.5,425},{55.3,84.4,425},{24.4,38.3,427},{60.3,20.7,425},{28.8,33.6,425},{64.1,50.4,425},{41.4,48.3,426},{60.6,69,425},{69.4,19.5,427},{43.4,86.2,427},{69.8,29.7,425},{23,60,427},{74.7,54.9,425},{33.5,24,425},{39.2,45.3,421},{47.1,29.4,425},{39,33.5,421},{74.6,55,425},{56.6,10.1,425},{43.6,91.3,425},{58.5,90.7,427},{71.5,73.1,426},{20.8,41.8,425},{50.8,43.7,427},{48.1,69.9,421},{52.3,33.9,425},{45,78.4,426},{20.6,41.9,425},{61.8,14.6,427},{63.7,50.3,425},{40.8,63.7,421},{67.9,31.4,421},{25.3,48.7,425},{56.4,90.5,427},{69.8,31.8,426},{33.5,29.6,425},{78.9,41.3,426},{40,51.8,421},{54.8,46.4,427},{57.4,18.2,421},{53.9,76.9,426},{48.6,23.3,422},{66.2,67.6,426},{58.9,27.1,426},{53.5,54.9,427},{68.8,30.3,425},{31.3,19.1,427},{30.9,73.3,425},{80.6,60.1,426},{65.3,49.4,426},{32,45,426},{21.7,59.9,425},{68.7,78.5,425},{52.6,44.7,427},{78.6,40,427},{55.2,59.8,426},{60.5,51.9,425},{57.1,37.2,426},{47.1,27.7,421},{38.4,72.4,426},{27.5,36.7,421},{62.7,34.3,426},{53.1,67.1,426},{50.5,11.8,427},{57.2,12.6,427},{35,37.5,425},{60.3,81,425},{32.8,72.1,421},{43.6,91.4,425},{61.1,54.9,421},{36.8,17,427},{37.4,17.4,427},{54.4,24.6,422},{48,44.8,427},{52.6,47.9,427},{77.2,40.3,427},{25.7,55.7,425},{73.4,36.1,421},{57.9,81.7,421},{53.1,44.7,427},{23.8,39.2,427},{59.8,51.1,425},{46.8,45.1,427},{29.5,31.9,425},{61.3,84.6,427},{46.5,45.5,427},{50.7,48.8,427},{25.2,48,426},{24.1,57.3,427},{54,66,426},{38.3,24.1,425},{22.8,49.8,427},{47.6,53.6,427},{53.5,55.9,427},{46.4,74.9,421},{51.1,24.6,426},{42.4,19.7,422},{64.5,65,425},{76.8,66.9,427},{23.3,41.4,427},{38.3,20.4,426},{38.7,54.5,425},{36.7,53.8,426},{43.7,92,425},{35.9,29.9,426},{74.1,70.1,427},{72.3,71.3,427},{32.7,80,427},{56.9,8,426},{68.3,79.9,427},{36.8,82.8,427},{64.9,71.2,426},{52.7,24.2,426},{36.3,53.5,426},{52.8,34.4,425},{22.1,66.6,427},{37,70.9,425},{77.1,59.9,427},{28.2,65.5,426},{55.4,18.1,425},{61.1,85.6,427},{55.3,64.4,426},{32.2,41.5,425},{55.7,17.4,425},{27.8,46.1,426},{29.7,57.3,425},{33.9,76.1,426},{59.8,75.1,421},{56.3,90.5,425},{53.3,76.4,426},{29.5,31.6,425},{56.6,63.9,426},{64.8,77,425},{62.1,14.6,427},{47.5,30.9,425},{45.6,15.7,422},{34.8,35.2,426},{39.2,15,427},{56.2,88.8,427},{28.1,46.9,426},{58.8,39,425},{44.7,87.7,427},{27.9,46.6,426},{55.4,83,425},{57.2,89.5,427},{56.1,30.5,421},{60.8,80.3,425},{44.3,36.3,425},{47.7,23.9,426},{52.6,24.1,426},{44.1,91,421},{49.6,70.1,425},{60.2,32.2,422},{35.5,65.1,426},{60.9,27.7,426},{42.7,71.8,421},{63.7,22.5,422},{42.4,83,425},{43.8,69.5,426},{56.7,61.6,426},{34.6,35.5,426},{42.3,83,425},{25.4,48.6,425},{74.3,38.5,426},{41.4,40,426},{53.4,23.3,426},{41.2,40.3,426},{33.3,76,426},{51,49.7,427},{42.9,18.6,422},{20.9,41.6,425},{66.7,47.6,426},{68,57.4,426},{67.8,74.1,426},{54.4,66.5,426},{74.1,42.8,426},{68.6,49.6,425},{48.3,62.5,421},{32.9,37,421},{69.7,34.4,426},{51.7,17.3,425},{50.5,44.4,427},{38.5,24.6,425},{59.7,38.8,425},{74.5,56.9,425},{38.8,23.2,425},{55.8,65.9,426},{66.2,20.9,427},{31,57.4,425},},["Fishing"]={},},
["Blasted Lands"]={["Mining"]={{68.8,9.4,214},{57.5,13,214},{55.4,6.8,214},{60.7,7.4,214},},["Herbalism"]={},["Fishing"]={},},
["Tirisfal Glades"]={["Mining"]={{28.1,47,201},{77.2,56.5,201},{81.2,48.7,201},{69.8,42.7,201},{77.6,35.6,201},{75.6,36.2,201},{84.2,38.6,201},{80.2,24.5,201},{53.5,53.6,201},{75.5,44,201},{54.4,37.8,201},{54.6,40.5,201},{55.1,31.3,201},{74.5,53.5,201},{77.4,32.8,201},{74.2,57.6,201},{56.9,25.8,201},{56,35,201},{49.3,48.6,201},{47.6,67.9,201},{38.6,53.4,201},{83.7,68.2,201},{45.1,69.9,201},{70.3,67.1,201},{53.4,26.5,201},{73.6,58.2,201},{49.6,27,201},{73.5,68.3,201},{61.2,46.4,201},{89.5,44.8,201},{29.7,42.5,201},{79.1,37.2,201},{74.1,56.6,201},{87.7,37,201},{76,31.2,201},{53.7,53.7,201},{56.5,45.2,201},{81.2,52.6,201},{52.9,41.9,201},{78.3,40.6,201},{33.5,52.8,201},{34.9,40.4,201},{63.5,27.1,201},{82,41.4,201},{49.9,66.1,201},{83.1,28.3,201},{77.6,28.3,201},{58,29.2,201},{65.9,45.1,201},{74.9,28.9,201},{57.2,30.2,201},{85.9,37.8,201},{50.7,34.3,201},{82.9,31.4,201},{42.7,31.5,201},{82.3,75.2,201},{84.9,64.2,201},{50.1,70.9,201},{78.2,32.4,201},{85.6,35.1,201},{81.8,57.1,201},{35.9,36.5,201},{39.3,37.1,201},{54.5,47.7,201},{40.7,39.2,201},{37.5,37.4,201},{43.3,64,201},{42,66.3,201},{48.6,45.9,201},{83,38.2,201},{91.1,45.9,201},{49.4,39.1,201},{50.6,44.2,201},{80.2,57.4,201},{34.6,47.2,201},{82.2,64.7,201},{43.2,35.9,201},{54.9,54.1,201},{73.9,41.5,201},{52.7,52,201},{52.3,46.1,201},{41.4,69.5,201},{77.7,45.3,201},{49.2,70,201},{47.3,69.9,201},{54.3,44.9,201},{83.7,64.4,201},{37.6,52.8,201},{81,60.4,201},{34.3,44.7,201},{48.4,47.4,201},{37.3,39.5,201},{80.1,43.6,201},{40.3,57.2,201},{79.5,73.6,201},{78.2,54.5,201},{91.2,51.6,201},{82.3,73.1,201},{68.6,54.3,201},},["Herbalism"]={{60.2,47.2,402},{76.1,34.6,403},{37.7,43.4,401},{54.7,58.6,402},{86.6,37.4,403},{37.4,39.3,403},{62.9,45.8,401},{46.1,51.4,401},{52.8,29.7,402},{80.3,62.1,402},{49.4,63.3,401},{48.2,37.1,402},{41.3,63.7,402},{71.8,49.4,401},{60.9,41.6,401},{69.2,59.4,401},{89.7,40.6,402},{61.9,37.2,402},{45.3,52.2,402},{66,50.6,401},{39,41.3,402},{50.9,64.3,401},{56,38.8,402},{36.1,47.4,401},{40.1,56.9,402},{50.2,61.6,402},{32.7,50.6,401},{52.8,71.2,401},{82.3,75.2,403},{71.5,36.8,402},{45.4,49,401},{96.3,30.9,427},{75.1,54.5,402},{83.7,65.8,402},{39.5,53.4,401},{58,33.9,402},{49.9,26.9,403},{47.5,27.5,403},{57.4,28.1,403},{58,38.6,402},{48.4,51.5,401},{63.1,28.2,403},{57.6,60.8,401},{55.3,31,403},{60.2,31,403},{44.7,45.5,402},{74.4,31.2,403},{82.5,31.6,403},{75.9,31.9,403},{53.7,49.9,402},{44.3,36.5,402},{42.4,31.9,403},{50.8,33.4,403},{76,34.6,403},{66.6,59.1,403},{74.9,56.5,403},{56,34.9,403},{84.3,36,403},{39,36.9,403},{40.1,44.9,401},{55.3,63.1,401},{54.7,40.1,403},{74,40.5,403},{78.9,41.4,403},{51.2,43.5,403},{49.4,30.2,402},{79.1,44.1,403},{48.5,44.3,403},{31.2,45,403},{41.7,53.4,402},{48.6,68.7,402},{76.2,46.4,401},{51.7,45.6,403},{35.2,46.2,403},{59.9,58.8,402},{73.7,59.7,401},{75.4,47,403},{48.9,48.2,403},{62.5,50,403},{91.3,51.5,403},{51.6,50.8,401},{42.6,51.2,402},{81,62.2,403},{82.2,64.6,403},{43.8,65.7,403},{81.6,73.2,401},{71.5,65.8,403},{48.3,67.4,403},{83.5,68.9,403},{46.4,65.7,402},{51.5,65.7,402},{73.6,73,403},{48.7,28.3,401},{53.8,28.9,401},{38.9,38.1,402},{56.2,50.5,402},{48.2,31.7,401},{50.8,32.1,401},{38.3,45.4,402},{62.8,33.9,401},{67,59,402},{89.4,48.9,402},{72,34,401},{65.5,34.4,401},{51.5,54.3,401},{52.2,26,402},{46.8,35,401},{49.9,37.3,401},{77.2,38,401},{46.8,42.1,401},{77.1,58.6,402},{66.6,38.1,401},{56.9,38.7,401},{46.8,39.6,401},{58.6,30.2,402},{44.3,40.1,401},{64.7,42,401},{84.5,42.6,401},{53.2,46.2,401},{59.8,45.4,403},{43.5,69.8,402},{72.6,46.8,401},{31,47.8,401},{47.1,48.2,401},{41.6,46.5,402},{60.6,57.1,401},{49.7,54.3,402},{61,44.2,402},{38.4,48.9,401},{66.6,33,402},{46,43.7,402},{54.4,55.3,402},{85.3,50.4,401},{41.8,67.3,402},{45.3,61.4,401},{76.8,73.1,401},{57.4,48.5,402},{48.7,64.8,402},{42.9,61.1,402},{40.8,49.1,402},{79.5,61.9,401},{51.9,53,402},{75.3,66.4,402},{73.8,67.6,401},{56.3,47.2,402},{55.2,41.4,402},{48.9,48.9,402},{53.3,43.3,402},{50.7,77.3,402},{63.5,35.5,402},{81.8,57,403},{48.5,58.8,402},{43.1,42.3,402},{57.4,54.2,401},{33.5,52.2,402},{75,49.7,402},{54,46,402},{83.3,54.2,402},{69.2,54.4,401},{57.1,58.1,401},{65.5,55.1,401},{46,54.7,401},{64.9,50.7,401},{42.3,58.3,401},{50.9,77.4,402},{53.3,52.5,402},{46.2,58.9,402},{64.8,38.1,402},{33.7,45.7,402},{57.4,30.6,403},{56.6,44,402},{61.4,32.8,402},{53.7,60.1,401},{60,38.8,402},{29.9,50.5,402},{76.3,71.9,402},{72,64.8,401},{81.3,74.1,402},{51.2,58,402},{64.5,52.4,402},{78.3,68.6,401},{50,65.9,401},{73.2,37.2,402},{39.4,51.4,402},{48.2,61.1,402},{53.2,61.5,402},{89.6,70.2,421},{50.8,70,401},{50.3,55.1,402},{44.2,30.8,401},{66.4,49.1,402},{97.3,33.5,421},{43.5,29.9,402},{75.4,32.7,402},{70.9,60.4,402},{43.8,57.5,401},{79.4,40.1,402},{81.3,67.3,401},{51.5,70.9,402},{51.8,60.8,401},{47.5,52.5,402},{36.2,46.3,402},},["Fishing"]={},},
["Silverpine Forest"]={["Mining"]={{35.3,12.2,201},{59.4,75.5,204},{41.9,31.5,204},{51,27.1,204},{34.9,18.5,204},{35.9,9,204},{47.3,76.4,204},{55.4,7.9,204},{57.9,79.1,202},{53,36.7,204},{59.8,70.7,204},{57,45.8,204},{56.7,46.6,204},{39.7,23,204},{60.8,80.8,204},{36.8,19.1,204},{48.5,42.5,204},{52.5,11.2,204},{49.3,13.4,204},{73.4,29.2,201},{51.7,64.6,204},{46,56.8,204},{42.9,75.5,204},{65.3,45.5,204},{69.3,54.6,202},{67.3,26.9,204},{37.9,18.6,204},{55.3,33.7,204},{46.5,68.9,204},{62.8,79.8,204},{64.5,22,201},{57.6,69.6,202},{45,48.6,204},{42.3,71.8,204},{56.4,48.5,201},{42.1,52,204},{56,80.3,204},{48.6,48.3,204},{33.3,15.4,204},{35.5,11.7,204},{58,45.2,204},{52.3,78.2,201},{40.1,69.2,204},{46.3,30.4,201},{33.1,20.5,204},{53.3,37.3,204},{51.9,32.3,204},{48,22.2,204},{71.1,60.1,204},{57.4,45.6,204},{59.6,70.7,204},{61.6,21.1,202},{75.8,36.6,202},{35.4,20.7,204},{61.3,37.2,202},{61.1,41,202},{35.2,9.9,204},{58.2,45.4,202},{67.8,46.4,202},{70.7,78.3,201},{47.4,51.8,202},{58.1,70,202},{43.2,24.8,204},{35.2,10.9,204},{62,7.4,204},{48.4,36.4,204},{56,54.9,204},{51.3,67.9,204},{36.8,13.2,204},{50.5,86.9,204},{59,70.6,202},{57.5,70.7,202},{43.2,22.6,204},{53.9,16.8,204},{58.4,44.7,202},{45.5,34.1,204},{43,27.8,204},{35,8.2,204},{67.8,52.6,204},{72,40.9,203},{56.7,27.1,204},{35.1,10.1,204},{56.5,50,204},{40.5,19.5,204},{59.6,72.2,204},{55,10.8,204},{50.2,46,204},{44.4,76.5,204},{71.1,13.1,204},{58,45.1,204},{58,45.4,201},{48.9,13.1,204},{34.9,12.5,204},{39.7,32.5,204},{58.4,43.1,204},{57.5,44.7,201},{44.6,15.9,204},{44.9,49.8,204},{52.1,16.9,204},{58.9,71.3,204},{35.4,13.9,204},{48.9,58.5,204},{41.6,27.4,204},{47.9,23.1,204},{48.1,37.6,204},{65,16.1,204},{45.5,15.4,204},{58.5,72,204},{53.5,84.9,204},{60,61,204},{35.2,14,204},{57.6,56.1,204},{48.1,68.4,204},{54,48.9,204},{44.3,26.5,204},{56.8,53.1,204},{49.9,41.2,204},{63.7,42.1,204},{54.4,30.8,204},{58.6,70.9,204},{76.7,20.3,204},{57.1,41.2,204},{41,15.9,202},{43.9,27.5,204},{46.8,51.4,204},{79.9,23.7,204},{49.9,63.9,204},{67.7,29.8,204},{47.7,16.8,201},{54.6,30,204},{53.9,23.4,204},{46.1,51.3,204},{41.4,80.2,204},{57,71,204},{44,82.2,204},{57.6,33,204},{49.5,24.6,204},{65.9,61.3,204},{48,33.5,204},{64.1,26.9,204},{63.3,82.5,204},},["Herbalism"]={{60.4,64.7,408},{54.2,55.5,404},{51.5,69.4,405},{49.2,36.3,405},{79.1,24.8,407},{46.1,32.5,403},{39.7,16.5,402},{50.3,27.5,402},{59.5,65.2,401},{69.8,42.8,412},{61,60.2,408},{64.4,11.8,404},{46,77.5,405},{46.3,54.7,408},{47.1,28.6,404},{65,76.3,405},{73.4,35.3,402},{56.6,22.1,401},{63.1,11.7,404},{77.2,38.8,412},{47.7,18.8,402},{55.4,40.1,402},{48.9,27.5,402},{76.8,13.6,407},{56.8,60.9,405},{59.9,15.5,401},{52.2,30,403},{45.6,83.3,401},{50.6,80,405},{35.6,16,404},{49.8,43,403},{48.6,19.3,402},{56.3,12.8,401},{49.3,57.5,408},{54.7,13.1,401},{54.7,14.7,402},{63.8,61.1,408},{59.2,67.1,408},{58.1,34.7,404},{39.7,72.6,407},{34.9,48.1,407},{35.5,29.2,407},{49.6,72.6,401},{79.4,37.2,412},{67.1,40.6,407},{47.6,69.1,408},{55.6,66,405},{57.4,8.8,402},{48.2,19.2,402},{51.3,58.8,401},{41.9,31.2,402},{47.4,27.1,403},{48.9,46.7,408},{61.6,13.4,401},{60.4,66.7,408},{38.8,28.2,401},{62.3,62.3,408},{64.6,37.1,407},{69.5,81,408},{61.1,62.1,408},{53.8,77.2,405},{78.3,31.5,407},{62.6,81.7,402},{69.4,82.2,408},{77.5,39.4,412},{58.7,16.3,401},{55.6,37.1,404},{64.4,55.5,408},{47.5,33.9,404},{52.1,18.8,402},{45.6,18.5,402},{46,30.3,403},{60.5,13.6,404},{68.5,30.3,404},{47.4,20.1,401},{53.1,70,404},{48.2,21.8,402},{56.2,29.4,404},{51.9,17.4,402},{55.7,31.6,404},{64.9,57,408},{42.7,70.6,404},{45.7,68.6,408},{55.2,63.2,401},{43,19.4,402},{65.9,12.5,404},{56.3,59.2,405},{64.3,80.7,403},{50.1,77.8,405},{64.3,59.3,408},{44.8,27.4,402},{50.9,39.4,405},{46.2,68,408},{44.7,16.3,402},{59.2,8.7,402},{38.2,26.2,401},{33.4,16.4,404},{50,56.5,408},{47.3,27.1,403},{54.9,68.3,401},{44.9,52.4,405},{64.4,5.7,402},{55.2,22.5,402},{60.5,65.4,408},{50.2,45,403},{66.6,8.4,402},{54.6,77.2,405},{39.7,24.4,402},{40.5,22.9,402},{50,74.1,405},{69.5,42.9,412},{52.6,64.6,405},{42,17.1,404},{44.5,49.1,405},{55.6,66.9,405},{55.2,63.1,401},{48.3,57.4,408},{62.1,61.3,408},{53.3,77.1,405},{48.7,29.1,404},{54.8,25.6,402},{54,44.2,405},{53.6,55.9,401},{52.1,16.5,402},{47,69.1,408},{47,30.6,404},{68.4,8.9,404},{47.7,45.8,408},{63.4,56,403},{56.5,24.1,404},{43.5,79.1,401},{71.4,40.6,407},{53,73.7,404},{56.4,16.2,404},{79,36.9,412},{62.5,8.4,402},{80.8,35.3,412},{72.4,42.6,412},{50.6,30,403},{54.7,46,403},{57.4,17.1,404},{66.5,48,401},{74.9,41.2,412},{60.3,60.7,408},{51.5,34.8,405},{39.3,17.6,402},{48.4,75.9,405},{49.9,81.6,404},{34.7,26.8,407},{62.1,11.5,402},{54,48.4,403},{50.9,20,402},{52,74.3,401},{52.4,56.7,405},{61.2,8.8,402},{66.1,77.3,405},{46.2,53.9,408},{45.8,68.8,408},{72.7,13.1,407},{77.1,39.1,412},{76.8,19.3,407},{39.6,29.8,401},{77.9,26.9,402},{38.9,21,402},{51.8,57.4,405},{47.2,21.7,402},{76,20,407},{51.8,62.2,401},{45.7,68.9,408},{54.5,28.5,404},{60.6,66.7,408},{65.9,54,401},{78.7,31.8,407},{49.5,18.4,404},{54.8,19.6,402},{56.3,8.2,402},{35.6,37.4,407},{74.9,38.2,407},{41.1,74.4,407},{46.3,68.2,408},{53.2,35.4,404},{63.9,56.9,408},{83.2,32.2,412},{44.2,24.1,402},{46.3,50.9,408},{55.1,35.8,404},{47,55.6,408},{74.3,41.2,412},{65.2,46.8,403},{72.7,42.7,412},{64.6,5.8,402},{44.4,31.1,402},{56.6,35.6,404},{45.5,25.8,404},{51.1,21.2,402},{55.5,60.2,405},{57.8,14.4,401},{58.2,11.4,401},{76.8,39.4,412},{63.8,55.8,408},{56.1,20.7,404},{46.8,33.5,405},{80.8,34.7,412},{42.2,29.5,402},{56.4,53.5,405},{46.9,51.4,408},{47.2,25,401},{72.5,42.9,412},{64.2,58,408},{60.2,74.1,402},{63.9,60.8,408},{67.1,84.6,408},{62.6,74.4,401},{52.5,76.3,401},{36.2,19.9,402},{61.9,61.1,408},{64,61.5,408},{60.9,62,408},{57.3,78,405},{59.9,66.1,408},{61.9,62.2,408},{53.7,37,404},{56.7,25.3,404},{52.9,34.2,404},{63.1,79.2,405},{62.2,62.4,408},{52,57.1,405},{62,62.3,408},{58.2,9.6,402},{52,20.2,401},{59.4,66.5,408},{59.7,67,408},{48.6,31.5,402},{59.9,67.1,408},{69.2,8.3,402},{46.7,67.4,408},{45.8,68.1,408},{47,68.2,408},{51.4,49.7,403},{47.4,71,408},{71.3,78.1,408},{50,68,405},{67.3,84.7,408},{45.5,27.9,404},{60.4,76.4,405},{49.9,81.5,404},{53.4,41.5,405},{54.2,27.7,403},{49.1,33.6,405},{59.9,9.8,401},{42.1,21.4,401},{61.3,79.5,401},{43.5,51.6,405},{54.7,71,405},{45.3,30.8,404},{52.2,11.9,402},{62,75.5,405},{40.8,25.1,402},{57.1,10.9,402},{53.3,84.9,403},{56.7,18.6,401},{59.8,62.2,408},{77.4,19.9,407},{45.2,80.1,404},{59.7,16.7,404},{73,17.2,404},{56.1,19.4,404},{56.7,23.2,404},{49,31.2,405},{52.6,29.2,404},{44.2,18.5,402},{55.1,35.1,404},{53.3,22.7,402},{64.6,53.3,403},{47.6,55.3,408},},["Fishing"]={{64.1,12.3,108},{64.1,34.6,108},{56.8,18.9,108},{66.8,37.9,108},{57.7,31.1,108},{41.1,71.5,107},{32.4,16,107},{35,20,107},{38.2,33.2,107},{60.6,17.4,108},{37,30.3,107},{59.6,33.4,108},{35.5,24.1,107},{58.9,34.6,108},{73.4,41.1,106},{66.8,10.7,108},{70.7,9.1,108},{64.8,35.8,108},{83,31.2,106},{58.9,33.8,108},{60.1,34.1,108},{35.6,23,107},{81.9,32.9,106},{57.2,21.4,108},{79,35.7,106},{76.7,38.9,106},{37.8,32,107},{42,77.2,107},{75.9,40.4,106},{42.2,75.9,107},{61.9,14.4,108},{36.9,28.6,107},{72.4,42.1,106},{56.7,26.2,108},{71.1,42.7,106},{38.2,34.5,107},{37.6,30.3,107},{60.3,36.5,108},{32.2,18.3,107},{63.7,33.8,108},{32.6,16.6,107},{75.1,40.7,106},{36.4,27.3,107},{59.7,35.3,108},},},
["Eastern Plaguelands"]={["Mining"]={},["Herbalism"]={{58.1,80.8,426},{57.7,81.8,426},{33.4,65.7,426},{62.2,77,426},{50.4,66.4,426},{53.8,50.6,428},{66,59.1,426},{64.5,61.4,428},{67.5,49.3,426},{72.9,72.8,426},{46.1,40.5,426},{29.1,67.6,426},{48.7,39,428},{64.7,61.7,428},{45.2,33,425},{60.9,29.3,427},{51.3,77.6,428},{82.6,84.8,425},{50.1,40,426},{47,33,425},{59.6,48.5,428},{29,39.1,426},{37.2,87.9,426},{87.5,87.6,425},{83.7,88.8,427},{63,85.6,428},{52.6,78.2,428},{53,57.4,421},{51.1,69.8,421},{53,79.3,428},{71.7,18.6,425},{67.1,66.3,426},{40.4,76.6,425},{57.9,25.9,425},{46.4,38.5,426},{65.1,39.8,426},{35.2,37.6,428},{43.3,53.4,427},{64,22.9,425},{37.5,52.5,428},{82.3,43.4,428},{39.2,29.9,431},{66.6,81.3,426},{62,47.2,421},{30,70.5,421},{16.4,64.6,428},{83.8,44.8,428},{40.5,76.2,425},{30.9,67.3,426},{77.2,54.8,426},{29.2,65.3,426},{47.4,25.5,426},{52.7,54.5,426},{28.4,43.8,427},{72.6,31.9,428},{71.4,15.7,428},{72.5,56.1,428},{63.3,52.6,425},{73.6,68.7,426},{62.2,61.9,421},{59.5,58.7,428},{52.6,54.6,426},{17.9,33,426},{67.1,48.6,425},{63.6,23.9,425},{40.4,76.3,425},{65.9,40.4,421},{31,71.7,421},{63.2,31.3,428},{46.3,40.7,426},{48.6,83.4,421},{57.4,56.9,426},{72.3,40.8,421},{74.2,76.5,428},{60.8,70.5,425},{86.7,82,426},{55.8,63.6,428},{76.1,53.9,426},{13.8,63.4,428},{59.6,67.1,431},{87.8,82.8,431},{27.8,73.9,428},{65.3,27.7,426},{50.3,66.4,426},{49.5,44.9,428},{41.6,40.1,425},{63.3,53.6,425},{22.6,26.6,428},{63.6,75.7,426},{51.7,55.1,426},{37.3,54.3,428},{24.1,36.3,421},{42.6,72.6,428},{55.1,24.3,428},{67.7,79.9,428},{40.5,52.1,428},{66.9,72.3,426},{28.4,86.8,425},{49.3,54.7,428},{64.2,68,428},{57.7,53.8,428},{18.3,28.9,421},{60.7,71.1,425},{38.7,93,425},{22.8,85.7,428},{71.4,15.6,428},{78.6,50.9,427},{18.3,32.5,425},{32.2,83.6,428},{53.7,43.6,428},{17.5,78.5,428},{38.9,34.2,431},{29.7,72.4,426},{76.6,49.9,431},{83.5,85.7,425},{36.4,23.8,428},{76.6,67.7,428},{26.7,29.7,431},{70.8,30.7,431},{37.4,52.3,428},{50.2,61.1,428},{40.2,31.7,431},{82.3,40.6,428},{82.3,42.2,428},{86,46.5,431},{39.8,25.1,431},{84.9,85.1,426},{41.3,40.7,425},{42.4,50.6,431},{69.6,74.4,426},{25.7,37.5,428},{55.4,57.6,421},{72.3,56.2,428},{82.2,65.3,427},{48.5,82.9,421},{84.5,38.5,428},{18.8,31.1,421},{74.9,53.3,431},{59.7,67.7,431},{60.1,68.2,431},{54.5,69.4,431},{18.6,30.4,421},{55,57.5,421},{62,81.3,431},{37,85.1,426},{28.2,86.2,425},{21.5,82.4,426},{69.9,50.1,426},{26.5,86.2,431},{51.8,79.5,428},{35.4,58.7,428},{72.3,17.2,428},{69.2,19,428},{38.2,25.3,428},{32.2,83.4,428},{57.5,19.6,428},{79.2,61.9,426},{31,67.1,426},{61.5,23.5,428},{36.5,23.8,428},{24.3,37.1,421},{48.3,70.8,428},{14.3,62.4,426},{24.5,24.1,428},{70.1,80.7,428},{55.4,24.4,428},{77.7,51.9,425},{55.5,25.1,428},{69.3,19.1,428},{31.9,83.4,426},{28,25.4,428},{38.6,25.6,428},{62.7,86.3,428},{72.7,30.6,425},{85.7,83,425},{46.6,26.1,428},{81.8,79.1,426},{14,64.6,426},{20.7,70,428},{85.6,82.6,425},{78,74.5,427},{22.6,26.3,428},{47.7,85.4,421},{45.8,39,428},{83.7,85.9,425},{32.6,72.4,426},{41.2,26.6,428},{63.8,24,425},{46.2,26.9,428},{66.3,27.1,428},{35.4,27.5,428},{18.2,32.6,425},{66.3,27.9,428},{60.6,72.2,425},{66.4,31.6,421},{52,29.9,428},{65.8,36.8,428},{48.3,30.1,428},{74.3,31.7,428},{67.5,49,425},{16.4,32.4,428},{84.3,80.6,425},{85.8,83.4,425},{54.7,33.4,428},{62.4,47.6,421},{67.3,33.7,428},{47,33.6,425},{41.7,35.2,428},{41.3,35.3,428},{24.3,37.6,421},{49.4,25.6,426},{75.8,54.1,426},{21.3,36.2,428},{21.5,36.5,428},{62.4,37.4,428},{52,30,428},{67.7,81.9,428},{25.4,37.2,428},{85.3,41.2,428},{52.7,54.3,426},{79.5,60.4,428},{47.7,84.3,421},{57.7,60.1,427},{54.2,75.5,426},{25.6,37.2,428},{53.1,57,426},{46.9,39.8,421},{66.1,37.5,428},{13.4,64.5,428},{76.4,52.3,431},{18,33.1,426},{52.8,38,428},{52.6,54.4,426},{62.2,38,428},{46.5,62.7,421},{41.6,35.2,428},{58.3,65.8,421},{62.5,85.4,428},{55.7,79.6,428},{22.6,33.2,425},{78.2,84.9,427},{69.4,15.7,425},{26.8,63.7,428},{70.6,38.2,428},{41.1,46.8,427},{84.6,86.4,425},{61.3,69.7,425},{56.7,75.7,421},{84.6,38.4,428},{37.1,87.6,426},{50.9,27,426},{70.9,38.5,428},{45,38.6,428},{61.6,23.9,428},{75,76.4,428},{52.3,39,428},{34,84.6,426},{26.9,39.6,428},{17.8,64.2,428},{31.5,40.6,428},{64.6,41.5,428},{85.6,41.5,428},{69.3,41.9,428},{18.7,30,421},{49.2,43.1,428},{63.2,22.9,421},{49.1,44,428},{87,44,428},{69.2,19.1,428},{56.7,46.1,428},{71.8,72.7,426},{39.7,83.3,428},{41.7,49.8,428},{61.6,50.4,428},{41.6,50.5,428},{53.7,51,428},{67.9,49,425},{38,52.2,428},{69.8,30.7,431},{37.6,52.4,428},{52.6,39.9,428},{42.1,75.5,428},{17.9,33.2,426},{49.4,54.1,428},{49.1,60.1,428},{33.5,40,421},{55.7,77.5,427},{64.9,69.6,428},{49.1,26.4,421},{35.6,58.5,428},{44.4,67.3,428},{87.1,79.9,427},{70.5,15.4,428},{54.2,59,428},{49.7,59.1,428},{54.6,59.1,428},{59.4,59.7,428},{49.1,60.9,428},{55.4,63.3,428},{26.1,63.3,428},{29.2,68.9,428},{30,38.8,426},{41.3,40.6,425},{62.7,35.9,421},{38.6,38.2,428},{38.6,53.7,428},{84.4,84.8,426},{55.4,29.6,426},{64.7,56.4,426},{78.7,65,426},{69.5,65.3,428},{71.4,69.4,426},{16.4,65.5,428},{15.8,65.9,426},{46.2,67,428},{37.9,67.5,428},{49.2,84,421},{83.6,85.9,425},{46.1,77,421},{31.4,68.3,428},{31.8,68.4,428},{37.9,69,428},{61.4,69.7,425},{28.9,69.3,428},{35.8,58.1,428},{75.5,47.4,427},{55.6,79.6,428},{73.2,71.3,428},{37.9,70.3,428},{67.1,61.1,427},{66.3,36.4,426},{73.7,71.4,428},{42.2,72.3,428},{19.3,33.8,421},{19.7,25.7,426},{32.4,73.9,428},{63.2,52.9,425},{34.7,74.2,428},{36.9,50.9,427},{60.9,74.3,428},{38.4,67.3,426},{51.6,63.5,426},{68.8,74.4,428},{26.4,75.6,425},{72.5,38.8,421},{42.7,76,428},{49.2,70.4,421},{59.5,64.9,421},{22.5,33.2,425},{17.7,36,427},{61.8,75.3,428},{55.8,43.2,427},{72.2,82.3,426},{84.1,38.2,428},{20.7,34.1,426},{61.1,47.1,421},{33,74.5,426},{43.5,37.8,426},{84.4,84.9,426},{49.6,39.1,426},{32.6,72.3,426},{27.6,85.2,431},{42.5,64.2,426},{84.3,86.1,425},{46.5,38.5,426},{70.4,80.9,428},{40,71.6,426},{45.3,80.7,428},{45.2,80.9,428},{43.1,82.1,428},{59.8,48.9,428},{69,36.1,426},{33.5,84.5,426},{54.4,33.4,428},{27.1,84.1,428},{28.9,39,426},{30.6,70.4,421},{45.5,75.7,421},{64.7,42,428},{55.9,57.8,421},{39.3,71.1,421},{61.8,62.3,421},{62.4,36.7,421},{24.1,19.3,427},{56.2,25.9,427},{38.6,67.3,426},{77.6,51.8,425},{38.4,38.4,428},{27.3,84.2,428},{47,39.5,421},{70.3,45.5,428},{48.1,38.2,428},{82,70.5,427},{84.1,80.4,425},{16.2,65,428},{22.3,60.2,427},{38,54.9,428},{34.9,74.1,426},{21.5,79.6,428},{31,62.1,427},{58.8,74.1,421},{38.8,93,425},{49.3,25.7,426},{53.4,43.1,428},{80.4,55.3,427},{70.6,68.1,426},{81.4,59.1,426},{51.4,78.1,428},{19.6,77.8,426},{71.3,36.7,426},{33.6,40.5,421},{17.6,64.8,428},{64.8,69.1,428},{71.5,36.8,426},{22.4,85.2,428},{71.3,18.6,425},{63.8,38.1,421},{69.7,55.8,426},{19.7,34.9,421},{66.8,42.7,426},{67.3,49.4,426},{47.5,39.4,421},{39.8,66.6,426},{62.4,38.8,428},{69.5,58.8,426},{49.7,78.5,426},{55.5,79.6,428},{27.7,25.7,428},{82.6,84.3,425},{57.4,21.2,428},{61.6,47.6,421},},["Fishing"]={},},
["Hillsbrad Foothills"]={["Mining"]={{21.8,40.9,204},{83.1,32.1,203},{88.6,35.3,203},{36.4,53.7,204},{59.7,33.5,204},{25.2,36.9,204},{41.7,6.6,208},{72.3,18,204},{36.2,28.4,202},{41.3,8,203},{18,49.9,204},{42.3,14,208},{8.7,48.9,204},{21.5,30.7,203},{62.9,74.8,204},{18.3,43.4,201},{34.4,19.7,202},{74,70.8,203},{58.2,57.1,202},{88.1,30.9,203},{32.7,56.7,204},{44.8,33.8,204},{53.8,28,204},{50.9,29.4,204},{38,24.9,202},{90.5,39.3,203},{41.4,6,203},{70.1,43.6,204},{37.6,26.1,204},{84.7,46,204},{78.9,28,204},{65.2,31.8,204},{39.7,27.5,203},{35.6,8.2,202},{47.6,35.5,201},{28.4,57.2,204},{62.3,12,204},{30.6,58.4,204},{75.9,49,204},{18.9,19.5,204},{36.1,15.8,203},{38,18.2,202},{43.9,28.3,203},{24.2,32.4,201},{40.2,24.5,203},{45.4,27,204},{28.2,57,204},{58,11.9,204},{42.1,11.4,208},{44.8,33.7,202},{88.7,37.7,203},{20.9,26.3,202},{41.1,20.3,203},{12,21,204},{34.8,19.8,203},{59.1,42,204},{88.7,31,203},{71.8,16.3,204},{32,53.3,204},{42.7,3.1,208},{44.7,12.1,203},{31.8,51.6,204},{30.4,53,204},{28.1,51.1,204},{35.6,26.2,203},{68.2,65.6,204},{31.4,54,202},{28.4,55,202},{17.1,56.3,204},{59.3,70.3,204},{28.7,55.8,202},{30.1,56.4,202},{66.9,83.1,203},{27,57.9,204},{33.7,23.2,203},{70.4,66.2,204},{86.6,35.4,204},{30.8,58,204},{43.1,26.1,203},{32.7,27,204},{70.6,54.8,204},{43.5,26.7,203},{44.4,27.6,203},{45,27.6,203},{41.7,6.1,203},{75.9,23,204},{43.7,30.1,203},{44.9,30.5,203},{80.1,30.8,203},{40.7,25.2,203},{66.6,70,204},{40.3,7.4,208},{73.2,71.4,203},{16.5,12.3,202},{33.8,67.9,201},{75.5,72.9,203},{72.7,74,203},{67.4,82.3,203},{31.4,56.9,202},{39,36.7,204},{70.9,83.9,203},{41.9,3.1,208},{43,3.5,208},{49.5,4.2,203},{59.2,42.3,204},{49,4.7,203},{88.8,37.1,204},{15.3,53.7,204},{38.8,5.9,208},{38.5,63.8,204},{64.5,25.8,204},{47.7,6.3,203},{42.5,7,208},{41,53.6,204},{74.1,73.7,203},{59.9,47.9,204},{87.7,45,203},{7.9,45.4,204},{46.7,8.2,208},{29.8,72.7,201},{45,62.2,202},{79.8,8.2,203},{44.9,11.1,203},{43.8,13.2,203},{40.1,31.3,204},{53.3,13.3,204},{40,19.4,203},{71.2,57.1,204},{41.4,25.9,203},{43.9,65.8,204},{69.9,38.3,204},{41.2,12.9,203},{63,9.6,202},{40.9,63.4,202},{56.9,8.5,204},{61.1,73.1,202},{78.8,62,204},{47.7,22.1,203},{40.3,20.2,203},{85.4,41.8,204},{66.6,9.9,204},{26.2,31.8,204},{32.7,22.5,203},{68,8.3,202},{64.7,11.5,202},{64.1,55.2,204},{35.8,15.2,202},{64,51.7,204},{66.6,14.7,204},{40.7,53.4,204},{72.1,33,204},{68.5,37.7,204},{13.5,79.2,204},{23.8,39.2,201},{43.1,27.7,203},{70.8,32.7,204},{67.2,86.3,203},{64.2,76.7,204},{64.7,15.3,204},{21.6,27.4,202},{67.3,87.1,204},{33.8,24.8,203},{85.1,42.1,204},{23.7,60.6,204},{32.4,65.6,204},{67.6,62,202},{18,52.2,204},{59.5,13.4,202},{20.4,20.7,202},{54.9,23.7,204},{54.6,19.8,204},{69.9,42.7,202},{65,47.8,204},{41.8,7.2,203},{34.5,26.2,203},{70,29.2,204},{53.4,16.5,204},{66.8,30.3,204},{37.1,5.4,203},{32.2,55.6,202},{48.9,26.5,204},{81.1,39.6,204},},["Herbalism"]={{66.2,10.2,408},{64.2,12.6,408},{27.7,18.2,413},{57.7,1.6,415},{63,35.4,411},{62.6,73.3,409},{13.8,51.8,408},{28.4,42.5,408},{66.4,66.1,411},{25.7,42.5,405},{64.8,54.1,408},{70.9,57,408},{57.5,23.2,404},{88.7,37,409},{88.2,24.8,409},{66.6,69.6,408},{42.1,11.5,416},{86.3,34.5,409},{69.3,39.1,409},{56.6,47.8,412},{70.4,23.9,405},{34.4,53.8,404},{29.4,39.7,408},{36.7,54.8,408},{79.5,45.7,408},{64.2,75.1,409},{54.6,52.3,404},{22.3,40.9,408},{7.7,47.8,402},{44.1,49.8,408},{67.1,32.6,412},{42.3,30.5,415},{36,60.7,411},{43.7,54,404},{19.7,43.3,405},{37.3,32.7,411},{71.2,55,408},{43.3,28.8,411},{41.7,56.6,404},{28.7,40.5,408},{32.5,53.9,404},{26.4,18.1,411},{57.4,25.4,404},{71.2,29.3,408},{43.2,8.6,416},{33.8,60.9,411},{45.8,28.5,415},{26.9,54.4,408},{46.6,4,416},{30.7,30.1,411},{52.3,29.3,408},{78.7,2.2,412},{57.6,73.8,407},{77.8,74.4,415},{36.6,58.9,405},{37,24.2,415},{64,53.9,409},{51.4,43.2,405},{40.6,10.3,416},{26.4,20.5,413},{43.7,30.4,415},{6,45,401},{32.9,27.2,408},{19.1,43.2,408},{44,75.5,407},{38.8,51.2,411},{69.2,63.2,408},{42.6,66.2,408},{68.4,69.5,411},{68.1,32.4,412},{48.5,50.9,408},{28.6,57.7,405},{7.7,38.3,401},{45,63.6,408},{28,24.2,408},{51.5,5.6,414},{66.7,56,411},{75.5,29.5,405},{17.6,54.6,408},{77.4,40.6,408},{75.1,19.8,409},{42.7,30.5,415},{78.1,28,408},{44.1,48.6,408},{52.1,9.7,411},{60.5,61.2,411},{39.6,39.8,408},{53.6,75.8,407},{71.6,40.5,405},{63.9,51.8,408},{9.4,20.5,408},{63.5,54.4,408},{52.7,86.5,407},{26.5,39.6,411},{71.4,60,411},{22.1,53.1,405},{76.4,28.9,409},{85.9,36.8,405},{17.9,67.6,407},{47.3,45.3,405},{38.5,69.7,407},{65.2,80.7,407},{33.3,60.9,411},{19.7,16.4,408},{85.8,42.3,405},{47.1,72.8,407},{57.4,22.6,404},{41.1,38.8,408},{59.3,46,412},{44.3,35.5,405},{75.7,52.7,405},{27.5,21,413},{42,39.6,405},{50.8,33.1,411},{68.8,27.2,412},{69.9,64.4,408},{73.3,31.5,408},{20.8,21.1,413},{39.3,69.8,407},{76.4,4.8,412},{58.4,44.9,412},{60.2,87.7,407},{51.5,14.6,411},{68.7,22.5,412},{69,36.6,405},{25.7,23.4,408},{74,71.8,409},{64,14.2,408},{58.3,14,405},{81.6,33.9,411},{63.2,54.7,405},{66.3,38.7,412},{44,67.9,407},{44,55.6,404},{58.5,57.6,408},{68.4,56,408},{74.9,59.5,405},{47.8,4,416},{28.8,68.9,405},{42.4,12.1,416},{47.3,78.4,407},{70.3,85.8,409},{39.7,39.1,408},{12,11.5,401},{33.4,28.4,408},{43.8,46.2,408},{43.1,3.7,416},{41.2,59.5,408},{13.6,51.7,408},{68.7,69.5,411},{79,30,408},{33.7,63.6,411},{31,62,405},{73.6,5.4,412},{8.4,44.6,405},{38.1,62.1,408},{43,1.2,416},{52.8,1.8,414},{58.1,2.2,414},{60.1,9.9,411},{59.1,4.1,411},{69.6,56.3,408},{65.1,18.7,405},{23.6,64.8,407},{56.2,65.6,407},{6.9,39.7,405},{46.2,65.9,407},{9.5,21.3,408},{12.2,42,405},{46.1,68.1,407},{76.8,32.6,411},{34.1,69.4,407},{42.1,69.4,407},{66.9,35.8,412},{29.6,33.7,405},{33.2,72.2,407},{52.7,34.5,405},{68.4,57,408},{39.3,71.1,407},{37.2,62.9,408},{70.3,41.9,409},{37.4,53.3,408},{55.6,69.4,407},{75.6,3,412},{24.2,21.4,408},{29.7,66.2,411},{33.9,69.9,407},{72.5,14.7,409},{41,41,408},{54.9,18.5,405},{53,29.3,408},{9.8,16.8,408},{41.2,33.8,408},{48.5,70.7,407},{82.4,48.9,405},{35,70.9,407},{17.2,55.7,408},{29.7,21,411},{19.7,15.3,408},{59.8,0.9,411},{20.8,71,407},{58.1,71.2,407},{57.4,56.7,408},{50.4,72.3,407},{41.1,73.6,407},{31.9,74.1,407},{40,75.6,407},{50,75.8,407},{27.5,54.9,408},{38.8,55.9,411},{34.8,76.4,407},{20.7,78,407},{63.6,78.3,407},{25.2,33.3,408},{30.5,79.3,407},{21.5,19.5,413},{40.7,40,408},{64.6,74.3,405},{10,46.5,403},{63,82.1,407},{50.7,80.9,407},{46.8,54.4,405},{54,83.2,407},{68.6,85.2,407},{68.9,85.4,407},{71.4,30.4,409},{24.4,33.7,408},{66.4,85.9,407},{66.6,86.7,407},{56.1,87.7,407},{66.3,89.8,407},{64.2,91.3,407},{54.8,91.4,407},{57.2,52.6,408},{53.8,21.2,409},{64.8,9.9,408},{65.4,94.7,407},{68.4,97.4,407},{29.5,39.4,408},{48.5,0.5,416},{72.8,20.7,408},{37.5,61.2,408},{34.9,16.1,411},{52.9,0.5,414},{44.3,4,416},{54.4,4.6,413},{46.2,6.5,416},{41.1,32.8,408},{43.4,8.4,416},{72.3,9,412},{67.7,84.5,409},{44.4,46.4,408},{76.1,68.1,405},{71.9,51.7,411},{27.7,55.7,408},{41.9,10.4,416},{57.3,2.3,415},{26.7,44.6,411},{35.9,12.5,415},{40.6,20.9,415},{45.8,29.5,415},{42.3,30.4,415},{28.6,41,408},{61.7,44.2,412},{78.1,74.7,415},{69.5,66.3,409},{60.3,70.2,409},{81,30.7,408},{62.6,63.8,405},{78.5,77.9,415},{68.7,7.9,408},{71.4,28.2,408},{79.1,78.5,415},{67.6,21.1,412},{88.4,30.2,409},{41.4,67.2,408},{35.6,69.3,407},{34.5,18.4,413},{48.3,80.8,407},{34.1,29.1,408},{42.5,52,404},{67.6,17,412},{53.3,4.8,413},{76.5,57.3,411},{67.5,29.4,412},{66.6,35.7,412},{82.3,48.4,405},{24.5,38.9,408},{65.8,37.5,412},{63.9,38.9,412},{23.5,55.6,411},{77.3,27.6,408},{64.1,39.1,412},{77.3,74.1,415},{64.3,30.2,409},{16.6,48.5,408},{59.2,46.1,412},{57.7,52.5,408},{27.5,63.4,405},{79.9,78.5,414},{37,56.6,408},{45.2,40.9,405},{40.7,67.1,408},{58.3,28.9,411},{58.8,59.2,405},{58.1,2.8,414},{26.7,31.2,408},{80.2,34.3,405},{39.3,67.4,408},{44.7,62.5,408},{39.7,38.2,408},{43.5,0.9,416},{66.1,68.3,405},{36.9,21.1,411},{52.2,24.8,411},{66,68.8,408},{35.3,35.8,405},{39.4,21.6,411},{71.1,28.8,408},{10.9,40.7,405},{9.9,18.4,408},{73.5,27.5,411},{37.9,57.1,405},{27.2,18.3,413},{29.3,42,408},{19.7,15,408},{30.8,40.3,408},{28.8,57.4,405},{40,9.5,416},{46.5,36.5,411},{69.3,37.6,409},{71.6,37,411},{43.7,53.9,404},{43.4,39.2,411},{76.7,40.1,408},{29.6,54,411},{69.3,51.1,411},{25,51.6,404},{45.5,56.2,411},{81.2,52.1,411},{46.3,7.7,416},{31,57.7,411},{69.6,57,408},{58.5,17.8,404},{67.7,26.1,412},{9.2,20.9,408},{19,50.2,408},{23.8,61.1,408},{70.9,65.5,408},{41.9,59.7,408},{36.8,53.4,408},{24,53.1,404},{52.6,83.1,407},{35.1,10.5,413},{16.7,53.8,408},{43.1,0.8,416},{57.6,92.1,407},{69.9,56.1,408},{65.8,14.7,408},{71.1,56.4,409},{25.7,22.2,408},{77.4,75,415},{20.9,41.3,408},{17.5,54.9,408},{71,64.6,408},{67,5.5,408},{68.7,63.2,408},{39.8,41,408},{69.1,63.7,408},{79.2,27.8,408},{30.7,39.9,408},{14.7,80.8,409},{76.6,40.1,408},{32.9,67.1,405},{43.6,63.3,408},{29.8,73.2,405},{10.8,15.4,408},{40.8,38.3,408},{44.4,34,408},{32.3,57.4,405},{10.1,13.5,408},{47.8,64.7,407},{16.7,47,408},},["Fishing"]={{55.1,60.8,107},{38,70.7,107},{51.1,62.5,107},{50.7,62.4,107},{55.7,56.6,108},{49.7,63.2,107},{43.9,68.8,107},{58.2,73.6,107},{60.8,34.1,108},{57.5,69.8,107},{68.2,20.4,108},{35.9,70.4,107},{46,67.2,107},{60.2,31.9,108},{59.4,75,107},{65,83.3,107},{64.3,79.9,107},{61.7,32.2,108},{69.6,13.3,108},{61.7,78,107},{22.8,64.9,107},{65.7,85.7,107},{42.3,70.4,107},{55.5,65.2,107},{68.5,16.7,108},{71.3,10.1,108},{67.5,35.4,108},{67.8,29.6,108},{67.7,87.9,107},{65.2,39.3,108},{60.5,30.3,108},{56.3,67.4,107},{68.5,26.3,108},{63.2,40.7,108},{34.4,70,107},{57.4,47.8,108},{40.1,70.7,107},{28.3,73.9,107},{56.3,50.9,108},{62.4,42.5,108},{24.3,68.3,107},},},
["The Hinterlands"]={["Mining"]={{50.1,71.6,208},{56.6,35.6,208},{27.1,69.6,208},{30.5,68.6,208},{77.3,56,208},{58.1,49.5,208},{35.5,74.8,208},{57.2,44.6,208},{51.6,65.8,208},{53.7,66,208},{60,89.5,203},{31.5,59,208},{71.7,66.2,208},{24.5,67,208},{60.7,57.9,208},{50.2,71,208},{39.8,43.8,208},{30.1,55,208},{63.1,40.8,208},{40.6,65.9,208},{47.4,70.6,208},{60.1,41.2,208},{25.6,65.8,208},{33.3,60.6,208},{64.2,40.7,208},{68.4,77,208},{68.9,72.3,208},{57.5,44.5,208},{62.3,72.5,208},{51.7,65.2,208},{56.7,42.5,208},{74,87.3,208},{57.7,40.6,208},{24.4,65.5,208},{40.2,67.5,208},{83,50.4,208},{72.2,52.4,208},{68.2,19.8,208},{52.5,64.9,208},{79.5,74,208},{67.9,55.5,208},{56.8,43.1,208},{31.3,59.4,208},{33.9,64.1,208},{41.4,57.3,208},{41,66.1,208},{49.8,65.3,208},{37.4,68.2,208},{60.3,88,203},{37.5,66.8,208},{57.9,19.6,208},{63.4,43.6,208},{56.9,43.7,208},{58.6,27.7,208},{41.1,59.2,208},{41.6,59.9,208},{55.5,44.9,208},{60.7,34.4,208},{64.2,36.6,208},{46.3,37.8,208},{59.6,43.7,208},{62.5,64.2,208},{58.6,41.7,208},{59,23.2,208},{5.1,67.3,203},{36.8,67.2,208},{25.1,68.8,208},{33.5,41.2,208},{46.9,33.4,208},{75.2,57.1,208},{79.4,50,208},{60.1,59.4,208},{59.7,57,208},{54.3,54.4,208},{4.6,67.3,203},{77.3,59.5,208},{23.3,59.8,208},{57.3,41.3,208},{50,48.2,208},{24.6,65.2,208},{55.5,55.7,208},{50.8,69.3,208},{40.6,59.6,208},},["Herbalism"]={{43.2,86.2,409},{66.5,41.4,412},{28.4,65.5,421},{51.5,43.2,421},{68,78.1,418},{21.9,56.1,421},{67.9,67,418},{31.6,69.7,414},{40.6,45.1,421},{29.1,58.5,414},{26.8,61.5,421},{52.1,38.7,415},{78.5,53.3,414},{27.9,66.6,421},{65.4,67.8,418},{47.8,70,418},{37.8,52.7,421},{74.9,47.4,412},{56.5,52.7,413},{47.7,70.1,418},{34.5,75.6,414},{75.6,51.9,415},{34.1,75,414},{45.7,68.2,425},{45.7,57.5,421},{36.2,73.3,418},{77.4,59.4,414},{75.5,54.7,425},{67.4,53.1,414},{44.4,62.8,421},{74.3,51.3,415},{63.9,47.1,415},{36.9,46,421},{45.1,64.1,414},{34.8,53.3,413},{48.2,48.1,414},{45.9,39.6,414},{45.1,58.2,421},{52.8,37.8,415},{67.7,49.5,425},{43.5,86.3,409},{64.9,33.6,425},{56.5,56.4,412},{37.6,51.3,421},{44.2,45.9,415},{57.6,42.8,418},{58.7,46.3,413},{27.6,69.6,414},{29.7,65.5,421},{60.2,39.7,415},{40.4,45.3,421},{31,66.9,418},{17.3,54.3,421},{76.2,56.5,425},{48.3,62.9,425},{41.5,64.3,415},{34.2,67.1,425},{65,52.7,414},{68.1,76.8,418},{49.7,54.3,418},{34.4,74.6,414},{72.7,52.6,414},{66.1,57.8,421},{52.7,36.3,412},{65.7,41.7,414},{68.4,70,418},{33.2,53.3,413},{53.4,42.4,421},{51.5,42.5,421},{66,47.2,421},{29.7,58,414},{33.9,62.9,414},{50.7,65.9,421},{31.4,64,413},{37.9,55.2,421},{27.4,54.3,413},{43.3,45.3,415},{26.2,55.2,421},{76.9,59.9,414},{32.3,58.1,418},{75,50.9,415},{45.9,39.5,414},{70.7,54.4,413},{74.1,50.9,415},{64.5,69.8,418},{66.4,53.1,414},{18.2,50.8,421},{27.4,69,414},{17.2,81.4,409},{49.5,63,418},{33.7,51.6,413},{63.2,51,415},{64.7,41.2,414},{50.2,53.6,414},{31.7,73.5,418},{78.8,53.3,414},{31.9,63.9,413},{65.4,52.1,414},{74.9,86.8,414},{18.4,54.3,421},{58.4,72.2,418},{71,46,415},{56.9,39.2,414},{45.7,64.3,414},{72.5,52.2,414},{67.9,45.9,421},{60.9,52.1,414},{56.3,45.8,421},{58.6,46.8,413},{63.6,51,415},{62.4,56.7,415},{62,65.2,418},{57,39.6,414},{61.6,52.3,414},{58.1,52.2,421},{29.4,64.7,421},{32.8,58,418},{37.6,71,414},{26.1,55,413},{28,65.3,421},{39.3,52.4,413},{75.6,56.5,414},{41,86.2,409},{67.9,74.2,418},{40.2,64.7,418},{63.2,39.7,412},{75.5,56.6,414},{50.2,40.7,425},{34.8,53.2,413},{23.9,59.2,418},{62.4,44.9,421},{36.5,46.9,421},{52.8,54.7,415},{72.3,48.1,412},{22.9,52.9,421},{67.2,53.1,414},{64.1,63.2,414},{63.4,60.8,412},{23.4,53.1,421},{66,66.8,418},{4.8,66.7,409},{41.2,46.9,421},{43,46,415},{74.7,86.4,414},{60.5,81.9,418},{44.8,42.8,425},{45.2,54.6,413},{31.7,58.2,418},{36.7,46.1,421},{36.5,58.9,421},{62.7,56.8,415},{31.1,68.8,414},{64.2,48.6,413},{54.6,55.2,414},{24.6,56.2,421},{38.4,44.6,425},{64.6,49.7,421},{70.3,54.7,413},{35.7,57.7,414},{69.1,69.5,418},{43.4,66.9,421},{62.2,73.4,418},{36.8,58.8,421},{66.2,19.3,425},{51.6,40.5,425},{22,52.6,421},{31.2,58.5,418},{63.9,44.3,425},{38.8,44.7,425},{67.7,47.9,425},{56.3,51,413},{53.3,55.1,425},{71.4,48.6,425},{76,55,425},{76.8,55,425},{71.6,48.3,425},{63.5,66.5,418},{24.9,58.4,425},{25.6,59.8,421},{53.5,55.4,425},{63.4,50.9,415},{40.9,49.9,421},{69.6,60.1,425},{57.7,38.1,412},{67.6,62.7,414},{38.7,60.4,425},{49.6,47.2,421},{69.7,60.5,425},{38.2,60.9,425},{27.2,64,413},{27.7,67.6,425},{34.4,67.7,425},{54,41.2,421},{21.7,57.3,421},{32,66.9,418},{18.1,51.4,421},{52.6,37.2,415},{54.4,42,421},{41.2,62.1,412},{56.2,44.3,421},{52.6,57.5,413},{26,54.3,413},{22.1,56.7,421},{43.4,44.9,415},{57.7,41.9,418},{71.3,60.4,421},{40.1,45.7,421},{37.7,54.5,421},{45.2,64.7,414},{46.4,54.7,421},{34.4,46.8,421},{41.8,46.9,421},{32.9,74.1,418},{53.8,47.2,421},{50.5,67.5,418},{4.7,62.2,409},{31.9,63.8,413},{61.8,48.8,421},{54.3,55.5,414},{58.9,49,421},{60.1,40,415},{45.8,69.1,414},{69.6,59.2,425},{31.8,61.9,413},{67.7,62.7,414},{52.4,50,421},{45.1,56,413},{68.4,51,421},{40.3,67.7,414},{30.2,73.2,414},{40.1,52.7,413},{61.1,54.8,421},{48.6,48.8,414},{63.8,66.6,418},{34.5,74.6,414},{34.5,61.5,421},{64.9,46.2,415},{50,52.2,418},{18.2,51,421},{75.6,51.1,421},{24.8,58.7,425},{48.8,62.5,425},{74.4,50.8,415},{57.6,37.6,412},{45,55,421},{68.6,57.7,421},{54.1,51.9,421},{63.8,43.1,414},{57,39.2,414},{35.4,51.6,421},{40.2,65.4,418},{18.8,51.6,421},{30.4,53.4,421},{52.5,58.1,413},{65.8,53.9,421},{66.5,64.7,418},{51,60.3,414},{48.2,54.6,421},{47,54.8,421},{66.8,52.5,414},{28.5,53.9,421},{30.2,43.6,412},{59.8,80.1,418},{56.2,52.1,413},{46.6,55.3,421},{30.2,43.5,412},{46.1,55.6,421},{57.4,63.8,418},{42.9,45.7,415},{40.1,45.2,421},{54.6,41.7,421},{67.1,62.2,414},{37.8,63.7,421},{31.3,63.4,421},{45.4,56.9,413},{49.5,62.9,421},{72,64.6,421},{48.8,68.9,418},{42,44.8,421},{63.4,43.5,414},{51.1,57.6,421},{41.8,45.3,421},{57.6,44.3,418},{33.9,53.1,413},{27.2,63.2,413},{48.8,55.5,421},{69.8,48.2,421},{22.7,57.5,418},{33.5,51.7,413},{55,55.9,414},{45.1,39.2,414},{46.8,36.5,412},{66.3,71.6,418},{65.4,64.8,418},{74.3,86.7,414},{65.8,68.1,418},{65.3,71.8,418},{58.2,56.1,412},{56.8,72.8,418},{46.3,51,421},{36.7,51.9,421},{64.7,82.9,418},{71.2,54,421},{56.5,39.4,414},{45.5,70,414},{75.3,49,415},{43.6,45.1,415},{62.3,69.4,418},{35.3,57.3,414},},["Fishing"]={},},
["Dun Morogh"]={["Mining"]={{51.7,43.9,201},{80.1,33.6,201},{78.9,53.5,201},{38.7,29.8,201},{41.3,33.4,201},{70.8,59.4,201},{82.5,55.7,201},{70.4,52.9,201},{42.9,44.9,201},{23.3,53.8,201},{70.4,55.1,201},{79.8,40.9,201},{43.6,50.7,201},{67,58.8,201},{68.9,57.3,201},{24.3,45.9,201},{56.1,53.4,201},{70.3,56.4,201},{33.5,30.7,201},{72.2,53,201},{41.3,29,201},{33,54.3,201},{62.5,47.1,201},{36.5,34.7,201},{68.9,52.9,201},{37.9,53.4,201},{27.1,34.8,201},{63.6,59.1,201},{70.6,52.1,201},{43.2,38.7,201},{61.2,57.5,201},{48.5,35.8,201},{76.3,53.5,201},{39.7,36.7,201},{42.1,36.8,201},{50,44.4,201},{38.9,37.9,201},{78.4,38.3,201},{82.4,39.3,201},{44.3,53.9,201},{57,61.4,201},{40.6,45.2,201},{66.6,59.7,201},{38.9,65,201},{49.9,57.7,201},{66.3,57.3,201},{70.6,54.1,201},{36,41.2,201},{50.3,62.9,201},{34.5,41.4,201},{72,49.6,201},{32.8,51.2,201},{68.4,60.7,201},{57.9,42,201},{42.3,46,201},{70.1,53.3,201},{71.6,55.4,201},{32,59,201},{42.8,63.5,201},{53.7,42.9,201},{64.9,51.4,201},{65.6,56,201},{45.2,45.1,201},{39,46.5,201},{39.3,47,201},{38,59.4,201},{81.6,51.3,201},{81.7,47,201},{42.9,47.3,201},{73.7,63.2,201},{23.6,52.1,201},{77.7,47.4,201},{75.1,52.3,201},{69.3,56.7,201},{42.3,48,201},{72.3,48.1,201},{39.8,68.1,201},{71.4,52.6,201},{52.5,58.3,201},{38.5,48.9,201},{67.5,61,201},{40.3,48.3,201},{38.9,48.7,201},{72.7,50.8,201},{41.7,52.6,201},{72.4,58.2,201},{80.9,57.7,201},{26.8,44.6,201},{37.6,54,201},{43.1,48.3,201},{40.8,49.4,201},{42.4,51,201},{43.1,61.3,201},{56.4,56.2,201},{42.2,49.6,201},{50,63.4,201},{58.8,56.5,201},{40.4,41.7,201},{43.9,49.9,201},{43.5,67.7,201},{53.4,50,201},{42.8,51.4,201},{71.2,57.3,201},{71.2,51.6,201},{73.5,53.7,201},{51.7,52.5,201},{23.4,51.2,201},{68.2,48.9,201},{72.1,53.5,201},{71.6,51.5,201},{40,33.1,201},{67,50.2,201},{21.4,51.8,201},{36,63.6,201},{78.2,57.9,201},{84.6,53.8,201},{72.4,52.5,201},{48.3,65.1,201},{71.2,62.6,201},{70.8,50.8,201},{73.1,51.5,201},{39.9,56,201},{75.6,59.2,201},{38.2,42.8,201},{21.2,54.7,201},{45.2,58.9,201},{42.5,34.2,201},{71.2,53.7,201},},["Herbalism"]={{35.5,57.5,403},{66.2,53.8,401},{32.1,55.6,402},{51.6,45.5,401},{74.6,55.1,402},{44.7,46.8,401},{44.4,58.2,401},{34.6,60.3,401},{72.1,49,402},{29.8,38.5,402},{44.4,57.4,402},{59.6,57.4,401},{73.8,51.2,401},{45.1,58.9,402},{36.8,60.9,401},{57.3,55.6,401},{27.9,40.2,402},{70.2,59.7,403},{48.8,58.6,401},{33.9,56.8,402},{79.7,57,401},{44,36.6,402},{33.5,32.7,401},{28.1,44.1,402},{29.3,39.1,401},{75.9,61.2,401},{26.5,45,402},{61.4,57.6,403},{39,61.1,401},{31.9,38.3,401},{63.4,59,402},{35.4,59.8,401},{49.6,57.7,403},{64.3,59.7,402},{57.1,57.9,402},{29.2,43.4,401},{44.5,31.4,402},{71.1,57.2,403},{27.6,54.5,401},{68.3,57.8,403},{40.3,59.6,402},{46.4,43,402},{42.2,56.9,401},{44.8,59.2,403},{37.3,35.5,401},{50.5,51.3,401},{69.4,56.9,403},{55.1,47.4,401},{76.1,47.8,403},{73.4,48.4,403},{31.7,57.3,402},{49,61.2,402},{70.5,50.1,403},{67.1,50.1,403},{68.7,50.4,403},{32.8,57.8,402},{74.5,52.1,403},{65.2,52.7,403},{61.6,53.1,403},{60.7,53.4,403},{64,53.4,403},{58.1,54.6,402},{72.9,53.4,403},{49.4,53.5,403},{28.8,47.9,402},{48.7,56.1,403},{47,62.9,402},{69.4,54.2,403},{59.1,54.9,403},{40.8,55.8,401},{49.2,63.9,403},{45.9,41.4,402},{66.4,54.9,403},{65.3,54.9,403},{29.5,44.7,402},{39.2,62,402},{78.9,56.9,402},{70.5,54.9,403},{69.6,55.1,403},{69.2,56.1,403},{63.9,56.3,403},{49.6,61.5,401},{72.6,56.5,403},{62.7,57.4,403},{58,57.5,403},{37,60.2,402},{72.9,54.6,401},{67.3,58.1,403},{57.9,58.7,403},{66.9,58.9,403},{70.7,59.3,403},{49.8,59.9,402},{47.7,59.5,403},{34.1,59.9,403},{66.8,60.4,403},{50,53.6,401},{63.6,55.3,402},{68.4,60.6,403},{37,61.6,403},{47.1,62,403},{46.1,63.7,401},{70.6,52.4,401},{39.4,62.5,403},{59,63,403},{48,62.6,401},{30.8,43.4,402},{47.3,43.2,402},{54.5,56.2,402},{29.8,55,402},{34.7,33.7,402},{38,60.3,402},{71,51.1,402},{48.2,64.2,402},{58.3,51,401},{28.4,37.3,402},{30.1,40.7,402},{45.4,50,401},{48.4,50,401},{43.9,33.5,402},{35.5,58.3,402},{33.9,35.8,401},{75.5,56.7,401},{27.6,37,401},{56.7,52.6,401},{69.3,51.7,402},{31.7,54.3,402},{47.8,44.7,402},{37.7,36.3,402},{69.5,50,402},{71.2,52.6,402},{29.2,53.9,402},{43.3,47,401},{25.9,42.2,401},{40.1,58,402},{29.1,45.2,401},{49.6,47.8,401},{46.2,40.1,402},{27.3,41.7,402},{50.2,45.7,401},{27.7,48.4,401},{39.3,59,402},{76.3,57,402},{48.1,55.5,401},{50.8,60.4,402},{38,33.4,402},{40.1,60.7,401},{66.3,51.1,401},{74.7,50.5,402},{56.3,61.3,402},{56.2,48.3,401},{54.3,57.5,401},{45.4,41.8,401},{61.9,55.3,402},{65.5,50.3,401},{29,48.6,401},{55.1,59,402},{46.8,41.2,402},{46.4,59.4,401},{29.8,51.7,401},{34.3,57.8,401},{28,42.2,401},{43.1,30.1,402},{49.4,63.3,402},{30.1,50.5,402},{74.2,55.2,401},{59,60.2,401},{45.3,56.6,402},{42.3,55.6,401},{45.6,58.1,402},{63,56,401},{43.9,56.7,402},{61.9,56.1,401},{73.4,56.1,402},},["Fishing"]={},},
["Searing Gorge"]={["Mining"]={{29.4,51.8,208},{52,49.5,206},{60.6,25.8,206},{84.8,76,208},{55.5,28,206},{26,61.5,208},{47.9,24.7,206},{31.3,39,208},{58.2,31.8,206},{42.5,35.2,208},{31.2,38.7,208},{55,51.2,206},{55.4,40.1,206},{43.7,65.6,208},{21.6,36.5,208},{73.7,81.9,206},{62.5,44.8,206},{22.8,55.7,208},{29.8,49.3,208},{30.3,65.8,208},{39.5,56.6,208},{33.5,22.9,208},{57.1,81.6,206},{64.7,32.6,206},{39.1,25.1,208},{57.5,68.4,206},{81.8,79.1,208},{56.9,66.9,206},{21.4,55,208},{25.8,60.2,208},{42.8,36.8,208},{39.8,62.7,208},{21.2,31.1,208},{38.6,67.4,208},{67.8,76.4,206},{85.7,75.9,208},{27.4,38.4,208},{73.2,82.9,206},{39.6,40.9,208},{39.4,56.2,208},{36.3,31.2,208},{39.8,25.5,208},{64.2,59.8,206},{67.4,57.8,206},{25.1,38.1,208},{24.9,75.9,208},{20.6,74.5,208},{36.7,78,208},{28.7,38.8,208},{49.7,33.6,206},{17.1,42,208},{67.7,32,206},{22.5,72.7,208},{37.7,71,208},{61.7,43.6,206},{17.9,34.4,208},{73.2,73,206},{56,30.6,206},{64.4,51.9,206},{49.1,34.4,206},{46.2,47.5,208},{24,71.4,208},{42.7,28.7,208},{49.5,75.9,206},{31.4,75.9,208},{53.9,47.5,206},{40.7,39.2,208},{23,51.1,208},},["Herbalism"]={{63.7,98.2,427},{27.9,41.6,417},{62,66.3,417},{55.7,75.4,417},{22.5,29,417},{54,72.8,417},{29.3,68.4,417},{60.8,29.4,417},{83.9,77.5,409},{19.2,94.4,427},{83.6,78.3,409},{36.6,50.2,417},{56.3,33,417},{41.3,62.1,417},{84.4,72.5,415},{56.2,52.8,417},{40.8,45.6,417},{27.9,48.5,417},{25.6,54.3,417},{70.1,50,417},{48.1,56.3,417},{52,60.9,417},{40.5,45.9,417},{38.1,33.5,417},{55.2,48,417},{31.1,52.9,417},{27.4,82,417},{58.4,64.5,417},{73.8,11.5,417},{20.4,74.6,417},{49.7,62.2,417},{52.1,35.4,417},{46.4,48.2,417},{59.3,46.4,417},{25.6,33.5,417},{42.8,74.3,417},{58.3,56.9,417},{27,23.8,417},{24.9,71.1,417},{66.4,81.9,417},{27.7,81.5,417},{24.4,79,417},{73,33.3,417},{22.2,29.5,417},{23.2,41.2,417},{61.4,51.9,417},{33,66,417},{83.8,79.5,409},{29.5,62.1,417},{24.3,78.1,417},{24.9,71.4,417},{46.2,48.6,417},{50.6,46.4,417},{82.9,76.9,417},{38.1,33.7,417},{60.3,82.3,417},{32.2,42.4,417},{37.3,76,417},{46.5,62.9,417},{53.5,66.9,417},{30,32.8,417},{36.8,66.6,417},{55.8,81.8,417},{39.2,51.2,417},{29,61.2,417},},["Fishing"]={},},
["Burning Steppes"]={["Mining"]={{58.3,89.3,201},{65.2,87,204},{67.9,21.4,208},{66,86.8,204},{59.6,88.5,202},{75,19.8,208},{65,84.9,204},{68.7,23.1,208},{71.2,84,204},{64.4,85.6,201},{66,88.3,204},{64.2,86.6,204},{65.6,88,202},{67.7,84.9,204},{67.4,86.8,204},{65.1,85.7,202},{67.6,18.8,208},{60.7,90,201},{97.8,11.2,208},{60.7,89.4,201},{67.7,86.4,201},{68.4,84.6,204},{61,38.6,208},{70.4,20.4,208},{78,41.9,206},{64.1,88,202},{59.2,88.8,201},{68,82.9,202},{79.2,25.3,208},{60.2,89.9,202},{65.7,86,202},{73.3,18.6,208},{56.8,90.8,201},},["Herbalism"]={{38,47.5,426},{18,50.3,426},{22.9,46.5,425},{49.6,58.6,425},{11.3,41.3,427},{14.6,58.7,427},{22.4,58.3,426},{75,68.4,427},{89.8,43.4,421},{55.8,67.9,427},{45.3,58.5,425},{82.3,48.2,427},{55.1,29.1,426},{90.1,33.9,421},{67.6,34.8,426},{14.8,57.2,427},{33.4,69.2,426},{66.4,59.6,421},{87.8,46.6,426},{31.4,56.6,431},{63.3,51.2,426},{30,46.7,425},{76.6,48.6,431},{66.7,47.4,426},{86.2,36.1,427},{15.1,30.2,431},{25.4,44.5,431},{70.1,48.7,426},{50.3,61.2,426},{85.5,27.5,425},{21.8,48.3,425},{38.2,28.6,427},{80.3,53,427},{86.6,57.6,421},{39,45.6,431},{74.2,66.8,427},{21.1,46.6,431},{16.5,24.2,427},{74.1,66.8,427},{91,33.3,426},{69.7,84,408},{35.7,48,425},{85.6,30.2,421},{97.8,14.7,409},{69.3,84.8,408},{86.4,63.8,427},{45.9,55.2,426},{22.9,72.9,426},{67.2,35.9,426},{86.7,71.2,425},{84.7,57.3,421},{75.9,62.2,431},{82.5,34.1,431},{43.2,34.3,431},{46.4,35.4,431},{54.7,36.5,431},{66.7,47.3,426},{94.5,58.8,427},{63.1,36.9,431},{78,38.3,427},{83.1,38.2,431},{62.6,39.4,431},{88.9,44.7,421},{61.3,40.1,431},{22.5,58.4,426},{68.1,46,426},{66.5,40.2,431},{88.6,60.4,427},{55.5,42,431},{36.8,44.5,431},{76.5,47.4,431},{44.8,41.9,426},{68.9,24.4,427},{35.6,48.9,431},{37.5,49,431},{19.6,49.2,431},{86.7,71.5,425},{91.2,33.1,426},{75.5,49.9,431},{51.1,54.4,431},{32.4,55.4,431},{51.8,53.9,425},{57.6,61.6,431},{38.4,42.4,427},{50.9,61.8,431},{33.3,55.2,426},{70.4,86.2,403},{92.4,31.8,431},{54.4,63.3,431},{18.9,48.8,431},{50.3,38.7,426},{54.3,63.5,426},{94.4,58.7,427},{72.9,26.4,427},{50.5,27.1,427},{82.4,57.8,421},{73.6,36.9,421},{38.1,28.7,427},{43.9,31.1,427},{76.3,62.3,425},{42.7,37.4,431},{74.3,43.9,421},{79,38.4,427},{78.9,38.8,427},{39.6,54.7,425},{37,65.1,427},{62.1,56.6,426},{44.7,39.5,427},{81.4,40.4,427},{31.4,61.8,431},{34.8,48.2,426},{47.5,53.4,425},{86.8,43.9,426},{59.7,34.8,421},{80.9,52.4,427},{34.8,48,426},{44.8,38.3,426},{66.9,55.2,427},{65.2,57.7,427},{73.6,35.7,421},{41.3,37.1,425},{75.7,52,421},{97.8,14.8,409},{48.3,42.1,426},{22.7,60.3,426},{34.6,48.4,426},{76.7,62.9,425},{86.9,37.2,427},{51.7,53.6,425},{47.6,54,425},{48.2,64.3,427},{90.7,51.8,421},{41.8,37.4,425},{57.3,25.8,426},{56.1,64.8,426},{65.7,60.2,421},{70.1,83.4,408},{90,33.4,421},{67.8,35.2,421},{45.6,60,425},{28,64,426},{66.9,34.6,421},{54.2,63.4,426},{90.1,32.1,426},{88.6,58.9,426},{75.5,32.6,426},{45.1,57.7,425},{91.1,33.2,426},{66.4,47.3,426},{70.2,48.8,426},{23.1,73,426},{78.3,44.3,427},{86.7,44.2,426},{66.8,47.1,426},{35.8,47.5,425},{76.3,54.1,421},{76.7,64.1,425},{50.4,38.7,426},{47.5,42,426},{23,47.5,425},{27.8,64,426},{69.3,84.6,408},{58.9,34.9,421},{56.9,41.5,426},{58.4,43.9,426},{38.2,42.6,427},{53.1,57.7,426},{89.2,57.3,426},{18.6,48.4,426},{18.7,48,426},{23.8,69.4,426},{92.5,33.1,421},{92.6,54.7,425},{56.2,55.5,425},{16.6,56.3,426},{23.1,46.5,425},{56.9,41.2,426},{87.9,40.5,425},{43.3,52.9,426},{70.3,48.7,426},{21.9,46.8,425},{70.4,83.7,408},{74.3,44.8,421},{18.6,48.1,426},{81.5,46,425},{69.7,83.6,408},{63.1,51.3,426},{87.9,37.5,425},},["Fishing"]={},},
["Elwynn Forest"]={["Mining"]={{40.7,82.1,201},{86.9,60.2,201},{34.3,72.5,201},{38.3,81.1,201},{65.1,47.1,201},{39.8,83.1,201},{55.9,81.3,201},{38.6,50.8,201},{51.5,83.6,201},{31.8,70.7,201},{57.5,78.6,201},{72.5,65,201},{62.1,48.4,201},{75.4,85.7,201},{83.6,80.6,201},{61.1,50.2,201},{40.7,79.8,201},{79.1,37.2,201},{25.4,69.2,201},{32.1,63.2,201},{54.1,82.2,201},{74.5,63.2,201},{60.1,65.2,201},{61.3,51.8,201},{69.7,37.3,201},{52,76.4,201},{64.8,39.1,201},{76.5,51.7,201},{74.6,55.2,201},{29.3,72,201},{67,70.5,201},{73.2,43.8,201},{41.7,80.5,201},{41.3,73,201},{51.3,80.7,201},{61.4,46.9,201},{60.9,47.4,201},{62,47.1,201},{30,60.2,201},{42,50.2,201},{59.5,78.8,201},{60.6,47.2,201},{40.2,77.9,201},{78.7,75.4,201},{82.6,55,201},{42,78.5,201},{51.3,67.5,201},{60.1,48.9,201},{25.5,66.6,201},{61,48.9,201},{43.5,49,201},{74,77.5,201},{37.3,82.8,201},{78.6,49.5,201},{60.1,49.7,201},{52.5,85.6,201},{61.5,54.1,201},{29.2,88.1,201},{61.4,49.7,201},{45.6,72.6,201},{75.9,59.8,201},{40.8,77.1,201},{85.4,81.3,201},{60.4,50.4,201},{38.3,81.9,201},{41.1,82.7,201},{38.1,71.1,201},{37.3,50.8,201},{62.2,52.3,201},{61.5,52.4,201},{65.4,56.5,201},{40,81.1,201},{41,52.4,201},{31.5,56.6,201},{72.6,52.5,201},{70.7,55.4,201},{61.9,53.8,201},{76.2,80.5,201},{52,58.6,201},{39.1,81.1,201},{62.3,63.5,201},{57.3,56.8,201},{30.2,54,201},{70.1,47.6,201},{85.7,79.1,201},{60.7,53,201},{89.4,62,201},{41.7,77.6,201},{73.3,58.6,201},{47.6,73.8,201},{60.4,63.8,201},{80.8,42.6,201},{56.3,79.3,201},{20.8,77.7,201},{38.3,86.7,201},{94.8,76,204},{17.9,75.5,201},{28.1,66.2,201},{41.6,77.1,201},{52.2,63.3,201},{38.9,81.6,201},{65.6,72,201},{69.1,68.8,201},{59.7,77.3,201},{50.5,87.2,201},{80.3,80,201},{38.9,78.3,201},{39.9,79.1,201},{43.7,74.1,201},{77.4,84.6,201},{20.7,74.9,201},{41.1,80.4,201},{40.2,78.6,201},{27.7,69.9,201},{50.1,84.7,201},{50.4,74,201},{24.2,84.4,201},{40.5,80.5,201},{40,79.3,201},},["Herbalism"]={{40.1,74.8,402},{69,68.1,402},{95.4,74.4,405},{29.4,71.5,402},{73.9,83.8,401},{80.6,46.8,402},{86,65.3,401},{37.1,60.9,401},{51.5,81.2,403},{35.2,58.1,401},{43.9,90.8,402},{95.1,78.3,401},{71.2,42,402},{43.3,56.7,402},{50.2,84.8,403},{49.9,80.9,402},{39,72.7,402},{75.3,75.8,402},{28.2,64.7,403},{70.7,63.2,402},{27.2,68.3,402},{68.5,81.4,401},{30.8,89.4,402},{39.8,53.4,402},{79.4,68,402},{77.5,70.1,402},{55.3,56.9,403},{88.5,77.1,401},{41.2,57.6,402},{76.5,83.9,402},{37.8,50.6,403},{68.1,50.8,402},{26.2,81.5,401},{35.6,69.4,401},{34.9,66.9,402},{89.4,79.7,402},{32.8,54.5,402},{57.7,60.2,402},{88.5,62.1,403},{36,61.9,402},{44.8,75.7,402},{53.8,70.3,402},{36.9,58.1,402},{45.2,63.5,401},{39.9,76.5,401},{62.8,53.9,402},{49,83.2,401},{16.7,78.4,408},{18.3,80.1,408},{82.9,79.8,403},{27.9,73.9,401},{68.9,76.2,402},{95.4,77.9,405},{43.8,71,401},{61.4,68.5,402},{95.2,74.8,404},{78.5,90.1,404},{35.1,74.5,402},{35,80,402},{49.5,59.6,401},{41.7,97.4,404},{72.3,34.1,403},{17.4,75.7,402},{34.2,88.1,402},{47,84.5,402},{85.9,61,401},{67.5,35.1,403},{34,58.1,402},{60.6,65.4,402},{57.6,75.5,402},{80,37.3,403},{78.3,38.6,403},{81.5,39.1,403},{26.5,87.9,402},{53.3,84,401},{87.5,78.5,402},{63.9,44.3,403},{40.2,47.9,403},{75.5,49.4,403},{50.6,74,403},{48.1,50.3,403},{82.3,50.4,403},{62.9,51.2,403},{46.2,86.1,401},{84.4,81.2,403},{82.1,54.2,403},{73.6,54.7,403},{50.7,54.9,403},{25.9,84.6,401},{30.8,55.7,403},{58.7,56.3,403},{52.5,57.6,403},{28.9,58.2,403},{85.1,58.7,403},{50.2,59.1,402},{25.2,66.9,403},{67.5,69.2,403},{66.2,70.8,403},{30.3,66.6,402},{44.7,55.2,401},{87.1,71,401},{65.2,72.1,403},{79.4,75.2,403},{80.5,54.4,402},{84.9,77.6,403},{57.4,78.7,403},{58.8,78.9,403},{27,84.5,402},{46.8,74.6,401},{50.7,84.3,403},{50.7,85.7,403},{40.9,53.7,401},{74.6,53.8,401},{62.5,58.1,401},{87.3,72.9,402},{78.8,58.3,401},{52.8,79.8,402},{27.6,91.9,402},{24,96.1,402},{85.8,83,402},{64.1,65.3,401},{70.6,61.6,401},{42.8,61,401},{22.7,75.6,401},{50.9,69.2,402},{42.8,83.9,402},{62.1,62.6,401},{25.7,88.9,401},{54.3,60.3,402},{81.1,80.6,402},{66.5,63.2,401},{71.7,82.7,401},{41.4,52.1,402},{65.3,36.3,403},{45.7,89.2,402},{56.3,66.9,402},{81.5,62.9,402},{41.4,55.3,402},{23.3,77.7,402},{82.6,84,402},{77.1,63.1,402},{55.4,80.5,401},{18.9,83.4,402},{40.9,69.6,401},{66.5,42.8,402},{44.7,51.3,402},{20.8,85.9,405},{84.1,56.7,402},{40.4,90.5,401},{85.8,80.6,403},{60.1,75.3,401},{21.3,73.6,402},{88.4,81.2,401},{35.1,70.7,402},{66.5,80.9,402},{65.6,67,402},{77,76.4,401},{79,77.8,402},{24.9,92.4,402},{65.8,78.2,401},{64.5,62.6,402},{82.3,76.6,402},{62.9,77.7,401},{30.6,57.7,402},{61.7,78.9,402},{87.3,64.9,402},{47,81,401},{60.7,60.9,402},{42.4,79.4,402},{67.6,65.1,402},{95.8,81.1,401},{38.8,87.5,401},{18.9,82.8,408},{35.6,87.6,401},{73.3,67.4,402},{60.5,81,401},{76.6,41.1,402},{31.3,66.8,402},{37.7,79.7,402},{63.9,63.8,401},{51.9,63.1,402},{40.4,84.2,402},{19.3,81,408},{67.3,60,402},{78.8,80.3,401},{84,85.1,401},},["Fishing"]={},},
["Loch Modan"]={["Mining"]={{35.1,18.9,201},{56.9,44.5,201},{74.1,22.2,201},{48,55,201},{68.3,67.9,201},{59.2,66.9,201},{73.3,57.2,201},{71.9,34.2,201},{75.3,75.1,201},{45,47.5,201},{53.8,72.2,201},{73.7,48.3,201},{33.5,69.9,201},{37.9,22.3,201},{35.2,88.7,201},{23.7,36.7,201},{68.1,27,201},{34.6,70.9,201},{36.3,26,201},{36.1,56.6,201},{37.5,91,201},{58.6,78.4,201},{55.8,68.3,201},{68.9,47.4,201},{41.8,26.3,201},{44.2,70.5,201},{45.8,60.1,201},{63.8,74.6,201},{35.5,89.9,201},{56.5,47.6,201},{34.1,57.6,201},{43.4,53.1,201},{35.5,76.8,201},{26,56.9,201},{25.6,44.5,201},{78,32.8,201},{37.3,88.8,201},{26.3,47.3,201},{35.4,23.7,201},{71.2,18.4,201},{28.6,80.1,201},{53,88.2,208},{67.8,53.7,201},{40.9,8.9,201},{30.9,9.5,201},{41.5,47.8,201},{36.5,10.1,201},{35.5,20.7,201},{52,13.4,201},{57.8,14.2,201},{36.8,16.4,201},{31,76.6,201},{51.8,50,201},{36.3,22.8,201},{26.7,56,201},{58.2,74,201},{57.7,70.9,201},{41.6,13.1,201},{70.4,68.6,201},{37.9,73.8,201},{41.6,19.1,201},{38.3,87.3,201},{67.3,77.1,201},{64.2,23.9,201},{76.6,60.8,201},{23.1,24.5,201},{70.1,34.8,201},{41,65.5,201},{33.3,26.1,201},{50.2,44.3,201},{35.1,27.1,201},{25.3,42.5,201},{35,85.2,201},{35.9,87.7,201},{35.4,25.2,201},{40.9,33.8,201},{48.2,32.8,201},{49.5,35.6,201},{47,37.6,201},{50.3,23.2,201},{84.2,57.3,201},{62.4,67.1,201},{47.6,43.3,201},{78.6,56.3,201},{33.7,88.3,201},{33.8,61.8,201},{36.6,20.4,201},{42,61.9,201},{26,50.9,201},{78.1,77.8,201},{56.3,59.5,201},{77.7,38.1,201},{36,18.9,201},{31.4,82.3,201},{58.6,72.2,201},{45.8,62.8,201},{77.9,53.8,201},{26.5,31.7,201},{32.2,20,201},{42.9,66.5,201},},["Herbalism"]={{40.1,69.7,402},{62,40,405},{30.1,17.7,402},{53.7,21.8,402},{33.3,55.7,402},{54.6,38.2,402},{59.7,27.6,402},{54.9,26.4,402},{28.1,30.2,402},{26.8,30.3,401},{59,24.9,404},{45.2,85.9,418},{44.2,87.8,418},{47.9,86.8,411},{58.6,26.1,402},{60.7,27.9,401},{71.5,18.4,408},{68.2,18.7,408},{40.8,35.1,404},{28.4,43.9,402},{52.8,74.4,404},{41.8,69.4,402},{70.6,20.4,408},{40.3,21.6,402},{67.8,49.7,408},{55,24.4,402},{69.9,20.5,408},{81.6,62.8,408},{65.7,22.3,408},{34.3,40.3,402},{77.7,55.6,408},{73.2,22.4,408},{73.3,22.4,408},{65.5,22.6,408},{71.8,22.8,408},{71.2,76.1,404},{65,23.3,408},{63.7,24.7,408},{64.7,26.1,408},{30.6,80.2,402},{55.4,42,405},{68.4,26.2,408},{64.3,26.5,408},{39,26,402},{30.9,43.1,402},{54.7,34.2,402},{69.4,26.7,408},{68,32.3,408},{72.1,28.7,408},{70,29,408},{81.1,65.9,408},{72.1,29.1,408},{69.8,29.7,408},{47.6,27.5,404},{39.3,14.2,402},{72.7,29.8,408},{68.6,30.6,408},{69.1,31,408},{69.3,32.1,408},{30,71.6,402},{75.2,27.5,408},{70.9,35,408},{77.7,35,408},{78.7,35,408},{33.1,79.4,402},{49.1,70.3,401},{69.5,35.1,408},{76.3,71.6,405},{69.7,37,408},{71.6,36,408},{58.4,27.6,402},{77.6,39.2,408},{78.3,41.6,408},{71.3,43.2,408},{28.6,86.8,402},{71.5,44.1,408},{78.9,44.3,408},{69,45.1,408},{70.2,45.3,408},{46.5,79.5,402},{51.7,28.1,404},{73.5,45.4,408},{68,47,408},{18.8,75.9,402},{67.9,49.6,401},{55.7,27,402},{69.6,47.6,408},{73.3,48.2,408},{69.5,48.8,408},{40,50.8,401},{65.9,72.5,404},{73,48.9,408},{73.3,57.6,408},{72.6,49.4,408},{40.8,42.3,404},{46.8,66.9,401},{76.6,53.1,408},{69.3,53.6,408},{70.5,53.8,408},{58.3,76.6,401},{70.3,49,408},{82.9,62.4,408},{82.7,62.5,408},{32.7,59,403},{70.5,22.3,408},{61.1,59.9,401},{83.5,63.7,408},{81.6,64.5,408},{27.2,60.4,403},{25.1,28,402},{58,66.8,405},{81.2,65.8,408},{78.1,57.7,404},{56.5,15.2,405},{26.5,57.9,402},{46.7,81,402},{50,21,405},{68.6,23.6,405},{24.5,14.7,401},{51.5,35.9,402},{56.3,37.1,402},{55,26.1,405},{59.6,18.7,404},{27.2,19,402},{39.5,66.7,403},{54.6,33.3,402},{77.3,31.3,405},{60.5,32.2,405},{54.5,35.9,405},{36.8,36.5,402},{51.6,70.4,401},{52.6,37.5,405},{20.8,77.1,401},{71,38.5,405},{37,30.4,402},{54.4,23.1,402},{74,41.6,405},{77.2,43,405},{74.4,46.3,405},{53.6,36.1,402},{47.7,80.1,402},{69.8,51.2,405},{71.5,53.1,405},{29.5,86.5,402},{33.4,75,401},{77.3,37.8,408},{37,17,404},{68.1,73.3,405},{41.8,14.3,404},{78.9,71.8,405},{73.6,26.7,405},{47.5,22.3,404},{54.5,25.1,404},{62.7,25.5,404},{36.4,77.9,403},{68.9,29.8,408},{49.5,30.1,404},{43.8,62.7,401},{65.3,31.8,404},{39.9,73.9,402},{55.3,27.7,402},{40.9,33.2,404},{55.2,33.5,404},{40.4,37.5,404},{38,45.6,404},{58.3,25.5,402},{76.3,41.7,404},{77.5,46,404},{26.9,47.3,404},{42.7,62.3,402},{54.9,28.5,402},{30.8,50,404},{68.3,51.3,404},{34.5,33.7,402},{30.6,53,404},{65.9,60.6,404},{55,53.5,404},{30.6,11.2,402},{28.7,14.4,401},{39.6,23.3,401},{54.6,28.9,402},{52,34.2,402},{63.1,56.7,404},{40.3,61.1,403},{36,32.4,401},{79.5,76.8,408},{35.2,71,402},{27.8,40.3,402},{41.3,31.4,404},{63.6,55,401},{54.3,24.2,402},{27.4,34.4,402},{55.1,25.9,402},{40.2,61.1,403},{55.9,32.7,402},{54.4,28.5,402},{32.4,68.9,402},{24.7,38.6,403},{56.4,35.7,402},{54.2,28.9,402},{55.6,28.4,402},{25.9,53.4,403},{37.6,56.2,403},{36.2,13.3,402},{31.9,35.5,402},{68.1,18.8,408},{53.7,28.2,402},{37.2,76.1,402},{30,75.8,402},{39,34.7,402},{48.3,77.2,402},{30.1,27.8,402},{42.6,55,401},{46.2,76.5,402},{21.8,16.6,402},{55.2,28.8,402},{30.2,83.2,403},{55.8,27.9,402},{29.6,87,402},{28.7,14.3,401},{53.7,24.2,402},{52.5,24,402},{47.8,74.8,402},{35.8,52,402},{29.5,36.4,402},{53.5,55.2,404},{43,58.8,402},{52.1,35.7,402},{31.7,31.6,402},{40,75.8,402},{28,36.9,401},{29.2,46.1,401},{64.6,46.5,401},{25.1,48.5,403},{24.9,23.8,402},{53.8,37.9,402},{29,23.3,402},{54.6,35.6,402},{56.2,33.9,402},{77.3,65.9,405},{67.9,42.3,401},{51.1,35,402},},["Fishing"]={{59.5,56.7,108},{57.6,23.1,108},{41.8,38.9,108},{56.1,41.8,108},{41.6,36.9,108},{51.5,67.6,108},{58.3,37.4,108},{47.1,62.8,108},{62.5,49.8,108},{42.4,14.1,108},{52.6,35.6,108},{42.4,15.5,108},{54.2,15.9,108},{51.3,19.5,108},{56.8,34.4,108},{52.7,41.5,108},{41.9,34.8,108},{53.6,66.1,108},{61.6,54,108},{54.8,43.7,108},{62.1,46.8,108},{56.6,61.7,108},{46.4,23.7,108},{57.5,29.6,108},{56.2,26.9,108},{53.3,57.3,108},{41.3,40.5,108},{59.4,42,108},},},
["Stranglethorn Vale"]={["Mining"]={{41.6,42.9,203},{32.5,62.1,203},{42.4,48.6,203},{26.1,63.4,203},{34.7,65.8,203},{28.9,7,203},{27.6,18,203},{45.9,43.9,203},{44.6,26,203},{33,72,203},{41.9,37,203},{35.1,56.4,203},{37.8,1.4,203},{44.4,45,203},{39.4,53.2,203},{32.8,68.2,203},{47.7,5.5,203},{42.4,41.7,203},{46.1,8.3,203},{29.3,15.3,203},{46.9,5.9,203},{52.9,28.1,203},{50.4,27.9,203},{27.4,13.6,203},{24.9,54.9,203},{30.5,6,203},{49.1,6.6,203},{50.8,27.8,203},{48.6,21.4,203},{49.5,7.5,203},{31.3,9.5,203},{42.2,43.1,203},{29.4,70.2,203},{49.7,7.1,203},{40.8,57.1,203},{31.7,76.3,203},{30.5,7.6,203},{47.3,7.8,203},{39.9,45.6,203},{49.9,7.9,203},{49,8,203},{48.3,8.2,203},{37.5,1.8,203},{31.3,13.8,203},{40.7,9.5,203},{45,38.5,203},{43.2,49.4,203},{41.4,43.8,203},{37.1,1.2,203},{37,56.5,203},{36.3,65.7,203},{33.1,42.6,203},{49.8,33.8,203},{29.8,68.9,203},{48.6,1.5,203},{50.3,27.5,203},{31.7,13,203},{32.1,12.4,203},{38.1,57.5,203},{51.3,28.2,203},{35.2,60.2,203},{34.2,14.2,203},{41.5,14.3,203},{50.6,14.9,203},{48.2,5.9,203},{38,56.7,203},{36.9,63.8,203},{25.7,15.4,203},{46.2,17.1,203},{32,17.7,203},{30,17.7,203},{26.3,18,203},{37.5,1,203},{47.2,20.3,203},{48.5,1.6,203},{47,22.6,203},{24.7,55.3,203},{30.2,52.9,203},{51,36.6,203},{28.6,81.1,203},{48.1,24.5,203},{29.2,69.5,203},{51.2,26.4,203},{44.7,26.5,203},{41.6,41.4,203},{48.2,26.9,203},{50.3,27.2,203},{41.7,50.9,203},{29.8,12.1,203},{39.4,36,203},{37,54.1,203},{31.4,65.3,203},{31.5,78.3,203},{50,28.4,203},{32,10.9,203},{49.9,30.4,203},{38.6,80.9,203},{29.4,60.1,203},{35.6,64.3,203},{28.3,67.7,203},{47.6,38.3,203},{47.8,28.5,203},{27.1,67,203},{28.7,40.8,203},{35.1,60.9,203},{25.2,52.5,203},{33.5,67.8,203},{49.2,9,203},{33.6,62,203},{50.1,28.1,203},{35.7,58.9,203},{39.8,82.1,203},{46.7,5.7,203},{26.3,81.9,203},{42.1,46.3,203},{41.1,51.5,203},{28,63.7,203},{41.5,49.2,203},{34.8,66.6,203},{42.3,47,203},},["Herbalism"]={{51.5,34.3,409},{27.8,11.7,415},{46.6,44.8,414},{37.8,18.8,415},{45.6,18.4,413},{36.4,56.9,413},{32.3,52.7,411},{46.1,5.7,409},{29.7,70.8,415},{40.5,50.3,413},{27.2,67.4,412},{35.7,24.2,412},{33.7,62,414},{38.9,15,415},{31.6,43.7,411},{37.6,16.5,411},{29.8,42.8,414},{32.4,52.7,411},{40.8,50.4,411},{38.2,49.1,409},{44.1,17.5,411},{35.7,26.3,411},{33.1,63.8,414},{25,10.2,414},{48.8,24.1,415},{50.8,29.4,409},{29.2,44.6,415},{35.7,58.6,409},{33.2,55.2,414},{33.1,37.9,415},{33.7,18.8,411},{49.3,24.3,415},{40.2,37.1,414},{27.9,11.6,414},{42.7,40.5,415},{38.6,36.3,415},{38.3,14.6,415},{26.4,32.4,407},{44.7,34.9,415},{50,20.3,414},{30.8,86.3,407},{29.7,68.5,412},{29.1,44.5,415},{13.9,13.3,407},{31.5,11.2,415},{42.3,33.8,414},{38.2,49,409},{32.3,59,411},{28,11.6,414},{40.4,39.3,414},{44.3,30.3,414},{46.3,31.3,415},{38.6,38.4,414},{27.8,58.9,412},{26.7,60.5,409},{34,16.7,409},{46.4,39.9,414},{32.6,20.3,414},{29.8,57.7,415},{45.1,30.6,415},{30.6,43,415},{30.6,66.7,415},{40.4,6.9,409},{48.4,32.2,411},{40.5,52.2,413},{27.1,47.7,412},{28.9,9.8,411},{42.4,40.2,414},{40.3,37,414},{36.9,31,414},{30.9,23.7,415},{27.8,15.7,415},{24.7,12,413},{39,42.8,414},{29.5,66.1,414},{26.3,60.2,411},{23.7,15.8,415},{23.9,63.3,415},{49.9,28.5,415},{39.1,34.2,414},{30.5,21.3,411},{40.3,39.1,414},{38.9,19,414},{39.5,19.3,414},{47.7,36,414},{36.7,56.7,413},{42.2,27.1,411},{23.6,54.5,415},{18.9,10.3,415},{33.9,35.9,407},{47.6,35.9,414},{24.4,63.5,415},{32.1,82.4,407},{29.3,37.9,415},{21.3,53.5,407},{39.7,40.9,415},{39,19,415},{44.7,34.4,415},{26.8,38.8,407},{29.9,89.9,407},{38.4,46.7,415},{40.5,49.9,413},{29.2,9.8,415},{45.6,34.8,411},{42.7,40.2,415},{22.5,81.9,407},{42.9,20.9,412},{31.9,21.9,414},{43.8,42.5,414},{40.3,19.6,412},{40.5,82.2,411},{30.1,44.7,415},{33.1,69.9,409},{33.8,14.2,415},{30.5,88,407},{34.3,36,407},{28.7,87.1,407},{40.2,49.7,411},{47.1,13.9,413},{47.8,40.1,418},{33.3,20.4,412},{39.4,38.5,414},{46.9,35.3,414},{48.5,40.4,415},{28.7,41.8,414},{44.3,38.3,414},{35.7,58.2,413},{42.1,11.8,415},{27.7,45.6,415},{45.3,12.9,415},{25.6,85.5,407},{28.1,30.7,407},{39.1,14.6,415},{24.9,48.5,407},{27.5,15.3,415},{41,22,412},{35.3,32.1,415},{30.1,44.6,415},{38.3,42.2,414},{39.7,86,415},{45.7,8.7,415},{39,25.3,414},{47.6,31.2,414},{48.6,40.3,414},{33.1,59,414},{33,22.3,412},{44.4,42.5,418},{29.3,37.7,412},{29.8,20.7,414},{36,32.4,412},{41.1,84.5,415},{22,51.3,407},{29.4,87.3,407},{35.9,19.4,413},{27.3,45.3,412},{34.6,20.9,412},{50.1,23.7,415},{32.9,61,414},{43.7,24.8,414},{39.4,40.5,414},{38.3,42.1,414},{37.2,20,414},{28.7,43.8,415},{40.4,25.9,412},{27.3,43.1,412},{46,30.2,415},{37.9,46.2,414},{39.5,51.3,415},{26.6,68.6,407},{29.7,14.1,409},{41,39.1,411},{29,39.6,415},{47.9,39.7,415},{35.5,77.3,407},{39.1,20.9,415},{48.5,14.1,415},{33.2,58.9,414},{39.8,36.3,414},{27.1,14.9,413},{30.6,42.5,415},{22.8,68.8,407},{37.7,18,415},{29.9,24.9,412},{35.2,57.7,413},{30.2,70.3,415},{43.7,11.6,414},{47.3,22,414},{33,80.3,407},{25.4,67.9,407},{23,62.4,407},{29.9,37.8,415},{32,84.1,407},{29.8,20.5,414},{24.1,54.3,415},{38.5,39.9,414},{25.5,16.2,411},{22.1,53.3,407},{30.1,89.6,407},{25.9,20.7,407},{33.4,15.8,418},{38.9,29.3,412},{39.2,51,411},{32.9,60.8,414},{46.5,21.5,411},{44.8,42.2,414},{33.1,65.2,411},{25.4,50.6,412},{32.9,26.3,415},{37.3,37.1,414},{38.6,39.9,414},{30.1,24.9,415},{38.4,63.5,407},{35.6,57.8,413},{28.3,86.5,407},{45.1,7.8,415},{47.5,17.6,415},{46.6,38.7,414},{48.4,39.6,414},{35.2,42.5,414},{38.4,29,415},{48.9,31.2,415},{41.7,41.4,415},{40,57.8,418},{27.8,15.1,415},{45.1,37.9,411},{37.6,17.8,413},{43.4,15.5,415},{23.3,53.8,412},{46.6,25.7,411},{33.7,13.7,415},{27.5,64.5,409},{29,67.4,412},{27.4,86,407},{32.3,17.3,409},{34,67.7,413},{30.6,18.6,415},{51,19.2,409},{38.2,15.9,413},{45.7,29.5,414},{29.5,43.9,411},{30.9,87.7,407},{47.5,43.3,415},{41.1,28.1,411},{46.4,29.8,415},{48.2,39.3,415},{46,33.9,415},{35.6,23.2,412},{27,49.1,415},{31.9,38.6,415},{33.6,84.7,407},{37.7,15.6,415},{33.9,9.4,412},{29.8,87.1,407},{47.6,34.6,414},{26.1,63.7,409},{31.7,36.3,407},{35.6,64.1,409},{28,56,412},{29.3,15.7,414},{30.2,18.3,415},{32.6,86.3,407},{29.1,39.3,415},{35.3,12.2,411},{50.2,27.2,415},{33.7,11.4,411},{23.8,53.9,415},{35.2,57.4,413},{25.8,59.2,412},{19.3,12.3,414},{28.8,6.8,409},{44.8,33.1,411},{25.4,63.3,409},{46.4,42.5,414},{37.7,30.6,418},{48.7,35,415},{27.8,58,412},{34.9,72.3,412},{25.7,59.1,415},{35.2,40.1,415},{43.7,10.9,415},{41.5,15.2,412},{43.9,19.6,415},{22.8,64.1,407},{34,86.9,407},{23.1,51.3,412},{21.1,25,407},{25.4,58.9,412},{21.1,15.3,412},{29.6,89,407},{26.6,44.4,407},{38.7,46.1,415},{23.3,9,418},{30.8,54.5,414},{22.5,9.3,418},{23.6,11.8,418},{39.6,53,409},{26.5,12.2,418},{34,65.3,414},{26.6,9.9,409},{34.1,15.1,418},{37.6,32.6,412},{33.7,16.3,418},{37.4,29.9,418},{46.1,31.8,418},{33.8,50.1,414},{46.5,32.8,418},{35.9,57.6,411},{27.8,42.8,415},{42.5,36.1,418},{34,15.7,414},{36.4,24.2,414},{40.1,29.5,412},{46.7,39.1,418},{43.2,23.4,414},{29.4,52.2,415},{37.6,45.5,414},{24.3,62.6,412},{48.4,43.2,409},{41.7,38.9,415},{44.4,36.9,415},{22.6,49,407},{48.4,40.8,418},{48.5,40.8,418},{33.6,24.1,409},{23.4,25.5,407},{37,53.8,414},{44.1,41.4,418},{46.1,43.2,418},{47.6,43.5,418},{27.4,62.8,418},{41.4,25.8,411},{26.8,59.5,415},{46.2,20.5,413},{28.2,63.6,418},{29.1,8,414},{35,37.7,415},{29.6,7,409},{28.9,8,414},{31.2,12.1,413},{43.3,9,414},{31.8,12,415},{40.1,12.2,412},{37.5,44.7,414},{31.2,16.4,411},{43.8,10.1,414},{25.1,10.2,414},{43.8,11.7,414},{27.6,34,407},{20.4,12.1,414},{19.3,12.2,414},{34.7,52.6,414},{47,16.5,415},{42.4,13.6,414},{41.8,14.8,414},{34.1,13.5,415},{30.4,87.1,407},{35.3,57.2,413},{31.9,16.6,414},{33.4,16.6,414},{43.6,27.7,414},{47.7,12.5,411},{47.2,33.8,414},{41.6,32.3,414},{33.5,16.6,414},{35.8,44.5,415},{46.9,20.7,413},{49.9,26.5,409},{46.2,17.1,414},{41.7,38.8,415},{38.9,18.8,414},{47.7,29.7,414},{29.3,39.1,415},{36.4,34,412},{24.5,8.7,412},{33.2,66.9,413},{18.8,22.7,407},{35.7,74.6,407},{30.1,43.8,411},{45.5,37.2,414},{31.8,8,412},{29.7,20,414},{31.2,31.4,407},{41.4,49.4,414},{47.6,29.6,414},{29.7,20.8,414},{41.2,49.6,414},{30.9,33.4,407},{27.8,68.5,412},{35.3,24.8,409},{39.7,23.2,414},{41.9,36.7,418},{42.5,40.3,414},{49.4,8.9,409},{30.6,20.3,415},{49.5,34.8,414},{23.6,8.2,412},{47.6,12.3,411},{46.1,36.1,414},{49.1,25.8,414},{36.3,25.8,414},{34.2,11.3,411},{44.6,26,414},{47.5,42.4,414},{48.6,27.5,414},{46.7,28.7,414},{41.5,10.6,413},{39.3,40.8,414},{27.8,85.7,407},{40.2,37.5,414},{32.5,82.3,407},{41.6,12.8,413},{47.5,29.6,414},{43.7,10.3,415},{35,44,415},{43.2,35.9,414},{49.6,29.6,414},{36.7,30.4,414},{47.5,30.6,414},{28.5,14.9,411},{36.6,10.3,415},{35.5,35,414},{38,15.3,415},{47.8,31.4,414},{33.2,28,415},{23.9,58.5,407},{37.5,47.1,414},{40.4,33.7,414},{40.5,33.9,414},{42.2,33.9,414},{41.3,34.4,414},{41.1,34.6,414},{32.2,67.9,413},{47.7,34.6,414},{42.8,34.7,414},{34.3,39.3,411},{43.9,10.3,415},{40,14.1,412},{29.4,54.1,415},{33.4,41,414},{50.5,30.8,414},{26.5,69.9,407},{31,39.8,415},{27.9,87.5,407},{40.1,35.4,414},{35.9,72.4,407},{46.9,35.5,414},{41.8,35.6,414},{45.3,7.9,415},{39.4,35.9,414},{29,43.1,415},{39.9,36.1,414},{48.6,25.5,414},{36.7,62,414},{39.2,46,415},{36.6,10.8,415},{30.2,52.3,409},{49.1,36.7,414},{47.8,37,414},{30,85.6,407},{38.3,45.4,414},{33.1,42.6,414},{44.9,37.3,414},{38,46.4,414},{42,40.9,415},{47.1,37.5,414},{46.9,28.9,414},{25.6,24.7,407},{29.5,39,415},{33.2,63.8,414},{43.1,39.3,414},{47.9,38,411},{30.7,24.5,413},{40.9,39.8,414},{43.3,35.7,414},{47.8,25,414},{48.5,40.3,414},{35.8,23.2,412},{23.4,14.4,415},{46.6,28.7,414},{39.4,42.5,414},{46,37.3,411},{47.2,42.5,414},{27.4,68.1,407},{46.2,37.1,414},{38.9,42.8,414},{48.1,43.4,414},{33,18.8,411},{46.9,28.8,415},{36.2,44.3,414},{39.4,44.3,414},{31.5,13,415},{25,8.7,412},{26.2,52.4,409},{38.7,46.5,415},{27,57.1,407},{23.5,10.1,414},{46.3,37.1,414},{47.9,42.2,415},{28.2,42.6,411},{22.6,11.8,413},{44.4,45.4,414},{37.5,45.7,414},{38.2,45.4,414},{36.9,23.2,413},{22.8,59.3,407},{37.8,46.3,414},{47,37.4,414},{43.3,9.7,415},{30.8,37.4,415},{33.8,23.8,412},{47.7,29.1,414},{31.3,59.2,411},{38.7,56.4,415},{39.8,59.1,414},{34.1,26.1,411},{47.9,33.5,414},{27,54.9,409},{35.3,48.4,414},{35.3,48.5,414},{48.8,21,414},{35.3,50.6,414},{35.1,51.5,414},{30.8,36.9,415},{34.3,51.7,414},{34.6,75.9,407},{25.3,53.1,414},{26.7,42.5,407},{36,42.1,415},{32.8,36.2,412},{31.8,55.1,409},{24.2,67.1,407},{32,53.9,414},{34.8,22.1,412},{26.2,9.2,418},{33.2,55.1,414},{30.5,37.2,415},{33,57.6,414},{30,19.7,414},{47.9,33.4,414},{25.6,17.2,409},{38.8,17.6,415},{44.9,31.9,415},{38.9,39.2,414},{34.6,65.2,414},{38.7,19.7,415},{33.9,65.3,414},{24.4,55.7,412},{32.1,68.9,414},{26.3,63.1,415},{32.2,72.5,411},{27.6,81.8,414},{23.4,21.1,407},{21.3,78.7,407},{32.8,57.7,414},{40,11.7,412},{25.9,47.8,407},{35.2,24.4,412},{27.4,22.8,407},{37,29.6,415},{36.6,70.2,407},{34.1,26,413},{27,11.7,415},{50.1,27.2,415},{36.3,56.1,413},{36.3,12,415},{33.6,67.6,409},{29,87.5,407},{44.4,18.6,413},{30.9,52.9,415},{43.4,16.4,411},{45.8,30.7,415},{33.8,12.9,415},{40.8,79.9,411},{26.4,82.5,407},{32.6,24.3,411},{48.9,33.8,411},{39.9,50.4,413},{25.8,30.7,407},{47.8,37.5,415},{32.4,42.9,415},{39,13.3,415},{28.7,32.3,407},{33.5,66.9,413},{36.7,10,412},{29.3,21.9,412},{37.3,81.1,415},{28.5,26.6,407},{38.9,39.1,414},{26.6,40.3,407},{38.9,58.5,414},{31.6,67.4,411},{26.9,17.8,409},{27,42.3,407},{33,53.4,414},{44.2,22.7,411},{23.1,14,409},{24.8,13.6,415},{38.8,45.5,415},{26.4,46.3,407},{42.9,34.6,414},{37,44.6,414},{35.5,22.3,412},{43.3,9.3,414},{38.7,20.6,415},{45.3,33.9,415},{24.2,64.1,412},{38.6,20.2,415},{46.2,29.7,415},{44.1,36.8,414},{32.2,42.2,415},{30.8,7,412},{25.4,57,407},{38.4,58.2,414},{47.2,15.5,415},{29,66.2,412},{21.6,8.9,415},{38.4,63.9,407},{36.5,40,411},{34.6,56.3,409},{47,28.3,411},{33.1,53.4,414},{21.4,68.3,407},{32.6,74.7,412},{27.9,27.1,407},{34.2,13.9,415},{32.3,18.5,415},{33.6,5.8,409},{25.6,86.3,407},{34.7,24,412},{45.4,32.7,415},{30.3,36.9,415},{33.6,64.4,411},{32.2,44.3,414},{37.1,14.4,415},{28,17.8,409},{38.9,27.3,412},{42.3,45,409},{27.7,39.9,415},{29.3,60.1,409},{32,67.9,413},{39.6,22.1,412},{24.3,14.5,409},{38.5,17.1,415},{26.3,62.9,415},{23.3,14,415},{37.3,42.5,414},{45.2,14.2,411},{32.5,61.9,409},{22.1,56.5,407},{30.2,66.5,415},{37.5,46.9,414},{33.3,82.4,407},{47.4,43.2,415},{28.1,83.9,407},{26.2,83.3,407},{46.4,45.1,409},{27.6,83.5,407},{31.8,22.5,411},{39.3,25.2,412},{41.3,40.7,411},{30.3,26.4,412},{28.6,40.3,414},{34.2,51.7,414},{24.8,53.5,415},{29.8,67.5,412},{39.2,21.3,415},{33.6,12.6,415},{29.6,88.2,407},{31.1,9.2,409},{45.5,17,411},{32.3,14.1,415},{30.2,10.6,411},{33.8,65.4,413},{47.2,36.8,411},{40.3,35.3,414},{26.4,67.2,415},{26.9,8.1,409},{32.2,51,411},{42.3,10.3,415},{50.3,34,409},{40.9,39.9,414},{31.6,82.7,407},{34.5,16.7,413},{22.2,45.7,407},{41.9,8.2,415},{28.2,61.6,409},{24.4,55.4,415},{36.5,57.1,413},{29.8,20.4,415},{29.9,9.5,415},{48.2,42.1,415},{26.8,84.6,407},{30.4,19.7,415},{40.5,78,415},{42.4,36.3,414},{33.3,39.3,415},{48,37.1,414},{29.6,32.1,407},{48,17.1,415},{46,15.8,409},{44.6,39.7,418},{27,41.5,415},{27.6,11.7,415},{30.6,58.2,415},{38.2,34.2,411},{39.1,79.9,411},{28.9,38.2,415},{43.8,9.1,415},{45,38,411},{47.8,24,415},{36.6,27,413},{38.2,19.1,415},{48.8,39.6,415},{24.1,16.4,409},{28.1,62.5,409},{28.4,44.4,415},{33.7,14.7,415},{38.7,17.9,415},{37.5,44.6,414},{38.6,47.3,415},{34.9,43.3,415},{34.5,26,413},{47.7,19.6,414},{32.5,40.9,411},{39.4,31.4,412},{38.9,15.1,413},{37.3,10.9,415},{45.5,31.8,411},{29.6,29.4,407},{27,13.5,409},{28.2,57.2,407},{26.5,13.3,413},{36.4,54.8,411},{28.1,66.2,415},{44.4,16.5,415},{24.3,53.1,411},{37.8,83.5,411},{28,42,415},{45.9,5.6,409},{43,21.5,411},{20.9,7,409},{26.2,84.2,407},{28.3,14.1,411},{47.2,16.3,415},{18.9,11.4,412},},["Fishing"]={{36.5,33.1,106},{35.5,72.6,120},{22.6,52.8,120},{41,60.6,120},{40.3,22.4,106},{24.5,49.9,120},{23.8,47.4,105},{30,27.7,105},{17.5,11.1,105},{35.8,9.4,106},{30,27.5,120},{24.8,58.3,120},{39.6,29.5,106},{23.7,62.5,120},{21.1,16.8,105},{19.3,13.8,120},{29.6,28.5,120},{24.4,59.1,120},{41.5,16.2,106},{26.5,19.9,105},{26.1,82.5,105},{35.3,10,106},{21.1,16.3,120},{40.3,15.3,106},{27.5,76.5,105},{24.9,56.3,120},{38.7,31.5,106},{21.1,21.1,105},{35.2,9.6,106},{42.7,20.4,106},{34.6,32.2,120},{39.7,26.9,106},{39.4,28.1,106},{24.9,50.2,120},{16,15.6,105},{36.1,71.5,120},{36.4,69.9,105},{37.3,10,106},{29.3,26.7,120},{29,22.6,105},{27.2,40,120},{24.6,19.6,105},{24.6,19.4,105},{28.9,37.7,105},{27.3,74.7,105},{31.7,36.5,120},{25.4,66.8,105},{32.9,31.5,105},{34.7,34.2,105},{32.4,35.5,105},{31.7,82,105},{28.8,22.2,120},{26.5,74.1,105},{31.8,36.5,105},{34.2,36.6,105},{29.4,37.2,105},{27.9,39,105},{26.9,40.9,105},{27.1,42.3,105},{26.9,44.5,105},{17.7,12.7,105},{27,44.3,120},{27.2,46.6,105},{26,48.6,105},{22.7,48.8,105},{26.6,20.2,120},{40,12.5,106},{24.6,49.9,105},{33.6,33,120},{22.5,52.8,105},{23.1,18.7,120},{39.9,17.8,106},{22.1,55.2,105},{22.8,56.4,105},{41.7,57.9,105},{24.3,59.4,105},{29.3,24.3,105},{41.4,59.4,105},{41.1,60.5,105},{23.8,61.4,105},{33.4,7.7,106},{37.8,10.5,106},{38.5,62.8,105},{23.7,63.1,105},{38.9,11.8,106},{20.6,15.9,105},{26.3,20.6,105},{25.6,67.1,120},{30.1,27.4,120},{32,36.4,120},{26.7,69.9,105},{24.1,19,105},{35.1,36.3,120},{25.9,84.1,120},{26.9,84.9,120},{35.1,36,105},{21.5,18.4,105},{28,21.7,120},{30,28.2,120},{30.4,83.6,120},{25.7,49.3,120},{39.8,22.1,106},{27.9,76,105},{29.4,27.8,105},{33.9,77.9,120},{33.7,78,105},{24.9,66.2,120},{32.4,35.6,120},{27.6,21.4,105},{32.6,80.6,105},{21.8,18.5,120},{34.1,8.8,106},{23.9,65.4,105},{30.7,83.2,105},{27.8,83.5,105},{30.8,6.5,106},{34.5,73.3,120},{29.3,83.6,105},{25.1,58.1,120},{23.2,18.6,105},{40.1,25.2,106},{35,35.4,120},{22.2,55.9,120},{39.3,30.6,106},{31.9,7.4,106},{34.9,10.1,106},{22.1,51.1,105},{32.6,8.2,106},{26,48.8,120},{35.6,8.7,106},{34,74.7,105},{38.6,30.8,106},{26.2,82.5,120},{25.5,20.3,105},{22.2,20.4,105},{24.8,19.7,120},{36.4,70,120},{27.3,38.8,120},{40.4,13.7,106},{22.9,56.4,120},{41.9,16.9,106},{27.7,84.2,120},{42,21.1,106},{26.5,84.7,105},{27.2,42.3,120},{27.3,45.8,120},{39.5,26.5,106},{19.7,14.9,105},{19.1,13.6,105},{22.9,19.8,105},{26.2,58.3,105},{34.1,32.7,105},{29.4,25.6,105},{30.3,28.9,105},},},
["Feralas"]={["Mining"]={{76.7,66.7,207},{27,70.5,208},{25.4,73.1,208},{91.7,45.6,203},{54.6,31.8,208},{57.5,47,208},{92.9,41.7,203},{73.5,64.1,207},{71.8,63.8,213},{55.4,33.6,208},{76.8,62.9,207},{77.8,65.3,207},{77.3,65.7,207},{79.2,65.4,207},{74,64.7,207},{74.5,65.3,213},{72.6,64.5,207},{52.8,60.8,208},{53.6,49.7,208},{54.9,61,208},{78.9,62.8,207},{28.5,67.9,208},{51.5,60.4,208},{78.5,63,207},{54.4,34.2,208},{26,68.9,208},{44.2,25.6,208},{75.8,55.7,208},{52.5,57.2,208},{77.6,63.3,207},{25,66.4,208},{28.7,70.5,208},{77.9,36.2,208},{77.5,34.2,208},{93.2,44,203},{37.7,20.5,208},{52.2,61.3,208},{54.6,63.8,208},{60.3,57.5,208},{52.6,58.9,208},{53.6,54.8,208},{52.4,59.4,208},{74.2,61.8,213},{54,59,208},{51.6,24.8,208},{61.4,84,211},{61.7,84.1,211},{52.4,59.8,208},{76.9,61.6,207},{76.5,33.6,208},{71.9,53,208},{59.4,74.1,208},{55,60.3,208},{27.8,69.2,208},{77.9,40.3,208},{77.2,62.8,207},{26.9,68,208},{62.3,55.6,208},{73.5,62.3,207},{53.3,60,208},{92,49.2,203},{64.9,52.1,208},{90.5,45.1,203},{91.7,43.5,203},{78.2,36.5,208},{91.6,48.1,203},{27.9,68.4,208},{25.5,68.5,208},{53.3,32,208},},["Herbalism"]={{75.7,38.5,415},{61.9,67.2,418},{78.8,38,421},{62.7,30.4,431},{92.1,41.6,409},{71.4,42,421},{40.3,9.1,425},{25.7,67.1,418},{55.7,74,421},{56.4,50.2,414},{91.9,49.3,408},{46.5,61.4,407},{68.3,54.2,415},{51.4,17.1,418},{60.6,67.1,418},{27.2,65.3,414},{64.4,32.1,418},{63.2,73.1,415},{81.6,44.8,415},{53.2,46.5,421},{47.9,48.5,412},{92.8,43.9,408},{49.8,35,414},{76.9,53.6,425},{85.7,45.8,421},{47.8,47,412},{24.8,62.8,407},{53.4,16.3,418},{63.4,49.3,415},{39.9,14.1,418},{61.8,49.6,412},{69,44.8,415},{23.9,63.6,418},{88.7,38,415},{68.6,57,421},{55.2,49.4,421},{73.5,56,415},{60.1,62.3,418},{70.4,38.3,421},{47.1,52.6,412},{56.2,69.6,414},{48.2,14.4,412},{60.8,43.8,415},{40.3,20.3,414},{60.4,69.4,418},{57.3,48.5,425},{75.6,41.2,412},{48.9,5,412},{50.4,35.3,414},{70.6,45,421},{25.5,57.4,407},{25.7,47.8,415},{86.5,45.9,425},{62.4,68.6,414},{26,62.4,407},{61.6,59.4,414},{34.8,35.9,407},{25.4,57.5,407},{29.2,57.8,407},{69.6,59.5,425},{48.5,24.7,412},{73.7,37,412},{64.9,52.8,415},{50.8,30.5,414},{61,56.9,418},{38.7,34.2,407},{69.8,41.6,421},{55.6,57.4,415},{43.7,64.6,407},{46,67.2,414},{45.6,65,407},{80,39.1,421},{60.5,52.1,414},{75,49.3,412},{31.9,57.5,407},{94,46.5,408},{43.9,43.5,407},{55.4,49.6,421},{74.5,39.2,415},{56.9,56.9,414},{39.9,11.1,418},{58.4,51.9,421},{56.8,47.4,421},{44.9,68.5,407},{39.1,22.2,414},{57.2,48.5,425},{48,46.6,412},{56.7,68.9,418},{45.2,70.8,407},{67.8,46.6,415},{48.7,9.4,412},{69.7,43.8,421},{75.8,55.8,414},{43.6,21.9,421},{45.5,57.6,407},{44.7,23.8,415},{61.5,72.8,418},{53.9,7.5,412},{59.6,57.4,418},{60.4,57.5,414},{24,63.4,407},{37.8,23.2,421},{45,26.1,414},{25.5,55.2,418},{48,56.2,414},{60.6,45.5,421},{45.7,52.5,407},{49.5,25,412},{50.2,30.6,421},{44.8,70.7,407},{75.1,35.2,414},{46,50,414},{60.9,75.6,414},{86.6,45.5,425},{76.9,33.6,414},{43.2,40.5,407},{50.9,20.1,418},{48.2,46.3,412},{41.1,12.3,418},{26.5,57.2,407},{70.6,61.4,421},{77.5,56.4,414},{56,62.7,421},{75.1,53.9,421},{38.7,37.6,407},{79.3,48.9,412},{86.5,45.5,425},{46.4,52.7,412},{86.3,38.3,421},{31.2,56.4,407},{56.7,75.2,414},{62.4,52.4,412},{43.3,53.7,407},{61.6,54.4,418},{76.1,63.9,415},{62.3,52.5,412},{81,38.3,415},{49.2,26.9,414},{78.7,36.2,414},{25.7,62.4,407},{56.8,59,414},{46.4,53.2,412},{46.3,57.6,407},{94.2,47,409},{60.5,68.5,418},{29.8,64.2,407},{70.8,64.8,414},{45.9,52.7,407},{92.6,43.5,411},{78,35.4,414},{56.9,65.3,421},{62.3,64.2,415},{83.3,43,415},{82.9,45.6,415},{50,23.2,412},{79.4,44.4,415},{49.9,24.4,415},{67.9,47.9,421},{35.6,35.9,407},{42.1,24.7,421},{61.3,65.9,414},{41.5,21.4,415},{68.9,41.9,414},{60.5,50.8,421},{50.9,45.1,412},{52.4,49.2,421},{47.4,48.2,412},{48.1,11,414},{23.2,66.4,414},{50.7,17,418},{48.8,31,414},{64.8,52.1,414},{75.1,40.4,412},{57.9,48,425},{62.7,29.1,431},{50.5,23.4,425},{73.6,36.8,412},{46,63.2,407},{37.9,31.8,415},{49.9,32.6,425},{49.3,32.4,425},{39.6,23.9,425},{84.4,37.8,425},{62.4,69.9,421},{58.6,60.5,421},{53.4,55.4,425},{76.2,54.3,425},{57.4,47.5,425},{54.3,71.5,421},{25.4,52,418},{72.3,64,415},{60.7,63.7,425},{70.4,47,421},{71.5,43.4,421},{38.2,15.4,418},{42.6,12.4,421},{41.7,16.1,421},{59.2,66.5,418},{49.2,24.9,412},{79.1,35.6,414},{53.1,15.7,412},{59.9,73.4,421},{50.4,15.7,418},{51.3,23.3,421},{51.4,51.4,415},{56.1,54.9,421},{48.4,50.7,412},{41,24.9,414},{59.9,58.4,415},{50.7,25.5,414},{36.8,37.1,407},{66.4,51.2,414},{43.9,47.1,407},{54.1,66.9,421},{80.9,46.8,414},{85.1,37,415},{69.4,39.8,415},{70.9,39.2,421},{47.9,48.9,412},{42.5,49.3,407},{71.6,40,421},{41.4,9.4,418},{60.5,48.6,414},{50,14.6,412},{52.1,15.8,418},{57.8,64.1,425},{82.3,44.3,421},{48.9,48.8,415},{44.8,66.7,407},{27.3,58.1,407},{52,48.2,421},{63.1,73.3,415},{80.7,46.5,414},{59.8,48.5,421},{57.9,50.7,421},{76.5,33.3,414},{53,30.8,415},{26.3,61.3,407},{72,60.3,421},{58.4,55.6,421},{82.6,39.4,415},{38.2,14.3,418},{44.7,73.4,407},{44.6,48.3,407},{72.3,55.8,421},{74.9,58.8,421},{46.2,61.9,407},{57.3,61.2,421},{44.2,50.3,407},{34.7,34.5,407},{24.4,57.9,407},{39.5,8.6,414},{56.4,63.6,425},{76.7,40,421},{30.6,62.9,407},{46.7,20.2,412},{41,39.3,407},{76.7,34.1,414},{66.7,46,414},{64.5,27.1,418},{46.8,24.2,421},{56.2,44.6,418},{26.1,53.9,418},{24.1,63.4,407},{54,11,412},{98,32.2,409},{60.4,64.6,418},{51.6,24.9,414},{98.2,32.2,409},{59.5,70.1,418},{71.2,52.8,412},{74.7,30.3,414},{57,65,421},{91,40.4,408},{47.6,0.6,409},{44.3,45.3,407},{34.4,57.8,407},},["Fishing"]={{44.2,46.5,105},{45,52.5,105},{49.6,52.3,105},{44.1,51,105},{44,40.1,105},{35.1,35.3,105},{44.1,45.1,105},{46.1,53.8,105},{42.9,40.2,105},{48,50.8,105},{47.9,53.1,105},{40.6,38.6,105},{33.6,32.4,105},{39.5,37.2,105},{38.8,33.8,105},{49.3,53.5,105},{36.8,36.3,105},{44.4,47.8,105},{34.4,34.2,105},{41.7,39.8,105},{44.2,43.5,105},{44.3,40.4,105},{44.2,41.6,105},{44.1,49.3,105},},},
["Wetlands"]={["Mining"]={{49.1,61,202},{35.9,45.5,202},{25.8,50.2,202},{50,72.3,202},{30.2,22.2,202},{66.8,60.8,202},{59.8,62.9,202},{47.2,61.9,204},{67.8,56,202},{44.5,41.7,202},{68,74.8,202},{53.4,66.9,204},{61.5,80,202},{61.8,68.2,202},{27.6,31.2,202},{48.3,70.8,202},{34.1,15.2,202},{29.5,28.1,202},{67.8,37.5,202},{47.3,43,202},{34.3,29.1,201},{45.7,64.3,204},{25.4,54.3,202},{60.2,56.9,202},{32.1,27.3,202},{59.6,79.3,202},{36.6,49.9,202},{66.5,30.5,202},{41.7,44.4,202},{50.5,58.4,204},{59.9,61.2,202},{45.4,47.8,202},{48.6,44.8,202},{66.6,74.8,202},{53.4,76.2,202},{61.3,80.3,202},{32.6,44.3,202},{69.7,36.1,202},{33.4,51.1,202},{51.7,46.5,202},{33.8,49.3,202},{44.1,45.9,202},{61.3,68.5,202},{34.9,44.5,202},{66.3,32.8,202},{37.7,43.3,202},{55.9,58.7,204},{19.5,36.5,202},{27.7,37.2,202},{66.8,30,202},{47.7,65.2,204},{30.3,46.8,202},{67,59,202},{27.5,32.3,202},{70.5,44.6,202},{32.6,47.4,202},{47.9,73,202},{37.3,33.3,202},{50.4,72.4,202},{31.4,5.8,203},{28.2,8.1,202},{45.1,42.2,202},{51.8,50.3,202},{53.4,55.7,202},{49.6,58.3,204},{54,77.6,202},{50.7,59.2,204},{67.9,69.6,202},{66.6,66.5,202},{25.1,35.4,202},{51.1,61.1,204},{66,39.4,202},{36.3,32.7,202},{24,59.9,202},{69.8,36.3,202},{68.8,32.9,202},{56.9,44.8,202},{67.9,37.6,202},{49,69.4,202},{54.7,79.4,202},{38.9,46.1,202},{67.5,33.3,202},{66.1,90.8,201},{69.3,31.1,202},{50.4,68.4,202},{22.8,38.9,202},{50.4,75.1,202},{32,26.5,202},{66.6,31.9,202},{27.1,31.7,202},{34.8,51.9,202},{61,70.1,202},{67.8,72.6,202},{54,62.1,202},{64.1,72.7,202},{54.3,58.7,202},{36.6,35.5,202},{27.8,38,202},{71.1,31,202},{20.7,35.2,202},{33,7.7,202},{47.5,60,204},{67.7,54.3,202},{60.3,78.8,202},{45.8,65.1,204},{53.1,62.7,202},{67.3,56.9,202},{31.5,21.4,202},{22.2,30.3,202},{31,22.1,202},{57.5,75.7,202},{48.5,60.3,204},{51.3,79.6,201},{54.1,76.2,202},{55.4,78.1,202},{65.1,75.1,202},{70.4,32,202},{67.6,27.5,202},{67.4,73.4,202},{68.8,35.4,202},{69,52.3,202},{50.6,61.3,204},{23.4,31.8,202},{65.4,32.5,202},{31.8,43.2,202},{48.7,63.1,204},{43.6,22.6,202},{32.9,48.6,202},{63.6,77,201},{54.1,57.7,202},{25.7,35.7,202},{69.3,31.6,202},{68,42.9,202},},["Herbalism"]={{19.2,26.4,411},{43.6,25.3,405},{53.9,43,405},{46.6,18,409},{31.7,22,412},{59.1,24,405},{32,40.9,408},{55.3,42.4,404},{48,17.4,408},{13.1,66,408},{49.1,62.6,408},{77.8,48.8,409},{55.2,36.1,412},{37.7,40.8,409},{22,34.6,412},{56.3,64.2,404},{24.3,51.1,404},{53.2,25.1,405},{45.9,46.6,405},{37.1,16.9,409},{49.7,48.5,411},{51.6,31.8,405},{64.6,37.2,405},{63.8,69.7,412},{27.1,47.5,408},{65.3,73.8,408},{43.1,43.5,411},{24.8,13.6,407},{20.5,19.5,407},{30.3,44.5,408},{67.5,71.7,404},{57.9,35,411},{13.1,57.7,408},{44.1,25.2,408},{52.5,55.3,409},{48.7,16.5,408},{24.9,23.9,404},{48.3,15.9,408},{7.9,62.2,407},{60.1,48.4,405},{49.7,45.8,405},{35.2,31.7,411},{53.9,53.1,409},{34,44.1,404},{12,31.2,407},{5.6,53.1,407},{12.1,41.1,407},{22.7,24.9,405},{35.1,23,408},{53,33.3,404},{42.2,21.5,408},{7.5,47.7,407},{25.9,21.9,412},{48.4,62.8,408},{23,18.4,407},{60.6,57.4,412},{7.3,60.7,407},{43,22.7,408},{44.9,32.2,405},{17.3,27.3,412},{49.4,52,409},{48.6,73.8,408},{35.2,21.8,408},{21.8,27.3,411},{59.7,79.3,408},{66.2,41.1,404},{65,54.3,411},{26.2,25.8,408},{68.8,45.5,405},{65.4,43.1,411},{53.5,62.6,408},{58.9,30.5,404},{66.1,64.2,404},{77.2,40.3,409},{66.8,63.9,408},{61.8,22.8,409},{74.5,45.1,409},{62.6,66.2,404},{24,24.4,405},{13.6,37.3,411},{37,16.7,409},{38.9,25.4,408},{33.5,47.6,408},{34.5,21.8,411},{27,35,411},{52.5,55.2,409},{54.3,38.1,412},{47.4,74.1,409},{68.5,35.1,408},{24.8,33.6,404},{16.1,51.7,407},{47,44.6,408},{53.8,31.2,412},{47.3,74.2,409},{54.2,75.6,408},{49.2,19,409},{61,36,405},{20.1,58.3,407},{41.4,20.8,408},{17.5,37.6,405},{64.7,62.6,411},{53.6,66.7,408},{33.7,11.5,408},{61.1,78,405},{21.8,17.9,407},{23.7,52.8,405},{66.6,38.4,409},{43.6,20.3,409},{69.8,36.2,408},{5.7,48.4,407},{26.5,13.4,407},{39.2,34.1,405},{14.8,27.7,407},{22.9,14.7,407},{20.7,15,407},{45.1,34,412},{28.8,15.7,407},{15.9,34.9,412},{51.5,29.1,411},{65.1,71.1,405},{55.4,28.7,408},{19.4,17.4,407},{50,53.3,409},{61.5,59.4,405},{67.2,36.6,405},{9.5,68.7,407},{15.6,17.5,407},{26.7,17.4,407},{25.5,17.9,407},{18.3,36.5,411},{18.1,20.6,407},{26.1,25.6,408},{14.9,20.6,407},{20.2,30.1,411},{13,21.6,407},{16.8,23.2,407},{59.4,72.6,408},{12.6,24.5,407},{13.6,25.8,407},{44.9,32.6,412},{14.9,26.5,407},{12.9,62.3,407},{14.4,28.1,407},{67,67.3,408},{46.4,27.6,405},{11.3,30.2,407},{47.1,74.9,409},{12.8,32.3,407},{12,34,407},{57.4,23.4,408},{43.6,25.6,408},{23.3,59.4,408},{28.1,44.6,408},{36.1,48.2,404},{10.2,40,407},{21,37.3,405},{12.2,38,407},{66.5,63.6,408},{66.9,42.8,405},{28.2,30.4,411},{43.5,34.8,405},{40.1,28.2,412},{35.3,44.6,408},{39.5,49.5,409},{35.7,51.6,408},{54.2,62.7,408},{69.9,43.5,404},{26.5,48.9,405},{6.1,43.5,407},{13.8,44.1,407},{12.2,44.2,407},{46.9,31.8,412},{12.2,45.3,407},{44.6,23.3,408},{74.4,45.1,409},{66.7,34.2,409},{5.9,70.5,407},{40.6,28.4,405},{29.7,20.5,404},{27.6,26.2,408},{9.6,47,407},{34.1,15.8,408},{31.4,13.4,407},{5,49.6,407},{46.8,18,409},{40.4,32.9,412},{7,50,407},{17.6,52.2,407},{58.2,20.5,409},{34.6,51.3,408},{66.6,59.7,408},{45.3,30.1,412},{27.7,46.4,408},{3.7,54.8,407},{25.4,36.3,412},{19.2,55.7,407},{16.8,55.7,407},{34.6,16,408},{30.4,12.7,407},{5.2,57,407},{6.7,57.4,407},{22.3,61.1,408},{18.3,58,407},{16,59.8,407},{18.7,60,407},{32.1,18.9,412},{60.7,66.7,411},{46.9,15.9,408},{13.8,62.8,407},{62.6,77.8,408},{62.2,32.3,408},{44.6,34.5,404},{68.7,51.3,405},{33,49.7,408},{35.3,19.7,405},{6.4,63.4,407},{53.8,35.3,405},{44.6,31.8,412},{10.6,64.1,407},{52.2,44.7,405},{8.7,64.4,407},{4.9,65.1,407},{62.5,64,412},{31.2,46.5,409},{23,27.9,404},{11,65.1,407},{53.2,64.5,405},{10.3,66.3,407},{32.8,44.6,409},{9.6,67.4,407},{58.8,50.3,412},{66.6,34,409},{45.6,29,412},{49,51.7,409},{53.8,43.1,412},{63.5,73.5,412},{47.5,15.5,408},{4.7,60.4,407},{50.9,38.2,412},{46.3,30.4,412},{7.6,66.8,407},{73.9,35.7,409},{32.3,15.5,404},{63.5,41.1,411},{38.6,30.2,404},{56.2,36.7,405},{33.5,25,412},{12.2,36.1,407},{29,27.8,412},{55.4,46.2,412},{20.7,28.1,412},{67.1,58.3,408},{44.6,29.3,412},{39.5,29.5,412},{53.9,45.1,412},{6.5,54.4,407},{28.4,21.2,412},{49.6,33.3,412},{39.5,35,412},{43.8,20.5,409},{41.4,29,412},{42.5,31.8,412},{27.4,26.4,408},{33.5,51.5,409},{40.1,31.9,412},{63.5,63.6,412},{43.8,33.5,412},{38.8,33.7,412},{39.4,33.9,412},{13,57.2,408},{24.7,54.7,408},{34.1,11.2,408},{45.6,15.6,409},{27,15.9,407},{16.7,63.1,408},{36.8,52.6,409},{60.9,25.2,404},{9.4,57.9,403},{51.6,36.5,412},{63.3,51.2,411},{53.9,29.8,408},{30.5,48.7,409},{55.4,61.7,404},{63.5,31.2,408},{8.7,71.1,407},{22.7,56.3,405},{55.4,44,412},{56.5,45,412},{55.4,29.6,404},{38,20.5,405},{59.2,73.2,408},{40.1,30,412},{18.5,40.5,404},{55.1,45.3,412},{39.3,49.4,409},{41,24.4,411},{35.5,24.5,411},{60.4,50,412},{6.3,68,407},{56.5,30.4,411},{11.3,67.5,408},{13.1,65.5,408},{61.8,53.5,412},{61.9,60.6,412},{54.5,79.3,408},{47.6,31.9,412},{71.3,43.3,408},{40.8,46.8,409},{56.7,48.9,412},{46.5,25.3,411},{61.7,39.2,411},{24.7,28.8,411},{25.1,16,407},{53.6,76.1,408},{49.8,51.2,408},{7.2,42.4,407},{47.9,16.6,408},{65.9,28.3,409},{21.8,51.2,405},{28.5,43.5,408},{55.9,45,412},{66.6,62.4,408},{55.3,66.8,404},{36.1,44.7,408},{31.5,36.2,411},{18.5,32.9,411},{43.6,25.4,408},{11.8,65.3,407},{65.4,47.6,405},{19.1,23.6,412},{53.5,40.9,412},{58.4,43.9,411},{66.4,66.7,408},{35.1,51.7,404},{23.5,48.6,411},{52.7,38.1,412},{33.8,15,408},{62.2,72.8,405},{67.2,52.3,411},{24,17.3,407},{45.4,48.9,409},{52.6,27,405},{65.6,74.1,408},{47.6,15.3,408},{50.6,45.6,409},{52.1,36,404},{13.2,65.5,408},{48.4,61.9,408},{13.1,58,408},{22.2,60.9,408},{40.2,20.5,408},{48.3,18.2,408},{6.1,55.8,407},{32.2,29,408},{50.5,51.8,408},{15.4,31.2,412},{14.6,62.1,407},{31.4,27.2,412},{13.2,65.2,408},{62,66.6,404},{69.5,33.6,409},{48.1,18.2,408},{9.2,46.3,407},{30.8,23.1,412},{49.4,50,405},{61.8,30.5,408},{59.3,32.9,411},{70.8,39,411},{12.1,66.4,408},{59.3,53.2,404},{52.4,47.5,409},{44.5,40.9,409},{18.6,31.2,405},{22.7,21.5,412},{69.6,34,409},{60.7,55.3,411},{29.2,11.9,407},{34.4,27.9,405},{52.6,47.8,409},{16,64.3,408},{24.2,55.8,408},{12.4,65.9,408},{66.4,57.6,404},{55.3,75.6,404},{51.1,31.4,412},{30.5,45.1,408},{47.2,17.9,408},{55.7,33.4,405},{28.2,36.7,405},{69.4,42.8,408},{30.2,43.5,408},{49.5,34.9,412},{44.5,35.5,412},{62.1,22.6,409},{31.6,33.9,412},{28.9,45.4,405},{30,48.6,409},{55.3,55.6,408},{44.4,23.2,408},{46.8,18.3,409},{64.1,30.9,408},{60.9,33.1,411},{15,33.4,411},{32.7,41.1,408},{12.7,57.4,408},{53.6,26.8,404},{37.1,18,409},{57.4,28.7,405},{44.7,26.1,408},{69.2,33.4,409},{28.7,24.7,404},{47.5,74.9,408},},["Fishing"]={{6.9,56.7,107},{12.7,33.5,107},{15.7,26.2,107},{12.8,61.5,107},{27.7,17.3,107},{28.9,15.5,107},{5.9,62.6,107},{17.9,22,107},{25.7,19,107},{32,12.4,107},{13.3,31.6,107},{33.1,11.3,107},{14.2,43.8,107},{21.5,19.4,107},{12.4,36.1,107},{12.1,40.5,107},{18.7,20.8,107},{7.8,63,107},{6.7,54.5,107},{12.1,38.6,107},{5.9,56.6,107},{14.9,27.5,107},{10.8,63.1,107},{19.9,20.2,107},{12.2,44,107},{5.3,58.4,107},},},
["Teldrassil"]={["Mining"]={},["Herbalism"]={{36,35.1,401},{40.8,46.5,402},{55.3,66.8,401},{44.2,39.4,401},{64.6,70,402},{37.1,66,403},{69.9,53.5,402},{40.4,27.1,402},{51,62.4,401},{60.1,61.3,401},{54.6,72.7,402},{37.7,42.4,402},{68.8,51.2,402},{50.3,73.8,403},{41.2,79,401},{39.1,36.2,402},{56.4,74.1,402},{58.8,74.3,403},{55.3,72.6,402},{53.3,60.2,402},{40.1,26.5,403},{63.1,71.6,401},{38.3,79.4,403},{40.8,54.1,402},{46.5,45.8,401},{36.4,40.7,402},{69.5,55,402},{38.8,61.5,404},{46,41.1,401},{49.4,73,402},{51.5,59.5,401},{43.4,71.1,402},{63.7,61.3,401},{40.1,55.5,401},{35.1,39.8,403},{47.4,54.7,402},{57.5,64.9,401},{49.2,61.6,402},{42.4,25.1,402},{51.4,52.4,402},{37.9,48,401},{40.4,63.3,403},{63.7,63.6,401},{41.6,53.2,401},{43.8,45.9,401},{52,69.2,402},{36.6,37.3,402},{55.1,66.6,401},{41.8,34.1,404},{47.2,45.1,404},{45.8,53,404},{67.7,53,404},{65.4,53.4,404},{69.4,56.4,404},{50,57.6,404},{65.3,64,404},{53.5,66.1,404},{69.6,58.8,401},{42.5,78.7,402},{62.1,69,404},{53.5,70.5,404},{68.8,61.6,402},{49.7,76.8,401},{49.6,72.2,404},{41.8,76.1,404},{38.3,45,401},{38.5,59.5,402},{49.1,78,404},{45.1,25.9,403},{39.6,29.6,403},{39.8,59.4,403},{47.8,33.4,403},{53.1,62.4,401},{34.7,35.8,403},{39.9,35.9,403},{44.7,39.3,403},{44.6,55.2,401},{47,41.3,403},{36.3,42.3,403},{57.6,70.6,401},{41.1,48.5,401},{52.6,73.8,401},{49,62.7,403},{44.8,46.7,403},{44.3,48.6,403},{45.1,53.7,403},{41,33.4,401},{52.9,67.1,401},{67.1,59.6,401},{40.1,69.2,401},{49,58.3,402},{46.3,74.3,402},{48.1,45.1,403},{67.6,58.1,402},{43.1,74,401},{45.9,43,401},{44.7,54,402},{61.8,61.3,401},{39.6,61.9,402},{49.3,55.4,401},{43.5,39,402},{40.5,60.3,401},{67.9,51.8,401},{66.1,52.7,402},{61.1,62.3,402},{46.4,76,402},{65.5,51.8,401},{46.6,39.7,402},{60.6,53.9,401},{35.5,28.5,402},{38.6,64.9,402},{49.6,68.1,401},{45.1,55.5,403},{67.6,61.8,401},{59.1,62.8,402},{41.4,30.6,403},{45.9,36.6,401},{64.1,70.9,402},{40.8,80,403},{45.4,27.7,402},{51.7,73,403},{39.1,80.4,402},{57.5,66.3,404},{44.9,75.3,403},{61,58.1,401},{56,72,401},{41.1,77.3,402},{56,77,402},{38.7,69,403},{38,25.8,402},{64.1,65,402},{51.1,67.1,403},{35.3,31.7,402},{44.2,29.4,401},{62.8,67.8,402},{45,31.5,401},{41.7,28.6,401},{46.7,47.1,402},{46.3,42.2,402},{45.2,76,401},{41.1,56.3,403},{66.2,50.9,402},{50.3,52.7,402},{38.6,67.1,401},{54.8,63.6,401},{41.8,44.6,401},{46.3,78.5,402},{62.6,64.3,402},{57.8,77.2,402},{65.5,61.3,402},{37.9,43.2,401},{60.9,55.2,401},{47.9,56.4,403},{40.8,63.4,402},{39.7,71.1,403},{37.3,40.3,401},{56.5,54.7,402},{62.6,73.7,402},{54.7,67.7,402},},["Fishing"]={},},
["Darkshore"]={["Mining"]={{30.6,92.4,204},{50.3,81.7,205},{60.7,19.7,204},{56.1,27.5,204},{37.8,63.2,204},{54.5,33.5,201},{44.9,35.8,204},{45.9,57.3,202},{39.5,61.1,204},{62.9,9.3,204},{57.8,24.2,204},{44.1,17.8,202},{42.7,73.4,204},{60,15,204},{47.1,20.3,202},{43.6,85.3,204},{52.5,18.7,204},{61.7,22.7,201},{32.3,78.7,204},{56,34.5,204},{45.8,54.5,204},{28,95.1,204},{40.5,40,201},{51.7,14.8,201},{26.1,97.4,204},{54.7,84,205},{33.2,84.1,204},{59.5,13.4,204},{51.9,33.2,201},{47.5,45.7,201},{40.1,71.4,204},{36.7,79.7,204},{48.1,42.5,204},{60.3,8.6,204},{49.3,27.1,204},{37.8,49.4,204},{62.2,15.9,204},{42.6,24.9,201},{53.8,33.4,204},{36.2,90.7,204},{55.6,35.6,204},{56,18.7,201},{41.3,39.5,204},{60.6,25.4,204},{36.1,85.6,204},{48.1,29.1,204},{59.3,19.6,204},{51.9,28.4,204},{39.8,85.5,202},{45.2,85.4,201},{59.1,38.3,205},{54.5,45.4,205},{46.7,53.5,204},{52.1,62.4,205},{61.5,21.5,204},{32.3,89.6,204},{34,72.6,204},{55.4,28.5,204},{47.8,32.8,204},{61.7,18.9,202},{49.7,19.5,202},{60.3,20.4,202},{60.2,20.6,202},{38.6,24.8,202},{51.3,30.3,202},{35.8,85.4,204},{40.3,26.6,204},{53.8,18.8,201},{42,30.9,202},{42.6,67.3,202},{45,85.6,202},{60.6,16.7,204},{50.4,37.1,204},{45,88.1,202},{61.4,8.8,204},{35.5,55.6,204},{61.1,9.8,204},{55,33.6,201},{62,12.4,204},{46.1,27.3,204},{26,95.8,204},{33.6,88.5,204},{44.5,85.4,204},{55.4,19.6,204},{44.4,81.1,204},{41.8,96.3,204},{42.5,52.7,204},{55,34.5,204},{31.1,87,204},{33.2,81.2,204},{34.7,56,204},{35.3,86.4,204},{39.1,81.4,204},{30.2,91.3,204},{44.7,61.2,204},{33.9,79.6,204},{34.1,85.9,204},{61.7,16.5,204},{38.6,88.9,204},{43.1,71.8,201},{31,94.3,204},{48.8,20.7,204},{43.5,36.8,204},{49.4,34.3,204},{57.3,14.8,204},{33.1,89.6,204},{43.6,46.2,204},{54.2,34.4,204},{23.8,96.7,204},{45.6,53.3,204},{43.5,52,204},{41.7,99.6,204},{56.4,35.4,205},{44.2,27.1,204},{43.1,22.3,204},{45.5,22.6,201},{40.4,29.3,204},{44.2,78.7,204},{51.4,37.3,201},{53.9,32.9,204},{39.5,73.5,204},{46.4,45.3,204},{52.9,23.1,204},{36.4,86.1,204},{56.2,25.4,204},{41.4,35.1,204},{32.4,86.4,204},{50.6,21.7,204},{50,27.9,204},{53.9,33.5,204},{42.2,58.3,204},{35.2,85.2,201},{46.2,38.9,204},{37.3,59.4,204},{56.9,27.7,204},{59.2,27.1,204},{43.1,45.3,204},{48.3,40.3,204},{37.9,72.8,201},{54.2,33.6,204},{42.9,86.6,204},{59.8,24.5,204},{54,32.4,204},{45,89.6,204},{54.5,32.9,204},{38.9,33.1,204},{44.3,70.8,204},{35.9,86.4,204},{43.1,98.5,204},{44.6,50.3,204},{43.5,38.4,204},{46.1,50.2,204},{46.8,50.2,204},{44.4,72.6,204},},["Herbalism"]={{35.9,47.5,404},{36.1,64.9,407},{36.1,51.8,407},{40.7,34.3,402},{56.9,18.6,404},{35.7,50.4,407},{39.7,67.3,405},{37.8,34,407},{43.5,60.7,408},{38.9,86.7,404},{39.3,39.7,405},{41.2,33.7,402},{39.1,25.5,407},{46.1,42.1,405},{38.5,49.2,404},{54.1,29.9,402},{38.3,36.6,404},{43.7,38,405},{44.8,49,404},{52.5,28.6,405},{47.1,37.7,405},{54.4,15.1,407},{44.4,30.2,402},{37.8,88.8,402},{35.5,78.7,407},{43.6,27.4,402},{49.7,27.1,402},{44.3,91.8,401},{60.8,15.5,401},{41.8,83.5,405},{56.9,27.1,402},{37.2,34.7,407},{39.3,89.4,405},{43.8,26.1,404},{38.9,70.9,405},{31.4,98.8,407},{43.4,28.7,402},{49.1,23,404},{43.4,47.4,401},{42.1,67.9,403},{38.3,84.7,402},{57.5,26.9,402},{35,77.4,407},{26.4,95.9,407},{39.8,64.2,405},{34.6,89.9,404},{46.3,37,408},{32.7,30.4,407},{55.1,84.8,428},{57.4,40.9,426},{45.9,25.7,402},{43.2,24.1,404},{36.1,56.3,407},{48.1,38.6,405},{56.9,26,404},{60.4,13.8,405},{33.2,97.7,408},{35.7,57.3,407},{59.2,17.9,404},{39.5,72.3,403},{58.4,13.5,404},{36.6,68,407},{31.4,93.7,408},{40.6,71.8,402},{36.2,65.8,407},{36.2,69.8,407},{39.6,52.4,405},{46.4,36.3,408},{59,25.6,402},{41.9,42.7,404},{53.6,14.9,407},{38.6,33.8,404},{42,72.8,404},{42,62.9,408},{39.3,62.9,404},{46.5,49,401},{45,37.4,408},{41.2,59.3,402},{39.1,65,405},{41.2,62.5,405},{56.4,84.8,424},{60.2,15.6,408},{57.2,17,404},{44.5,41.2,408},{35.8,64.1,407},{38.3,37.6,404},{52.9,32.8,402},{53.3,25.9,402},{48.2,22.9,404},{36.3,98.8,408},{39.4,38.7,402},{45.5,40,408},{36.5,66.2,407},{36.1,49.3,407},{43.1,66.9,403},{30.7,87.8,407},{43.1,84,401},{34.9,79.6,407},{53.8,23.7,402},{36.4,69,407},{34.1,85.9,403},{39.3,49.5,402},{35.6,90,405},{38.9,47.3,401},{58.3,14.6,404},{42.1,67.3,404},{44.1,27.2,402},{33.7,77,407},{45.2,55.3,401},{36.9,84.7,408},{56.9,41.7,428},{39.8,39,404},{38.6,50.6,402},{53.6,23.9,402},{56.4,41.9,427},{39.2,33.3,404},{31.5,99.4,407},{23.6,94.3,407},{38.6,55.4,404},{47,52.6,403},{40.5,77.2,402},{42.4,56.5,404},{56.2,20.8,401},{28.8,95.4,418},{31.8,99.7,418},{41.8,65.5,402},{51.7,15.7,407},{39.7,72,403},{54.6,16,407},{46.1,18,407},{48,20.3,407},{30.1,92.5,407},{46.8,20.4,407},{41.9,20.9,407},{41.4,39.5,403},{43.4,57.4,408},{41.4,21.1,407},{35.5,54.1,407},{50.3,22,407},{43.8,27.5,402},{38.3,77.4,404},{35.2,83.5,408},{35.5,26.8,407},{54.1,22.2,404},{60.2,18.7,404},{39.8,26.8,407},{38.4,28,407},{37.7,61,404},{36.5,28.6,407},{34.6,81.8,404},{41.7,37,401},{41.8,28.8,407},{42,30.2,407},{48.6,23.4,404},{39.2,39.7,402},{32.8,30.9,407},{44,89.8,404},{54.7,26.3,402},{42.4,57.3,408},{39.6,31.3,407},{44.9,60.4,405},{36.3,67.2,407},{32.9,31.5,407},{35.9,77.3,407},{30.6,98.2,407},{31.3,98,407},{35.3,71.6,407},{38,31.8,407},{30.9,33.7,407},{57.3,28,405},{39.7,82.4,402},{33.8,34.8,407},{35.5,72.9,407},{33,53.7,407},{58.8,23,404},{37.1,36.6,407},{56.8,27,402},{43.1,22.4,402},{62,22.3,404},{60.6,16.6,408},{43.4,79.8,401},{32.6,38,407},{36.2,63.3,407},{33.5,38.7,407},{40.8,32.7,404},{35.7,39.3,407},{35.8,75,407},{53.3,30.6,404},{34.3,42.9,407},{36.1,44.8,407},{39.6,63,405},{35.2,84.8,404},{34.9,46.5,407},{30.9,46.8,407},{35.2,74.1,407},{56.7,24.4,401},{30.9,98.5,407},{35.4,56,407},{30.4,48.3,407},{38.6,84.5,402},{40.7,80.4,405},{36.1,85.6,408},{42.6,60.5,408},{35.8,48.4,407},{36.3,50.5,407},{36.3,35.9,407},{30.9,99.8,407},{35.1,90.8,403},{41.8,96.2,405},{33.6,63.7,407},{32.4,90,403},{43.9,64.2,404},{35.2,53.7,407},{37,74.1,404},{39.3,58.8,405},{54.2,29.5,404},{42,50.5,404},{38.5,92.1,405},{30.1,70.8,407},{47.6,41.1,401},{39.1,75.6,405},{29.9,54,407},{50.3,21.3,407},{43.2,43,401},{36.2,86.8,408},{36.4,47.8,404},{36.3,55.2,407},{58.7,23.6,404},{61,24.6,405},{44.9,55.5,402},{36,47.2,407},{36.5,61.1,407},{45.2,43.4,402},{36.6,57.7,407},{45.2,32.7,405},{42.1,46.9,405},{41.7,98.7,405},{34.5,58.9,407},{36.7,56.8,407},{36.1,61.8,407},{45.2,43.9,405},{44.4,60.9,404},{36.3,54.6,407},{36.4,64.1,407},{29,99.1,407},{63.1,6.6,405},{61.6,21.2,403},{31.7,91.6,407},{42.4,69.8,405},{40.3,61.6,405},{36.1,70.5,407},{32.3,84,407},{43.1,27.7,402},{45.6,37.1,408},{45.4,42.6,402},{39.1,78,401},{36.8,67.1,407},{30.2,70.9,407},{35.8,71.2,407},{38.5,87,404},{43,89.3,402},{42.8,81.8,405},{35.1,72.4,407},{38.7,51.2,402},{37,35.3,407},{49.9,35.1,402},{35.8,73.4,407},{37.7,82.6,401},{36.1,74,407},{35.2,83.7,408},{44.5,36.7,408},{30.1,99,407},{35.9,76.4,407},{39.6,83.3,405},{48.3,27.9,402},{35.2,79.2,407},{42.3,43.7,404},{32.7,79.4,407},{36.3,80.4,407},{53.6,21.6,404},{37.5,49.4,404},{39.2,80.8,403},{32.2,80.6,407},{49.8,30.9,401},{31.2,80.9,407},{35,81.7,407},{33.7,82.7,407},{36.5,68.5,407},{30.7,84.7,407},{43.2,58,408},{56.2,21.7,408},{54.3,30.9,404},{47.8,32.2,405},{43.1,57.6,402},{41.4,47.6,405},{32.8,87.6,407},{30.2,93.4,407},{38,36.5,404},{43.1,37.8,405},{55.3,88,424},{45.8,30.3,405},{30.4,96.1,407},{22.5,96.2,407},{49.4,27.9,402},{37.6,34.9,404},{30.2,98,407},{44.3,50.3,402},{39.1,53.9,402},{37,31.8,407},{47.6,30.3,405},{36,46.9,407},{45.7,42.7,405},{61.7,20.5,408},{31.1,98.6,407},{37.9,70.3,405},{37.9,57.2,404},{24.7,99,407},{35.6,75.7,407},{31.6,99.8,407},{42.5,38.1,405},{45.6,92,403},{56.2,20.2,408},{56.8,20.3,408},{59,20.7,408},{39.6,54.9,405},{43.2,66,405},{36.3,86.1,404},{57.6,21.6,408},{46.3,23.8,401},{38.6,87.1,408},{58.2,21.6,408},{59.6,22,408},{41.1,34.4,405},{43.2,38.7,404},{45.8,35.3,408},{45,36.7,408},{43.5,54.4,401},{35.5,70.2,407},{56.9,25.1,402},{47.9,37.1,408},{47.9,30.9,405},{33,31.2,407},{58,27,402},{44.2,29.6,402},{61.1,12.6,401},{43.9,58.4,408},{43.7,62.3,408},{57.6,15.7,401},{39.6,68.9,405},{39.9,75.2,402},{36.6,62.2,407},{54.2,20.7,404},{42.7,46.4,403},{52.2,32.8,402},{38.4,88.9,403},{41,34.5,402},{49.9,27.5,405},{30.8,91.8,408},{35.5,84.7,408},{52.5,27.1,405},{58.3,14.3,405},{41.9,84.5,402},{31.2,37.6,407},{32.9,83.7,403},{59.4,16.2,408},{34,94.7,408},{62.4,20,405},{34.2,71.2,407},{39,84.2,402},{44.4,62.9,403},{30,98.1,407},{57.1,19.1,404},{44.4,39.9,408},{36,98.8,408},{47,24,405},{42.6,71.9,403},{47.1,34.2,405},{59.6,27.2,403},{48.7,22.6,404},{40.1,72,402},{39.6,37.1,405},{30.7,96.2,407},{39.9,52,402},{37.8,66.9,404},{32.2,85.6,407},{30.5,97.5,407},{45.2,59.3,405},{43.8,57.2,402},{42.2,88.1,402},{41.8,31.4,407},{44.6,46.6,402},{44.2,55.1,405},{39.7,62.2,402},{44.1,67.2,405},{40.9,81.8,405},{41,38.5,404},{42.1,62.4,408},{44.4,88.2,403},{35.2,84.7,404},{44,41.2,402},{35.6,77.8,407},{43.5,27.5,402},{37.3,70.6,404},{61.8,13.1,404},{44.1,45.3,402},{41.9,67.9,405},{52.3,30.7,402},{41.5,35.5,403},{42.3,54.5,402},{41.3,62.6,408},{42.8,51.3,402},{36.9,85.6,408},{57.7,27.7,402},{43.6,85.2,403},{36.4,91.6,404},{44.7,42.2,402},{47.3,48.8,403},},["Fishing"]={{35.8,48.9,107},{37,36.1,107},{35,71.6,107},{32.5,41.3,107},{41.7,29.6,107},{35.8,56.2,107},{36.5,61.9,107},{49.9,20.6,107},{31.5,41.9,107},{43.4,20.1,107},{37.6,34.1,107},{42.2,20.6,107},{42.1,31.3,107},{36.5,53.6,107},{31.9,82.4,107},{41.6,26.6,107},{35.9,59.8,107},{46.1,20,107},{47.6,20,107},{48.7,20.3,107},{35.9,69.8,107},{51.9,20.6,107},{45.1,20.6,107},{35.9,46.7,107},{32,83.8,107},{41.5,25.3,107},{33.8,82.7,107},{41.5,23.6,107},{40,31,107},{35.9,51.5,107},{38.3,31.3,107},{34.2,80,107},{41.9,21.4,107},{36.5,55.3,107},{34.7,43.5,107},{42,28.2,107},{36.7,38.6,107},{36.5,57.1,107},{32.4,42.3,107},{36.2,64.2,107},{35.9,74.1,107},{36.6,67.4,107},{33,81.9,107},{34.5,42.3,107},{35.8,77,107},{33.3,41.7,107},},},
["Winterspring"]={["Mining"]={{69.4,38.5,215},{64.6,70.4,215},{66.5,37.5,215},{53.3,44.4,208},{56.3,25.6,215},{69,38.6,215},{54.8,10.5,215},{70.8,39.7,215},{53.7,57.3,215},{65.5,79.5,215},{54,39,215},{60.3,78.8,215},{59.6,63.4,215},{57.1,89.5,215},{54.2,13.3,215},{53.4,53.7,208},{48.2,8.8,215},{24.6,38.1,205},{52.2,85.6,215},{57.8,61.1,215},{69.7,38.6,215},{58.4,88.8,215},{55.9,14.6,215},{63.2,67.7,215},{64.6,29.7,215},{37.7,38.1,208},{69.6,41.8,215},{54.3,55.4,215},{65.7,58.8,215},{64.6,34.6,215},{62.8,71.1,215},{55.7,48.9,215},{61.7,67.8,215},{54.7,49.7,215},{41,35.2,208},{60.6,82,215},{53.6,84.5,215},{53.5,89.2,215},{51.5,40.3,208},{71.2,81.2,215},{50.3,43.7,215},{51.3,45.1,208},{59.5,77.6,215},{31.8,47.6,208},{53.4,51.6,208},{61.3,68.9,215},{66.3,61.5,215},{56.6,77.6,215},{58.9,78.3,215},{52.3,55.7,208},{56.3,49.1,215},{70.7,37.3,215},{57.1,55.3,215},{49.9,41,208},{67.3,39,215},{61.1,64,215},{58.9,78.2,215},{47.8,6.6,215},{51.1,7,215},{24.6,34.9,205},{69.1,39.8,215},{48.3,9.2,215},{66.2,69.2,215},{55.9,44.7,215},{56.8,89.9,215},{64.8,68,215},{60.6,15.9,215},{50.4,15.9,215},{59,84.4,215},{50.3,16.9,215},{57,42.4,215},{59.4,67.8,215},{55.5,43.6,215},{51.5,18.6,215},{59,88.6,215},{48.7,6.4,215},{59.4,86.3,215},{57.3,32.8,215},{56.5,42.7,215},{64.6,60.8,215},{68,35.6,215},{56.9,50.4,215},{49.3,14.3,215},{60.7,54.1,215},{62.4,82.7,215},{60.1,62.4,215},{55.7,44.3,215},{68.8,37.3,215},{60.5,68.3,215},{67.7,38.6,215},{61.2,80.4,215},{55.7,51.6,215},{70.2,39.8,215},{53.8,86.7,215},{61.1,84.3,215},{66.7,28.2,215},{52.1,39.5,208},{61.7,78.6,215},{65.3,58.6,215},{24.5,39.9,205},{67.7,41.5,215},{55.1,39.2,215},{56.9,44.6,215},{59.6,87.9,215},{57.4,72.5,215},{70,38.2,215},{66.7,60.1,215},},["Herbalism"]={{34.6,37,429},{67.7,40.5,427},{43.2,37,429},{82.2,79.4,426},{81,80.3,426},{30.5,35.2,427},{56.1,43.6,429},{50.4,41.8,429},{32.4,43.9,429},{61,61.3,429},{38.5,44.4,429},{61.4,73.1,429},{65.6,63.3,431},{60.2,47.8,427},{62.1,71.2,429},{63.2,68.3,429},{65.1,48.4,429},{56,25.5,427},{24.7,40.2,424},{50.2,43.1,429},{62.8,61.8,429},{57,53.2,429},{42.8,47.3,427},{65,51.7,429},{48.5,35.5,427},{47.7,8.1,427},{51.1,21.7,429},{58.4,53.1,429},{43,34,429},{51.8,26.2,427},{56,33.5,427},{31.4,34.9,427},{47.2,37,429},{64.4,65.2,429},{60.1,54.3,429},{60.9,68.3,429},{52.9,27,427},{44,36,429},{63.9,39.6,429},{28.3,39.1,429},{41.1,43.4,429},{62.3,69.3,429},{31.1,47.8,429},{31.1,35.5,427},{67.2,45.8,427},{63.3,57.4,429},{59.1,61.3,429},{51.8,37.9,427},{59,20.8,429},{64.3,68.5,429},{60.5,62.3,429},{44.4,37.6,429},{58.1,42.7,427},{36.3,41.6,429},{56.6,32.7,427},{60,72.5,429},{60.7,65.8,429},{39.1,34.8,427},{37.6,35.5,427},{51.5,40.9,431},{64.1,68.7,429},{38.9,36.9,429},{67.5,42.2,431},{43,37.1,429},{29.5,47,427},{59,61.4,429},{49.1,17,427},{28.7,40.2,429},{30.4,35.5,427},{62.4,61.6,429},{53.2,42.6,429},{63.1,70.4,429},{63.1,31.9,427},{60,54.3,429},{71.1,81.2,427},{31.3,37.1,429},{61.9,53.1,427},{61.5,63.2,429},{48.1,43.3,427},{50.8,21.9,427},{66.4,54.7,429},{41.4,45.4,427},{53.7,42,429},{68.3,27.3,429},{68.6,32.3,429},{52.9,26.9,427},{58.2,67.1,427},{57,40.2,429},{67.4,38.5,427},{44.8,38.1,429},{52.4,40.3,431},{43.2,36.8,429},{35.9,41.5,429},{61.5,65.3,429},{60.7,56.1,429},{59.9,62.4,429},{60.3,57.1,429},{30.7,45,429},{59.9,58.1,429},{50.3,7.5,431},{49.2,18.4,427},{65.2,39.5,429},{59.4,58.7,429},{31.8,35.4,427},{36,41.9,429},{24.7,42.5,424},{59.4,59.2,431},{54.4,30.4,429},{64.3,68.9,429},{52.8,27.5,431},{59.7,58.3,429},{29.6,47.1,427},{29.4,46.8,427},{63,68.3,429},{50.8,21.3,427},{60.7,73.7,429},{59.6,67.5,429},{40.1,44.5,427},{60.7,53.9,427},{58.7,59.5,427},{56.8,27,427},{60.2,66.8,429},{61,65.3,427},{46.4,46.3,427},{43.3,42.5,429},{57.1,34.1,427},{68.9,51.1,427},{69.7,35.7,427},{64.7,50.2,429},{30.4,35.7,427},{65,47.7,429},{63.9,39.9,429},{58.1,60.7,427},{25.2,39.2,424},{58,54.4,429},{47.3,36.1,429},{61,61,429},{45,43.1,427},{51.8,46.8,427},{69.4,33.9,427},{57.6,49.5,431},{56.8,69.7,427},{54.5,30.2,429},{60.6,73.2,429},{54.1,45.1,427},{56,25.2,427},{51.7,46.9,427},{63.6,32.2,427},{67,45.8,427},{59.7,62.5,429},{29.8,39.6,429},{55.1,30,429},{60.4,62.2,429},{47.6,35.5,429},{49.4,9.4,431},{30.7,35.5,431},{68.3,36.6,431},{37.7,36.1,427},{67.4,41.4,431},{50.7,42.2,431},{60.8,73.3,429},{40.2,44.2,431},{59.9,59.6,431},{55.1,44.4,429},{64.8,62.9,431},{65.1,64.3,431},{44.6,46.2,427},{62.2,47.2,427},{55.7,33,427},{63.1,72.8,431},{64,73.8,431},{62.4,74.3,431},{42.9,36.8,429},{64.8,37.7,429},{58.6,13,429},{41.3,43.3,429},{56.8,16.4,429},{31.4,46.5,427},{56.7,50,429},{59.5,17.7,429},{62.1,47.3,427},{52.5,36.8,427},{59.7,58.2,429},{66.6,53.2,429},{53.4,18.7,429},{67.2,20.5,429},{39.8,34.9,427},{61.5,23.6,429},{66.2,69.7,427},{58,54.6,429},{60,24.5,429},{60.7,72.9,429},{60,72.8,429},{57,27.4,427},{64.2,38.4,429},{68.4,30.2,427},{60.4,58.4,429},{58.9,28.1,429},{54.2,44.1,429},{64.6,29,429},{60.9,65.1,427},{54.5,30.1,429},{65.8,30.7,429},{61.5,65.1,429},{61.4,72.2,429},{56,33.6,429},{69.9,36.4,427},{58.4,49,429},{38.7,45.3,427},{58.2,35,429},{38.8,35,429},{49.2,8.6,431},{48.8,18.7,427},{46.7,36.2,429},{42.5,34.9,427},{34.3,44.9,429},{67.9,39.3,427},{64.8,72.4,429},{50.8,42.4,429},{48,36.4,429},{59.8,62.3,429},{54.4,29.7,429},{42.8,36.8,429},{65.5,72.1,429},{41.9,34.8,427},{49.4,7.3,429},{60.5,62.2,429},{61.6,73,429},{67,67.1,429},{42.8,36.9,429},{43,36.9,429},{54.7,44.3,429},{58.1,53.1,429},{56.2,48.4,429},{29.8,39.5,429},{50.1,41.2,429},{59.9,53.5,429},{61,71.1,429},{66.9,20.7,427},{82.2,79.5,426},{47.7,44.6,427},{67.6,43.4,431},{38.4,45.7,427},{47.9,34.8,427},{43.9,38.4,429},{63.8,66.6,427},{68.9,37.1,427},{57.1,16.3,427},{35.9,45.1,427},{62.9,19.9,427},{44.7,38.2,429},{82.1,79.6,426},{57.2,16.8,427},{51.2,38.6,429},{61.6,65.4,429},{52.2,46.6,427},{65.6,26.5,429},{44.5,46.2,427},{63.3,33.5,427},{54.9,13,429},{62.3,61.5,429},{56.9,40.5,429},{47.7,35,427},{61.8,58.7,429},{31.7,45.2,427},{57.7,49,429},{47.9,36.3,429},{55.9,54.6,427},{40.8,39.2,427},{59.4,72.2,429},{53,42.5,429},{50.5,40.7,431},{47.1,36.7,429},{52.5,26.9,427},{63.9,67.2,429},{63.4,68.5,429},{46.3,46.2,427},{60.1,72.6,429},{65,28.8,429},{59.2,60.3,431},{54.3,44.4,429},{55.4,44.8,429},{60.8,53.7,427},{38.4,44,429},{54.9,47.2,429},{64.6,22.3,427},{65,48,429},{47.3,37,429},{29,40.2,429},{53.8,42.1,429},{62.4,61.4,429},{58.1,49.8,429},{64.6,50.1,429},{58,24.8,429},{56.8,51.5,429},{61.4,63,429},{51.8,26.3,427},{56.2,51.7,429},{48,44.7,427},{29.3,46.8,427},{58.8,52.8,429},{61,54.9,429},{58.9,53,429},{63.6,24.8,427},{69,33.1,427},{42.6,34.7,427},{61.7,23.6,429},{61,54.8,429},{61.8,58.5,429},{56.7,41.3,429},{62.8,61.9,429},{43.3,36.9,429},{69.7,37.6,427},{60.1,54.9,429},{56.5,43.7,429},{61.6,68.2,429},{65.2,64.2,427},{41.9,34.9,427},{57,12.6,427},{43.6,37.6,429},{59.4,71.9,429},},["Fishing"]={},},
["Thousand Needles"]={["Mining"]={{36.3,30.7,203},{12.1,33.1,203},{52.7,47.1,203},{37.4,56.4,203},{58.4,55.3,203},{39.1,33.8,203},{67.2,58.2,203},{32.4,30.8,203},{36.4,37,203},{59.4,49.3,203},{43.4,33,203},{15.3,30.9,203},{35.2,28.8,203},{76.2,94,203},{37.3,54.1,201},{47.5,58.6,203},{25.8,55.2,203},{23.1,38.9,202},{65.8,51.8,203},{43.9,60.2,203},{63.7,86.4,207},{22.1,24.3,203},{20.5,33.8,203},{67.2,51.2,203},{41.8,36.7,203},{55.3,49.3,203},{57.5,57.4,203},{53.7,46.4,203},{19.7,40.5,203},{33.9,34.6,203},{62.9,45.6,203},{25.3,27.7,203},{35.2,50.7,203},{19.4,32.3,203},{44.1,36.4,203},{42.3,36.1,202},{32.3,48.8,203},{64.6,50,203},{14.7,34.4,203},{40.1,57.7,203},{31.9,39.9,203},{64.9,84.4,207},{56.1,47.8,203},{31.3,50.5,203},{37.2,30.4,203},{68.7,54.2,203},{30.3,27.1,203},{25.7,33.1,203},{69.4,84.9,207},{62.1,59.9,203},{59.1,47.4,203},{32,52.6,203},{88.7,80.7,202},{19.6,25.9,202},{15.2,34.6,203},{45.2,59.1,203},{28.1,28.1,203},{32.1,46.6,202},{51.2,56.8,203},{45.5,39.5,203},{29.8,51.2,203},{25.4,45.2,203},{27.5,41.9,203},{27.3,54.7,203},{40.5,33.4,203},{35.1,55.6,203},{11.9,31.7,203},{25.7,52.6,203},{59.1,49.5,203},{26.8,56.1,203},{59.4,49.7,203},{66.3,86.4,207},{27,52.1,203},{28.5,39.1,203},{23.7,44.8,203},{25.6,24.1,203},{48.2,58.7,203},{38.2,55.1,203},{66.1,49.2,202},{40.3,38.7,202},{26.7,55.4,203},{14.3,27.1,203},{63,53.4,203},{26.1,25.1,203},{39.5,35.9,203},{44.2,33.5,203},{15.8,18.9,203},{23.8,22.2,203},{34.3,27.9,203},{27.2,45.7,203},{69.3,82.8,207},{74.7,94,203},{17.2,31,203},{68.9,54.9,203},{26,54.6,203},{26,42.3,203},{65.3,87,207},{20.7,37.8,203},{40.5,41.1,203},{42.4,33.5,203},{77.9,87.5,203},{43.4,60.6,203},{43.8,39.8,203},{80.1,63.5,203},{37.5,56.7,203},{29.1,22.3,203},{26.2,38.3,203},{89.6,77.2,203},{75.3,51,203},{68.4,77.9,203},{55.4,51.1,203},{64.5,60.6,203},{64.4,46.3,203},{89.2,74.4,203},{69,86.8,207},{31.6,27.6,203},{44.1,39.4,203},{17.5,20.6,203},{37.1,37.9,203},{43.2,51.7,203},{77.7,62,203},{55.1,50.9,203},{38.2,55.3,203},{22.7,41.1,203},{14.3,27.2,203},{24,42.5,203},{69.9,92.1,203},{64.5,85.7,207},{45,41.5,203},{18.2,36.6,203},{37,54.3,203},{15.2,40.3,203},{26.4,39.9,203},{47.1,42.2,203},{26.4,55.4,203},{35.4,32.4,203},{34.8,52.9,203},{46.3,41,202},{21.4,23.7,203},{14.6,25.5,203},{36.1,28.1,203},{16.6,40.9,203},{37.8,51.2,203},{26.7,55.3,203},{68.7,91.9,203},{59.1,47.7,203},{25.5,43.9,203},{45.3,41.1,203},{62.9,60.8,203},{13.3,11.4,203},{48.3,40.2,203},{29.5,27.9,203},{67.7,51.9,203},{19.4,40.1,203},{19.3,32.2,203},{21.1,30.6,203},{26,24.3,203},{79.1,62.4,203},{31.9,34.4,203},{51.6,43.2,203},{27.5,29.2,204},{29,48.8,203},{8.9,34.3,203},{15.7,32.6,203},{54.1,44.5,203},{58.7,55.6,203},{38.5,32.7,203},{40.2,50.8,203},{35.8,33.5,202},{42.4,39.6,204},{17.5,34.6,203},{34.2,44.8,203},{38,37.3,203},{65.4,51.9,203},{55.2,53.7,203},{17.8,34.6,203},{26.4,52.9,203},{35.5,52,203},{69.8,69.2,203},{63.2,49,202},{56.6,49,203},{41.5,32.9,203},{29.8,44.1,203},{48.9,40.2,203},{27.3,49.1,202},{41.3,41.9,203},{19.6,23.2,203},{61.9,59.8,203},{41.1,54.7,203},{66.6,60.8,203},{11.3,17.5,203},{21.4,26.1,203},{47.3,42.4,202},{11.3,14.2,203},{13.7,15,203},{51.9,42.8,203},{53.6,46.6,203},{16.4,18,203},{17.3,19.7,203},{23.9,24.4,203},{11.2,21.4,203},{28.6,30,203},{66.3,84.5,203},{29.3,22.4,203},{29,22.6,203},{18,36,203},{24.2,23.2,203},{35.8,53.8,203},{32.2,45.5,203},{11.8,23.2,203},{67.1,63.2,203},{21.5,23.4,203},{19.2,34.3,203},{79.9,60.9,203},{27,46.6,203},{26.9,53.8,203},{43.4,33.1,203},{17.7,40.1,203},{63.9,59,204},{54.4,44.6,203},{15.6,31.1,203},{16.7,26.1,203},{46.7,54.8,203},{18.1,22.9,203},{45.1,39.1,203},{9.5,16.6,203},{71.1,91.6,203},{24.6,29.1,203},{12.6,25.3,203},{29.5,27.8,203},{42.6,31,203},{56.2,47.8,203},{43.6,40.5,203},{70.3,92,203},{38.4,30.9,203},{9.9,33.3,203},{28.8,49,203},{17.3,30.8,203},{41.8,54.4,203},{21.6,42.8,203},{14,38.4,203},{26.3,53.3,203},{58.6,55,203},{62,47.8,203},{48.4,57.6,203},{37,48.6,203},{34.6,25.9,203},{65.6,85.8,207},{13.3,36.9,203},{18,41.9,203},{27.2,52.5,203},{19.8,40,203},{28.6,28.9,203},{32.3,34.5,203},{80.8,90.2,203},{27.3,53.9,203},{43.1,34.8,203},{36,36.5,201},{40.4,57,203},{50.6,46.4,202},{10.5,38.4,203},{66.4,49.2,203},{19,37.7,203},{35.4,27.5,203},{58.2,51.8,202},{76.3,93.7,203},{78.7,90.2,203},{27.3,51.5,203},{67.4,58.5,203},{22.1,40.9,203},{77.2,87.1,203},},["Herbalism"]={{34.4,17.2,409},{36.4,40,408},{65.6,60.8,409},{35.5,48.7,409},{14.8,30.1,408},{13,14.8,408},{23.7,24.3,408},{64.5,49.9,408},{18.6,31.7,409},{24.4,27.1,409},{23.1,25,408},{32.2,17.4,404},{80.6,90.7,409},{45.2,41.5,408},{40.6,37.1,408},{88.9,61.4,409},{12.8,14.1,411},{34.4,34.5,408},{52.7,47.5,409},{88,60.7,408},{33.5,53.3,411},{17,37,411},{31,46.4,411},{63.7,47.6,411},{27.1,39.6,408},{74.7,51,409},{12.4,35.9,409},{22,40.2,408},{41.3,58.2,411},{79.2,50.4,408},{40.4,36,411},{24.5,27.2,409},{63.2,51.5,409},{34.9,16.8,409},{70.3,54.1,408},{27.8,44.5,409},{36.5,49.9,411},{46.2,41.6,408},{27.3,39,409},{27.8,40.7,408},{11.6,23.4,408},{26.4,28,411},{18.5,31.4,409},{70,71.2,408},{51.2,53.7,408},{9.9,39.4,409},{41.9,36.9,408},{58.7,54,408},{58.8,52.6,408},{12,11.2,409},{86.7,75.3,411},{79.9,67.5,411},{71.6,90.2,411},{14.4,38.8,409},{82.9,55.2,411},{14.1,26.9,408},{15.3,19.7,409},{20.9,22.7,409},{69.8,75,408},{20.5,22.9,409},{43.6,37.2,408},{88.2,70.3,408},{34.9,29.7,409},{34.2,34.2,408},{13.8,31.3,409},{66.6,61.6,408},{59.1,48.2,409},{36.2,31.6,409},{42,37,408},{8.5,34.6,409},{15,18.9,408},{68.9,86.3,408},{44.9,60.4,408},{20.7,22.8,408},{12.4,36,409},{83.7,52.6,409},{76.7,92.2,408},{21.4,36.2,409},{67.9,90.3,408},{12.7,36.5,409},{70.7,65.5,411},{17.3,40.3,409},{70.8,54.3,408},{55.8,48.3,408},{69.8,71.4,408},{29.3,51.2,409},{18,40.6,409},{18.5,40.8,409},{88.5,69.5,408},{76.4,70.1,411},{32.5,18.7,404},{56,49.7,411},{29.8,51.2,409},{54.9,48.1,408},{61.3,58.6,409},{41.4,52.9,411},{70.9,77.8,411},{33.8,52.3,408},{59.6,48.6,409},{51,41.9,408},{19.3,23.4,408},{42.2,39.1,408},{86,85.1,408},{48.7,44.4,409},{10.2,9.2,408},{34.5,53.9,408},{38,52.7,409},{67,89.8,408},{21.5,35.4,409},{67.4,63.2,408},{81.7,90.9,408},{13.5,25.9,408},{86.5,57.1,408},{86.7,84.9,409},{67.5,65,408},{66.6,81.4,408},{33.8,53.3,408},{14.8,29.9,408},{45.4,59.6,408},{51.8,54.6,408},{15.7,31.8,408},{68,85.3,408},{68.4,83,408},{13.8,31.2,409},{69.4,85.1,408},},["Fishing"]={},},
["Durotar"]={["Mining"]={{51.6,71.4,201},{44.2,24.1,201},{40.3,27.7,201},{50.7,74.2,201},{38.5,29.6,201},{46.8,79.2,201},{38.3,50.6,201},{47.9,79.5,201},{45.8,31.4,201},{38.2,25.1,201},{35.6,35.5,201},{50.4,33,201},{55.5,63.2,201},{47,45.8,201},{52.8,27.7,201},{54.7,60.5,201},{50.7,51,201},{40.9,33.9,201},{42.4,38.1,201},{48.5,49.2,201},{52.7,62.6,201},{51.7,71.7,201},{50,78.1,201},{42.7,51.6,201},{39.1,25.2,201},{49.2,80.9,201},{42.8,25.5,201},{54.4,75,201},{39.4,28.7,201},{53.1,28.8,201},{50.8,17.2,201},{38.7,31.1,201},{43.8,34.6,201},{39.2,28.9,201},{37.3,51.6,201},{50.5,63.1,201},{42.8,24.3,201},{53,27.2,201},{68.1,73.5,201},{56.5,68.5,201},{54.8,70.2,201},{48,79.6,201},{52.9,36.6,201},{51.5,8.2,201},{49.3,70.3,201},{56.8,8.3,201},{52,8.4,201},{52.5,27.6,201},{54.8,8.5,201},{53.7,8.5,201},{51.2,9,201},{40.9,30.9,201},{51.8,24.9,201},{54,9.1,201},{53.2,9.7,201},{54.9,9.7,201},{60.9,49.3,201},{58.9,47.1,201},{55.4,9.8,201},{51.6,9.9,201},{52.6,9.9,201},{44.6,47.8,201},{60.5,55.6,201},{53.8,9.9,201},{51.1,10.7,201},{52,11.1,201},{53.2,11.1,201},{50,25.8,201},{54.2,13.9,201},{39.6,14.4,201},{41.4,17.9,201},{36.1,44.2,201},{48.9,50.2,201},{38.4,15.4,201},{56.5,16,201},{56.3,16.1,201},{49.7,16.9,201},{49.8,41.1,201},{50.7,17.3,201},{59.5,17.8,201},{40.9,24.5,201},{53.1,17.9,201},{53,18.2,201},{51.5,18.9,201},{49.6,19.1,201},{51.6,19.3,201},{39.5,40.2,201},{54,79.6,201},{47.9,19.5,201},{54.6,19.6,201},{51.5,30,201},{56.3,39.4,201},{55,59.9,201},{37.6,20.9,201},{49.8,48.2,201},{39.2,25.7,201},{43.4,39.6,201},{49.9,54.4,201},{55.4,21.3,201},{53.8,21.3,201},{40.5,30.5,201},{42.9,51.5,201},{54.3,67,201},{52.4,21.7,201},{51.4,22.9,201},{43.8,23.3,201},{42,34.5,201},{49.3,71.3,201},{40.1,23.5,201},{52.1,23.7,201},{55.7,23.9,201},{45.7,49.6,201},{48.4,49,201},{39.4,24.2,201},{50.4,74.5,201},{54.6,59.8,201},{59.2,41.1,201},{54.8,17.9,201},{52.7,24.8,201},{49.9,26.4,201},{55.1,35.8,201},{42.4,27.2,201},{68.5,69.8,201},{59.5,78.1,201},{43.8,25.1,201},{41.1,47.5,201},{60.2,61.8,201},{56.5,71.5,201},{61.1,60.1,201},{42.5,27.6,201},{48.3,78,201},{60.4,55.5,201},{45.1,50.4,201},{52.5,76.2,201},{53.5,46,201},{54.3,28.6,201},{39.6,27.6,201},{51.4,55.4,201},{40.1,25.9,201},{60.1,61.8,201},{42.8,19.7,201},{59.3,61,201},{49.7,21,201},{42.9,26.6,201},{48,68.8,201},{36,26.3,201},{53.1,7,201},{52.8,8.2,201},{48.8,34.3,201},{55,59.7,201},{52.6,59.3,201},{37.1,37,201},{49.5,51.1,201},{51.8,27.8,201},{36.1,28.9,201},{48.6,49.4,201},{52.8,32.9,201},{49.5,35.9,201},{52.6,26.5,201},{40.5,50.3,201},{59.3,69.5,201},{42.7,24.4,201},{48.2,31.1,201},{47.8,49.2,201},{52.3,76.2,201},{55.7,66.9,201},{52.7,27.4,201},{56.9,41.2,201},{41.6,27.3,201},{61.6,65.7,201},{46.6,37.2,201},{38.9,54.5,201},{53.1,45.8,201},{56.2,36.1,201},{36,45.4,201},{56.3,48.8,201},{36.4,33.7,201},{50,78.2,201},{54.6,60.3,201},},["Herbalism"]={{48.5,84.2,407},{57,17.4,402},{33.8,26.2,404},{64.6,73.6,402},{56.2,68.6,402},{36.1,29.6,403},{49.6,12.3,402},{51.5,48,401},{52.6,59,402},{39.3,40.5,402},{56,35.7,402},{59.1,45.9,401},{56,66.7,402},{56,40.5,402},{42.1,46,401},{54.4,57.9,403},{58.6,52.9,401},{60.5,60.8,402},{44.8,49.5,402},{55,63.6,402},{49.3,74.1,402},{56.2,69.1,402},{64.2,75.1,402},{44.7,72.6,402},{54.6,55.5,401},{55,51.8,401},{42.4,40,403},{44.6,33.7,401},{55.3,69.1,402},{56.5,46.8,402},{58,23.1,402},{57.2,13.9,401},{41,14.4,402},{54.9,10.2,402},{54.1,70.5,403},{33.7,33.5,404},{52.5,79.9,401},{57.5,70.2,402},{54.8,54.7,402},{44.1,24.1,402},{57.1,41.8,402},{40.2,14.8,402},{44.7,49.6,402},{51.6,58.5,402},{33.6,28,403},{57,17.3,402},{44.3,49.5,404},{60.3,55.1,402},{60.7,91.5,402},{39.5,45.3,401},{50.3,47.2,402},{54.1,22.9,404},{58.3,16.3,402},{36.4,56.2,401},{40.6,19.4,401},{55.6,59.6,402},{55.6,67.6,402},{50.6,26.5,404},{56.3,47,402},{40.2,49.8,403},{54,10.7,402},{41.7,14.6,402},{51.6,77.7,402},{53.9,10.8,402},{38.2,50.3,403},{52.3,29.8,402},{44.2,49.6,404},{57.6,20.3,402},{55.7,32.7,402},{44.2,45.3,401},{57.6,28.3,401},{69,70.9,402},{54.8,66.4,402},{64,76.3,402},{50.2,51,402},{49.8,46.1,402},{51.3,62.5,402},{52.4,58,401},{51.2,72.8,403},{38.8,34.6,401},{50.8,47.6,402},{35.7,28.4,401},{38.6,21.2,402},{52.7,60.3,401},{56.1,41.3,402},{50,54.4,402},{47.7,47.5,402},{56.1,14,403},{60.2,82.4,402},{39.3,24.9,404},{42.9,51.1,402},{36.4,37.7,401},{58.6,41.5,402},{55.9,35.6,402},{57,39.1,402},{52.8,10.4,402},{43.2,13.8,402},{53.8,79.8,403},{41.8,14.7,402},{51.5,65.4,402},{60.3,52.8,402},{60.6,54.6,402},{55.2,66.9,402},{42.5,26.7,404},{47.6,48.1,402},{42.1,65.4,402},{56.7,48,402},{42.1,80.9,407},{41.9,79.8,407},{50.6,16.2,401},{56.7,17.5,402},{54,73.1,402},{43.6,28.8,402},{40.3,80.1,407},{43.6,50.7,402},{55.4,38.3,401},{55,62.3,402},{58.1,16.9,402},{37.8,29.6,402},{64.1,75,402},{64.9,87.4,402},{49.6,47.3,403},{36.4,47.3,401},{46.9,48.9,402},{40.4,78.9,407},{38.9,51.8,401},{61.3,58,402},{42.9,44.9,403},{50.6,56.8,402},{42.3,66.2,402},{40.2,32.6,403},{50.2,48.7,402},{50.5,75.1,402},{40.9,14.4,402},{43.2,49,401},{56.6,47.5,402},{43.2,13.7,402},{56.9,21.5,401},{55,63.3,402},{58.4,16.5,402},{37.2,36.7,403},{51.5,15.6,403},{45.4,22.3,401},{69,71.8,401},{52.2,63.4,401},{54.8,61.4,402},{52.5,11.2,402},{57.8,45,403},{54.8,60.3,403},{60.1,89.3,401},{53.6,16.8,402},{38.2,50.2,403},{39,20.1,402},{52.7,59.6,402},{60.4,53.1,402},{48.5,34.1,404},{46.9,36,402},{36.6,54.5,403},{55.9,32.2,402},{33.6,34.1,404},{36.8,31.8,401},{58.3,43.3,401},{33.7,35.4,404},{58.1,29.6,404},{33.5,26.8,403},{40.6,77,407},{33.5,31.1,403},{44.4,18.6,401},{38.7,17.5,401},{46.4,47.8,401},{47.7,30,403},{66.8,87.6,402},{39.9,75.5,407},{38.7,77.2,407},{43.3,80.5,407},{43.4,82.7,407},{57,72.1,403},{49.7,84.4,407},{60.2,54,403},{37,24.8,403},{51.5,19.2,404},{51.9,23.8,404},{43.2,24,404},{40.4,28.2,404},{36.7,30.3,402},{49.3,12.8,402},{33.8,26,403},{60.4,83,402},{55.4,28,402},{55,65.9,402},{64.2,74.2,401},{55,34.5,401},{46.2,29.3,402},{33.6,28.9,404},{56.1,14.3,403},{41,16.3,403},{41,18.7,403},{57.2,41.9,402},{55.6,19,403},{48,19.6,403},{42,15.7,402},{44.8,20.1,403},{37.2,46.8,403},{39.6,24.1,403},{53,13,401},{57.9,17,404},{50.4,48.8,402},{51.4,73.9,402},{55.6,10.1,404},{37.7,39,403},{38.1,73.8,407},{53.8,32.5,403},{48.4,38.3,403},{65.4,86.2,401},{42.1,35.9,401},{42.5,14.3,402},{54.9,80.5,402},{54.8,15.3,401},{52.1,55.4,401},{42.3,70.6,402},{38.2,39.7,401},{37.1,26.6,401},{46.8,45.9,403},{58.5,29.1,402},{57.4,21.3,402},{38.4,55.8,404},{56,68.3,402},{37,50.1,401},{56.4,37.6,402},{42.8,24.1,402},{65.3,82.5,402},{42.8,39.6,401},{56.8,18.1,402},{40.3,40.7,402},{50.2,53,403},{65.7,82,402},{40.1,40.4,402},{57.5,41.5,402},{45.8,35.6,401},{53.7,53.4,403},{60.3,83.6,402},{45,28,403},{51.7,54.6,403},{51.8,59.5,402},{44.6,42.9,402},{37.4,20.6,402},{58.7,57.7,402},{52,64.4,403},{47.6,49.5,402},{57.4,41.9,402},{56,33.1,402},{52.5,76.3,402},{42.9,24.5,403},{45.6,37.6,401},{42.5,20.7,401},{56.1,18.2,401},{57.1,24.3,401},{60.1,41.6,403},{39.6,73.6,407},{41.5,66.8,402},{48.6,18.6,401},{43.5,13.5,402},{51.6,77.6,402},{56.3,26.3,402},{57.1,30.9,402},{54.6,30.3,401},{58.9,25.9,402},{60.6,56.1,402},{43.6,13.6,402},{50.4,11.6,402},{40.7,50.9,404},{50.7,34.9,401},{54.9,62.8,402},{40.1,37.6,401},{49.7,49.1,402},{42.4,16.8,401},{52.7,10.8,402},{40.1,48.4,402},{38.8,41.1,402},{38.7,48.3,401},{39.9,20.3,402},{55.7,34.5,402},{54.7,49,401},{58.4,40.9,402},{60.7,83.1,402},{41.4,49.8,401},{58.9,50.7,401},{36.4,53.6,401},{51.2,11.5,402},{58.1,41.3,402},{54,78.1,401},{44.2,21.4,402},{60.2,54.8,402},{54.1,64.2,401},{54.5,67.8,401},{57.8,71.5,401},{47.9,47.5,402},{60,83.2,401},{42.5,31.1,401},{39.8,14.8,402},{58.3,58.1,402},{37.7,21.3,402},{60.4,55.2,402},{40.3,15,402},{53.7,80.4,402},{39.2,25.4,403},{47.7,47.1,402},{42.6,24.6,402},{38.6,75.3,407},{53.9,71.9,401},{41.7,65.7,402},{51.2,71.9,401},{60.3,56.3,402},},["Fishing"]={},},
["Mulgore"]={["Mining"]={{33.6,34.8,201},{31.2,42.6,201},{68.4,67.6,201},{68.8,65.3,201},{34.6,79.7,201},{62.7,32.4,201},{48.4,74.4,201},{58.9,34.1,201},{62.8,38.7,201},{34.8,58.9,201},{61.5,53.4,201},{28,26,201},{32.5,59.8,201},{55.9,13.6,201},{34,51.5,201},{71.6,56.7,204},{58.3,31.4,201},{63,25.9,201},{49.3,24.7,201},{30.4,28.5,201},{32.9,40.6,201},{61.3,22.3,201},{43.8,72.8,201},{59.8,33.3,201},{60.8,29.2,201},{30.8,59.4,201},{34.5,79.8,201},{55.3,74,201},{31.8,47.6,201},{32.7,60.7,201},{57.6,43,201},{61.3,72.2,201},{26.5,26.4,206},{64.6,42.7,201},{63.5,44.9,201},{31,62,201},{52.2,4.9,201},{41.2,6.6,201},{50.2,6.7,201},{66.9,72.7,201},{61.5,53,201},{60.1,30,201},{64.6,71.1,201},{55,10,201},{33.4,47.1,201},{60.9,37.4,201},{58.4,35.7,201},{54.7,12.8,201},{36.9,14.2,201},{60.9,18.8,201},{54.5,14.2,201},{53.9,74.7,201},{61,40.2,201},{31.6,50.3,201},{34.5,38.3,201},{61.6,50.4,201},{56.8,15.8,201},{34.8,69.7,201},{62.4,17.3,201},{56.6,40.4,201},{32.2,61.5,201},{56,74.8,201},{58.8,17.9,201},{66.2,71.3,201},{56.9,38.6,201},{43.5,20.1,201},{43.4,20.1,201},{63.4,20.5,201},{62.8,55.4,201},{33.5,32.5,201},{63,23.7,201},{64.3,42.1,201},{31.7,59.7,201},{60.9,32.5,201},{32.6,35.8,201},{33.5,58.2,201},{65.3,37.5,201},{63.1,35.4,201},{33.2,70.1,201},{59.2,37,201},{44.6,12.1,201},{71,80.6,204},{32.4,59.2,201},{59.4,45.9,201},{38.3,7.1,201},{32.9,76.2,201},{62.3,19.7,201},{52.2,72.7,201},{42.7,74,201},{35.1,55.1,201},{36.4,16.6,201},{68.8,63.2,201},{68.5,69.6,201},{62.7,42.4,201},{33,62.6,201},{33.2,54.1,201},},["Herbalism"]={{60.7,60.5,402},{38.3,20.6,401},{35.1,74.2,402},{59,26.1,402},{37,66.4,401},{35.3,57.9,402},{58.3,59.1,402},{59,55.9,401},{38.6,59.6,402},{41.2,64.3,402},{51.9,32.5,401},{39.6,19.5,402},{38.7,63.9,402},{59.1,18.6,402},{68.1,68.9,403},{47.8,68.5,402},{36.9,45.2,401},{53.8,44.1,401},{62,61.9,402},{63.3,56.7,402},{51.4,7,402},{60.7,56.5,402},{34.2,80.9,402},{64.2,57.4,402},{46,38.4,402},{37.6,36.5,402},{62.8,57.5,402},{32.7,40.6,403},{35.3,60.8,403},{59,21.3,401},{43.5,47.2,401},{55.2,20.8,401},{38.9,51.1,401},{66.1,68.2,401},{29.1,23.6,402},{72.4,83.4,408},{52.5,25.7,401},{41.8,18.5,402},{64.3,59.3,402},{49,8.3,402},{72.7,81.3,408},{71,57.4,405},{35.5,43.5,402},{71.8,64.2,405},{48.1,47.2,402},{73.2,63.6,404},{70.4,58,401},{66.2,58.6,401},{53.6,19.7,402},{56.1,50.5,402},{72.3,80.4,409},{58.8,30,402},{44,9.3,401},{34.5,62.4,402},{47.7,73.5,403},{28.5,25.8,403},{36.3,12.3,403},{55.2,16.5,403},{56.8,17.5,403},{45.4,36.4,401},{62.3,19.7,403},{60.6,21.2,403},{32.5,19,401},{38,53.1,402},{54.5,9.8,403},{60.2,29.4,403},{57.9,32.5,403},{40.7,62.5,401},{44.6,49,402},{49.2,40.8,402},{34,35.3,403},{57.6,43.2,403},{59.5,44.5,403},{36.8,62.6,401},{51.1,37.9,402},{60.4,46.6,403},{33.4,47.1,403},{38.3,41.1,401},{34.6,40.6,402},{65.8,60.3,402},{32.5,48.6,403},{61,52.1,403},{42.2,50.8,401},{34.9,54.6,403},{58.9,56.9,402},{34.5,57.3,403},{46.7,32.3,401},{38.9,48.5,401},{34,37.5,402},{34.8,69.7,403},{66.3,71,403},{52,71.6,403},{42.7,17.8,401},{34.3,25.9,401},{58.4,58.1,402},{46.1,71.9,403},{52.8,74.1,403},{54.1,74.3,403},{55.8,74.7,403},{53,7.9,403},{48,9.8,401},{52.4,9.9,401},{38.9,10.3,401},{41.1,49.3,402},{57.8,44.4,402},{52.6,12.8,401},{38.1,12.9,401},{48.6,14.8,401},{32.3,18,402},{66.7,64.5,401},{37.6,16.6,401},{43.5,40.5,401},{45.2,16.8,401},{37.7,77.8,402},{46.7,16.6,402},{51.7,18.7,401},{31.7,25.6,401},{57.7,25.6,401},{62.1,61.7,402},{72.6,80.9,408},{46.6,27.6,401},{49.4,28.4,401},{33.6,29.5,401},{31.2,42.2,402},{65.4,63.4,402},{55,29.5,401},{44.9,29.7,401},{36.3,38.7,401},{69,58.8,403},{60.7,61.4,402},{35,33.5,401},{56.2,35.2,401},{49.2,36.3,401},{38.6,42.8,402},{57.8,64.5,402},{59.6,60.6,401},{50.6,16.7,402},{36.6,37.7,401},{51.2,32.3,401},{53.8,16.8,401},{62.3,57.8,401},{37.7,36.6,402},{62.5,56,402},{53.5,58.4,402},{44.6,32.8,402},{51.2,41.2,401},{34.3,42.2,401},{38.3,7.7,403},{57.5,47,401},{53.6,42.3,402},{46.7,49,401},{59.7,55.6,402},{56.4,62.2,402},{41.4,66.5,401},{46,43.2,401},{44.2,67.3,402},{56.3,44,401},{34.3,48.8,401},{33.8,33.6,402},{55.7,58.6,401},{62.7,58.5,402},{64.7,60.1,402},{42.2,11.9,402},{64.6,58.3,402},{62.8,70.6,401},{45.2,52.3,402},{58.2,58.9,402},{59.3,47.9,402},{38.5,16.3,402},{66.6,60.1,402},{36.9,56.9,401},{55.6,41.7,402},{57.5,46.3,401},{56.4,19.3,402},{54.4,37.1,401},{43.3,36,402},{35.4,77.1,402},{55.1,64.5,401},{62.4,60.8,402},{61.7,58.5,402},{62.8,66.3,401},{45.5,51.9,402},{52.5,68.5,401},{44.9,70.3,402},{56.9,36.5,402},{36.6,9.2,402},{56.8,30.2,402},{64.7,57.6,402},{36.5,16.1,402},{47,45.1,402},{65.2,59.3,402},{47.6,29.4,402},{55.1,54.8,402},{41.5,44.1,401},{47.9,25.8,402},{34.1,24.3,402},{62.5,59.7,402},{47.1,33.9,402},{37.8,48.2,402},{51,28.3,402},{64,71.2,402},},["Fishing"]={},},
["The Barrens"]={["Mining"]={{64.2,49.5,204},{58.1,26.8,204},{55,89.3,203},{40.5,61,201},{38.2,49.3,201},{53.5,54.7,204},{53.5,13,204},{59.6,25,204},{51.5,88.1,203},{35.5,37,201},{42,13.5,201},{64.9,8,201},{36.8,39.2,201},{56.1,13.1,204},{51.1,57,204},{48,62.3,204},{61.7,34.8,204},{41.5,93.5,203},{45.2,51.2,204},{42.1,77.8,204},{47.9,15.9,204},{37.5,56,201},{64,20.8,201},{48.6,74.4,204},{36.9,53.5,201},{36.5,37.4,201},{55.4,28.9,204},{42.6,78,202},{53.5,55.2,202},{33.4,34.4,201},{49.6,74.8,201},{63,43.9,204},{53.8,54.3,204},{46.1,39.4,204},{36.6,46.9,201},{40.6,93.2,203},{44.5,83,201},{44.9,67,201},{50.6,58.1,204},{42.1,71.1,204},{49,96.9,203},{45.6,94.5,203},{37.9,14.6,204},{46.4,12.8,204},{37.3,36.7,201},{40,14.5,204},{46.3,95.8,203},{42.6,95.1,203},{45.9,64.2,204},{58.1,32.6,204},{41.1,14,201},{51.2,57.9,204},{45.8,94.8,203},{39.5,92.9,203},{40.1,32.3,201},{56.5,51.6,201},{43.1,52,204},{56.5,38.2,204},{49.2,68.8,204},{53,41.3,201},{43,54.8,202},{49.5,44.4,204},{44.9,50.4,204},{46.8,18.2,204},{43,21.1,201},{40.4,63.2,201},{65.2,10.2,201},{57.5,6,204},{45.6,96.6,203},{41.9,82,204},{36.9,54.8,201},{53.5,53,201},{45.5,95.1,203},{42.8,55,201},{42.6,95.6,203},{57.7,9.5,201},{45.1,54.4,202},{46.2,37.6,204},{63.8,15.6,201},{52.7,52.3,204},{37.4,44.3,201},{51.5,42.5,204},{43.4,74.6,204},{42.9,92.3,203},{41,45.1,204},{40.4,80.3,204},{43.4,84.2,202},{56.4,32.4,204},{40.4,27.9,204},{42.9,43.1,204},{37.3,90.4,203},{59.4,14.4,201},{46.4,40,204},{31.2,26.8,201},{45.2,68.7,204},{41.1,79.2,204},{47.1,30.6,202},{44.9,23.1,201},{48.3,86.4,204},{40.5,92.2,203},{47.4,84,204},{47.1,84,204},{55.4,27.7,204},{47.5,84.2,204},{46.8,84.5,204},{61.1,51.4,204},{47.9,84.8,204},{57.7,28.9,204},{58.1,28.2,204},{47.1,85.1,204},{48.6,85.2,204},{35.5,45.2,201},{47.2,85.4,204},{30.9,23.4,201},{49.6,76.8,204},{47.3,85.9,204},{48.3,85.9,202},{39.5,23.6,204},{44.6,42.1,202},{47.5,85.9,204},{32.1,30.4,201},{48.5,86.1,204},{48.7,88,204},{59.5,3,204},{60.4,3.7,202},{44.9,22.5,204},{46.4,38.9,204},{45.2,93.8,203},{38.9,10.8,202},{44.5,51.3,204},{49.4,33.2,204},{46.4,34.6,204},{47.5,30.1,204},{42.1,18.9,204},{41.4,93.1,203},{41.3,93.1,203},{45.3,22.3,202},{37.4,49.4,201},{41.6,29.7,202},{40.6,59.9,201},{38.4,49.5,201},{52.4,52.6,204},{50.9,11.6,204},{47.4,68.7,204},{58.5,12.2,204},{66.5,58.3,203},{47,40.3,204},{51.6,51.4,202},{47.4,22.7,204},{43.5,72.8,204},{52.7,10,201},{52.6,51.8,202},{51.5,52.6,204},{49.7,48.6,202},{42,56.7,204},{34.7,20.9,205},{47.3,98.2,203},{63.4,42.7,204},{50.6,57.6,202},{47.6,86.1,204},{44.2,96,203},{62.2,46.8,201},{43.8,22.7,204},{58.3,15.1,204},{36.6,44.4,201},{43.8,27.5,204},{61.4,30.1,204},{48.7,80.5,202},{58.9,27.2,201},{49.1,15.8,202},{40.9,44.5,201},{40.3,45.5,201},{58.3,17.2,204},{52.5,47.1,201},{51,21.6,204},{52.7,51.6,201},{53.7,53.4,201},{64.7,46.5,204},{42,78.2,201},{49.4,62,204},{41.7,68.8,204},{48.6,96.1,203},{46.8,32.6,204},{55.1,43.8,204},{41.1,35.3,204},{60.9,61.4,203},{51.7,64.4,203},{43.3,62.9,204},{54.4,65.1,203},{58.1,43.1,204},{51.6,65.1,203},{51.9,65.3,203},{52.4,65.5,203},{39.7,93.1,203},{36.1,43.1,201},{62.2,51,202},{52.7,77.3,203},{59.2,23.6,204},{43.1,54.5,204},{60.7,13.8,204},{50.3,17.9,204},{52.1,65.7,203},{52.8,79.9,203},{52.8,80.1,203},{41.1,29,201},{51.9,87.9,203},{44.9,25.1,204},{37.7,91.2,203},{48.7,82.3,204},{43,94.7,203},{51.8,88.2,203},{52.9,91.5,203},{43.6,12.1,204},{58.6,5.6,204},{48.7,22.7,204},{59,11,201},{35.8,51.2,201},{59.2,8.7,202},{47.1,12,202},{55.5,17.3,202},{46.4,46.9,204},{44.4,50.8,204},{48.6,14.8,204},{33.5,33,201},{40.7,92.7,203},{55.5,42.4,201},{57.8,16.1,202},{39.8,19.4,201},{40.1,22.1,202},{44,26.6,202},{55.4,42,202},{46.1,45,202},{51.7,48.2,202},{53.5,54.4,202},{55.8,26,204},{55.8,43.1,204},{65.3,5.1,201},{64.1,20.1,201},{52.7,65.5,203},{46.2,39,204},{39.9,25.2,204},{62.2,55.1,202},{48.9,64.1,202},{47.2,97.2,203},{34.5,35.9,201},{43.4,23.1,204},{43.9,78.3,202},{45.7,97.1,202},{47.2,54.4,204},{48.5,98.3,202},{38.5,14.3,202},{63.2,45.6,201},{42.1,95.3,204},{49.5,32.4,204},{36,44.8,201},{62.3,9.7,204},{39.3,31.3,201},{61.3,40.3,204},{64.1,10.8,201},{43.3,94.3,203},{41.5,38,204},{48.6,97.1,203},{60.2,11.1,201},{62.1,11.4,204},{60.1,49.2,204},{37.3,37.9,201},{55.9,11.8,204},{41.1,94.6,203},{49.3,98.4,203},{39.6,11.9,204},{61.2,26.5,204},{43.5,17.5,201},{50.1,11.9,204},{50.9,41.3,201},{45,23.6,204},{51.6,65.7,203},{44.3,82.4,204},{57.1,14.1,204},{41.2,78.9,204},{62.1,29.3,204},{41.8,36.4,204},{37.6,14.8,204},{59.9,36.6,204},{60.1,16.4,204},{56.9,11.8,201},{64.7,44.5,204},{50.7,24,204},{61.1,17.6,201},{65.3,12.5,201},{58.7,31.6,204},{31.1,31.3,201},{46.8,96,203},{42.7,82.8,204},{44.9,51.2,204},{51.4,54.7,204},{53.7,54.1,204},{48,18.1,204},{37.9,50.7,201},{43.3,19.1,204},{50.5,19.6,204},{42.9,23.2,204},{50.2,19.8,201},{55.6,31.5,204},{31.6,25.4,201},{47.9,86.1,204},{62.4,49.1,204},{43.6,76.8,204},{63.2,50.8,202},{32.5,21.4,205},{42.8,92.3,203},{46.2,20.7,204},{50.9,57.4,202},{58.1,49.4,204},{44.9,21.2,201},{44.7,21.4,204},{48.5,71.5,202},{44,22.3,204},{45.1,22.5,204},{48.3,22.6,204},{37.6,41,201},{55.3,27.3,204},{44.7,23.5,204},{38.4,12.5,204},{58.8,29.3,204},{56.9,10.7,204},{61.1,44.2,204},{59.3,24.8,204},{38.9,25.4,201},{54.9,87.4,203},{40.8,95.2,203},{55.7,25.4,204},{48,84.9,204},{40.7,46.9,204},{33.3,35.1,201},{46.8,34.3,204},{57.2,26.9,204},{48,66.7,204},{46.7,39.7,204},{31.3,27.2,205},{59,51.2,204},{40.6,45.7,204},{57.1,43.6,204},{31,22.9,201},{44.1,70.8,204},{50.9,57.7,204},{58.9,27.7,204},{39.6,64.8,201},{57.5,4.6,201},{57.4,25.6,204},{54.4,25.4,204},{49.4,97.1,203},{55.1,60.4,203},{51.8,52.9,204},{47.1,34.6,201},{64.3,14.7,201},{41.3,78.8,204},{51,60.8,201},{52.4,52.9,204},{40.9,45.6,204},{48.9,97.7,203},{57.9,30.2,204},{47.8,40,204},{56.2,31,204},{49.6,80.3,204},{45.4,36.1,204},{35.7,46.7,201},{37.6,39.9,201},{43.9,94.5,203},{50,24.2,201},{46.5,39.6,204},{45.4,17.9,204},{41.4,39.9,201},{60.3,3.4,204},{36.9,55,201},{42.4,94.8,203},{47.8,97.1,203},{36.6,48.3,201},{68.3,57.5,203},{45.9,32.8,204},{46.5,15.5,202},{42.7,92.4,203},{37.8,38.3,201},{41.6,33.5,201},{50.6,17.6,204},{47.9,43.8,204},{42.7,38.9,204},{41.5,78.3,204},{57.8,25.7,204},{61.5,45.5,204},{41.9,44.4,204},{45.9,95.9,203},{38.7,92.7,203},{48.2,96.9,203},{49,97,203},{60.5,45.9,204},{60.5,47.5,204},{45.1,94.7,203},{51.2,65,203},{34,34.8,201},{40.9,78.6,204},{62,14.7,204},{47.8,33.1,204},{37.5,47.5,201},{39.5,92.7,203},{51.9,39.6,204},{49.3,45.3,201},{48.5,48.4,204},{61.9,31.4,204},{50.8,21.6,201},{41.8,81.4,204},{47.4,40,204},{55.3,43,204},{58.4,53.2,204},{60.1,54.1,204},{46.9,96.8,203},{55.7,40.7,204},{45.7,82.2,204},{42.7,41.1,204},{64.1,12.2,201},{58.9,41.5,204},{44.9,42.6,204},{36.5,42.7,201},{48,20.1,201},{54.8,53.3,201},{35.2,43.8,201},{40.4,62.2,201},{58.3,27.1,202},{37.7,45.9,201},{41.9,78.6,204},{49,34.5,201},{40.7,79.2,204},{38.8,46.9,201},{45.2,12.2,202},{41.9,47.4,201},{48.2,72.8,204},{56.3,14.5,201},{49,31.2,204},{57.8,18.6,204},{55.9,43.3,202},{51.6,88,203},{43.2,83.5,204},{44.3,64.6,204},{49.6,62.9,201},},["Herbalism"]={{46.4,36.6,404},{65.4,8.2,402},{64,46.7,403},{63.9,54.8,407},{51.4,24.5,402},{45.8,63.1,401},{39.5,81,409},{60.9,19.1,403},{40.4,29.8,403},{56.2,42.1,405},{42.6,50.5,408},{46.4,36.2,405},{50.4,30.2,402},{33.4,22.4,404},{45.3,63.5,404},{49.8,56.7,404},{64.4,49.1,407},{54.1,44,404},{66,43.1,407},{47.2,77.4,401},{64.9,8.2,402},{43.1,82.5,404},{39.6,23.6,403},{44.7,40.9,404},{43.1,69,408},{56.8,5.8,405},{65.5,39,407},{36.2,42.8,403},{64.6,10,403},{61.9,16.7,403},{60.8,53,408},{43.1,77.6,409},{45.8,35.3,408},{65,48.4,407},{52.6,32.1,402},{45.4,36.6,402},{40.9,32.9,403},{43.8,69.2,404},{61.4,17.1,403},{35.7,52.2,402},{44.7,84.7,404},{34.6,21.8,408},{68.2,49.5,407},{63.4,54,407},{47.4,33.4,411},{52,49.6,404},{43.8,73.3,409},{60.9,17.5,403},{46.3,87.3,409},{47.9,81.3,411},{43.8,59.8,405},{48,28.6,402},{47.9,41.2,404},{45.3,30.8,405},{49,62.6,401},{62.3,49.8,403},{41.9,44.4,408},{39,58.5,402},{59.8,22.3,402},{38.2,57,402},{44.8,75.8,401},{54.2,87.5,415},{38.6,15.4,402},{48.5,63,404},{42.4,70.2,408},{59.9,22.8,404},{59.9,53.9,408},{54,28,401},{43.8,72.5,408},{65.5,37.4,407},{40.8,44.9,409},{41.4,18.2,402},{48.4,17.5,408},{38.6,15.2,404},{60.3,7.6,401},{48.8,87,405},{63.9,11.9,401},{56.2,12.7,404},{61.5,2.9,405},{48,31.9,404},{48.3,87.4,409},{48.5,57.7,404},{34.9,40.9,401},{38,14.9,408},{34.1,21.6,408},{55.2,27,401},{45.8,41.9,401},{63.5,43.9,403},{42.9,24.4,401},{46.3,41.1,404},{55.8,40.2,404},{53.6,50.6,404},{43.7,61.8,404},{55.7,12.7,404},{48.9,33.5,404},{64.1,12.5,403},{32.9,21.4,405},{46.4,37.1,408},{56.8,25.1,402},{45.3,37.8,405},{39.3,28.7,403},{43.7,70.4,408},{32.3,25.8,408},{47.9,70.3,411},{45.3,95.5,409},{63.6,53,407},{41.6,50.1,408},{43.3,40.6,404},{50,23.4,402},{43.7,47.9,401},{67.2,39.3,407},{41.6,36.6,403},{45.2,36.5,404},{41.4,57.3,401},{47.8,37.9,402},{32.3,34.4,401},{45.4,69,408},{35.7,37.3,402},{51.1,13.3,401},{45.9,32.6,408},{60.9,41.3,403},{60.8,18.3,403},{41.7,19.3,403},{45.2,67.2,404},{59.9,47,409},{43.8,70.1,408},{64.6,46.1,407},{59.3,46.9,408},{38.8,11.1,408},{51,21,402},{45.3,36.6,404},{51.5,51.3,404},{63.5,37.8,407},{42.9,72.5,404},{44.4,69.8,404},{53.1,67.4,414},{60.4,10.2,405},{71.2,41.1,407},{43.7,68.8,408},{42.5,56,403},{62.9,10.7,403},{47.9,28.6,402},{44.2,90.1,404},{64.1,46.1,403},{37.8,56.7,402},{43.2,78.2,403},{47.8,63.3,405},{50,17.3,403},{48.5,72.9,409},{59.8,45.3,403},{48.9,84.7,408},{46.8,37.9,402},{49.1,46,405},{41.1,27.6,408},{53.7,26.6,401},{47.9,19.2,408},{53.7,17.6,402},{54.2,52.4,402},{45.3,30.9,402},{68.1,57.3,414},{38.5,92.7,408},{38.5,57.1,402},{42.2,71.1,408},{62.5,46.8,401},{47.4,81.8,404},{49.5,12.8,402},{43.7,76.6,404},{44.2,44.7,404},{64.6,40,407},{43.9,73.5,405},{63.4,48.8,403},{47.5,15.6,404},{41.1,80.6,408},{30.8,26.6,408},{63.1,6.4,404},{43.7,80.7,408},{40.4,93.1,408},{40.2,16,405},{40.6,14.5,404},{47.4,67.9,408},{47,16,403},{57.8,51.4,411},{39.9,80.4,409},{76.6,43.7,401},{49.6,75.1,404},{49,75,405},{62.1,16.2,402},{50.1,56.3,411},{46.9,54.8,405},{60,31.6,401},{50,24.3,402},{35.5,43.1,402},{56.3,48.5,411},{40.4,21.5,403},{40.6,27.4,403},{65,41.6,407},{44.2,61.1,404},{40.6,22.9,405},{47,32.8,408},{48,71.3,404},{46.4,37.2,402},{64.6,42.9,407},{64,42.8,407},{45.4,83,408},{62.1,42,407},{48.1,36.2,402},{46.3,58.4,401},{40.4,30.1,403},{45.8,85.8,405},{42.8,25.6,404},{54.7,27.1,401},{44.8,73.9,401},{61.4,41,405},{55.8,44,404},{61.6,6.8,408},{63.6,48.2,403},{62,14.1,403},{62,9.6,403},{48.5,43.1,404},{64.6,11,401},{67.8,39.1,407},{64,51,407},{46.9,71.2,405},{62.6,53.9,405},{56.8,15.4,405},{30.5,32.1,402},{55.2,43.5,404},{65.2,46.3,407},{46.4,13.9,401},{48.5,47.2,404},{56.4,43.3,402},{47.4,74.5,411},{61.1,11.3,405},{48.1,12.9,404},{65.6,40.1,407},{45.3,89.9,409},{40.6,57.7,403},{52.6,32.7,402},{39.6,14.7,402},{64.2,34,403},{45.4,68.3,405},{32.9,22.9,408},{40.7,22.8,403},{42.8,38.3,403},{45.3,36.3,402},{61,19,402},{55.4,17.5,404},{43.2,51.7,408},{54.3,49.3,404},{34.5,21.2,408},{41.2,44.1,409},{65.1,49.1,407},{46,85.6,404},{44.4,51.5,403},{39.6,23.3,403},{48.4,41,402},{42,18.8,403},{61.6,5.2,408},{35.2,21.8,409},{60.5,5.9,408},{48.5,81.6,405},{60.4,45.1,403},{38.3,58,402},{64,49.4,403},{47.4,37.7,402},{58.9,20.5,402},{48,24.3,402},{48.5,59.1,411},{48.6,37.5,401},{47,39,402},{43.3,69.4,404},{61.9,55.8,408},{46.6,13.7,401},{42.8,24.4,403},{48,68.5,409},{56.9,5.3,404},{40.2,62.9,403},{49.1,76.4,401},{63.2,29.5,401},{45.3,83.8,411},{55.8,23.6,405},{42.7,72.4,404},{61.1,18.3,403},{60.9,30,401},{56.3,40.4,404},{55.4,51.5,402},{44.5,15.2,404},{65.7,43.1,407},{52.1,53.6,404},{52.1,49.1,404},{33.1,23.3,404},{41.5,14.3,404},{43.3,77.2,409},{69.4,47.9,407},{48,40.7,404},{48.1,59.2,401},{63,9.3,403},{50.1,33.9,402},{61.4,41.9,403},{53.7,78.3,412},{56.2,61.2,412},{46.4,24.2,404},{43.3,81.3,411},{48.6,76,405},{66.1,36.5,407},{54.7,1,408},{47.5,67.7,408},{33.7,36.3,403},{62.7,11.1,403},{44,23.8,403},{47.6,68.2,408},{46.9,54.1,404},{65.1,59.8,407},{46.4,45.9,404},{64.6,47.1,403},{47.4,79.9,411},{45.9,33.2,404},{57.4,16,404},{64.2,21.8,401},{56.3,47.8,404},{43.9,76.1,404},{45.4,51.6,405},{53.3,21.1,401},{64.7,47.6,407},{45.5,65.6,401},{49,15.8,404},{40.5,15.1,408},{60.9,41.5,403},{53.2,77.9,415},{53.7,46,404},{61.5,28.1,403},{65.3,47.3,407},{55.8,43.7,402},{61.6,11,404},{57.5,25.1,402},{62.1,10.2,404},{62.1,41.3,407},{43.3,75.6,409},{40.7,78.7,409},{45.9,41.4,404},{59.9,7.1,401},{65.8,59.6,414},{44.4,21.3,404},{54.7,21.9,402},{38.8,60.1,402},{49.1,24.9,404},{46,41.9,404},{53.3,20.3,402},{62.6,9,403},{32.6,31.9,403},{60.9,54.2,409},{42.2,71.8,408},{64.6,50.4,407},{59.1,0.7,408},{76.5,40.5,401},{40.4,22.8,403},{57.4,41.4,402},{41.8,24.2,404},{63.6,51.6,407},{55.9,12.3,404},{56.9,15.2,408},{34.5,36.8,403},{62.2,41,407},{55.8,11.4,404},{48.1,78.9,411},{57,20.2,402},{46.6,63.3,404},{31.9,21.9,408},{39.1,30.7,403},{49.6,81,409},{46.9,78.7,405},{43.5,71.3,411},{67.3,33.9,402},{44.9,54.9,411},{43.3,20.8,404},{36.6,16.5,408},{52.3,47.3,405},{49.2,68.8,408},{44.3,85.9,408},{31.9,21.7,408},{44,83.6,404},{53.8,13.8,405},{48.5,81.3,404},{45,86.5,408},{47,65.7,404},{42.8,40,404},{76.7,40.7,402},{32.7,23,408},{50.1,52.8,401},{41.7,18.4,403},{52.7,54.2,404},{46.1,49.8,404},{35,44.4,403},{41.8,19.1,405},{64.1,45.1,403},{39.1,92.5,409},{64.6,44.3,403},{39.2,57.6,401},{57.9,12.4,401},{45.4,53.3,401},{40,19,405},{64.2,45.6,407},{43.4,60.6,401},{59.9,44.8,403},{49.7,58.2,401},{56,20.2,401},{40.4,21.8,403},{43.9,72.9,404},{64.2,45.2,407},{44.9,71.3,404},{55.4,46.7,404},{30.9,27,405},{32.9,24,408},{38.9,15,402},{43.3,59.3,405},{45.9,96.3,409},{64.8,44.9,407},{46.1,62.1,404},{61,16.7,403},{32.7,22.4,409},{41.5,29.7,403},{44.9,75.4,411},{61.2,18.1,403},{56.4,18.1,404},{32.9,23.8,408},{62,41.7,407},{42.8,21.4,402},{48.7,36.5,404},{42.8,34.7,403},{52.9,36.4,402},{51.7,54.2,404},{47,41.6,402},{41.5,78.4,404},{46.1,48.2,401},{45.5,21.5,405},{62,41.3,407},{54.2,90.3,413},{44.4,22.2,404},{61.1,16.8,403},{42.8,21.2,405},{44,63.6,404},{56.9,34.5,404},{46.6,65,404},{56.4,61.9,412},{34.5,21.9,408},{62.2,15.7,404},{49.7,56.6,404},{46.5,86.2,409},{48.7,71.3,408},{53.4,43.8,404},{51.2,54.2,404},{44.6,49.8,405},{54.4,77.8,415},{40.7,94.3,409},{60,30.2,405},{45.6,39.2,404},{61.7,42.7,403},{62.2,41.9,407},{54.8,40.5,405},{48.1,13.1,401},{66.4,37.3,407},{61.6,41.8,403},{41.2,17.8,402},{50.8,59.6,404},{48.2,13.6,401},{64.3,48.2,403},{49.2,16.5,404},{41.3,45.1,408},{54.3,36.4,404},{55.8,11.9,404},{45,38.7,402},{48.7,70.5,405},{34.3,37.7,402},{46,37.1,402},{60.5,6.5,408},{62.8,14.6,404},{48,78.5,404},{53.7,85,415},{38.9,13.8,402},{60.5,19.6,403},{47.1,40.5,404},{53.9,77.4,411},{48.1,70,411},{68.8,58.6,407},{60.7,43.1,408},{44.1,62.5,404},{55.3,47.5,402},{46.6,40.9,404},{54.9,26.7,401},{60.5,19.2,403},{46,40.8,404},{45.5,68.2,408},{51.8,39.2,402},{43.5,84.5,409},{34.5,43.2,402},{55.9,51.7,402},{69.4,49.3,407},{48.1,60.6,404},{63.2,52.2,407},{48.7,42.7,404},{58,35.9,401},{53.4,46.3,404},{33,36.4,401},{44.6,16.7,405},{47,47.8,401},{46.7,14.4,404},{60.7,15.7,402},{68.9,49.7,407},{49.7,58.7,411},{44.1,61.7,404},{49.1,98.7,408},{44.1,21.6,404},{55.5,43.6,404},{45.5,36.3,405},{65.8,44.2,407},{58.5,25.7,405},{52.2,14.6,401},{63.1,6.3,404},{46.1,40.5,404},{45.1,64.2,404},{41.7,78.2,405},{47.6,11.5,404},{55.5,12.1,405},{41.5,14.4,405},{60.7,19.4,403},{45.5,67,411},{55,26,401},{47.6,24.6,404},{42.3,38,404},{43.4,82.4,411},{43,61.6,403},{54.4,52.5,408},{64.2,49.4,403},{62.1,11.6,403},{44.4,40.7,404},{65.8,43.4,407},{46.2,40.6,404},{53.3,44.2,404},{31.7,26.1,408},{65.3,26.2,404},{60.1,45.5,403},{38.9,12.6,405},{45.1,90,409},{43.6,43.3,405},{38.7,15.5,402},{44.5,18.7,401},{33.7,22.9,408},{65.7,42.1,407},{44.6,81.4,405},{64.7,47.8,403},{65.2,47,407},{65.7,46.2,407},{33.7,22.7,408},{45.1,36,408},{62.2,42.4,407},{62.1,14.9,403},{61.6,42.3,403},{62.8,15.5,404},{44.6,72,411},{45.7,26.7,404},{64.4,36.1,407},{47.2,68.9,404},{46.7,29.6,402},{50.7,54.7,404},{61.6,10.8,404},{45.2,40.6,405},{55.5,41.2,402},{53,18.2,401},{56,40.4,404},{59.6,18.1,401},{54.9,76.7,411},{46.2,30,401},{54.3,76.6,412},{51.2,31.4,402},{59.5,17.2,402},{46.1,38.1,402},{45.1,61.8,405},{69,47.4,407},{56.5,52.7,409},{46.1,60.2,401},{40.7,29.5,403},{62.7,27.3,405},{64.9,48,403},{39.5,60.6,401},{43,37.1,403},{42.6,34.6,403},{54.4,63.6,413},{62.7,49.4,405},{41.5,17.5,402},{43.1,37.6,405},{43.6,72.4,404},{48.7,61.2,401},{56.9,59.6,411},{65.2,45.4,407},{48.8,75.2,404},{53.8,9.9,405},{40.5,32.2,405},{53.5,43.2,402},{62.7,13.4,403},{52.8,91.3,413},{47.6,43.9,404},{61.3,47.4,405},{43.6,76.5,405},{32.2,32.9,401},{45.6,15.6,405},{45.7,34.1,404},{44.5,83,409},{48.2,12.5,404},{53.5,42.8,405},{46.1,41.4,402},{60.1,7.1,405},{46.6,40.6,404},{51.4,27.1,401},{55.5,44.1,404},{56.5,47,404},{61.8,41.7,403},{64.9,46.8,403},{43.1,23.3,403},{64.9,37.8,407},{43.6,53.6,405},{38.9,28.8,403},{48.8,56.4,401},{30.6,20.7,405},{49.8,23.7,402},{43.5,83.8,405},{32.5,25.8,408},{41.8,19,403},{62.2,13,404},{52.9,50.9,404},{47.6,16.1,404},{55,79.7,412},{43.1,36,404},{64.7,44.6,403},{55,30.6,405},{45.1,77.4,401},{51.9,52.1,409},{31.4,26.3,408},{41.1,18,403},{39.4,81,409},{64.2,45,403},{54.9,42.8,402},{34.1,23.9,409},{34.5,22.4,408},{44.6,68.8,408},{47.7,73.9,404},{45.5,48.7,401},{41.8,14.1,404},{53.9,84.1,412},{50.4,53.7,404},{32.7,22.3,409},{40.3,29.6,404},{53.3,48.4,404},{45.2,64,411},{43,69.9,408},{42.6,51,404},{52.9,49.7,404},{39.8,12.4,403},{66.4,38.3,407},{34.3,20.6,409},{38.2,27.2,403},{44.2,56.2,404},{41,21.2,402},{42.1,82.7,408},{44.7,55.4,401},{41.3,14.5,408},{60.9,3.9,408},{49.5,57.1,405},{60.6,7.5,408},{58.2,11.7,408},{38,12,408},{58.6,12.3,408},{48,68.4,408},{63.7,44.6,403},{44.5,62.6,401},{58.1,13.1,408},{45,97.4,408},{46.1,56.6,404},{37.8,14.5,408},{38.4,14.7,408},{36.7,16.6,408},{62.3,43,407},{46.5,16.7,408},{33.3,32.9,403},{46.6,17.8,408},{62.9,38.3,407},{62.8,12.2,404},{47.3,19.4,408},{46.6,77.9,411},{47.1,19.7,408},{64.3,44.3,403},{47.9,32.6,408},{67.9,40.3,407},{66.4,42,407},{64.8,7.9,402},{35.1,21.7,409},{49.2,33,408},{54.4,82.1,414},{36.9,26.1,403},{43.8,33,404},{35.6,38.7,401},{60.2,44.9,403},{55.1,51.6,402},{46.6,34.1,408},{46.5,57.7,408},{40.5,17.1,402},{48.6,34.7,408},{48,35.7,408},{49.4,27.1,404},{46.4,36.4,408},{39.5,23,403},{46.7,64.9,404},{60.8,18,403},{59,20.5,403},{51.7,37.9,401},{60.5,43.6,408},{31,22.3,408},{62.1,44.8,408},{58.3,45.1,408},{56,13.5,404},{62.1,45.5,408},{58.1,45.8,408},{61.8,11.9,403},{61,46.4,408},{58.6,47.2,408},{42.5,47.2,408},{42.1,48,408},{47.1,67.9,408},{49.3,79.4,411},{43.8,81.3,408},{52.4,50.8,404},{39.5,58.4,402},{62,54,408},{38.5,15.4,404},{57.5,54.3,408},{47.2,32.6,404},{68.5,47.9,407},{62,54.7,408},{53.6,55.6,408},{58.7,10.9,404},{62.3,56.4,408},{62.9,10.8,404},{46.3,34.7,408},{44.6,48.8,404},{59.7,44.9,403},{52.5,49.4,404},{47.8,58.6,408},{47.4,15.6,404},{64.4,12.9,402},{55,63.4,413},{47.7,13.8,401},{57.2,48.5,408},{57.2,12.9,408},{42.5,68.9,408},{53.4,91.5,415},{43.3,69,408},{64.4,35,405},{42.5,69.1,408},{56.6,13.5,404},{45.1,70.5,408},{43.1,46.3,401},{47.1,40.3,402},{37.5,57,402},{43.7,71.9,408},{65,12.6,402},{43.9,73.1,408},{31.7,31.5,402},{40.6,80,408},{48.8,83.9,408},{65.5,42.9,407},{57.5,50.4,405},{64.3,25.1,401},{61.9,25.1,401},{41.1,81,408},{45.2,61.6,404},{43.9,81.1,408},{40.2,93.4,408},{48.7,83,403},{52.9,51.8,408},{41.6,24.6,405},{36.6,54.3,403},{41.4,82,408},{61.2,33.1,401},{42.3,82.6,408},{42,82.6,408},{44.7,83.4,408},{49.3,60.6,405},{39.8,14.7,405},{31.9,21.6,408},{47.9,85.2,408},{54.4,44.9,405},{47.8,85.7,408},{55,67.1,412},{40.3,28.2,405},{62.3,9.9,403},{48.2,85.8,408},{46.5,86.1,408},{45.5,86.3,408},{43.7,81.2,408},{62.1,5.5,405},{58.5,8.1,405},{62.2,8.2,405},{55.4,8.4,405},{45.6,68.5,404},{48.9,9.8,405},{48.5,12.3,405},{42.7,14.2,405},{47.8,84.7,408},{37.5,15.6,405},{38.6,16.7,405},{40.1,18.3,405},{41.2,19.1,405},{65.9,40.9,407},{40.2,20.7,405},{57,14.8,404},{46.1,54.2,404},{44.3,23.2,405},{55.8,13.1,404},{51.9,52.6,409},{67,48.7,407},{42.8,60.1,404},{58,24.6,401},{45,24.9,405},{58.9,20.7,403},{52.9,51,405},{63.3,39,407},{57.6,25.3,405},{30.5,23.8,408},{37.2,37.9,403},{47.8,53.2,405},{46.9,40.6,404},{49.8,54.9,405},{63.2,49.3,403},{54.2,26.8,405},{56,11.5,404},{60.3,34.4,401},{53.6,0.8,408},{56.7,5.6,404},{43,34.3,403},{48.4,88.7,409},{61.5,17.6,403},{44.9,65.4,404},{54.8,27.2,402},{42.1,14.4,404},{38.9,30.3,405},{47.8,77.7,405},{43.5,70,404},{43.6,21.6,404},{41.6,31.1,405},{79.4,42.1,401},{64.6,48.8,403},{62.8,30.4,405},{56,37.3,405},{48.5,80.4,404},{46.3,37.2,402},{32.9,24.9,408},{51.4,26,402},{61.7,17.6,404},{38.8,58,402},{59.1,36.9,405},{47.8,74.9,401},{57.1,4.1,404},{44.1,82.1,403},{49.4,33.3,404},{59.4,38.3,405},{63.3,47.2,403},{46.6,83.7,404},{45.1,37,408},{45.2,84.7,411},{51.4,12.4,402},{38.8,12.7,402},{64.9,36.7,407},{46.6,61.7,405},{48.2,37.6,402},{43.6,83.6,408},{45.8,36.7,402},{45.6,27.2,402},{48.4,39,402},{45.7,39.7,404},{64.3,44.6,403},{49.9,15.9,402},{31.2,26.8,409},{49.9,76.7,405},{59.6,19.5,403},{34.3,23.1,408},{50.3,21.8,403},{44.2,77.7,405},{64.3,46.4,405},{45.7,35.3,408},{41.6,94.8,411},{46.1,44,401},{47.8,49,405},{58.9,49.7,405},{42.2,48.8,401},{63.8,41.5,407},{63.6,47.5,403},{60.8,50.4,405},{40.8,22.1,403},{47.7,64.6,404},{55.2,50,405},{61.2,26.6,403},{43.6,43.1,408},{38.5,58.4,402},{76.9,44.9,402},{62.5,43.6,407},{49.1,87.6,403},{62.3,9,403},{56.2,11.7,404},{49.3,14,401},{46.7,74.8,411},{65.4,36.4,407},{65.4,6.2,401},{59.5,20,403},{64.1,43.3,403},{59.2,7.4,401},{64.7,48.9,407},{62.6,54,405},{43.5,82.4,411},{42.3,68.6,409},{43.8,38.5,404},{45.8,36.8,402},{51.4,49.9,404},{49.4,36.4,401},{47.9,34.5,411},{43.9,25.6,405},{44.6,55.3,405},{56.5,33.9,405},{52.9,67,414},{66,48.3,407},{59.7,6.1,408},{44.5,19.2,404},{61.2,48.3,401},{40.1,22,403},{35.6,41.1,402},{42.9,55.5,404},{54.1,35.7,402},{54.5,47.2,404},{64.4,55.5,407},{46.7,65.4,404},{43.5,62,405},{42.5,83.3,409},{64.4,44.9,407},{44.9,64.1,405},{43,16.4,404},{40.1,25.4,403},{51.5,24.9,402},{41.6,18.7,403},{46.4,35.2,404},{39.2,92.4,409},{38.4,57.5,402},{43.1,34.1,403},{64.4,49.4,403},{48.3,73.8,405},{60.9,18.6,403},{40.8,30.5,403},{49.1,40.9,404},{55,78.3,415},{64.9,44.1,403},{55.3,26.7,401},{48.6,32,411},{64.3,48.5,403},{45.2,83.5,405},{54.5,47.1,402},{56.6,13.7,404},{48.2,71.6,408},{64.2,16.7,401},{63.3,32.1,403},{59.3,33.6,405},{63.4,5.6,404},{61.8,16.5,403},{50.3,24.1,402},{54,29.9,401},{62.9,6.8,404},{48.7,62.1,411},{79.1,42.7,402},{62.8,14.9,404},{44.6,40.3,404},{40.8,30.3,403},{62.5,6.7,404},{47.5,65.8,404},{59.8,19.3,403},{57.3,9.9,404},{43.1,20.2,404},{58.4,10.5,404},{56.5,14.2,404},{48.2,40.1,402},{61.3,21.4,403},{42,29,404},{56.3,10,401},{40.5,26.1,403},{64.5,45,407},{48.3,18.5,408},{65.1,35.6,407},{51.6,54.6,404},{45.8,64.8,409},{49.5,27.3,402},{53,53.2,411},{43.8,28.4,401},{64.3,25.6,403},{60.9,18.2,403},{61.7,42.5,403},{61.4,53,408},{46.7,37.6,402},{46,83.6,404},{47.2,72.4,411},{49.3,39,401},{55.3,82.4,412},{48.3,12.8,404},{50,23.7,402},{39.8,23.5,405},{30.6,25.4,408},{47.4,69.3,408},{38.2,15.2,404},{64.2,26.4,401},{54.9,61.9,411},{53.9,73,415},{41.4,14.4,404},{39.3,23.3,403},{60.6,41.8,401},{40.1,20.3,405},{61.8,42.3,403},{61.4,16.3,402},{40.7,32.1,403},{53.3,15.3,404},{55.7,43.6,404},{50.3,50.5,405},{44.2,50.8,404},{50.4,23.7,402},{48.4,85.3,403},{45.6,21.3,402},{47.2,67.5,408},{41.5,30.7,402},{64.3,43.5,403},{50.3,23.6,402},{33,24.3,411},{47.8,85.2,408},{45.1,56.3,401},{34.3,21.7,404},{46.9,34.8,408},{43,16.3,404},{63.9,48.6,403},{55.9,46.6,404},{45.7,38.4,402},{51.3,24,402},{42.6,16.1,404},{51.4,19.7,401},{60.1,54.2,409},{65.9,35.5,407},{49.4,30.1,401},{63.8,47.7,403},{55,89.3,414},{48.4,18.2,408},{44.3,21.2,404},{65.1,48,407},{48.4,13.7,401},{46.8,81.9,411},{40.8,94.4,409},{68.6,49.7,407},{41.9,23.2,404},{46.3,38.1,402},{61.1,24.4,405},{47.8,80.3,404},{54.3,21,401},{57.2,25.3,402},{48.1,25.6,404},{61.7,41.9,403},{56.2,13.4,404},{35.8,50.5,403},{45.7,33.5,408},{53.7,37.9,401},{64.6,43.3,407},{59.8,53.3,404},{47.4,34.2,404},{40.9,30.2,403},{48.4,17.8,408},{60.4,19.6,403},{44.4,34.6,404},{47,36.1,404},{55.5,16.9,402},{53,24.5,402},{45.4,36.7,404},{60.3,7.9,401},{47.2,38.5,402},{65,47.1,407},{46.8,72.5,404},{31.5,22.8,409},{43.2,39.6,404},{43.8,39.7,404},{48.3,43.5,404},{45.7,40.4,404},{69.7,49.9,407},{64.3,42.9,407},{48.3,40.5,404},{39.6,29.3,403},{46.2,32.3,411},{59.2,26.2,401},{45.3,50.7,403},{54.5,25.1,402},{65.9,44.6,407},{64,48.3,401},{54.1,28.4,401},{61.9,10.5,403},{59.9,45,403},{44.3,90.7,404},{36.3,51.5,403},{46.8,41,404},{80.1,42.8,402},{46.7,40.8,404},{46.3,32.8,408},{44.8,52.8,404},{60.2,45.1,403},{36.4,38.6,403},{44,24.1,403},{64.6,38.6,407},{37.4,56.3,402},{55.9,12.7,404},{53,42.8,404},{44.7,20.8,403},{63.8,46.5,403},{58.3,36.9,404},{47.5,45.3,404},{53.9,43.8,404},{46.5,38.1,402},{40.6,32,405},{61.5,16.6,403},{68.2,47.8,407},{42.9,40.1,404},{63.1,37.7,407},{56.8,17.3,404},{39.6,14.2,403},{51.7,49,404},{46.3,32.4,411},{61.8,44.8,405},{44.6,77.6,401},{45.7,36.8,404},{51.7,53.1,404},{50,24.1,402},{53.5,50,404},{60.3,24.7,403},{43.1,57.5,404},{47.8,51.2,404},{48.3,12.9,404},{40.9,29.6,403},{46.5,37.8,402},{62.3,30.5,403},{41.6,57,405},{70.5,41,407},{45.2,66,405},{54.6,62.4,412},{66.3,38.9,407},{42.8,41.2,403},{46.5,77.9,404},{56.7,24.5,401},{45.8,63.9,404},{43.1,82.3,404},{61.5,15.9,403},{76.9,40.5,402},{64.1,33.3,405},{68,59.1,407},{62.8,11.7,403},{61.2,17.7,403},{63.9,43.9,401},{39.6,28.7,403},{47,37.6,402},{33,23.5,408},{48.4,51.8,401},{40.8,21.9,403},{47.7,98.2,411},{42.1,60.5,405},{59.2,51.6,405},{43.7,24.2,403},{56.3,12.3,404},{60.9,22.7,401},{33.9,22,408},{64.7,43.8,403},{42.6,71.2,401},{64.4,48.1,403},{65.3,42.8,407},{51.7,56.6,404},{62.3,12.1,403},{47.5,41.5,404},{67.1,38.7,407},{44.5,23.1,402},{61.4,54.3,405},{55.1,12.1,401},{63.3,40.4,407},},["Fishing"]={{44.7,23.6,109},{63.5,38.8,107},{46.1,37.7,109},{63.1,38.5,107},{55.2,41.8,109},{64.4,42.9,107},{63.4,59.3,105},{65.9,43.4,107},{56.1,43,109},{48,40,109},{63.5,50.1,107},{47.5,40.4,109},{63,52.8,107},{46.5,38.5,109},{45.9,39.8,109},{63,52.4,107},{64.5,43.1,107},{63.3,50.5,107},{45.1,23.6,109},{62.7,38.7,107},{63.9,58.8,105},{64.6,36.2,107},{63.2,50.2,107},{63.2,38,107},{63.1,53.2,107},{64.5,56.9,105},{63.4,38.2,107},{55.8,42.5,109},{64.3,57.8,105},{63.8,60,105},{64.8,47.3,107},{45.1,22.2,109},{63.6,41.6,107},{45.5,22.7,109},{46.3,37.6,109},{55.5,43.3,109},{64.5,56.1,105},{64.9,47.7,107},{46.3,40.2,109},{55.2,42.8,109},{64.6,45.7,107},{63.5,36.8,107},{63.7,38.3,107},},},
["Desolace"]={["Mining"]={{29.5,71.3,206},{30.2,58.3,206},{83.3,56.8,201},{69.8,54.3,206},{31.7,51.9,206},{84.2,72.8,201},{47.2,88.2,206},{27.7,57.5,206},{65.9,84.4,206},{33,61.6,206},{59,91.2,206},{74.3,60.2,206},{75,67.6,206},{38.2,60.8,206},{64.3,38.6,206},{35.4,56.5,206},{73.9,20.2,206},{31.9,65.2,206},{76.9,28.2,206},{31.9,65,206},{46.4,63.1,206},{32.1,58.9,206},{62.3,24.6,206},{30.4,60.4,206},{32.3,63,206},{39.4,85.4,206},{86.3,70.6,201},{28.1,74.3,206},{43.4,83.7,206},{86.8,78,201},{40.9,73.9,206},{24.7,82.4,206},{47.2,52.4,206},{33.4,83.1,206},{67.4,57.9,206},{30.5,74.1,206},{49.8,5.5,206},{74.4,57,204},{55.9,82.7,206},{85.8,65.1,201},{52.9,5.2,206},{50.1,5.9,206},{51.9,7.6,206},{56.2,8.1,206},{45.6,77.6,206},{52.8,9.6,206},{75.2,10.8,206},{59.5,10.9,206},{36.3,60.5,206},{46.7,13.2,206},{86.5,17.5,205},{61.7,13.8,206},{80.9,16.9,206},{63.8,14.5,206},{55.1,33.7,206},{34,14.7,206},{69.6,16.1,206},{88.7,16.5,202},{75.2,14.1,206},{51.1,90.1,206},{77.8,19.4,206},{54.4,20.7,202},{29.2,57.7,206},{32.1,71.6,206},{57.4,79.8,206},{43,22.3,206},{29.7,59.7,206},{53,24.2,206},{54.8,79.6,206},{50.3,82.3,206},{78.8,28.3,206},{78.8,28.9,206},{68.7,42.2,206},{50.5,65.8,206},{60.3,41.9,206},{48.5,29.4,206},{77.3,30.1,206},{61.6,31.1,206},{47.7,76.6,206},{66.5,67.7,206},{88,67.9,201},{57.3,73.4,206},{75,32,202},{42.3,65.7,206},{67.8,77.4,206},{60.8,32.2,206},{58.5,33.4,206},{69.3,34,206},{40.1,43.7,206},{58.2,74.6,206},{74.5,36.2,206},{30.9,36.7,202},{33.3,65.6,206},{74.1,36.9,206},{48.1,78.9,206},{34.1,38.1,202},{38.5,38.2,206},{68.5,39.5,206},{45.3,54,206},{65.6,40.7,206},{72.5,40.8,206},{72.7,41.2,206},{36.3,79.9,206},{71.5,76.3,206},{48.8,29.4,206},{75.2,42.4,206},{57.5,43.1,206},{47.1,43.1,206},{54.5,31.7,206},{87,64,201},{48.4,43.9,206},{54.1,44.6,206},{64.9,44.9,206},{59,43.9,206},{45.3,68.1,206},{71.2,45.6,206},{56.2,45.7,206},{54,87.6,206},{67.9,84.4,206},{72.2,57,206},{55,46,206},{55.2,46.2,206},{50.4,46.5,206},{35.1,52.1,206},{61.4,69.2,202},{66.3,47,206},{62.3,47.7,206},{68.8,48.4,206},{28.6,62.6,206},{54.9,79.5,206},{75.4,49.8,206},{45.2,49.8,206},{35.5,55.2,206},{31.2,62.2,206},{30.6,51.2,206},{64.3,51.2,206},{30.6,64,206},{27.1,58.2,206},{41.7,76.1,206},{74.8,45,206},{49.2,73.2,206},{42.5,73.1,206},{35.4,78.3,206},{65.9,53.3,206},{74.5,76.4,206},{65.9,60.7,206},{32.1,52.9,206},{39.4,74.7,206},{31.1,62,206},{27.8,83.8,206},{29.2,66,206},{64.2,55.2,206},{29.1,58.1,206},{36.2,92.4,206},{78.9,54.3,206},{30.8,52.9,206},{35.6,53.5,206},{32.3,62.6,206},{29.8,56.6,206},{69.3,55.2,206},{58.9,65.6,206},{34.9,52.6,206},{45.9,73,202},{29.3,58.4,206},{54.5,83.4,206},{44.7,82.1,206},{40.2,55.5,206},{29.2,56.2,206},{33.1,53.2,206},{49.4,42.2,206},{34.9,60.2,206},{49.5,64.3,206},{31.5,59.4,206},{64.5,79,206},{72.1,63.2,206},{29.4,62,206},{46.1,57.7,206},{33.6,61,206},{27.1,78.7,206},{51.5,43.2,206},{86.9,61.3,201},{62.4,60.3,206},{68,61.7,206},{35,80.7,206},{80.6,53.9,201},{30,59.3,206},{76.5,75.4,206},{67.5,59.4,206},{27.7,74,206},{68.5,45.8,206},{87.3,17.4,205},{36.8,59.4,206},{61.6,76.7,206},{34.7,71.5,206},{36.1,86.5,206},{68.3,56.5,206},{61.7,90.3,206},{29.1,61.6,206},{27.5,74.4,206},{75.4,22.5,202},{55.8,73.1,206},},["Herbalism"]={{87,57.8,401},{52.5,21.9,409},{87.8,53.8,401},{36.1,29.4,407},{62.3,74.1,411},{46.8,94.9,409},{84.2,72.4,402},{55.1,46,408},{78.8,17.1,408},{33.3,54.9,408},{61.6,44.3,408},{50.4,73.4,408},{85.5,44.8,402},{37,59.9,408},{47.8,47.3,411},{36.9,60.1,408},{78.7,20.2,408},{18.6,77.5,407},{23.3,73.3,407},{33.5,52.7,408},{45.2,56.1,411},{90.7,21.6,409},{30.2,60.6,423},{61.5,0.7,409},{30.1,60.8,423},{56,47.8,411},{87.8,72.4,401},{74.6,75,412},{42,53.6,411},{64.4,54.2,408},{56.8,84.6,411},{88.6,62.5,401},{61.5,70.5,412},{84.9,53.4,401},{41.1,26.2,411},{73.6,16.6,408},{20.5,79.2,407},{50.7,72.1,408},{87.5,64.5,403},{53.7,80.1,424},{37.3,61.2,408},{51.3,43.4,408},{41.2,19.7,407},{33.1,36.8,407},{51.7,76.7,412},{87.2,62.5,402},{49.4,80.4,412},{34.4,56.7,408},{59.4,70.6,412},{81.2,53.6,403},{51.1,68.7,424},{50.3,70.3,424},{50.3,72.7,424},{50.3,72.9,424},{56.7,73.5,424},{50.3,73.7,424},{82,35.5,409},{51.9,28.4,408},{88.2,70.6,402},{49.8,73.9,424},{53.9,73.9,424},{54.2,74.1,424},{75.4,25.8,408},{55.9,78,424},{50.1,81.4,424},{46.7,82.7,424},{52.6,83.2,424},{61.9,59,411},{87.4,67.1,402},{29.1,54.1,423},{28.9,54.8,423},{53.2,78.1,412},{48.9,74.9,408},{28.1,55.1,423},{28.9,57,423},{27.5,57.6,423},{32.1,29,407},{49.5,77.2,408},{29.3,58.4,423},{42,63.4,411},{36.5,26.5,407},{41.9,45.7,411},{74.6,32.5,411},{30.5,63.2,423},{32.2,63.3,423},{41.3,22.4,407},{28.4,63.6,423},{29.9,65.6,423},{31.4,18.2,407},{39.1,20.8,407},{40.3,22.5,407},{36.6,61.4,408},{52.2,90.7,409},{37.6,24.7,407},{36.1,32.4,407},{35.9,35.4,407},{36.6,61.2,408},{54.7,44.6,408},{71.9,70.1,412},{23.9,73.2,407},{33.5,53,408},{42,70,411},{86.7,78,403},{57.2,80.7,412},{49.7,72.8,408},{64.2,44.8,408},{32.3,62.7,423},{75.5,26.9,408},{79,24.9,408},{26.1,76.9,407},{79.5,23.1,408},{75.4,26.9,408},{49.3,39.5,411},{26,78.4,407},{70.6,17.4,408},{75.2,71,412},{35.3,60.5,408},{50.7,74.3,408},{72.6,12.4,409},{51.7,69.9,408},{81.8,51.1,402},{53.2,28.2,408},{61.4,61.7,408},{51.7,29.5,408},{85.7,45.9,401},{64.2,35,411},{25.8,81.2,407},{75.5,45.7,409},{78.6,18.3,408},{78,24.4,408},{72.3,77.3,412},{22.3,71.1,407},{72.6,16.7,408},{54.2,44.8,408},{39,62,408},{54,25.7,408},{22,82.3,407},{47.9,90.9,409},{86,70.6,403},{53.7,26.5,408},{24.6,81.8,407},{43.5,82.3,412},{48.7,8.9,409},{43.2,63.2,411},{45.4,81.3,412},{40.9,81.8,412},{44,78.3,412},{54.6,30.8,408},{52.5,91.1,409},{50.8,27.3,411},{50,71.3,408},{37.3,61.3,408},{75,45.7,409},{45.2,40,411},{26.1,80,407},{53.2,25.5,408},{26.1,75.3,407},{51.4,68.3,424},{87.6,51.9,402},{90.4,34.7,402},{29,53.3,408},{52.6,42.7,408},{29.1,82.3,411},{79.3,34.7,409},{75.8,52.2,409},{55,46.2,408},{47.1,13.3,409},{48.6,78.7,408},{69.3,21.6,411},},["Fishing"]={{25.7,78.2,105},{35.7,31.1,105},{21.5,73.3,105},{21.9,74.8,105},{25.8,76.8,105},{24.1,73.6,105},{25.8,79.6,105},{24.5,81.3,105},{36,26.4,105},{25.8,80.7,105},{21.1,74.2,105},{23.5,73.6,105},{39.2,22,105},{38.5,22.8,105},{37.9,24.1,105},{35.8,28.1,105},{22.1,72.7,105},{37,25.1,105},{24,82.5,105},{35.7,30.2,105},{26,75.8,105},},},
["Tanaris"]={["Mining"]={{33.5,46.6,208},{61.9,63.2,208},{30.2,78.8,208},{44.2,13.2,207},{44.9,26.2,208},{43.7,13.6,207},{50.7,18.5,203},{37,28.2,208},{48.6,23.7,208},{34.2,30.8,208},{36.3,20.1,208},{37.6,21,208},{56.9,73.9,208},{32,24.9,208},{57.7,23.3,208},{47.1,23.7,208},{57.7,70.3,208},{45.1,25.5,208},{29.7,47.6,208},{29.7,68.8,208},{37.1,27.5,208},{60.3,62.5,208},{70.3,52,208},{33.2,45.7,208},{71.8,48.5,208},{41.2,76.1,208},{38.3,78.3,208},{37.4,45.8,208},{43.9,25.9,208},{61.6,41.1,208},{27.2,55.6,208},{57.1,26.3,208},{57,69,208},{32.9,44.4,208},{44.5,22.8,208},{37.9,26.7,208},{34.3,26.8,208},{70.2,50.8,208},{57.4,27.2,208},{30.9,66.7,208},{33.1,42.7,208},{62.5,56.8,208},{56.8,69.6,208},{27.9,71.9,208},{34.3,29.8,208},{52.6,78.9,208},{41.4,58,208},{34.7,80.3,208},{37.9,41.3,208},{38.2,27.2,208},{38.5,27.2,208},{57.4,26.3,208},{57.9,74.8,208},{57.8,71.9,208},{31.5,80.1,208},{36.6,33.7,208},{47.3,29.2,208},{46.7,29.9,208},{35.4,43.3,208},{62.1,31.2,208},{62.4,32.1,208},{30.9,63.4,208},{35,42.3,208},{34.7,78,208},{59.8,53.8,208},{55.6,72.9,208},{63.8,35.9,208},{57.8,36,208},{48.2,79.9,208},{57.6,37.5,208},{33.4,37.6,208},{61.6,63.6,208},{36.5,51.9,208},{29.9,65.3,208},{55.5,69.9,208},{71.9,47,208},{36.7,33.3,208},{58.4,75.3,208},{41.3,76.5,208},{54.3,24.5,208},{28.7,69.8,208},{33.6,45.9,208},{45.7,77.5,208},{47,56.2,208},{33.6,47,208},{28.2,53.4,208},{26.8,71.8,208},{33.4,41.6,208},{37.7,27,208},{51.2,79.4,208},{47.4,78.9,208},{27.2,70.6,208},{71.3,52.6,208},{40,34.2,208},{27.7,56,208},{63.7,62.5,208},{68.8,54.9,208},{27.1,69.2,208},{44.4,76.5,208},{27.9,53.7,208},{27.6,56.6,208},{31.9,66.7,208},{60,54,208},{31.4,67.1,208},{43.3,78,208},{55.9,77.2,208},{45.5,55.1,208},{63,59,208},{29.4,65.2,208},{53.3,69.1,208},{31.5,46.1,208},{41.3,54.4,208},{32.4,65.2,208},{61.9,53.6,208},{33,79.7,208},{28.7,52.9,208},{54.7,77.4,208},{58.8,72.7,208},{31.6,79.4,208},{62.5,57.3,208},{34.5,40.3,208},{55.2,75.9,208},{34.7,42.4,208},{57.1,68.2,208},},["Herbalism"]={{71.4,55.4,407},{46.8,73.9,417},{56.5,32.7,417},{42,36.2,417},{41.5,31.2,417},{73.2,43.4,407},{68.3,25.5,407},{66,62.9,407},{52.3,44.2,418},{63.5,52.9,418},{47.8,65.8,418},{65.7,20.1,417},{38.9,20.6,418},{68,35.8,407},{53.7,47.5,418},{50.8,60.6,417},{44.4,24.8,417},{55.5,44.3,417},{72.9,49.6,417},{38.8,21,418},{60.8,37,417},{58.8,58.2,417},{63.6,49.3,418},{64.2,32.2,417},{60.3,22.7,418},{60.8,22.7,418},{35.3,64.6,417},{31.4,58.2,417},{59.4,40,417},{36.7,60.2,417},{68.6,30.8,407},{59.3,23.3,418},{60.6,24.2,418},{65.1,52.2,418},{45.5,61.1,417},{59.4,24,418},{37.2,73.4,417},{61.7,29.8,417},{60.2,24.5,418},{60.8,23.7,418},{63.5,52.7,418},{53.4,47.5,418},{32.3,34.2,426},{40,39.3,417},{52.7,45.9,418},{65.6,29.2,417},{41,66.8,417},{52.7,45.5,418},{37.5,81.7,418},{54.4,46.5,418},{63.8,58.2,417},{46.3,51,417},{59.9,24.2,418},{63.3,35,417},{54.7,48,418},{71.5,50,417},{53.4,44.8,418},{46.8,64.2,418},{59.9,43.7,417},{33.8,61.7,417},{39.4,74,418},{46.7,64.9,418},{45.5,64.5,418},{37.6,37.2,417},{39.2,20.4,418},{47,65.8,418},{47.8,67,418},{53.9,47.5,418},{61.7,24.1,417},{40.5,71.8,418},{40.2,72.8,418},{66.6,40.9,417},{51.7,37.8,417},{29.8,74.8,417},{59.9,22.9,418},{45.4,64.4,418},{62.8,43.6,417},{36.1,79.5,418},{72,45.2,417},{60.8,60.5,417},{38,80.2,418},{39.2,20.9,418},{39.5,72.8,418},{44.9,42.9,417},{65.8,34.5,417},{57,24.8,417},{49.8,33.6,417},{41.5,26.2,417},{54.4,35,417},{41,53.2,417},{62.6,51.7,418},{55.9,58.8,417},{56.6,50.1,417},{44.9,30,417},{47.3,32.3,417},{70.1,56.5,407},{65.9,65.9,407},{64.6,41.2,417},{47.3,67.1,418},{63.2,50.8,418},{68.3,39.2,407},{71.6,47.4,417},{39.1,66.8,417},{38.6,24.8,417},{48.6,37.2,417},{33.3,55.4,417},{44.4,47.5,417},{47.7,42.3,417},{47.1,36.1,417},{49.2,40.6,417},{49.8,44.3,417},{54.6,40.7,417},{36.2,55.9,417},{70.5,42.8,417},{71.8,41.2,407},{40.1,76.8,417},{59.9,50.9,417},{70.2,39.5,407},{46.8,27.1,417},{40.4,61.2,417},{38.3,20.7,418},{48.4,76.2,417},},["Fishing"]={{67.7,35.7,105},{73.7,50.3,105},{66.6,18.2,105},{73,44.2,105},{67.4,19.4,105},{67.9,27.2,105},{67.5,37.8,105},{67.9,22.6,105},{72.7,43.9,105},{71.3,41.1,105},{68.6,23,105},{71.4,41.8,105},{68.5,34.6,105},{69.9,56.2,105},{75.5,47.1,105},{68.1,28.3,105},{67.5,25.7,105},{67.7,21,105},{67.4,24.9,105},{68.1,29.5,105},{73.2,51.4,105},{68,36.8,105},{71.1,40.3,105},{65.4,60.2,105},{74.7,49,105},{67.5,38.9,105},{68.2,39.5,105},{67.9,23.4,105},{74.1,49.6,105},{65.1,61.2,105},{66.2,60.3,105},{72.1,42.9,105},},},
["Felwood"]={["Mining"]={{47.8,14.2,205},{63.7,25.2,205},{58.4,87.9,205},{30.6,29.7,204},{52.9,30.4,205},{28.6,66.2,202},{29.7,34,202},{36.2,68.9,205},{57.6,17.3,205},{36,11.2,201},{63,23.9,205},{57.7,19.1,205},{41.6,9,205},{61.3,21.3,205},{36.8,39.8,205},{38.8,62.1,205},{37.8,52,205},{43.5,18.2,205},{47.2,95.3,205},{61.7,9.1,205},{36.6,62.7,205},{40.4,22.4,205},{40.8,9.2,204},{36.3,55.4,205},{43.4,41.2,205},{44.7,12.3,205},{28.8,65.9,201},{63.1,10.2,205},{34.7,61.8,205},{44.2,48.5,205},{60.3,22.9,205},{38.9,55.1,205},{47.9,37.5,205},{64.4,6.5,205},{64.4,10.5,205},{61.8,8.5,205},{49.4,27.4,205},{63.2,7.8,205},{28.6,70.8,204},{61,21.8,205},{37.7,52.7,205},{61.3,6.8,205},{37.6,66,205},{61.9,22.3,205},{38.6,61.9,205},{63.5,11,205},{45.6,12.2,205},{57.3,19.5,205},{56.4,17.6,205},{63.4,26.5,205},{38.2,45.7,205},{44.4,16.2,205},{44.1,15.9,205},{52.5,18.6,205},{50,31.9,205},{42.8,84.1,205},{38.9,33.2,205},{57.5,95.4,203},{29.6,30.7,204},{41,75.3,205},{58.5,97.8,203},{59.2,19.4,205},{38,48.4,205},{39.8,22.3,205},{64.3,12.8,205},{39.5,20.4,205},{57.8,22.1,205},{63.4,21.3,205},{39.9,95.5,204},{59.7,21.1,205},{39,56.8,205},{61.8,21.3,205},{63.2,24.7,205},{49.5,90.9,205},{37.9,33.4,205},{59.6,6.1,205},{37.7,47,205},{47,72.4,205},{57.5,22.5,205},{38.3,66.1,205},{28.6,69,202},{36.6,52,205},{38.1,32.2,205},{57.4,25.7,205},{48.6,23.8,205},{41.1,81.5,205},{39,46.4,205},{43.2,46.7,205},{48,35.6,205},{39.7,64.4,205},{42.8,40.2,205},{38.8,47.4,205},{37.5,54.2,205},{38.1,50.4,205},},["Herbalism"]={{65,21.8,426},{51.6,15.8,426},{55,15.5,426},{48.1,28.5,428},{48.5,21.6,426},{49.6,18.7,425},{41.6,65.3,424},{47.2,72.9,426},{46.9,23.5,425},{58.7,96.1,409},{48,79.4,425},{57.5,15.2,424},{44.8,76.8,426},{46.3,42.4,426},{43.3,16,426},{60.5,25.5,427},{49.7,17.5,426},{38.8,49.1,424},{42,82.2,424},{64.2,19.5,426},{46.6,77.3,424},{39.3,83.8,428},{39.5,31.7,424},{55.7,95.9,405},{45,82.4,424},{52.3,27.2,428},{39.1,45,424},{46.9,24,426},{56.8,22.4,426},{42.3,81.3,426},{37.9,49.1,424},{49.1,29.4,424},{40.4,25,424},{46.3,86.2,424},{40.5,84.5,425},{41.3,55.2,426},{47,87.5,426},{38.4,38.6,424},{54.3,17.3,421},{43.9,65.5,428},{53.8,11.5,424},{58.8,17.3,424},{49.6,18.6,425},{46.1,14.2,421},{49.5,12.3,424},{40.2,59.7,426},{39.6,80.2,426},{57.4,85.8,421},{44,81.4,424},{56.3,84.4,426},{52.4,26.5,426},{45.1,72.6,425},{53.9,23.1,426},{40.1,68.1,426},{63.8,6.5,425},{41.4,19.5,425},{43.4,65.5,426},{56.8,22.3,426},{53.3,93.3,409},{44.5,41.2,428},{40.4,59.7,426},{37.7,42.6,424},{40.2,58.6,424},{65.1,11.9,424},{41.3,58.1,421},{38.8,73.1,424},{44,82.4,428},{55.9,8.9,426},{38.6,58.9,425},{50.8,32.6,428},{63.4,4.8,427},{41.6,58.8,426},{40.8,76.6,426},{41,67.8,426},{64.5,13.1,424},{42.9,65.8,421},{42.7,63.1,426},{45.3,18.8,426},{47.2,16,424},{56.7,10.6,425},{53.2,26,421},{40.7,76.7,426},{49.7,80.4,428},{56.6,21.4,425},{42.6,44.5,427},{61.9,25.8,428},{48.5,21.4,426},{42.2,16.1,428},{51.5,12.5,425},{52.3,24.9,425},{54.5,25.5,421},{49.2,15.2,424},{56.8,26.5,428},{58,18.1,426},{40.8,50.1,426},{62.5,11.7,426},{48.3,90.6,424},{40.2,30.5,421},{69.4,13.1,429},{45.2,46.7,427},{39.8,56.9,426},{48.6,86.5,428},{38.8,72.8,428},{38.6,59.4,424},{57,22.5,426},{41.7,16.4,427},{41.1,23,424},{45.5,41.5,425},{51.6,11.8,428},{42.4,80.8,425},{47.4,15.7,426},{56.5,86.7,425},{51.5,87.3,426},{39.3,36.1,424},{62.2,14.7,424},{45.3,21.4,424},{40.4,69,424},{40.4,84.5,425},{39.6,74.5,425},{50.5,87.4,425},{38.8,59.4,424},{44.4,46.5,426},{55.9,9.3,421},{45.5,36.1,424},{42.4,74.9,424},{37.8,52.3,424},{29.4,73.5,403},{46.6,24.1,426},{55.7,84.4,426},{64.9,21.6,426},{41.4,41.6,428},{45.7,41.2,425},{56.8,28,427},{38.5,46.1,424},{48.7,24.8,428},{56.7,86.4,425},{49,88.6,424},{45.9,81.6,426},{63.9,6.2,425},{43.2,65,424},{49.3,35.3,421},{43.9,63.1,424},{47.3,22.7,428},{42.2,18.7,424},{38.9,50.7,426},{56.7,83.7,428},{54.4,87.5,424},{38.3,40.7,424},{49.5,17.9,425},{53.2,93.2,409},{62.1,7.2,424},{52.8,94.2,409},{55.9,8.7,421},{38.8,49.2,424},{53.5,27.6,424},{44.7,85.1,424},{42.8,15.3,426},{38,60.3,424},{48.5,79.5,425},{57.3,97.9,411},{64.5,22,427},{47.3,18.9,424},{36.8,69.2,424},{41.2,34.3,426},{46.1,85,424},{39.3,30.4,421},{58.7,17.1,424},{54.8,16.4,421},{40.2,69.7,428},{55.2,11.1,428},{39.2,84.8,421},{62.1,21.6,424},{52.5,26.6,426},{42,80.2,424},{55.9,9.2,424},{43.6,66.6,426},{46.7,90.7,428},{49.8,17.5,425},{53.1,22.8,426},{56.6,90.7,424},{56.8,18.6,428},{38.4,68.9,428},{62.4,11.6,426},{52,18.7,428},{55,20.4,428},{43.4,21.6,428},{38.2,56.3,428},{56.7,23.9,428},{40.1,36.4,426},{55,15.6,426},{48.9,20.7,426},{38.1,40.1,421},{63.8,6.2,425},{46.4,39.7,426},{47.9,38.7,428},{43.3,42.9,428},{54.2,16,426},{40.3,43,426},{39.1,44.8,424},{42.1,49.8,428},{30.9,28.6,403},{60.7,25.8,425},{40.2,65.3,428},{37.6,68.7,424},{41.9,68.3,428},{44.8,69.9,428},{56.3,10.2,425},{38.9,52.9,424},{46.5,76.4,428},{38.1,54,421},{43,21.8,424},{47.5,80.1,425},{40.3,72.6,428},{42.1,58.6,428},{37.3,61.1,426},{52.8,23,425},{53.1,83,428},{44.8,86.5,426},{50.2,12.7,426},{62.4,19.6,425},{38.7,53.3,421},{40.3,72.2,424},{53.6,90.4,428},{40.9,78.2,428},{38.6,53.4,421},{55.9,88.2,428},{40.7,77.9,424},{41.7,20.5,427},{44.7,69.5,426},{59.9,10.7,427},{53.3,24.9,427},{38.7,57.8,425},{55.9,9,426},{39.9,44.9,426},{52.2,24.9,425},{40.3,38.8,428},{37.6,39.3,421},{51.4,87.3,426},{53.8,14.3,428},{50.5,32.6,426},{46.9,24.1,426},{41,37.6,428},{56.8,22.5,426},{56.8,10.2,421},{64.5,16,424},{40.7,78.1,426},{45.8,84.8,426},{56.7,84.9,426},{49.1,33.4,421},{51.7,29.8,424},{37.9,49.2,424},{63,25.5,424},{57.5,18.9,424},{50.8,21.3,424},{41.9,77.8,424},{52.9,23.9,425},{69,11.7,429},{39.8,29.5,424},{55.2,11.7,424},{53,10.5,426},{40.1,58.8,424},{46.8,17,424},{42.6,32.7,427},{47.1,24.9,427},{49.8,17.4,425},{40.7,49.9,426},{60.1,7.3,428},{56.7,21,425},{45.4,72.6,425},{40.7,23.4,421},},["Fishing"]={},},
["Stonetalon Mountains"]={["Mining"]={{80.2,84.5,205},{65.5,61.3,205},{34.2,16.4,205},{43.6,26.1,205},{35.8,50.6,205},{31.5,83.1,206},{67.2,89.4,205},{76,48.7,202},{41.1,13.7,202},{72,54.1,205},{32.4,12.6,205},{46,34.9,205},{35.9,59.4,205},{49.1,32.3,201},{36.9,19.5,205},{70.9,87.5,205},{29.2,60.3,204},{72.1,51.7,205},{34.8,47.9,205},{73.4,61.4,205},{51.3,32.1,201},{77.5,95.6,201},{66.1,89.8,201},{59.1,82.1,205},{26.7,64.4,205},{37.6,61.2,204},{35.6,58.8,205},{32.7,19.2,205},{72.5,87.3,205},{34.6,11.2,202},{73.1,59,205},{38.1,53.1,205},{76.7,59.5,201},{49,88.7,206},{31.3,64.8,204},{54.2,42,205},{38.3,51.9,205},{59.6,65.9,205},{30.4,11.9,205},{59.4,91.8,205},{29.9,64.7,205},{41.8,6.9,205},{52.9,35.8,205},{29.5,66.1,204},{60,68.2,205},{28.4,80.5,206},{44,14.5,205},{40.2,17.8,205},{26.1,68.9,205},{72.2,43.7,201},{60,51.3,205},{60.1,91.7,205},{25.6,80.7,206},{65,41.1,205},{34.5,85.7,206},{27.6,82.7,206},{75.8,84.2,205},{31.8,75.9,204},{73.7,92.2,205},{84.7,83.5,205},{36.2,62.8,205},{70.5,88.5,205},{35.6,20.7,204},{38.5,89.1,206},{36.7,45.3,204},{59.6,60.3,201},{44.2,15.2,202},{37.4,61,205},{72.4,61.1,205},{36.6,88.4,206},{76.7,52.7,205},{50.9,50.6,205},{50.4,38.7,202},{67.7,39.6,202},{61.4,90.9,202},{68.8,53.3,205},{47,39.9,202},{28.5,73,204},{77,87.5,201},{49,85.7,206},{57.7,71.8,201},{73.9,60.7,202},{27.3,67.9,204},{44.8,18.6,205},{37.5,41.3,205},{72.8,41.6,205},{35.8,52.1,205},{34.8,65.2,202},{38.9,67.8,204},{32.6,62.2,205},{60.8,73.9,205},{63.2,64.7,201},{43.4,19.3,205},{44.1,14.2,205},{34.4,11.1,205},{52.4,35.7,205},{38.3,21.1,205},{45.5,25.3,205},{57.7,59.3,201},{35,74.6,204},{56,41.3,205},{70.9,85.8,202},{39.2,41.8,205},{28.2,62.4,204},{36.7,64.1,205},{54.2,91.3,206},{47.8,48.7,205},{68,28.2,204},{40.7,9,205},{38.6,49.7,205},{77.7,96.5,205},{68.3,44.7,205},{40.7,14,205},{41.8,17.3,205},{44.5,34.5,205},{77,88.7,201},{41.2,17.6,205},{75.3,94,205},{43.9,19.2,205},{25.9,81.1,206},{49.3,30.8,202},{64.4,40.4,205},{63.4,51.6,205},{68.6,51.9,205},{68.6,44.6,205},{53.9,47.7,205},{78.3,92.7,201},{72.3,51.7,205},{72.2,88.1,205},{38.5,66.1,205},{62.1,45.1,205},{36.9,63.8,204},},["Herbalism"]={{82.6,87.5,408},{38.6,66.2,408},{68.4,42.9,409},{52.3,63.1,405},{60.7,59,408},{54.6,64.1,405},{37.6,16.6,408},{72.6,47.5,408},{37.6,19.8,408},{25.9,71.4,409},{36.6,22.6,409},{36.4,76.3,409},{85.5,85.1,409},{44.5,24.2,405},{35.4,60.9,408},{78.9,84.9,408},{44.4,34.5,409},{57.8,73.1,409},{25.8,67.5,409},{50.9,42.8,408},{45.9,45,405},{51.6,37.7,408},{24.6,83.9,409},{84.5,85.2,408},{81,89.9,408},{63.4,63.2,408},{46.9,33.1,405},{74.4,43.2,408},{47.6,32.8,408},{69.4,41.1,409},{44.1,38,409},{30.4,57.2,408},{30.4,59.6,408},{39.4,7.2,411},{48.2,49.7,409},{40.5,19.8,409},{79.9,44.1,409},{74.9,88,409},{81,89.3,408},{46.9,21.3,409},{34.7,61.7,405},{73.3,57.8,408},{61,71.9,405},{36,63.9,408},{36.8,19.9,408},{85.8,85.2,409},{31.4,5.2,409},{32.7,73.7,405},{28.5,72,408},{37.5,61.3,409},{61.6,80.8,405},{25.8,71.2,409},{64.3,22.5,405},{32.1,61.3,408},{65,46.8,408},{32.1,10.5,404},{61.9,47.8,408},{58.8,84.1,409},{34,8.5,408},{71.4,92.1,408},{36.8,51.7,411},{30.3,66.9,408},{76.3,92.7,408},{45.7,49.4,409},{33.7,63.4,411},{36,7.2,408},{60.9,84.8,408},{38.3,22.1,409},{38.3,22.9,409},{72,45.4,408},{73.9,85.9,408},{73.9,44.2,408},{73.5,42,409},{25.6,67.4,409},{73.4,57.1,408},{32.1,60.2,411},{70.3,58.1,408},{40.7,19.5,409},{29,70.3,405},{31.1,10.6,405},{58.4,73.3,408},{38.9,67.9,409},{44.2,42.6,408},{59.1,82.1,408},{37,50.1,408},{44.6,42.1,408},{38.5,67.3,409},{66.7,50.6,404},{77,96.1,405},{49.5,36.8,408},{46.8,21.3,409},{52.5,62.1,411},{45.6,21.1,404},{32.3,12.9,408},{31.7,75.1,409},{58.9,51.8,409},{71.4,86.7,411},{51.5,52.6,405},{63.8,40.1,409},{40.1,11.1,411},{48.4,47.7,411},{49.5,49.6,408},{27.2,68.4,408},{43.7,27.1,409},{73.9,85.3,408},{35,71.7,411},{68.2,27.9,405},{81.2,90.5,411},{33.1,68.6,411},{36.7,65.4,408},{80.7,87.9,408},{73.8,46.9,408},{34.2,17.3,411},{37.8,43.5,411},{64.2,47.6,404},{35.5,14.4,404},{44.2,47.3,408},{54.5,40.4,408},{49.1,35.6,408},{58.6,84.2,409},{69.3,41,408},{31.6,5.4,408},{32.7,57.3,409},{52.5,44.9,408},{36.9,66.2,408},{83.8,87.9,408},{82.6,87.2,408},{29.4,67.1,411},{63.9,39.9,409},{38.8,20.9,409},{81,87.5,408},{30.2,13.2,408},{53.5,45.3,408},{74.5,51.9,408},{35.7,18.7,404},{28.6,65.1,411},{48.8,35.4,408},{71.8,47.6,408},{69.8,40.9,408},{73.2,91.4,409},{53.7,65.9,409},{38.1,68.5,408},{76.2,83,405},{27.9,68.6,408},{78.9,50.9,408},{33.1,20.7,409},{38.8,42,408},{53.5,36.2,409},{75.3,83,409},{58.5,83.7,409},{73,90,408},{72.2,42.3,408},{48.9,44.3,405},{68.7,90.3,408},{80.6,86.3,409},{28.6,62.4,408},{62.6,84.7,408},{58.4,54.4,409},{35.1,67.5,411},{30.1,57.4,409},{81.2,88.8,408},{33.1,14.1,411},{83.9,82.9,409},{43.6,15.6,411},{78.9,85.1,408},{36.6,16.8,411},{37.6,61,409},{36.6,48.6,411},{76.6,95.3,408},{36,5.2,409},{74.5,50.3,411},{51.7,30.8,409},{66.7,56.5,411},{34.5,60.9,411},{49,32.4,408},{29.8,61.9,411},{44.9,38.9,409},{36.1,48.4,408},{49.7,42.8,408},{55.8,40.9,408},{64.6,83.2,405},{31.7,17,409},{54.7,37.9,409},{31.6,71.8,411},{63.4,60.2,405},{66.9,49.6,408},{60.1,75.4,411},{35.5,62.2,408},{36.2,5.3,409},{58.8,72.6,408},{32.8,61.4,408},{37.4,16.1,408},{25.7,66.9,409},{72.5,59,409},{41.7,7.8,409},{64.1,40.1,409},{38.9,21,409},{42.4,11.6,409},{30.1,9,409},{77.1,86.2,408},{84.3,85.6,408},{34.8,47.8,409},{59.8,82.1,408},{40.4,19.7,409},{64.3,40.5,409},{35.8,51.2,408},{72.4,39.2,409},{66.4,53,408},{45.1,37.1,409},{62.8,67.3,409},{53.4,37.2,409},{44,37.8,409},{54.4,53.6,409},{84.4,84.1,408},{33.7,13.3,408},{39,18.2,408},{83.8,85.1,404},{65.4,48.7,408},{36.7,72.7,404},{31.9,67,411},{72.3,90.2,408},{59.9,69.7,405},{81.5,88.3,404},{37.6,40.3,409},{40,43.7,408},{35.9,17.6,408},{37.4,40.8,409},{61.5,45.3,408},{57.7,49.8,409},{35.9,49.8,408},{47.1,31.3,405},{68.5,41.7,409},{38,20.8,408},{32.8,57.1,409},{84.2,86.5,408},{67.9,42.3,409},{72.1,58.9,409},{79.8,93.5,408},{53.8,17,409},{77.6,48.2,409},{75.9,47.5,405},{36.8,51,408},{48.1,49.5,409},{45.4,49.5,409},{44.5,14.7,409},{78.7,49.8,409},{83.4,89.7,409},{64,39.1,409},{61.7,84.6,408},{54.4,53.7,409},{75.8,90.8,408},{72.2,59.1,409},{46.4,33.8,411},{28.5,68.4,408},{59.7,81.1,408},{48.3,32.6,408},{44,21.7,405},{75.1,90.9,404},{40.6,42.2,408},{83.6,84.9,408},{30.2,15.8,408},{76.1,89.4,408},{32.9,7.5,408},{62.3,72.8,409},{58.5,77.8,405},{81.1,84.5,405},{38.3,8.7,405},{31.8,75.8,409},{78,94.6,408},{80.9,89.4,408},{28.3,70.1,408},{74.9,90.8,408},{80.5,86.6,409},{46.6,87.1,409},{73,47.6,408},{78.2,87.4,409},{74.4,58.1,408},{28.2,71.9,408},{74.1,89.8,408},{38.8,49.9,409},{63.3,95.5,409},{34.9,66.6,408},{58.3,54.4,409},{31.6,6.1,408},{53.3,56.6,405},{82.1,86.5,404},{62.1,17.8,408},{80.1,93.7,408},{62.5,18.9,408},{75.3,94,408},{36.6,21.8,408},{63.7,22,405},{78.9,85.5,408},{51,32.2,408},{52.5,35.1,408},{78.5,94.2,408},{54.8,36.6,409},{75,88,409},{27.7,62.6,408},{36.3,51.8,408},{37.3,19.1,408},{34.2,66.9,408},{83.1,85.7,408},{69.6,49.5,408},{77.6,95.6,409},{80.9,91.8,408},{31.7,70.4,411},{63,62.8,408},},["Fishing"]={},},
}

;(function(...)
local _,ns=ADDON,GF;local E,N,P=ns.Forever,ns.NormalUI,ns.ProfessionGuide
local F=ns.FarmingPlanner;F.meta=ns.ClassicGatheringMeta;F.names={};F.known={};F.source={}
for id,v in pairs(F.meta)do F.names[id]=v.name end

function F.Decode(coord)local x=math.floor(coord/1000000)/100;local y=math.floor(coord%1000000/100)/100;return x,y end
function F.LoadKnown()
 F.boundZones=F.boundZones or{}
 for zone,kinds in pairs(ns.ClassicGatheringLocations5 or{})do local info=ns.ForeverData.zones[zone]
  if info and info.mapID and F.boundZones[zone]~=info.mapID then F.boundZones[zone]=info.mapID
   for kind,points in pairs(kinds)do F.known[kind]=F.known[kind]or{};local t={};F.known[kind][info.mapID]=t
    for _,v in ipairs(points)do if F.meta[v[3]]then t[math.floor(v[1]*100+.5)*1000000+math.floor(v[2]*100+.5)*100]=v[3]end end
   end
  end
 end;return true
end

function F.Skill(kind)local s=E.state or E.Snapshot();local v=s.skills[kind];return v and v.rank,v and v.cap end
function F.Material(id)return id,E.ItemName(id)end
local function refreshRouteButton()
 if N.root then N.Refresh()end
end
function F.Plan(kind,item)
 local p=E.CurrentPosition();if not p then return nil,'Outdoor position unavailable.'end
 local candidates={};local rank=kind=='Cloth'and 1 or F.Skill(kind);if not rank then return nil,'Learn '..kind..' first.'end
 for zone,kinds in pairs(ns.ClassicGatheringLocations5 or{})do local info=ns.ForeverData.zones[zone];if info and info.mapID==p.mapID then for _,v in ipairs(kinds[kind]or{})do local meta=F.meta[v[3]];if meta and meta.item==item and meta.skill<=rank then candidates[#candidates+1]={mapID=p.mapID,x=v[1],y=v[2],name=meta.name}end end end end
 for _,site in ipairs(E.materialSites and E.materialSites[item]or{})do if site.mapID==p.mapID then candidates[#candidates+1]=site end end
 if kind=='Fishing' and item==21113 then
  for _,visit in ipairs(E.db and E.db.fishingPoolVisits or{})do
   local at=visit.position
   if type(visit.name)=='string' and visit.name:lower():find('wreckage',1,true) and at and at.mapID==p.mapID and type(at.x)=='number' and type(at.y)=='number' then
    candidates[#candidates+1]={mapID=at.mapID,x=at.x,y=at.y,name=visit.name}
   end
  end
 end
 table.sort(candidates,function(a,b)return(E.Distance(a,p)or math.huge)<(E.Distance(b,p)or math.huge)end)
 if #candidates==0 then return nil,'No sourced local route yet; choose a supplied Classic route or record a gathering location.'end
 local out={};for i=1,math.min(12,#candidates)do local v=candidates[i];out[#out+1]={mapID=v.mapID,x=v.x,y=v.y,name=v.name or E.ItemName(item)}end;return out,nil,p
end
function F.Start(kind,item,target,targetSkill)
 local nodes,why=F.Plan(kind,item,12);if not nodes then return false,why end
 F.route={nodes=nodes,steps={},cursor=1,item=item,target=target,skill=kind,targetSkill=targetSkill}
 for i,v in ipairs(nodes)do F.route.steps[i]={id='gf-route5:'..i,kind='farm',category='Gathering',title='Farm '..E.ItemName(item)..' - '..i..' / '..#nodes,body='Follow the farming route. Gather manually; Skip bypasses this waypoint.',destination={mapID=v.mapID,x=v.x,y=v.y,name=v.name},priority=10000}end
 refreshRouteButton();return true
end
function F.Stop(message)F.route=nil;refreshRouteButton();if message then ns.Print(message)end end
function F.Advance()
 if not F.route then return false end
 if F.route.reference and F.route.reference.mode=='open' and F.route.cursor>=#F.route.steps then
  F.Stop('Farming route complete.');return true
 end
 F.route.cursor=F.route.cursor%#F.route.steps+1
 if ns.NavigationCompass then ns.NavigationCompass.age=1 end
 return true
end
local tick=N.Tick
N.Tick=function(...)
 local r=F.route;if r and r.item and(E.Call(C_Item and C_Item.GetItemCount or GetItemCount,r.item)or 0)>=r.target then F.Stop('Material target reached; quest guide resumed.')end
 return tick(...)
end
end)(ADDON,GF)

-- GF_KNOWN_NODE_PINS88_BEGIN
;(function(...)
local _,ns=ADDON,GF
local F,G=ns.FarmingPlanner,ns.GatheringObserver
if not F or not Minimap then return end
local M={pins={},points={},limit=48};ns.KnownNodePins=M
local function read(fn,...)if type(fn)=='function'then local ok,a,b,c=pcall(fn,...);if ok then return a,b,c end end end
local function valid(v)return type(v)=='number'and v==v and v>=0 and v<=100 end
function M.Enabled()return not ns.Forever.db or ns.Forever.db.knownNodePins~=false end
local outdoorRadii={[0]=233.3333,200,166.6667,133.3333,100,66.6667}
function M.Range()
 return outdoorRadii[read(Minimap.GetZoom,Minimap) or 0]
end
function M.Project(dx,dy,width,height,radius,facing)
 if not radius or radius<=0 or width<=0 or height<=0 then return end
 local c,s=math.cos(facing or 0),math.sin(facing or 0)
 local x,y=(dx*c+dy*s)/radius,(-dx*s+dy*c)/radius
 -- Inset keeps the complete icon inside both circular and square minimaps.
 if x*x+y*y>0.85*0.85 then return end
 return x*width/2,y*height/2
end
function M.Hide()
 M.lastPaint=nil
 for _,pin in ipairs(M.pins)do if pin:IsShown()then pin:Hide()end end
end
function M.Build(map,px,py,w,h)
 F.LoadKnown()
 local points,seen={},{}
 local function add(kind,x,y,name,item,source)
  if not valid(x)or not valid(y)then return end
  local key=kind..':'..math.floor(x*100)..':'..math.floor(y*100)
  if seen[key]then return end;seen[key]=true
  local dx,dy=(x-px*100)*w/100,(py*100-y)*h/100
  if dx*dx+dy*dy>350*350 then return end
  points[#points+1]={x=x,y=y,kind=kind,name=name or kind,item=item,source=source,distance=dx*dx+dy*dy}
 end
 for _,node in pairs(G and G.data and G.data.nodes or{})do
  local p=node.position;local meta=F.meta[node.sourceNodeID]
  if meta and p and p.mapID==map and not node.instanced and((node.sourceMatchedHarvests or 0)>0 or(node.observedClicks or 0)>0)then
   add(meta.kind,p.x,p.y,node.name,meta.item,'Your observed gathering position')
  end
 end
 for _,kind in ipairs({'Mining','Herbalism','Fishing'})do
  local skill=F.Skill(kind)
  if type(skill)=='number'and skill>0 then
   -- Optional existing provider only; GF does not copy or require its database.
   for coord,id in pairs(F.known[kind]and F.known[kind][map]or{})do
    local meta=F.meta[id];local x,y=F.Decode(coord)
    if meta and meta.kind==kind then add(kind,x,y,meta.name,meta.item,'GF historical gathering catalog')end
   end
  end
 end
 table.sort(points,function(a,b)return a.distance<b.distance end)
 while #points>M.limit do table.remove(points)end
 M.points=points;M.map=map
end
function M.Pin(index)
 if M.pins[index]then return M.pins[index]end
 local pin=CreateFrame('Button',nil,Minimap);pin:SetSize(12,12);pin:SetFrameLevel(Minimap:GetFrameLevel()+3)
 pin.icon=pin:CreateTexture(nil,'ARTWORK');pin.icon:SetAllPoints();pin.icon:SetTexCoord(0.08,0.92,0.08,0.92);pin:SetAlpha(0.72)
 pin:SetScript('OnEnter',function(self)
  if not GameTooltip or not self.node then return end
  GameTooltip:SetOwner(self,'ANCHOR_RIGHT');GameTooltip:AddLine(self.node.name,1,0.82,0.3)
  GameTooltip:AddLine('Known gathering location',0.25,0.85,0.8)
  GameTooltip:AddLine('Possible spawn; not live detection.',1,1,1)
  GameTooltip:AddLine(self.node.source,0.7,0.7,0.7);GameTooltip:Show()
 end)
 pin:SetScript('OnLeave',function()if GameTooltip then GameTooltip:Hide()end end)
 M.pins[index]=pin;return pin
end
local function updateMinimap(elapsed)

 local showPins=M.Enabled()
 local compass=ns.NavigationCompass
 M.rangeAvailable=false
 if (not showPins and not (compass and compass.Enabled())) or not Minimap:IsShown()
  or read(IsInInstance)or read(IsIndoors)then M.Hide();return end
 local p=ns.Retail and ns.Retail.Client.PlayerPosition()
 if not p or p.status~='available'or not valid(p.x and p.x*100)or not valid(p.y and p.y*100)then M.Hide();return end
 if M.sizeMap~=p.mapID then
  local w,h=read(C_Map and C_Map.GetMapWorldSize,p.mapID)
  if not w then
   local a,x,y=read(ns.Retail.Client.WorldPosition,p.mapID,0,0)
   local b,x2,y2=read(ns.Retail.Client.WorldPosition,p.mapID,100,100)
   if a and a==b and x and y and x2 and y2 then w,h=math.abs(y2-y),math.abs(x2-x)end
  end
  M.width,M.height=w,h;if w and h then M.sizeMap=p.mapID end
 end
 local w,h=M.width,M.height
 if type(w)~='number'or type(h)~='number'or w<=0 or h<=0 then M.Hide();return end
 local moved=M.centerX and ((p.x-M.centerX)*w)^2+((p.y-M.centerY)*h)^2
 if M.map~=p.mapID or M.dirty or not moved or moved>=80*80 then
  M.Build(p.mapID,p.x,p.y,w,h)
  M.centerX,M.centerY,M.dirty=p.x,p.y,nil
 end
 local zoom=read(Minimap.GetZoom,Minimap)or 0
 local radius=M.Range()
 if not radius then M.Hide();return end
 M.rangeAvailable=true
 if not showPins then M.Hide();return end
 local facing=read(GetCVar,'rotateMinimap')=='1'and(read(GetPlayerFacing)or 0)or 0
 local width,height=Minimap:GetWidth(),Minimap:GetHeight()
 local last=M.lastPaint
 if last and last.points==M.points and last.x==p.x and last.y==p.y and last.zoom==zoom
  and last.facing==facing and last.width==width and last.height==height then return end
 M.lastPaint={points=M.points,x=p.x,y=p.y,zoom=zoom,facing=facing,width=width,height=height}
 local count=0
 for _,n in ipairs(M.points)do
  local x,y=M.Project((n.x-p.x*100)*w/100,(p.y*100-n.y)*h/100,width,height,radius,facing)
  if x then
   count=count+1;local pin=M.Pin(count)
   if pin.node~=n then
    pin.node=n
    local icon=read(C_Item and C_Item.GetItemIconByID or GetItemIcon,n.item)
    pin.icon:SetTexture(icon or(n.kind=='Mining'and'Interface/Icons/Trade_Mining'or n.kind=='Fishing'and'Interface/Icons/Trade_Fishing'or'Interface/Icons/Trade_Herbalism'))
   end
   pin:ClearAllPoints();pin:SetPoint('CENTER',Minimap,'CENTER',x,y);pin:Show()
  end
 end
 for i=count+1,#M.pins do M.pins[i]:Hide()end
end
function M.Update(elapsed)
 M.elapsed=(M.elapsed or 0)+(elapsed or 0)
 if M.elapsed<.25 then return end
 local due=M.elapsed;M.elapsed=0
 return updateMinimap(due)
end
local slash=SlashCmdList.GRINDINGFOREVER
SlashCmdList.GRINDINGFOREVER=function(message)
 local arg=type(message)=='string'and message:lower():match('^nodes%s*(.-)%s*$')
 if arg then
  ns.Print('Gathering dots use Blizzard minimap tracking.');return
 end
 return slash(message)
end
end)(ADDON,GF)
-- GF_KNOWN_NODE_PINS88_END

-- GF_NODE_BUTTON89_BEGIN
;(function(...)
local _,ns=ADDON,GF;local N,W,M=ns.NormalUI,ns.WindowWorkflow,ns.KnownNodePins
if not N or not W or not M then return end
function M.SetEnabled(enabled)
 local db=ns.Forever.db;if type(db)~='table'then return end
 db.knownNodePins=enabled==true;M.age=5
 if not enabled then M.Hide()end
 if M.button then M.button.label:SetText(M.Enabled()and'Hide Nodes'or'Show Nodes')end
end
local layout=W.Layout
function W.Layout(...)
 local result=layout(...);local farm=N.farmButton
 if not farm then return result end
 if not M.button then M.button=N.MakeButton(farm:GetParent(),'Hide Nodes',110,function()M.SetEnabled(not M.Enabled())end)end
 local b=M.button;b:SetParent(farm:GetParent());b.label:SetText(M.Enabled()and'Hide Nodes'or'Show Nodes')
 local parent=farm:GetParent();local available=math.max(180,parent:GetWidth()-56);local total=math.min(318,available)
 farm:ClearAllPoints();farm:SetPoint('BOTTOM',parent,'BOTTOM',-(total*0.36+8)/2,30);farm:SetSize(total*0.64-4,34)
 b:ClearAllPoints();b:SetPoint('LEFT',farm,'RIGHT',8,0);b:SetSize(total*0.36-4,34);b:SetShown(farm:IsShown())
 return result
end
N.WorkflowLayout=W.Layout
local slash=SlashCmdList.GRINDINGFOREVER
SlashCmdList.GRINDINGFOREVER=function(message)
 local arg=type(message)=='string'and message:lower():match('^nodes%s+(on)%s*$')
 if arg then M.SetEnabled(true)end
 if type(message)=='string'and message:lower():match('^nodes%s+off%s*$')then M.SetEnabled(false)end
 return slash(message)
end
W.Layout()
end)(ADDON,GF)
-- GF_NODE_BUTTON89_END
-- Approved three-state layout; no new artwork and no deployment by this file.
;(function(...)
local _,ns=ADDON,GF;local N,W,M=ns.NormalUI,ns.WindowWorkflow,ns.KnownNodePins
local function place(f,parent,x,y,w,h)
 f:SetParent(parent);f:ClearAllPoints();f:SetPoint('TOPLEFT',parent,'TOPLEFT',x,-y)
 if w then f:SetWidth(math.max(1,w))end;if h then f:SetHeight(math.max(1,h))end
end
function W.SetView(view)
 if view~='normal'and view~='steps'and view~='recipes'then return false end
 W.recipeCompact=view=='recipes';W.collapsed=false;W.view=view;if ns.db then ns.db.workflowView95=view end
 local result=N.SetMode(view=='normal'and'normal'or'compact')
 W.Layout();N.Refresh(true);N.RefreshRecipes();return result
end
local layout=W.Layout
W.Layout=function(...)
 local r=N.root;if not r then return layout(...)end
 -- Undo the recipe-only reparenting before running the established layout.
 for _,f in ipairs({r.recipeScroll,r.recipeSearch,r.recipesText})do if f then f:SetParent(r.panels[3])end end
 if W.view==nil and ns.db and ns.db.workflowView95=='recipes'then W.recipeCompact=true;W.view='recipes'end
 local value=layout(...);local compact=N.mode=='compact';local recipe=compact and W.recipeCompact
 r.modeButton:Hide()
 r.workflowGrip:SetScript('OnClick',function()W.SetView(compact and'normal'or'steps')end)
 r.workflowGrip.glyph:SetTexture((compact and r.back.glyph or r.forward.glyph):GetTexture())
 r.workflowGrip:SetShown(not recipe);r.workflowGrip:ClearAllPoints();r.workflowGrip:SetPoint('CENTER',r.panels[1],'LEFT',0,0)
 if not r.recipeCompactGrip then
  local b=N.MakeButton(r,'',22,function()W.SetView(N.mode=='compact'and'normal'or'recipes')end);r.recipeCompactGrip=b;b:SetSize(22,58);b:SetFrameLevel(r:GetFrameLevel()+30)
  b.glyph=b:CreateTexture(nil,'OVERLAY');b.glyph:SetSize(16,16);b.glyph:SetPoint('CENTER')
 end
 local grip=r.recipeCompactGrip;grip.glyph:SetTexture((recipe and r.forward.glyph or r.back.glyph):GetTexture());grip:ClearAllPoints();grip:SetPoint('CENTER',recipe and r.panels[2]or r.panels[3],'RIGHT',0,0);grip:SetShown(not compact or recipe)
 if recipe then
  if r:GetHeight()<820 then r:SetHeight(820)end
  local p=r.panels[2];local width=r:GetWidth()-16;local height=r:GetHeight()-145-10
  place(p,r,8,145,width,height);p:Show();r.panels[1]:Hide();r.panels[3]:Hide()
  for _,f in ipairs({r.done,r.skip,r.inlineFarm,r.inlineSearch,N.bodyScroll})do if f then f:Hide()end end
  if r.browserSwitch then place(r.browserSwitch,p,28,24,width-56,30);r.browserSwitch:Fit(width-56);r.browserSwitch:Show()end
  place(r.zoneButton,p,28,68,width-56,36);r.zoneButton:Show()
  place(r.sourceButton,p,28,112,(width-66)*.46,36);r.sourceButton:Show()
  place(r.professionButton,p,38+(width-66)*.46,112,(width-66)*.54,36);r.professionButton:Show()
  local mapHeight=math.max(65,math.min((width-56)/1.5,(height-345)*.47))
  r.recipeMap:SetParent(p);r.recipeMap:ClearAllPoints();r.recipeMap:SetPoint('TOPLEFT',p,'TOPLEFT',28,-162);r.recipeMap:SetPoint('TOPRIGHT',p,'TOPRIGHT',-28,-162);r.recipeMap:SetHeight(mapHeight);r.recipeMap:Show();W.FitMap()
  r.mapHint:SetParent(p);r.mapHint:Show()
  local listTop=162+mapHeight+38
  place(r.recipesText,p,28,listTop-18,width-65,18);r.recipesText:Show()
  r.recipeScroll:SetParent(p);r.recipeScroll:ClearAllPoints();r.recipeScroll:SetPoint('TOPLEFT',p,'TOPLEFT',28,-listTop);r.recipeScroll:SetPoint('BOTTOMRIGHT',p,'BOTTOMRIGHT',-42,155);r.recipeScroll:Show()
  -- Existing row builders size against panel3; retain that logical width.
  r.panels[3]:SetWidth(width);r.recipeContent:SetWidth(width-72)
  r.recipeSearch:SetParent(p);r.recipeSearch:ClearAllPoints();r.recipeSearch:SetPoint('BOTTOMLEFT',p,'BOTTOMLEFT',28,113);r.recipeSearch:SetPoint('BOTTOMRIGHT',p,'BOTTOMRIGHT',-28,113);r.recipeSearch:Show()
  local buttons={N.farmButton,M and M.button,N.professionChoiceButton};local widths={.58,.42};local usable=width-56
  if buttons[1]then place(buttons[1],p,28,height-93,(usable-8)*widths[1],32);buttons[1]:Show()end
  if buttons[2]then place(buttons[2],p,36+(usable-8)*widths[1],height-93,(usable-8)*widths[2],32);buttons[2]:Show()end
  if buttons[3]then place(buttons[3],p,28,height-53,usable,32);buttons[3]:SetShown(not (ns.MenuControls and ns.MenuControls.Finished()))end
  for i,b in ipairs(r.workflowRecipeIndicators)do place(b,p,width-29,i==1 and listTop or height-182,22,26)end
  W.ScrollState()
 end
 return value
end
N.WorkflowLayout=W.Layout
local scroll=W.ScrollState
W.ScrollState=function(...)
 local result=scroll(...);local r=N.root
 if r and W.recipeCompact and N.mode=='compact'and W.ready then
  local f=r.recipeScroll;local max=math.max(0,r.recipeContent:GetHeight()-f:GetHeight());local v=f:GetVerticalScroll()
  for i,b in ipairs(r.workflowRecipeIndicators)do b:SetShown(max>2);b:SetAlpha((i==1 and v<1 or i==2 and v>=max-1)and .4 or 1)end
  W.ScrollRail(r.workflowRecipeIndicators,v,max,max>2,function(n)f:SetVerticalScroll(n);W.ScrollState()end)
 end;return result
end
W.Layout()
end)(ADDON,GF)

;(function(...)
local _,ns=ADDON,GF;local F,N,C=ns.FarmingPlanner,ns.NormalUI,ns.Retail.Client
local R={references=ns.FarmingRouteReferences or{},materials={},byID={}};ns.MaterialRoutes=R
local function read(f,...)if type(f)=='function'then local ok,a,b,c=pcall(f,...);if ok then return a,b,c end end end
local fish={[105]={6359,100},[106]={21153,175},[107]={6358,1},[108]={21071,75},[109]={6522,1},[110]={13422,205},[112]={27437,330},[114]={27439,280},[115]={27435,305},[116]={27438,305},[117]={27437,305},[118]={27422,305},[120]={19807,1}}
for id,v in pairs(fish)do F.meta[id]={kind='Fishing',item=v[1],skill=v[2],name=F.names[id]}end
local function material(id,name,kind,skill)
 if R.byID[id]then R.byID[id].skill=math.min(R.byID[id].skill,skill or 1);return end
 local m={id=id,name=name,kind=kind,skill=skill or 1};R.materials[#R.materials+1]=m;R.byID[id]=m
end
local materialNames={[11370]='Dark Iron Ore',[248815]='Heavy Thorium Ore',[2770]="Copper Ore",[2771]="Tin Ore",[2772]="Iron Ore",[2775]="Silver Ore",[2776]="Gold Ore",[3858]="Mithril Ore",[7911]="Truesilver Ore",[10620]="Thorium Ore",[2447]="Peacebloom",[765]="Silverleaf",[2449]="Earthroot",[785]="Mageroyal",[2450]="Briarthorn",[3820]="Stranglekelp",[2453]="Bruiseweed",[3355]="Wild Steelbloom",[3356]="Kingsblood",[3357]="Liferoot",[3818]="Fadeleaf",[3821]="Goldthorn",[3358]="Khadgar's Whisker",[8831]="Purple Lotus",[4625]="Firebloom",[8838]="Sungrass",[8845]="Ghost Mushroom",[8846]="Gromsblood",[13464]="Golden Sansam",[13463]="Dreamfoil",[13465]="Mountain Silversage",[13466]="Plaguebloom"}
for id,m in pairs(F.meta)do if m.item and(m.kind=='Mining'or m.kind=='Herbalism')then local name=read(GetItemInfo,m.item);material(m.item,materialNames[m.item]or name or F.names[id]or('Item '..m.item),m.kind,m.skill)end end
material(11370,'Dark Iron Ore','Mining',230)
material(248815,'Heavy Thorium Ore','Mining',300)
for _,m in ipairs({{21071,'Sagefish Pool',75},{21153,'Greater Sagefish Pool',175},{6358,'Oily Blackmouth School',1},{6359,'Firefin Snapper School',100},{6522,'Deviate Fish School',1},{13422,'Stonescale Eel Swarm',205},{19807,'School of Tastyfish',1},{21113,'Floating Wreckage',1}})do material(m[1],m[2],'Fishing',m[3])end
for _,m in ipairs({{2318,'Light Leather',1},{2319,'Medium Leather',75},{4234,'Heavy Leather',155},{4304,'Thick Leather',205},{8170,'Rugged Leather',260}})do material(m[1],m[2],'Skinning',m[3])end
for _,cloth in ipairs({{2589,'Linen Cloth'},{2592,'Wool Cloth'},{4306,'Silk Cloth'},{4338,'Mageweave Cloth'},{14047,'Runecloth'},{14256,'Felcloth'}})do
 material(cloth[1],cloth[2],'Cloth',0)
end
local zoneMaps={["Durotar"]=1411,["Mulgore"]=1412,["Tirisfal Glades"]=1420,["Elwynn Forest"]=1429,["Teldrassil"]=1438,["Dun Morogh"]=1426,["The Barrens"]=1413,["Silverpine Forest"]=1421,["Loch Modan"]=1432,["Darkshore"]=1439,["Hillsbrad Foothills"]=1424,["Wetlands"]=1437,["Stonetalon Mountains"]=1442,["Stranglethorn Vale"]=1434,["Arathi Highlands"]=1417,["Tanaris"]=1446,["Searing Gorge"]=1427,["The Hinterlands"]=1425,["Felwood"]=1448,["Desolace"]=1443,["Thousand Needles"]=1441,["Un'Goro Crater"]=1449,["Blasted Lands"]=1419,["Eastern Plaguelands"]=1423,["Winterspring"]=1452,["Burning Steppes"]=1428,["Feralas"]=1444}
for zone,id in pairs(ns.ProfessionKnowledge.maps)do zoneMaps[zone]=id end
-- Bind baseline gathering zones only when this client confirms the map name.
 for zone,id in pairs(zoneMaps)do
  local info=read(C_Map and C_Map.GetMapInfo,id)
  if type(info)=='table'and info.name==zone then local entry=ns.ForeverData.zones[zone]or{name=zone};ns.ForeverData.zones[zone]=entry;entry.mapID=entry.mapID or id end
 end
 local function mapFor(zone)

 local z=ns.ForeverData.zones[zone];if z and z.mapID then return z.mapID end
 if zone=="Duskwood"then local info=read(C_Map and C_Map.GetMapInfo,1431);if info and info.name==zone then return 1431 end end
end
local function pos()local p=C.PlayerPosition();if not p or p.status~='available'then return end;return p end
local function yards(map,x,y,p)
 local a,ax,ay=C.WorldPosition(map,x,y);local b,bx,by=C.WorldPosition(p.mapID,p.x*100,p.y*100)
 if a and a==b and ax and bx then return math.sqrt((ax-bx)^2+(ay-by)^2)end
end
function R.Eligible(ref,m,skill,level,faction)
 if ref.kind~=m.kind or skill<ref.minSkill or level<ref.minLevel then return false end
 if ref.faction and ref.faction~=faction then return false end
 if ref.materials then for _,name in ipairs(ref.materials)do if name==m.name then return true end end;return false end
 if m.kind=='Skinning'then return skill>=m.skill and((m.id==2318 and ref.minSkill<85)or(m.id==2319 and ref.maxSkill>=75 and ref.minSkill<170)or(m.id==4234 and ref.maxSkill>=155 and ref.minSkill<230)or(m.id==4304 and ref.maxSkill>=205 and ref.minSkill<280)or(m.id==8170 and ref.maxSkill>=260))end
 return m.kind=='Herbalism'and skill>=m.skill and m.skill>=math.max(1,ref.minSkill-65)and m.skill<=ref.maxSkill
end
function R.Recommend(m)
 local p=pos();if not p then return nil,'Outdoor position unavailable.'end
 local rank=m.kind=='Cloth'and 1 or F.Skill(m.kind);if not rank then return nil,'Learn '..m.kind..' first.'end
 if rank<m.skill then return nil,'Requires '..m.kind..' '..m.skill..'.'end
 local level=read(UnitLevel,'player')or 1;local faction=read(UnitFactionGroup,'player');local best,score
 for _,ref in ipairs(R.references)do if R.Eligible(ref,m,rank,level,faction)then local map=mapFor(ref.zone)
  if map then for i,v in ipairs(ref.points)do local d=yards(map,v[1],v[2],p);if d then local cost=d+(map==p.mapID and 0 or 4000)+math.max(0,ref.minLevel-level+5)*500
   if not score or cost<score then best={reference=ref,mapID=map,start=i,material=m,distance=d};score=cost end
  end end end
 end end
 if best then return best end
 -- Pool and unsupported material routes use the native local catalog/species planner.
 return nil,'No eligible traced route nearby; use the available local source circuit.'
end
-- Zone preference follows the published guide order, not player traffic.
local guideZones={
 [2770]={'Durotar','Dun Morogh','Elwynn Forest','Tirisfal Glades','Mulgore','Darkshore'},
 [2771]={'Hillsbrad Foothills','Redridge Mountains','The Barrens','Ashenvale'},
 [2775]={'Hillsbrad Foothills','Redridge Mountains','The Barrens','Ashenvale'},
 [2772]={'Arathi Highlands','Desolace','Thousand Needles'},
 [3821]={'The Hinterlands','Arathi Highlands'},
 [8846]={'Felwood','Blasted Lands','Desolace'},
}
local function guideScore(zone,materials)
 local score=0
 for _,m in ipairs(materials)do
  for index,name in ipairs(guideZones[m.id] or {})do
   if zone==name then score=score+10-index;break end
  end
 end
 return score
end
-- Buffered entrance areas. Node pins remain available for voluntary detours.
local deadEnds={
 ['Elwynn Forest']={{36,78,44,87},{58,50,65,58}},
 Durotar={{48,18,55,27}},
 ['Silverpine Forest']={{58,14,84,45}},
}
local function crossesDeadEnd(a,b,box)
 local lo,hi=0,1
 for axis=1,2 do
  local delta=b[axis]-a[axis]
  if delta==0 then
   if a[axis]<box[axis] or a[axis]>box[axis+2]then return false end
  else
   local x=(box[axis]-a[axis])/delta
   local y=(box[axis+2]-a[axis])/delta
   lo=math.max(lo,math.min(x,y));hi=math.min(hi,math.max(x,y))
   if lo>hi then return false end
  end
 end
 return true
end
local function outsideDeadEnds(a,b,areas)
 for _,box in ipairs(areas)do if crossesDeadEnd(a,b,box)then return false end end
 return true
end
local function orderZoneLoop(choice)
 if not choice or not choice.start then return end
 local ref=choice.reference
 local first=ref.points[choice.start]
 local areas=deadEnds[ref.zone] or {}
 local points,seen={},{}
 local function length(a,b)
  return math.sqrt((a[1]-b[1])^2+(a[2]-b[2])^2)
 end
 for _,point in ipairs(ref.points)do
  local key=point[1]..':'..point[2]
  if not seen[key] and outsideDeadEnds(point,point,areas)then
   seen[key]=true;points[#points+1]=point
  end
 end
 if #points==0 then ref.points={};choice.start=nil;return end
 -- Keep hand-traced bends. For node-only routes, leave isolated spawns off the circuit.
 if not ref.traced and #points>=7 then
  local gaps,ordered={},{}
  for i,point in ipairs(points)do
   local gap=math.huge
   for j,other in ipairs(points)do if i~=j then gap=math.min(gap,length(point,other))end end
   gaps[point]=gap;ordered[#ordered+1]=gap
  end
  table.sort(ordered)
  local limit=math.max(9,ordered[math.ceil(#ordered/2)]*3)
  local cluster={}
  for _,point in ipairs(points)do if gaps[point]<=limit then cluster[#cluster+1]=point end end
  if #cluster>=3 then points=cluster end
 end
 local function turn(a,b,c)
  return (b[1]-a[1])*(c[2]-a[2])-(b[2]-a[2])*(c[1]-a[1])
 end
 local function crosses(loop)
  for i=1,#loop-2 do
   local a,b=loop[i],loop[i+1]
   for j=i+2,#loop do
    if i~=1 or j~=#loop then
     local c,d=loop[j],loop[j%#loop+1]
     if turn(a,b,c)*turn(a,b,d)<0 and turn(c,d,a)*turn(c,d,b)<0 then return true end
    end
   end
  end
  return false
 end
 if not ref.traced or crosses(points) then
  local cx,cy=0,0
  for _,point in ipairs(points)do cx=cx+point[1];cy=cy+point[2] end
  cx,cy=cx/#points,cy/#points
  local bearings={}
  for _,point in ipairs(points)do
   local x,y=point[1]-cx,point[2]-cy
   bearings[point]={math.atan2(y,x),x*x+y*y}
  end
  table.sort(points,function(a,b)
   local x,y=bearings[a],bearings[b]
   if x[1]~=y[1]then return x[1]<y[1]end
   return x[2]<y[2]
  end)
  if #points>=6 then
   local changed=true
   while changed and #points>4 do
    changed=false
    for i=1,#points do
     local a,b,c=points[(i-2)%#points+1],points[i],points[i%#points+1]
     local direct=length(a,c)
     if direct<=24 and length(a,b)+length(b,c)>direct*1.35+2 then
      table.remove(points,i)
      if crosses(points)then table.insert(points,i,b)else changed=true;break end
     end
    end
   end
  end
 end
 local area=0
 for i,a in ipairs(points)do
  local b=points[i%#points+1]
  area=area+a[1]*b[2]-b[1]*a[2]
 end
 ref.mode=math.abs(area)>.001 and 'loop' or 'open'
 if ref.mode=='open'then
  table.sort(points,function(a,b)if a[1]~=b[1]then return a[1]<b[1]end;return a[2]<b[2]end)
  if #points>1 and (first[1]-points[#points][1])^2+(first[2]-points[#points][2])^2
      <(first[1]-points[1][1])^2+(first[2]-points[1][2])^2 then
   for i=1,math.floor(#points/2)do points[i],points[#points-i+1]=points[#points-i+1],points[i]end
  end
  choice.start=1
 else
  local nearest=math.huge
  for i,point in ipairs(points)do
   local distance=length(point,first)
   if distance<nearest then nearest=distance;choice.start=i end
  end
 end
 if #areas>0 then
  local routed={}
  local n=#points
  local limit=ref.mode=='loop' and n or n-1
  for i,point in ipairs(points)do
   routed[#routed+1]=point
   local nextPoint=points[i%n+1]
   if i<=limit and not outsideDeadEnds(point,nextPoint,areas)then
    local corners={}
    for _,box in ipairs(areas)do
     if crossesDeadEnd(point,nextPoint,box)then
      local x,y,u,v=box[1]-.8,box[2]-.8,box[3]+.8,box[4]+.8
      for _,c in ipairs({{x,y},{x,v},{u,y},{u,v}})do corners[#corners+1]=c end
     end
    end
    local best,cost
    for _,a in ipairs(corners)do
     if outsideDeadEnds(point,a,areas)then
      for _,b in ipairs(corners)do
       if outsideDeadEnds(a,b,areas) and outsideDeadEnds(b,nextPoint,areas)then
        local lengthSum=length(point,a)+length(a,b)+length(b,nextPoint)
        if not cost or lengthSum<cost then best,cost={a,b},lengthSum end
       end
      end
     end
    end
    if not best then ref.points={};choice.start=nil;return end
    routed[#routed+1]=best[1]
    if best[2]~=best[1]then routed[#routed+1]=best[2]end
   end
  end
  if ref.mode=='loop' and crosses(routed)then ref.points={};choice.start=nil;return end
  local start=points[choice.start]
  for i,point in ipairs(routed)do if point==start then choice.start=i;break end end
  points=routed
 end
 ref.points=points
end
-- Ground approaches traced from the bundled Forever Silverpine map.
local silverpineMainland={{50,15},{45,23},{43,33},{45,43},{48,54},{49,64},
 {44,71},{47,76},{53,76},{59,73},{62,66},{61,60},{54,58},{53,44},{53,30},{54,21}}
-- Forever camp observations. Coordinates are areas to search, not fixed spawns.
local foreverCampRoutes={
 {kind='Cloth',zone='Tirisfal Glades',minSkill=1,minLevel=6,
  materials={'Linen Cloth'},targets='Balnir Farmstead undead',points={{70,61},{72.8,60.5},{74.5,62},{73,64},{70,63}},mode='loop'},
 {kind='Cloth',zone='Duskwood',minSkill=1,minLevel=24,
  materials={'Silk Cloth'},targets='Raven Hill undead',points={{24,41},{27.3,41},{30,43},{28,46},{25,45}},mode='loop'},
 {kind='Cloth',zone='Silverpine Forest',minSkill=1,minLevel=12,
  materials={'Wool Cloth','Linen Cloth'},targets='Dalaran mages around Ambermill',points={{55,60},{62,61},{63.5,63.4},{60,66},{55,65}},mode='loop'},
 {kind='Skinning',zone='Silverpine Forest',minSkill=55,maxSkill=74,minLevel=10,
  materials={'Light Leather'},points={{47,30},{50,29},{53,32},{52,35},{48,35}},mode='loop'},
}
for _,ref in ipairs(foreverCampRoutes)do R.references[#R.references+1]=ref end
for _,camp in ipairs(ns.ProfessionKnowledge.camps)do
 R.references[#R.references+1]=camp
end
-- Select the best compatible subset without enumerating the power set.
local function combineFarmSources(zone)
 local sets=zone.sources
 if #zone.materials<2 then return end
 local function overlaps(a,b)
  if a==b then return true end
  for _,x in ipairs(a.points)do
   for _,y in ipairs(b.points)do
    if (x[1]-y[1])^2+(x[2]-y[2])^2<=12^2 then return true end
   end
  end
  return false
 end
 local best,bestWeight
 for index,seed in ipairs(zone.materials)do
  local group={seed}
  local weight=#sets[seed.id].points
  for offset=1,#zone.materials-1 do
   local m=zone.materials[(index+offset-1)%#zone.materials+1]
   local compatible=true
   for _,other in ipairs(group)do
    if not overlaps(sets[m.id],sets[other.id]) then compatible=false;break end
   end
   if compatible then group[#group+1]=m;weight=weight+#sets[m.id].points end
  end
  if not best or #group>#best or (#group==#best and weight>bestWeight)then best,bestWeight=group,weight end
 end
 zone.materials=best
 local paths,points={},{}
 local traced,count=false,0
 for _,m in ipairs(best)do
  local source=sets[m.id]
  if not paths[source]then
   paths[source]=true;count=count+1;traced=source.traced
   for _,point in ipairs(source.points)do if #points<60 then points[#points+1]=point end end
  end
 end
 zone.reference.points=points
 zone.reference.traced=count==1 and traced
 zone.reference.targets=count==1 and sets[best[1].id].targets or nil
end
function R.RecommendSelection(materials, ranks, scope)
 local E=ns.Forever
 local p=pos()
 if not p then return nil,'Outdoor position unavailable.' end
 local level=read(UnitLevel,'player') or 1
 local faction=read(UnitFactionGroup,'player')
 local zones={}
 table.sort(materials,function(a,b)return a.id<b.id end)
 for _,ref in ipairs(R.references)do
  local matched={}
  for _,m in ipairs(materials)do
   if ref.mode~="backtrack" and ranks[m.id] and R.Eligible(ref,m,ranks[m.id],level,faction)then matched[#matched+1]=m end
  end
  local map=#matched>0 and mapFor(ref.zone)
  if map and (scope~='current' or map==p.mapID)then
   local zone=zones[map]
   if not zone then
    zone={materials={},seen={},curated={},sources={},reference={zone=ref.zone,points={},mode=ref.mode},mapID=map}
    zones[map]=zone
   end
   local source={points=ref.zone=="Silverpine Forest" and ref.kind=="Herbalism" and silverpineMainland or ref.points,traced=true,targets=ref.targets}
   for _,m in ipairs(matched)do
    if not zone.seen[m.id]then
     zone.seen[m.id]=true;zone.curated[m.id]=true;zone.sources[m.id]=source
     zone.materials[#zone.materials+1]=m
     if #zone.materials==1 then zone.reference.points=source.points;zone.reference.traced=true;zone.reference.targets=source.targets end
    end
   end
  end
 end
 F.LoadKnown()
 local function addMapped(m,map,x,y)
  if not map or type(x)~='number' or type(y)~='number' or x<0 or x>100 or y<0 or y>100
   or (scope=='current' and map~=p.mapID)then return end
  local zone=zones[map]
  if not zone then
   local info=read(C_Map and C_Map.GetMapInfo,map)
   local name=info and info.name
   if not name then for label,facts in pairs(ns.ForeverData.zones)do if facts.mapID==map then name=label;break end end end
   if not name or (info and info.mapType and info.mapType~=3)then return end
   zone={materials={},seen={},sources={},reference={zone=name,points={}},mapID=map}
   zones[map]=zone
  end
  if zone.curated and zone.curated[m.id]then return end
  if not outsideDeadEnds({x,y},{x,y},deadEnds[zone.reference.zone] or {})then return end
  if not zone.seen[m.id]then
   zone.seen[m.id]=true;zone.materials[#zone.materials+1]=m
   zone.sources[m.id]={points={}}
   if #zone.materials==1 then zone.reference.points=zone.sources[m.id].points end
  end
  local pts=zone.sources[m.id].points
  if #pts<60 then pts[#pts+1]={x,y}end
 end
 local selected,kinds={},{}
 for _,m in ipairs(materials)do
  local rank=ranks[m.id]
  if rank and rank>=(m.skill or 1)then
   selected[m.id]=m;kinds[m.kind]=true
  end
 end
 for kind in pairs(kinds)do
  for map,points in pairs(F.known[kind] or {})do
   if scope~='current' or map==p.mapID then
    for coord,id in pairs(points)do
     local meta=F.meta[id]
     local m=meta and selected[meta.item]
     if m and m.kind==kind and ranks[m.id]>=(meta.skill or 1)then
      local x,y=F.Decode(coord);addMapped(m,map,x,y)
     end
    end
   end
  end
 end
 for _,m in ipairs(materials)do
  if selected[m.id] then
   for _,site in ipairs(E.materialSites and E.materialSites[m.id] or {})do addMapped(m,site.mapID,site.x,site.y)end
  end
 end
 local observer=ns.GatheringObserver
 for _,node in pairs(observer and observer.data and observer.data.nodes or {})do
  local meta=F.meta[node.sourceNodeID];local at=node.position
  local m=meta and selected[meta.item]
  if m and m.kind==meta.kind and not node.instanced and at then addMapped(m,at.mapID,at.x,at.y)end
 end
 local ranked,here={},nil
 for _,zone in pairs(zones)do
  combineFarmSources(zone)
  for i,point in ipairs(zone.reference.points)do
   local d=yards(zone.mapID,point[1],point[2],p)
   local cost=d and d+(zone.mapID==p.mapID and 0 or 4000)
   if not cost then cost=zone.mapID==p.mapID and math.sqrt((point[1]-p.x*100)^2+(point[2]-p.y*100)^2)*100 or 20000 end
   if cost and (not zone.cost or cost<zone.cost)then zone.start=i;zone.cost=cost end
  end
  if zone.cost then
   zone.score=guideScore(zone.reference.zone,materials)
   if zone.mapID==p.mapID then here=zone else ranked[#ranked+1]=zone end
  end
 end
 table.sort(ranked,function(a,b)
  if #a.materials~=#b.materials then return #a.materials>#b.materials end
  if a.score~=b.score then return a.score>b.score end
  if a.cost~=b.cost then return a.cost<b.cost end
  return a.mapID<b.mapID
 end)
 if scope=='cards' then
  local info=read(C_Map and C_Map.GetMapInfo,p.mapID)
  here=here or {mapID=p.mapID,reference={zone=info and info.name or 'Current Zone',points={}},materials={}}
  here.current=true
  orderZoneLoop(here)
  local nearby,best
  for _,zone in ipairs(ranked)do
   orderZoneLoop(zone)
   if zone.start then
    if not best then best=zone end
    if not nearby or #zone.materials>#nearby.materials or
     (#zone.materials==#nearby.materials and zone.cost<nearby.cost)then nearby=zone end
   end
  end
  local cards={here}
  if nearby then nearby.recommendation='Nearby';cards[#cards+1]=nearby end
  if best==nearby then
   best=nil
   for _,zone in ipairs(ranked)do if zone.start and zone~=nearby then best=zone;break end end
  end
  if best then best.recommendation='Farming Pick';cards[#cards+1]=best end
  return cards
 end
 local best=ranked[1]
 if here and (not best or #here.materials>=#best.materials)then return here end
 return best
end
local oldPlan=F.Plan
function F.Plan(kind,item,limit)
 local choice=R.request;if not choice then return oldPlan(kind,item,limit)end
 local ref=choice.reference;local nodes={};local pts=ref.points;local ordered={}
 if ref.mode=='backtrack'then for i=choice.start,#pts do ordered[#ordered+1]=i end;for i=#pts-1,1,-1 do ordered[#ordered+1]=i end;for i=2,choice.start-1 do ordered[#ordered+1]=i end
 elseif ref.mode=='open'then for i=1,#pts do ordered[#ordered+1]=i end
 else for n=0,#pts do ordered[#ordered+1]=(choice.start+n-1)%#pts+1 end end
 for _,i in ipairs(ordered)do local v=pts[i];nodes[#nodes+1]={mapID=choice.mapID,x=v[1],y=v[2],name=ref.zone..' '..kind..' Route',profession=kind,item=item,routeWaypoint=true}end
 return nodes,nil,{mapID=choice.mapID}
end
function R.Start(m,target)
 if m.kind=='Mining'and(read(C_Item and C_Item.GetItemCount or GetItemCount,2901,false)or 0)<1 then return false,'Carry a Mining Pick.'end
 if m.kind=='Skinning'and(read(C_Item and C_Item.GetItemCount or GetItemCount,7005,false)or 0)<1 then return false,'Carry a Skinning Knife.'end
 if read(IsInInstance)then return false,'Use an outdoor farming route.'end
 local choice,why=R.Recommend(m);R.request=choice
 local ok,err=F.Start(m.kind,m.id,target or((read(C_Item and C_Item.GetItemCount or GetItemCount,m.id,false)or 0)+20));R.request=nil
 if not ok then return false,err or why end
 if choice then F.route.traced=true;F.route.reference=choice.reference
  for i,step in ipairs(F.route.steps)do step.title='Farm '..m.name..' - '..i..' / '..#F.route.steps;step.body=(m.kind=='Skinning'and'Kill, loot and skin suitable beasts.'or m.kind=='Fishing'and'Fish matching pools along the route.'or'Gather '..m.name..' along the route.')..'\n\nApproximate route from your supplied map. Follow accessible terrain; Skip bypasses a waypoint.';step.destination.name=choice.reference.zone..' Farming Route'end
  N.Refresh()
 end
 return true
end
function R.Open()
 if F.route then F.Stop('Quest guide resumed.');return end
 local r=N.root;if not r then return end
 if not R.menu then
  local f=CreateFrame('Frame',nil,r,'BackdropTemplate');R.menu=f;f:SetSize(390,510);f:SetPoint('CENTER',r,'CENTER');f:SetFrameStrata('DIALOG');f:SetBackdrop({bgFile='Interface/Tooltips/UI-Tooltip-Background',edgeFile='Interface/Tooltips/UI-Tooltip-Border',tile=true,tileSize=16,edgeSize=16,insets={left=4,right=4,top=4,bottom=4}});f:SetBackdropColor(.07,.045,.025,1)
  local t=f:CreateFontString(nil,'OVERLAY','GameFontNormalLarge');t:SetPoint('TOPLEFT',18,-18);t:SetText('Plan Farming Route')
  local edit=CreateFrame('EditBox',nil,f,'InputBoxTemplate');R.search=edit;edit:SetSize(340,28);edit:SetPoint('TOPLEFT',24,-50);edit:SetAutoFocus(false)
  local sf=CreateFrame('ScrollFrame',nil,f,'UIPanelScrollFrameTemplate');sf:SetPoint('TOPLEFT',16,-88);sf:SetPoint('BOTTOMRIGHT',-34,62);local body=CreateFrame('Frame',nil,sf);body:SetSize(320,1);sf:SetScrollChild(body);R.body=body;R.buttons={}
  local close=N.MakeButton(f,'Close',90,function()f:Hide()end);close:SetPoint('BOTTOM',f,'BOTTOM',0,16)
  edit:SetScript('OnTextChanged',function()R.Fill()end)
 end
 R.menu:Show();R.Fill()
end
function R.Fill()
 local query=(R.search:GetText()or''):lower();local y=0;local n=0
 table.sort(R.materials,function(a,b)return a.name<b.name end)
 for _,m in ipairs(R.materials)do if m.name:lower():find(query,1,true)then n=n+1;local b=R.buttons[n]
  if not b then b=N.MakeButton(R.body,'',320,function(self)local ok,why=R.Start(self.material);if ok then R.menu:Hide()else ns.Print(why)end end);R.buttons[n]=b end
  b.material=m;b:ClearAllPoints();b:SetPoint('TOPLEFT',R.body,'TOPLEFT',0,-y);b:SetSize(320,32);b.label:SetText(m.name);b:Show();y=y+36
 end end
 for i=n+1,#R.buttons do R.buttons[i]:Hide()end;R.body:SetHeight(math.max(1,y))
end
local layout=ns.WindowWorkflow.Layout;ns.WindowWorkflow.Layout=function(...)local v=layout(...);if N.farmButton then N.farmButton:SetScript('OnClick',R.Open)end;return v end;N.WorkflowLayout=ns.WindowWorkflow.Layout
local tick=N.Tick
N.Tick=function(...)
 local result=tick(...);local r=F.route
 if r and r.traced then local p=pos();local s=r.steps[r.cursor];local d=s and s.destination;local now=read(GetTime)or 0
  if p and d and now-(R.lastAdvance or-10)>1.5 then local dist=yards(d.mapID,d.x,d.y,p);if dist and dist<=12 then R.lastAdvance=now;F.Advance()end end
 end;return result
end
end)(ADDON,GF)


-- GF_FARM_SELECTOR96_BEGIN
;(function(...)
local _,ns=...;local R,N=ns.MaterialRoutes,ns.NormalUI;local open=R.Open
function R.Open(...)
 local value=open(...);local f=R.menu
 if f then f:SetFrameStrata('TOOLTIP');f:SetFrameLevel((N.frame or N.root):GetFrameLevel()+240);f:SetClampedToScreen(true);f:SetToplevel(true);f:EnableMouse(true)end
 return value
end
local layout=ns.WindowWorkflow.Layout
ns.WindowWorkflow.Layout=function(...)local v=layout(...);if N.farmButton then N.farmButton:SetScript('OnClick',R.Open)end;return v end
N.WorkflowLayout=ns.WindowWorkflow.Layout
end)(ADDON,GF)
-- GF_FARM_SELECTOR96_END


-- GF_MATERIAL_CLICK97_BEGIN
;(function(...)
local _,ns=...;local R=ns.MaterialRoutes;if not R then return end
local fill=R.Fill
R.Fill=function(...)
 local result=fill(...)
 for _,button in ipairs(R.buttons or{})do
  button:SetScript('OnClick',function(self,key)
   if key and key~='LeftButton'then return end
   if not self.material then ns.Print('Choose a material first.');return end
   local ok,why=R.Start(self.material)
   if ok then R.menu:Hide()else ns.Print(why or'No eligible route is available for this material.')end
  end)
 end
 return result
end
end)(...)
-- GF_MATERIAL_CLICK97_END

-- GF_NAVIGATION98_BEGIN: approved native navigation and multi-resource controls.
;(function(...)
local _,ns=...;local N,P,F,R,W=ns.NormalUI,ns.ProfessionGuide,ns.FarmingPlanner,ns.MaterialRoutes,ns.WindowWorkflow
if not(N and P and F and R and W)then return end
local C=ns.Retail.Client
local AS='Interface\\AddOns\\GrindingForever\\Media\\'
local K={pins={},targets={},markers={},ticks={},world={},worldCount=0,age=1,selected={}}
ns.NavigationCompass=K
local function read(fn,...)if type(fn)=='function'then local ok,a,b,c=pcall(fn,...);if ok then return a,b,c end end end
local function wrap(a)return(a+math.pi)%(math.pi*2)-math.pi end
local function text(parent,size,value)
 local t=parent:CreateFontString(nil,'OVERLAY');t:SetFont('Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf',size);t:SetTextColor(.13,.08,.025);t:SetText(value or'');return t
end
local function texture(parent,path,layer)local t=parent:CreateTexture(nil,layer or'ARTWORK');t:SetTexture(AS..path);return t end
local function icon(id)return read(C_Item and C_Item.GetItemIconByID or GetItemIcon,id)or'Interface\\Icons\\INV_Misc_Book_09'end
local function position()local p=read(C.PlayerPosition);if p and p.status=='available'then return p end end
local function world(loc)
 if not loc or type(loc.mapID)~='number'or type(loc.x)~='number'or type(loc.y)~='number'then return end
 local key=loc.mapID..':'..loc.x..':'..loc.y;local v=K.world[key]
 if not v then local i,x,y=read(C.WorldPosition,loc.mapID,loc.x,loc.y);if i and x and y then
  if K.worldCount>=256 then K.world={};K.worldCount=0 end
  v={i,x,y};K.world[key]=v;K.worldCount=K.worldCount+1
 end end;return v
end
local function distance(loc,p)
 local a=world(loc);local b=p and world({mapID=p.mapID,x=p.x*100,y=p.y*100})
 if a and b and a[1]==b[1]then local dx,dy=a[2]-b[2],a[3]-b[3];return math.sqrt(dx*dx+dy*dy),math.atan2(dy,dx)end
end
function K.Mode()return 'Compass'end
function K.Enabled()return true end
function K.SetMode(mode)
 if mode~='Arrow'and mode~='Compass'then return false end
 if ns.db then ns.db.navigationStyle=mode end;K.age=1;K.Sync();return true
end
function K.Sync()
 if K.thumb then K.thumb:ClearAllPoints();K.thumb:SetPoint(K.Mode()=='Compass'and'RIGHT'or'LEFT',K.switch,K.Mode()=='Compass'and'RIGHT'or'LEFT',K.Mode()=='Compass'and-2 or 2,0)end
 if K.frame then K.frame:Show()end
 if not K.Enabled() and K.ClearLiveArt then K.ClearLiveArt()end
 if K.Mode()=='Compass'and N.arrowFrame then N.arrowFrame:Hide()end
end
function K.FlagKey(record,loc)return tostring(record.spellID or record.learnableItemID or record.itemID or record.id or record.name)..':'..tostring(loc.mapID)..':'..tostring(loc.x)..':'..tostring(loc.y)end
function K.Flag(record,loc)
 if not world(loc)then return false end;local key=K.FlagKey(record,loc)
 if K.Unpin(key)then return true end
 local n=0;for _ in pairs(K.pins)do n=n+1 end;if n>=6 then ns.Print('Unpin a recipe source before adding another.');return false end
 K.pins[key]={key=key,name=loc.name or record.name,zone=loc.zone,location=loc,icon=AS..'RecipePin',pin=true};K.age=1;return true
end
K.questIcon='Interface\\TargetingFrame\\UI-RaidTargetingIcon_3'
K.manualPinAtlas='Waypoint-MapPin-Tracked'
function K.Unpin(key)
 if not key or not K.pins[key] then return false end
 K.pins[key]=nil
 if key==K.questPin then K.questPin=nil end
 if key==K.dungeonPin then K.dungeonPin=nil end
 if key==K.recipePin then K.recipePin=nil end
 K.age=1
 return true
end
function K.ClearQuestPin()
 local key=K.questPin;K.questPin=nil
 return K.Unpin(key)
end
local liveNodes={}
local lootRefresh=CreateFrame('Frame')
lootRefresh:SetScript('OnEvent',function()K.age=1 end)
lootRefresh:RegisterEvent('LOOT_CLOSED')
local scanCursor=0
local scanMap
local scanGrid,gridCursor={},0
local resourceNames
local function resourcesByName()
 if not resourceNames then
  resourceNames={}
  for _,meta in pairs(F.meta)do
   if meta.name and meta.item and (meta.kind=='Mining' or meta.kind=='Herbalism' or meta.kind=='Fishing')then
    resourceNames[meta.name:lower()]=meta
   end
  end
 end
 return resourceNames
end
local function addGlint(parent,size)
 local glint=CreateFrame('Frame',nil,parent)
 glint:SetSize(size,size)
 for _,horizontal in ipairs({true,false})do
  local ray=glint:CreateTexture(nil,'OVERLAY')
  ray:SetColorTexture(1,.86,.42,.9)
  ray:SetSize(horizontal and size or 2,horizontal and 2 or size)
  ray:SetPoint('CENTER')
 end
 if glint.CreateAnimationGroup then
  local pulse=glint:CreateAnimationGroup()
  pulse:SetLooping('BOUNCE')
  local fade=pulse:CreateAnimation('Alpha')
  fade:SetFromAlpha(.2);fade:SetToAlpha(1);fade:SetDuration(.65)
  pulse:Play()
 end
 return glint
end
local mapSymbols={}
local function paintLiveNodes(found,p)
 if not Minimap or not Minimap:IsShown() then found={} end
 local M=ns.KnownNodePins
 local radius=read(C_Minimap and C_Minimap.GetViewRadius)
 if not ns.Forever.Public(radius) or type(radius)~='number' or radius<=0 then radius=M and M.Range() end
 local facing=read(GetCVar,'rotateMinimap')=='1' and read(C.Facing) or 0
 local count=0
 if p and M and M.map==p.mapID and radius and ns.Forever.Public(facing) and type(facing)=='number' then
  local w,h=Minimap:GetWidth(),Minimap:GetHeight()
  for _,node in ipairs(found)do
   local loc=node.location
   local x,y=M.Project((loc.x-p.x*100)*M.width/100,(p.y*100-loc.y)*M.height/100,w,h,radius,facing)
   if x and count<10 then
    count=count+1
    local symbol=mapSymbols[count]
    if not symbol then
     symbol=CreateFrame('Frame',nil,Minimap)
     symbol:SetSize(16,16)
     symbol:SetFrameLevel(Minimap:GetFrameLevel()+4)
     symbol.icon=symbol:CreateTexture(nil,'ARTWORK')
     symbol.icon:SetAllPoints()
     symbol.glint=addGlint(symbol,8)
     symbol.glint:SetPoint('TOPRIGHT',2,2)
     mapSymbols[count]=symbol
    end
    if symbol.texture~=node.icon then symbol.texture=node.icon;symbol.icon:SetTexture(node.icon)end
    symbol:ClearAllPoints();symbol:SetPoint('CENTER',Minimap,'CENTER',x,y);symbol:Show()
   end
  end
 end
 for i=count+1,#mapSymbols do mapSymbols[i]:Hide() end
end
local worldGlint
function K.ClearLiveArt()
 paintLiveNodes({})
 if worldGlint then worldGlint:Hide()end
end
local function refreshWorldGlint()
 if worldGlint then worldGlint:Hide()end
 if not K.Enabled() or read(InCombatLockdown) then return end
 local name=read(UnitName,'softinteract')
 if not ns.Forever.Public(name) or type(name)~='string' or not resourcesByName()[name:lower()]then return end
 local plate=read(C_NamePlate and C_NamePlate.GetNamePlateForUnit,'softinteract')
 if not ns.Forever.Public(plate) or not plate then return end
 if not worldGlint then worldGlint=addGlint(UIParent,19) end
 worldGlint:ClearAllPoints()
 if pcall(worldGlint.SetPoint,worldGlint,'CENTER',plate,'CENTER')then worldGlint:Show()end
end
local sparkleEvents=CreateFrame('Frame')
sparkleEvents:SetScript('OnEvent',function(_,event,unit)
 if event=='NAME_PLATE_UNIT_ADDED' or event=='NAME_PLATE_UNIT_REMOVED' then
  if not (ns.Forever.Public(unit) and type(unit)=='string' and
   (unit=='softinteract' or read(UnitIsUnit,unit,'softinteract'))) then return end
 end
 refreshWorldGlint()
end)
for _,event in ipairs({'PLAYER_SOFT_INTERACT_CHANGED','NAME_PLATE_UNIT_ADDED','NAME_PLATE_UNIT_REMOVED','PLAYER_REGEN_DISABLED','PLAYER_REGEN_ENABLED','PLAYER_ENTERING_WORLD'})do
 pcall(sparkleEvents.RegisterEvent,sparkleEvents,event)
end
local function probeNodes(p)
 local E=ns.Forever
 local M=ns.KnownNodePins
 local tooltip=C_TooltipInfo and C_TooltipInfo.GetMinimapMouseover
 if not p or not M or not Minimap or not Minimap:IsShown()
  or not Minimap.UpdateMouseoverAtPoint or not Minimap.SetUsingSoftCursor
  or type(tooltip)~='function' or read(InCombatLockdown) or read(UnitOnTaxi,'player')
  or read(IsInInstance) or read(IsIndoors) or read(Minimap.IsMouseOver,Minimap) then
  return {}
 end
 if scanMap~=p.mapID then scanMap=p.mapID;liveNodes={};scanCursor=0;gridCursor=0 end
 M.Update(1)
 if not M.rangeAvailable or M.map~=p.mapID then return {} end
 local radius=read(C_Minimap and C_Minimap.GetViewRadius)
 if not E.Public(radius) or type(radius)~='number' or radius<=0 then radius=M.Range()end
 local left,bottom=read(Minimap.GetLeft,Minimap),read(Minimap.GetBottom,Minimap)
 local scale=read(Minimap.GetEffectiveScale,Minimap)
 local w,h=Minimap:GetWidth(),Minimap:GetHeight()
 if not radius or not left or not bottom or not scale or w<=0 or h<=0 then return {} end
 local facing=read(GetCVar,'rotateMinimap')=='1' and read(C.Facing) or 0
 if not E.Public(facing) or type(facing)~='number' then return {} end
 local now=read(GetTime) or 0
 local started=read(debugprofilestop)
 local names=resourcesByName()
 if #scanGrid==0 then
  for y=-11,11 do for x=-11,11 do
   if x*x+y*y<=121 then scanGrid[#scanGrid+1]={x/11,y/11,x*x+y*y} end
  end end
  table.sort(scanGrid,function(a,b)
   if a[3]~=b[3] then return a[3]<b[3] end
   if a[2]~=b[2] then return a[2]<b[2] end
   return a[1]<b[1]
  end)
 end
 local function readProbe(x,y)
  Minimap:UpdateMouseoverAtPoint((left+w/2+x)*scale,(bottom+h/2+y)*scale)
  local data=tooltip()
  local lines=E.Public(data) and type(data)=='table' and data.lines
  if not E.Public(lines) or type(lines)~='table' then return end
  local found
  for _,line in ipairs(lines)do
   local text=line.leftText
   if E.Public(text) and type(text)=='string' then
    local name=text:gsub('|c%x%x%x%x%x%x%x%x',''):gsub('|r',''):match('^%s*(.-)%s*$')
    local meta=names[name:lower()]
    if meta then
     if found and found~=meta then return end
     found=meta
    end
   end
  end
  return found
 end
 local function probe(x,y)
  local candidate=readProbe(x,y)
  if not candidate then return end
  -- A stale tooltip can follow the probe outside the minimap.
  if readProbe(-w,-h) then return end
  local confirmed=readProbe(x,y)
  if confirmed==candidate then return confirmed end
 end

 local function remember(node)
  for key,entry in pairs(liveNodes)do
   if entry.node.item==node.item then
    local dx=(entry.node.x-node.x)*M.width/100
    local dy=(entry.node.y-node.y)*M.height/100
    if dx*dx+dy*dy<=12*12 then liveNodes[key]=nil end
   end
  end
  local key=node.kind..':'..node.x..':'..node.y
  liveNodes[key]={node=node,expires=now+8}
 end
 local function sweep()
  Minimap:SetUsingSoftCursor(true)
  local function overBudget()
   return started and (read(debugprofilestop) or started)-started>=1
  end
  local c,s=math.cos(facing),math.sin(facing)
  -- Old hits cannot survive a refresh unless Blizzard still reports the dot.
  local previous=liveNodes
  liveNodes={}
  local verified=0
  for _,entry in pairs(previous)do
   local node=entry.node
   local x,y=M.Project((node.x-p.x*100)*M.width/100,(p.y*100-node.y)*M.height/100,w,h,radius,facing)
   if x then
    local meta=probe(x,y)
    if meta and meta.item==node.item then remember(node)end
    verified=verified+1
    if verified>=10 or overBudget()then break end
   end
  end
  if overBudget()then return end
  for _=1,20 do
   gridCursor=gridCursor%#scanGrid+1
   local point=scanGrid[gridCursor]
   local x,y=point[1]*w/2,point[2]*h/2
   local meta=probe(x,y)
   if meta then
    local right,up=point[1]*radius,point[2]*radius
    local east,north=right*c-up*s,right*s+up*c
    remember({name=meta.name,item=meta.item,kind=meta.kind,
     x=p.x*100+100*east/M.width,y=p.y*100-100*north/M.height})
   end
   if overBudget()then return end
  end
  local attempts=0
  for _=1,#M.points do
   scanCursor=scanCursor%#M.points+1
   local node=M.points[scanCursor]
   local x,y=M.Project((node.x-p.x*100)*M.width/100,(p.y*100-node.y)*M.height/100,w,h,radius,facing)
   if x and node.item then
    local meta=probe(x,y)
    local key=node.kind..':'..node.x..':'..node.y
    liveNodes[key]=nil
    if meta and meta.item==node.item then remember(node) end
    attempts=attempts+1
    if attempts>=4 or overBudget()then return end
   end
  end
 end
 local ok=pcall(sweep)
 pcall(Minimap.SetUsingSoftCursor,Minimap,false)
 if not ok then liveNodes={};return {} end
 local found={}
 for key,entry in pairs(liveNodes)do
  if entry.expires<=now then liveNodes[key]=nil
  else
   local node=entry.node
   local loc={mapID=p.mapID,x=node.x,y=node.y}
   local yards,bearing=distance(loc,p)
   if yards and yards<=radius and bearing then
    found[#found+1]={key='live:'..key,name=node.name,location=loc,distance=yards,bearing=bearing,
     icon=icon(node.item),resource=true,liveNode=true}
   end
  end
 end
 return found
end
function K.Collect()
 local E=ns.Forever
 local rows={};local d=read(P.Destination);local row=P.selected
 if d and not N.gpsSuppressed and not N.areaNavigation then
  local id=d.materialID or F.route and F.route.item or row and(row.materialID or row.itemID)
  rows[1]={key='active',name=d.name or row and row.title or'Current Objective',zone=d.zone,location=d,icon=id and icon(id)or'Interface\\AddOns\\GrindingForever\\Media\\RecipePin',active=true,pin=not id}
 end
 local route=F.route;local p=position()
 if route and route.multiMaterials then
  local current=route.steps[route.cursor or 1]
  if N.model and N.model.Current then current=N.model:Current()or current end
  local currentID=current and current.destination and current.destination.materialID
  for _,m in ipairs(route.multiMaterials)do if m.id~=currentID then
   local best,yards
   for _,node in ipairs(route.nodes)do if node.materialID==m.id then local dist=distance(node,p);if dist and(not yards or dist<yards)then best=node;yards=dist end end end
   if best then rows[#rows+1]={key='material:'..m.id,name=m.name,zone=best.zone,location=best,icon=icon(m.id)}end
  end end
 end
 for _,pin in pairs(K.pins)do rows[#rows+1]=pin end
 local live=probeNodes(p)
 paintLiveNodes(live,p)
 if p and p.mapID then
  local nearby=live
  if route then
   for _,m in ipairs(ns.MaterialRoutes and ns.MaterialRoutes.materials or {})do
    if (m.kind=='Skinning' or m.kind=='Cloth') and (m.id==route.item or K.selected and K.selected[m.id])then
     local best,yards
     for _,site in ipairs(E.materialSites and E.materialSites[m.id] or {})do
      local d=site.mapID==p.mapID and distance(site,p)
      if d and d<=400 and (not yards or d<yards)then best,yards=site,d end
     end
     if best then nearby[#nearby+1]={key='farm-target:'..m.id,name=best.name or m.name,
      location=best,icon=icon(m.id),distance=yards,resource=true}end
    end
   end
  end
  table.sort(nearby,function(a,b)if a.distance~=b.distance then return a.distance<b.distance end;return a.key<b.key end)
  for i=1,math.min(10,#nearby,15-#rows)do
   local marker=nearby[i]
   rows[#rows+1]=marker
  end
 end
 for _,r in ipairs(rows)do if not r.resource or not r.bearing then r.distance,r.bearing=distance(r.location,p)end end;K.targets=rows;K.revision=(K.revision or 0)+1
end
function K.ShowRouteMap()
 local route=F.route
 local step=route and route.steps and route.steps[1]
 local mapID=step and step.destination and step.destination.mapID
 local frame=WorldMapFrame
 if not (mapID and frame and frame.SetMapID) then return end
 if not frame:IsShown() then
  if ShowUIPanel then ShowUIPanel(frame) else frame:Show() end
 end
 frame:SetMapID(mapID)
end
function K.Ensure()
 if K.frame then return end
 local f=CreateFrame('Frame',nil,UIParent);K.frame=f;f:SetSize(744,66);f:SetPoint('TOP',UIParent,'TOP',0,-55);f:SetFrameStrata('HIGH');f:SetClampedToScreen(true);f:EnableMouse(true);f:SetMovable(true);f:RegisterForDrag('LeftButton');f:SetScript('OnDragStart',f.StartMoving);f:SetScript('OnDragStop',f.StopMovingOrSizing)
 N.PanelChrome(f,nil,320,52)
 f:HookScript('OnSizeChanged',function()K.lastFacing=nil end)
 local routeButton=CreateFrame('Button',nil,f)
 routeButton:SetSize(32,32);routeButton:SetPoint('CENTER',f,'CENTER');routeButton:Hide()
 routeButton:SetScript('OnClick',K.ShowRouteMap)
 routeButton:SetScript('OnEnter',function(self)
  local route=F.route
  local zone=route and route.reference and route.reference.zone
  local mapView=ns.MapControls99
  local report=mapView and mapView.routeReport
  N.ShowInfoTooltip(self,(zone or 'Farming route')..(route and (' · '..#route.steps..' waypoints') or '')..'\nClick to show the route on the world map'..(report and ('\n'..report) or ''))
 end)
 routeButton:SetScript('OnLeave',N.HideInfoTooltip)
 K.routeButton=routeButton
 K.routeArrow=routeButton:CreateTexture(nil,'OVERLAY')
 K.routeArrow:SetTexture(N.ProjectedArrowAsset());K.routeArrow:SetAllPoints()
 K.caption=text(f,19);K.caption:SetTextColor(.94,.82,.55);K.caption:SetPoint('TOP',f,'BOTTOM',0,-20);K.caption:SetPoint('LEFT',f,'LEFT',18,0);K.caption:SetPoint('RIGHT',f,'RIGHT',-18,0);K.caption:SetJustifyH('CENTER')
 K.headingStatus=text(f,15,'Compass heading unavailable');K.headingStatus:SetPoint('CENTER');K.headingStatus:SetTextColor(.94,.82,.55);K.headingStatus:Hide()
 for i=0,47 do local line=f:CreateTexture(nil,'ARTWORK');line:SetColorTexture(.9,.68,.36,1);line:SetSize(1.25,i%6==0 and 10 or 5);local t=text(f,15,({[0]='N',[6]='NE',[12]='E',[18]='SE',[24]='S',[30]='SW',[36]='W',[42]='NW'})[i]);t:SetTextColor(.94,.81,.54);K.ticks[i]={line=line,label=t,bearing=-i*math.pi/24}end
 for i=1,15 do local b=CreateFrame('Button',nil,f);b:SetSize(28,28);b.icon=b:CreateTexture(nil,'ARTWORK');b.icon:SetAllPoints()
  b.arrow=texture(b,'ControlTriangleRight','OVERLAY');b.arrow:SetSize(7,7);b.arrow:SetRotation(math.pi/2);b.arrow:SetPoint('BOTTOM',b,'CENTER',0,-15);b.arrow:Hide()
  b:RegisterForClicks('RightButtonUp')
  b:SetScript('OnClick',function(self)
   if self.target and K.pins[self.target.key]==self.target and K.Unpin(self.target.key) then
    self.target=nil;self:Hide();N.HideInfoTooltip()
   end
  end)
  b:SetScript('OnEnter',function(self)if self.target then N.ShowInfoTooltip(self,self.target.name..(self.target.zone and'\n'..self.target.zone or'')..(self.target.distance and'\n'..math.floor(self.target.distance+.5)..' yd'or'')..(K.pins[self.target.key]==self.target and '\nRight-click to unpin' or ''))end end);b:SetScript('OnLeave',N.HideInfoTooltip);K.markers[i]=b
 end
 f:SetScript('OnUpdate',function(_,elapsed)K.Update(elapsed)end);K.Sync()
end
function K.Update(elapsed)
 if not K.Enabled()then K.frame:Hide();paintLiveNodes({});return end
 if N.arrowFrame and K.Mode()=='Compass'then N.arrowFrame:Hide()end
 K.age=K.age+(elapsed or 0);if K.age>=1 then K.age=0;K.Collect()end
 K.paintAge=(K.paintAge or 0)+(elapsed or 0)
 if K.paintAge<1/30 then return end
 K.paintAge=0
 local facing=read(C.Facing)
 if not ns.Forever.Public(facing) or type(facing)~='number' or facing~=facing or math.abs(facing)==math.huge then
  if not K.headingUnavailable then
   K.headingUnavailable=true;K.lastFacing=nil;K.captionText=nil;K.arrowRevision=nil
   for _,b in ipairs(K.markers)do b:Hide()end
   for _,tick in pairs(K.ticks)do tick.line:Hide();tick.label:Hide()end
   K.caption:SetText('');K.headingStatus:Show();K.routeButton:Hide()
  end
  return
 end
 local route=F.route
 local step=route and route.steps[route.cursor or 1]
 if K.arrowStep~=step or K.arrowRevision~=K.revision then
  K.arrowStep,K.arrowRevision=step,K.revision
  local _,bearing
  if step then _,bearing=distance(step.destination,position())end
  K.routeBearing=bearing
  K.routeButton:SetShown(bearing~=nil)
 end
 if K.routeBearing and (K.lastFacing~=facing or K.lastRevision~=K.revision)then
  N.PaintProjectedArrow(K.routeArrow,wrap(K.routeBearing-facing))
 end
 if K.headingUnavailable then K.headingUnavailable=nil;K.headingStatus:Hide()end
 if K.lastFacing==facing and K.lastRevision==K.revision then return end;K.lastFacing=facing;K.lastRevision=K.revision
 local width=math.max(1,K.frame:GetWidth()-36);local span=math.pi
 for _,t in pairs(K.ticks)do local a=wrap(t.bearing-facing);local show=math.abs(a)<=span/2;local x=-a/span*width;t.line:SetShown(show);t.label:SetShown(show);if show then t.line:ClearAllPoints();t.line:SetPoint('BOTTOM',K.frame,'BOTTOM',x,9);t.label:ClearAllPoints();t.label:SetPoint('TOP',K.frame,'TOP',x,-10)end end
 local focus
 for i,b in ipairs(K.markers)do local r=K.targets[i]
  if r and r.bearing then local a=wrap(r.bearing-facing);local clipped=math.max(-span/2,math.min(span/2,a));local x=-clipped/span*width
   b.target=r
   local manualPin=K.pins[r.key]==r and not r.customIcon
   local atlas=manualPin and b.icon.SetAtlas and pcall(b.icon.SetAtlas,b.icon,K.manualPinAtlas)
   local nativePin=atlas and (not b.icon.GetAtlas or b.icon:GetAtlas()==K.manualPinAtlas)
   if not nativePin then
    b.icon:SetTexture(r.icon);b.icon:SetTexCoord(0,1,r.professionButton and 23/64 or 0,r.pin and .75 or 1)
   end
   b:SetSize(nativePin and 28 or r.pin and 24 or r.active and 32 or 28,nativePin and 28 or r.professionButton and 34 or r.pin and 36 or r.active and 32 or 28);b:ClearAllPoints();b:SetPoint('CENTER',K.frame,'CENTER',x,0);b.arrow:SetShown(r.active==true);b:SetAlpha(r.resource and (.25+.75*math.min(1,r.distance/40)) or 1);b:Show();if r.active then focus=r end
  else b:Hide()end
 end
 local caption=focus and(focus.name..'\n'..(focus.zone and focus.zone..' - 'or'')..math.floor(focus.distance+.5)..' yd')or''
 if K.captionText~=caption then K.captionText=caption;K.caption:SetText(caption)end
end
local heading=N.UpdateHeading
N.UpdateHeading=function(...)local result=heading(...);if N.arrowFrame then if K.Mode()=='Compass'then N.arrowFrame:Hide()elseif K.frame then N.arrowFrame:ClearAllPoints();N.arrowFrame:SetPoint('TOP',K.frame,'BOTTOM',0,-64)end end;return result end
local setArrow=N.SetArrow
N.SetArrow=function(...)local result=setArrow(...);K.Sync();return result end
local size=N.SetArrowSize
N.SetArrowSize=function(...)local result=size(...);K.Sync();return result end
function K.Settings()
 local f=N.settingsFrame;if not f then return end
 if N.arrowToggle then N.arrowToggle:Hide()end
 f:SetWidth(332);f:SetHeight(382);f:EnableMouse(true);f:SetFrameStrata('TOOLTIP');f:SetFrameLevel(N.root:GetFrameLevel()+200)
 for i,b in ipairs({N.autoFlightToggle,N.autoAcceptToggle,N.autoTurninToggle})do b:SetCheckedVisual(ns.Forever.db[({'autoFlights','autoAcceptQuests','autoTurnInQuests'})[i]]==true);b:ClearAllPoints();b:SetPoint('TOPLEFT',f,'TOPLEFT',18,-64-(i-1)*40);b:SetWidth(294)end
 if not K.rule then K.rule=f:CreateTexture(nil,'ARTWORK');K.rule:SetColorTexture(.45,.31,.12,1);K.rule:SetSize(294,1);K.rule:SetPoint('TOPLEFT',f,'TOPLEFT',18,-48)end
 K.Sync()
end
local function materialName(m)return m.name end
function R.ToggleMaterial(m)
 if not m then return end
 if K.selected[m.id]then K.selected[m.id]=nil else local n=0;for _ in pairs(K.selected)do n=n+1 end;if n>=8 then ns.Print('Select up to eight resources.');return end;K.selected[m.id]=true end
 R.Fill()
end
function R.Fill()
 if not R.body then return end
 local query=(R.search:GetText()or''):lower();local list={};for _,m in ipairs(R.materials)do if materialName(m):lower():find(query,1,true)or m.name:lower():find(query,1,true)then list[#list+1]=m end end
 table.sort(list,function(a,b)if not not K.selected[a.id]~=not not K.selected[b.id]then return K.selected[a.id]==true end;return materialName(a)<materialName(b)end)
 local y=0
 for i,m in ipairs(list)do local b=R.buttons[i]
  if not b then b=CreateFrame('Button',nil,R.body);R.buttons[i]=b;b.icon=b:CreateTexture(nil,'ARTWORK');b.icon:SetSize(28,28);b.icon:SetPoint('LEFT',b,'LEFT',8,0);b.label=text(b,19);b.label:SetPoint('LEFT',b,'LEFT',44,0);b.wash=b:CreateTexture(nil,'BACKGROUND');b.wash:SetAllPoints();b.wash:SetColorTexture(.03,.43,.38,.23);b.mark=texture(b,'RidgedFacetedHex');b.mark:SetSize(14,14);b.mark:SetPoint('RIGHT',b,'RIGHT',-9,0);b.rule=b:CreateTexture(nil,'ARTWORK');b.rule:SetColorTexture(.46,.28,.1,.25);b.rule:SetHeight(1);b.rule:SetPoint('BOTTOMLEFT');b.rule:SetPoint('BOTTOMRIGHT');b:SetScript('OnClick',function(self)R.ToggleMaterial(self.material)end)end
  b.material=m;b:SetSize(340,50);b:ClearAllPoints();b:SetPoint('TOPLEFT',R.body,'TOPLEFT',0,-y);b.label:SetText(materialName(m));b.label:SetWidth(267);b.icon:SetTexture(icon(m.id));b.wash:SetShown(K.selected[m.id]==true);b.mark:SetShown(K.selected[m.id]==true);b:Show();y=y+51
 end
 for i=#list+1,#R.buttons do R.buttons[i]:Hide()end;R.body:SetHeight(math.max(1,y));local n=0;for _ in pairs(K.selected)do n=n+1 end
 if K.count then K.count:SetText(n..' Resources Selected')end
 if K.resourceScroll then K.resourceScroll:SetVerticalScroll(0)end
 if K.resourceBar then K.resourceBar:SetShown(y>316)end
end
function R.StartSelection()
 local selectedCard=K.confirmed
 local materials={};for _,m in ipairs(R.materials)do if K.selected[m.id]then materials[#materials+1]=m end end
 table.sort(materials,function(a,b)return a.id<b.id end)
 if selectedCard then materials=selectedCard.materials end
 if #materials==0 then return false,'Select at least one resource.'end
 if read(IsInInstance)then return false,'Use an outdoor farming route.'end
 local ranks={}
 for _,m in ipairs(materials) do
  local rank=m.kind=='Cloth' and 1 or F.Skill(m.kind)
  if not rank or rank<(m.skill or 0) then return false,'Requires '..m.kind..' '..tostring(m.skill or 1)..' for '..m.name..'.' end
  ranks[m.id]=rank
  if m.kind=='Mining' and (read(C_Item and C_Item.GetItemCount or GetItemCount,2901,false) or 0)<1 then return false,'Carry a Mining Pick.' end
  if m.kind=='Skinning' and (read(C_Item and C_Item.GetItemCount or GetItemCount,7005,false) or 0)<1 then return false,'Carry a Skinning Knife.' end
 end
 local choice,why=K.confirmed
 K.confirmed=nil
 if not choice then choice,why=R.RecommendSelection(materials,ranks,K.scope)end
 if not choice and #materials==1 then
  local m=materials[1]
  local ok,err=F.Start(m.kind,m.id,math.huge)
  if not ok then return false,err end
  if R.menu then R.menu:Hide()end
  K.age=1;K.SyncFooter()
  return true
 end
 if not choice then return false,why or (K.scope=='current' and 'No mapped trail for the selected resources in your current zone.' or 'No mapped trail for the selected resources on this continent.') end
 if #choice.materials<#materials and not choice.selectedCard then
  return false,'No single trail covers all selected resources. Select resources that share a trail.'
 end
 local first=choice.materials[1]
 R.request=choice
 local called,ok,err=pcall(F.Start,first.kind,first.id,math.huge)
 R.request=nil
 if not called then F.route=nil;error(ok,0) end
 if not ok then return false,err end
 local route=F.route
 route.traced=true
 route.reference=choice.reference
 route.item=nil
 route.target=nil
 local names={}
 for _,m in ipairs(choice.materials) do names[#names+1]=m.name end
 for i,step in ipairs(route.steps) do
  step.title=choice.reference.zone..' Farming Route'
  step.body=choice.reference.targets and ((first.kind=='Skinning' and 'Skin ' or 'Farm ')..choice.reference.targets..' for '..table.concat(names,', ')..'.')
   or 'Gather '..table.concat(names,', ')..' along the trail.'
  step.destination.name='Trail Waypoint '..i..' / '..#route.steps
 end
 R.lastAdvance=read(GetTime) or 0
 K.age=1
 N.Refresh()
 if F.DrawPins then F.DrawPins() end
 if R.menu then R.menu:Hide() end
 K.SyncFooter()
 return true
end
function K.SyncFooter()if N.farmButton then local label=F.route and'Stop Farming Route'or'Plan Farming Route';if N.farmButton.label:GetText()~=label then N.farmButton.label:SetText(label)end end end
function R.Open()
 if F.route then F.Stop('Quest guide resumed.');K.SyncFooter();return end
 if not N.root then return end
 if not K.resourceMenu then
  local f=CreateFrame('Frame',nil,N.root,'BackdropTemplate');K.resourceMenu=f;R.menu=f;f:SetSize(396,592);f:SetPoint('CENTER',N.root,'CENTER');f:SetFrameStrata('TOOLTIP');f:SetFrameLevel(N.root:GetFrameLevel()+120);f:EnableMouse(true);f:SetClampedToScreen(true)
  N.PanelChrome(f)
  local paper=texture(f,'BaseParchment','BACKGROUND');paper:SetPoint('TOPLEFT',10,-10);paper:SetPoint('BOTTOMRIGHT',-10,10);paper:SetTexCoord(0,1254/2048,0,1254/2048)
  local title=text(f,23,'Plan Farming Route');title:SetPoint('TOPLEFT',24,-30)
  local search=CreateFrame('EditBox',nil,f,'InputBoxTemplate');R.search=search;search:SetSize(340,28);search:SetPoint('TOPLEFT',28,-80);search:SetAutoFocus(false);search:SetTextColor(.14,.09,.03);search:SetScript('OnTextChanged',R.Fill)
  local sf=CreateFrame('ScrollFrame',nil,f);K.resourceScroll=sf;sf:SetPoint('TOPLEFT',26,-124);sf:SetSize(340,316);sf:EnableMouseWheel(true)
  local body=CreateFrame('Frame',nil,sf);body:SetSize(340,1);sf:SetScrollChild(body);R.body=body;R.buttons={}
  local bar=CreateFrame('Frame',nil,f);K.resourceBar=bar;bar:SetSize(7,316);bar:SetPoint('TOPRIGHT',f,'TOPRIGHT',-16,-124);local line=bar:CreateTexture(nil,'BACKGROUND');line:SetPoint('TOP',bar,'TOP',0,-8);line:SetPoint('BOTTOM',bar,'BOTTOM',0,8);line:SetWidth(2);line:SetColorTexture(.43,.27,.12,1)
  local function scroll(by)local max=math.max(0,R.body:GetHeight()-316);sf:SetVerticalScroll(math.max(0,math.min(max,(sf:GetVerticalScroll()or 0)+by)))end
  sf:SetScript('OnMouseWheel',function(_,delta)scroll(-delta*51)end)
  for _,up in ipairs({true,false})do local b=CreateFrame('Button',nil,bar);b:SetSize(14,14);b:SetPoint(up and'TOP'or'BOTTOM',bar,up and'TOP'or'BOTTOM');local arrow=texture(b,'ControlTriangleRight');arrow:SetAllPoints();arrow:SetRotation(up and-math.pi/2 or math.pi/2);b:SetScript('OnClick',function()scroll(up and-51 or 51)end)end
  K.count=text(f,15);K.count:SetPoint('BOTTOMLEFT',f,'BOTTOMLEFT',24,130)
  local help=text(f,15,'Choose the resources you want to gather.');help:SetPoint('BOTTOM',f,'BOTTOM',0,84)
  K.start=N.MakeButton(f,'Start Route',166,function()local ok,why=R.StartSelection();if ok then f:Hide()else ns.Print(why or'Route unavailable.')end end);K.start:SetPoint('BOTTOMLEFT',f,'BOTTOMLEFT',24,28)
  local cancel=N.MakeButton(f,'Cancel',166,function()f:Hide()end);cancel:SetPoint('BOTTOMRIGHT',f,'BOTTOMRIGHT',-24,28)
 else R.menu=K.resourceMenu end
 R.menu:Show();R.Fill()
end
local goal=F.CheckGoal;if goal then F.CheckGoal=function(...)if F.route and F.route.multiMaterials then return end;return goal(...)end end
local destination=P.Destination
P.Destination=function(...)
 if F.route then
  local route=F.route;local current=N.model and N.model.Current and N.model:Current()
  for _,step in ipairs(route.steps)do if current and step.id==current.id then return step.destination end end
 end
 return destination(...)
end
for _,name in ipairs({'Stop','Start'})do local fn=F[name];F[name]=function(...)local a,b=fn(...);K.age=1;K.SyncFooter();return a,b end end
local refresh=N.Refresh
N.Refresh=function(...)local result=refresh(...);K.SyncFooter();return result end
local recipes=N.RefreshRecipes
N.RefreshRecipes=function(...)
 local result=recipes(...)
 for _,b in ipairs(N.root and N.root.recipeRows or{})do local record=b.record;local loc=record and(record.location or record.locations and record.locations[1])
  local allowed=b:IsShown()and loc and loc.mapID and loc.x and loc.y and record.kind~='boss'and record.kind~='loot'
  if allowed then
   if not b.compassFlag then local flag=N.MakeButton(b,'',25,function()local r=b.record;K.Flag(r,r.location or r.locations[1]);N.RefreshRecipes()end);b.compassFlag=flag;flag.symbol=texture(flag,'RecipePin','OVERLAY');flag.symbol:SetSize(12,18);flag.symbol:SetTexCoord(0,1,0,.75);flag.symbol:SetPoint('CENTER');flag:SetScript('OnEnter',function(self)N.ShowInfoTooltip(self,'Pin / Unpin Recipe Source')end);flag:SetScript('OnLeave',N.HideInfoTooltip)end
   b.compassFlag:SetSize(25,25);b.compassFlag:ClearAllPoints();b.compassFlag:SetPoint('TOPRIGHT',b,'TOPRIGHT',-2,-3);b.compassFlag:Show();b.compassFlag:SetAlpha(K.pins[K.FlagKey(record,loc)]and 1 or .75);b.label:SetWidth(math.max(60,b:GetWidth()-70))
  elseif b.compassFlag then b.compassFlag:Hide()end
 end;return result
end
local layout=W.Layout
W.Layout=function(...)local result=layout(...);K.Ensure();K.Settings();K.SyncFooter();if N.farmButton then N.farmButton:SetScript('OnClick',R.Open)end;return result end
N.WorkflowLayout=W.Layout
local tick=N.Tick
N.Tick=function(...)local result=tick(...);if K.Mode()=='Compass'and N.arrowFrame then N.arrowFrame:Hide()end;K.SyncFooter();return result end
if N.settingsFrame then N.settingsFrame:HookScript('OnShow',K.Settings)end
K.Ensure();K.Settings()
end)(ADDON,GF)
-- GF_NAVIGATION98_END

-- GF_REFINEMENT99_BEGIN
;(function(...)
local _,ns=...;local N,P,W,K,R,F=ns.NormalUI,ns.ProfessionGuide,ns.WindowWorkflow,ns.NavigationCompass,ns.MaterialRoutes,ns.FarmingPlanner
local AS='Interface\\AddOns\\GrindingForever\\Media\\'
local function text(p,size,value)local t=p:CreateFontString(nil,'OVERLAY');t:SetFont('Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf',size);t:SetTextColor(.15,.09,.035);t:SetText(value or'');return t end
local function tex(p,path,layer)local t=p:CreateTexture(nil,layer or'ARTWORK');t:SetTexture(AS..path);return t end
local function icon(id)local fn=C_Item and C_Item.GetItemIconByID or GetItemIcon;return fn and fn(id)or'Interface\\Icons\\INV_Misc_Book_09'end
local function now()return type(GetTime)=='function'and GetTime()or 0 end
local function invalidate()if ns.StepWork99 then ns.StepWork99.value=nil end end
-- Cache only within a short stable display interval; actual game events and all guide mutations invalidate immediately.
if not ns.Forever then
 local Q={hits=0,misses=0};ns.StepWork99=Q
 local visible=N.model.Visible
 function N.model:Visible(...)
  if select('#',...)>0 then return visible(self,...)end
  local db=ns.SharedExplorer.db;local route=F.route;local steps=route and route.steps or P.steps
  local goals='';for _,s in ipairs({'Questing','Dungeons','Gathering','Crafting'})do goals=goals..tostring(self.goals[s])end
  local v=Q.value;local clock=now()
  if v and clock>=v.time and clock-v.time<.5 and v.steps==steps and v.index==self.index and v.browsing==self.browsing and v.view==self.view and v.goals==goals and v.pace==db.pace and v.journey==db.journey then Q.hits=Q.hits+1;return v.rows end
  local rows=visible(self);Q.value={time=clock,steps=steps,index=self.index,browsing=self.browsing,view=self.view,goals=goals,pace=db.pace,journey=db.journey,rows=rows};Q.misses=Q.misses+1;return rows
 end
 for _,pair in ipairs({{N,'Refresh'},{N,'Resync'},{P,'Refresh'},{P,'Done'},{P,'Skip'},{F,'Advance'},{F,'Stop'}})do local owner,key=pair[1],pair[2];local fn=owner[key];if fn then owner[key]=function(...)invalidate();return fn(...)end end end
 local events=CreateFrame('Frame');Q.events=events
 for _,event in ipairs({'QUEST_LOG_UPDATE','QUEST_WATCH_UPDATE','QUEST_ACCEPTED','QUEST_TURNED_IN','BAG_UPDATE_DELAYED','SKILL_LINES_CHANGED','PLAYER_LEVEL_UP','ZONE_CHANGED','ZONE_CHANGED_NEW_AREA','PLAYER_ENTERING_WORLD'})do events:RegisterEvent(event)end
 events:SetScript('OnEvent',invalidate)

end
function K.PinAvailable()return K.Enabled()and K.Mode()=='Compass'end
local flag=K.Flag;K.Flag=function(...)if not K.PinAvailable()then return false end;return flag(...)end
local recipes=N.RefreshRecipes
N.RefreshRecipes=function(...)
 local value=recipes(...)
 for _,b in ipairs(N.root and N.root.recipeRows or{})do if b.compassFlag then b.compassFlag:SetAlpha(K.PinAvailable()and 1 or .45);b.compassFlag:SetScript('OnEnter',function(self)N.ShowInfoTooltip(self,K.PinAvailable()and'Pin / Unpin Recipe Source'or'Only usable with Compass')end)end end
 return value
end
local settings=K.Settings
K.Settings=function(...)local v=settings(...);if N.recordStatus then N.recordStatus:Hide();N.recordStatus:SetText('')end;local d=ns.db;if d and not d.gpsSize99 then d.gpsSize99=true;N.SetArrowSize(55)end;local d=ns.db;if d and not d.gpsSize99 then d.gpsSize99=true;N.SetArrowSize(55)end;return v end
local sync=K.Sync
K.Sync=function(...)local v=sync(...);for _,b in ipairs(N.root and N.root.recipeRows or{})do if b.compassFlag then b.compassFlag:SetAlpha(K.PinAvailable()and 1 or .45)end end;return v end
-- Explicit solid paper base prevents transparent source gutters/backdrop layers obscuring labels.
function R.Fill()
 if not R.body then return end
 local list={};for _,m in ipairs(R.materials)do list[#list+1]=m end;table.sort(list,function(a,b)return a.name<b.name end)
 local rows=math.ceil(#list/5);R.body:SetHeight(math.max(1,rows*100))
 for i,m in ipairs(list)do local b=R.buttons[i]
  if not b then
   b=CreateFrame('Button',nil,R.body);R.buttons[i]=b;b.icon=b:CreateTexture(nil,'ARTWORK');b.icon:SetSize(36,36);b.icon:SetPoint('TOP',b,'TOP',-8,-8)
   b.label=text(b,16);b.label:SetPoint('TOPLEFT',b,'TOPLEFT',3,-50);b.label:SetWidth(112);b.label:SetHeight(42);b.label:SetJustifyH('CENTER');b.label:SetWordWrap(true)
   b.check=CreateFrame('CheckButton',nil,b,'UICheckButtonTemplate');b.check:SetSize(23,23);b.check:SetPoint('TOPRIGHT',b,'TOPRIGHT',-3,-13);b.check:SetScript('OnClick',function()R.ToggleMaterial(b.material)end)
   b.wash=b:CreateTexture(nil,'BACKGROUND');b.wash:SetAllPoints();b.wash:SetColorTexture(.03,.43,.38,.17);b:SetScript('OnClick',function(self)R.ToggleMaterial(self.material)end)
  end
  b.material=m;b:SetSize(120,98);b:ClearAllPoints();b:SetPoint('TOPLEFT',R.body,'TOPLEFT',((i-1)%5)*124,-math.floor((i-1)/5)*100);b.icon:SetTexture(icon(m.id));b.label:SetText(m.id==21071 and'Sagefish Pool'or m.name);b.check:SetChecked(K.selected[m.id]==true);b.wash:SetShown(K.selected[m.id]==true);b:Show()
 end
 for i=#list+1,#R.buttons do R.buttons[i]:Hide()end
 local n=0;for _ in pairs(K.selected)do n=n+1 end;K.count:SetText(n..' Resources Selected')
 if K.resourceBar then K.resourceBar:SetShown(R.body:GetHeight()>K.gridHeight)end
end
function R.Open()
 if not N.root then return end
 if not K.gridMenu then
  if K.resourceMenu then K.resourceMenu:Hide()end
  local f=CreateFrame('Frame',nil,UIParent);K.gridMenu=f;K.resourceMenu=f;R.menu=f;f:SetSize(680,640);f:SetPoint('CENTER',UIParent,'CENTER');N.ApplyWindowLayer(f,'farming');f:EnableMouse(true);f:SetClampedToScreen(true)
  local cards=CreateFrame('Frame',nil,f)
  cards:SetPoint('TOPLEFT',f,'TOPLEFT',23,-55);cards:SetPoint('BOTTOMRIGHT',f,'BOTTOMRIGHT',-23,106)
  cards:SetFrameLevel(f:GetFrameLevel()+12);cards:EnableMouse(true);cards:Hide()
  cards:SetScript('OnShow',function()K.resourceScroll:Hide();R.syncScroll()end)
  cards:SetScript('OnHide',function()if K.resourceScroll then K.resourceScroll:Show();R.syncScroll()end end)
  local options={}
  local function openRoute(choice)
   choice.selectedCard=true
   K.confirmed=choice
   local ok,why=R.StartSelection()
   K.confirmed=nil
   if not ok then K.count:SetText(why or 'Route unavailable.');return end
   cards:Hide()
   K.ShowRouteMap()
  end
  for i=1,3 do
   local card=CreateFrame('Button',nil,cards)
   N.BronzeRectangle(card)
   local highlight=card:CreateTexture(nil,'HIGHLIGHT');highlight:SetAllPoints();highlight:SetColorTexture(.93,.73,.37,.15)

   card.plot=CreateFrame('Frame',nil,card)
   card.plot:SetPoint('TOP',card,'TOP',0,-2)
   card.map=card.plot:CreateTexture(nil,'BACKGROUND');card.map:SetAllPoints()
   local plotFill=card.plot:CreateTexture(nil,'BACKGROUND',nil,-1);plotFill:SetAllPoints();plotFill:SetColorTexture(.29,.20,.12,1)
   card.band=card.plot:CreateTexture(nil,'OVERLAY',nil,-1)
   card.band:SetPoint('BOTTOMLEFT');card.band:SetPoint('BOTTOMRIGHT');card.band:SetColorTexture(0,0,0,.5)
   card.title=text(card.plot,12);card.title:SetPoint('TOP',card.band,'TOP',0,-2)
   card.detail=text(card.plot,9);card.detail:SetPoint('BOTTOM',card.band,'BOTTOM',0,2);card.detail:SetTextColor(.95,.72,.43);card.detail:SetWordWrap(false)
   card.title:SetJustifyH('CENTER');card.title:SetTextColor(.98,.77,.48);card.title:SetWordWrap(false)
   card.lines={}
   card:SetScript('OnClick',function()if card.choice and card.choice.start then openRoute(card.choice)end end)
   options[i]=card
  end
  local function showCards(choices,total)
   cards.choices,cards.total=choices,total
   local width=(f:GetWidth()-66)/3
   for i,card in ipairs(options)do
    local choice=choices[i]
    card.choice=choice
    card:ClearAllPoints();card:SetPoint('TOPLEFT',cards,'TOPLEFT',(i-1)*(width+10),-4)
    local mapWidth=width-4
    local mapHeight=mapWidth*683/1024
    card:SetSize(width,mapHeight+4);card.plot:SetSize(mapWidth,mapHeight)
    card.title:SetWidth(width-12);card.detail:SetWidth(width-12)
    local art=choice and ns.ForeverFacts.maps[choice.reference.zone]
    card.map:SetShown(art~=nil)
    if art then card.map:SetTexture(art.path);card.map:SetTexCoord(0,art.u,0,art.v)end
    local badge=choice and (choice.current and 'Current Zone' or choice.recommendation)
    card.title:SetText(choice and choice.reference.zone or 'No mapped alternative')
    local detail='No mapped route'
    if choice and choice.start then
     local path=choice.reference.mode=='loop' and 'Loop' or #choice.reference.points==1 and 'Camp pin' or 'Open route'
     detail=path..' · '..(choice.reference.targets or (#choice.materials..' / '..total..' resources'))
     if #choice.materials<total then
      local names={}
      for _,m in ipairs(choice.materials)do names[#names+1]=m.name end
      detail=detail..' · '..table.concat(names,', ')
     end
    end
    card.detail:SetText((badge and badge.." · " or "")..detail)
    for _,label in ipairs({card.title,card.detail}) do
     local font,size,flags=label:GetFont()
     local maximum=label==card.title and 12 or 9
     label:SetWidth(0)
     for candidate=maximum,8,-1 do
      label:SetFont(font,candidate,flags)
      if label:GetStringWidth()<=width-12 then break end
     end
     label:SetWidth(width-12)
    end
    card.band:SetHeight((mapHeight+4)*.175)
    card.map:SetAlpha(choice and choice.start and 1 or .65)
    card:EnableMouse(choice and choice.start~=nil or false)
    for _,line in ipairs(card.lines)do line:Hide()end
    local points=choice and choice.reference.points or {}
    local count=choice and choice.reference.mode~='loop' and math.max(0,#points-1) or #points
    if #points==1 then
     if not card.campDot then
      card.campDot=card.plot:CreateTexture(nil,'OVERLAY')
      card.campDot:SetColorTexture(.18,.06,.03,1)
      card.campDot:SetSize(6,6)
     end
     card.campDot:ClearAllPoints()
     card.campDot:SetPoint('CENTER',card.plot,'TOPLEFT',points[1][1]*mapWidth/100,-points[1][2]*mapHeight/100)
     card.campDot:Show()
    elseif card.campDot then card.campDot:Hide() end
    for j=1,count do
     local line=card.lines[j]
     if not line then
      line=card.plot.CreateLine and card.plot:CreateLine(nil,'ARTWORK') or card.plot:CreateTexture(nil,'ARTWORK')
      line:SetColorTexture(.035,.025,.018,.86)
      if line.SetThickness then line:SetThickness(2)end
      card.lines[j]=line
     end
     local a,b=points[j],points[j%#points+1]
     local x,y,u,v=a[1]*mapWidth/100,-a[2]*mapHeight/100,b[1]*mapWidth/100,-b[2]*mapHeight/100
     if line.SetStartPoint then
      line:SetStartPoint('TOPLEFT',card.plot,x,y);line:SetEndPoint('TOPLEFT',card.plot,u,v);line:Show()
     elseif line.SetRotation then
      line:ClearAllPoints();line:SetPoint('CENTER',card.plot,'TOPLEFT',(x+u)/2,(y+v)/2)
      line:SetSize(math.max(1,math.sqrt((u-x)^2+(v-y)^2)),2);line:SetRotation(math.atan2(v-y,u-x));line:Show()
     end
    end
   end
   cards:Show()
  end
  local scope=N.MakeButton(f,'Recommend a Zone',157,function()
   if cards:IsShown()then cards:Hide();return end
   local materials,ranks={},{}
   for _,m in ipairs(R.materials)do
    if K.selected[m.id]then
     materials[#materials+1]=m;ranks[m.id]=m.kind=='Cloth' and 1 or F.Skill(m.kind)
    end
   end
   if #materials==0 then K.count:SetText('Select at least one resource.');return end
   local choices,why=R.RecommendSelection(materials,ranks,'cards')
   if not choices then K.count:SetText(why or 'No mapped zone for this selection.');return end
   showCards(choices,#materials)
   K.count:SetText('Choose a zone card to start its route.')
  end)
  f:HookScript('OnHide',function()cards:Hide();K.confirmed=nil;K.recommended=nil end)
  N.LiveLayout(f,function()
   if cards:IsShown() and cards.choices then showCards(cards.choices,cards.total) end
   R.Fill()
  end)
  K.recommendButton=scope
  scope:SetPoint('BOTTOMLEFT',f,'BOTTOMLEFT',26,26)
  local sf=CreateFrame('ScrollFrame',nil,f);K.resourceScroll=sf;K.gridHeight=450;sf:SetPoint('TOPLEFT',26,-50);sf:SetPoint('BOTTOMRIGHT',-33,105);sf:EnableMouseWheel(true)
  R.body=CreateFrame('Frame',nil,sf);R.body:SetSize(620,1);sf:SetScrollChild(R.body);R.buttons={};R.search=nil
  R.syncScroll=N.PanelScroll(f,sf,function()return sf:GetVerticalScroll()end,function(v)sf:SetVerticalScroll(v)end,
   function()return cards:IsShown() and 0 or math.max(0,R.body:GetHeight()-K.gridHeight)end,85)
  K.count=text(f,16);K.count:SetPoint('TOPLEFT',f,'BOTTOMLEFT',26,94);K.count:SetPoint('TOPRIGHT',f,'BOTTOMRIGHT',-26,94)

  local stop=N.MakeButton(f,'Stop Route',116,function()
   K.confirmed=nil;K.recommended=nil;R.request=nil
   cards:Hide()
   if F.route then F.Stop('Farming route stopped.')end
   K.SyncFooter();R.Fill()
  end);stop:SetPoint('BOTTOMRIGHT',f,'BOTTOMRIGHT',-26,26)
  N.PanelChrome(f,{'Farming','Routes'},490,460,function()R.Fill()end)
 end
 R.menu=K.gridMenu;local h=UIParent:GetHeight();if type(h)=='number'and h>0 then R.menu:SetScale(math.min(1,math.max(.5,(h-32)/640)))end;R.menu:Show();R.Fill()
end
local function clickThrough()
 local r=N.root;if not r then return end
 if N.frame then N.frame:EnableMouse(false)end;r:EnableMouse(false)
 if r.headerDrag and r.wood then r.headerDrag:ClearAllPoints();r.headerDrag:SetAllPoints(r.wood)end
 -- Keep panel surfaces and their children interactive while the transparent header gap passes through.
 for _,p in ipairs(r.panels or{})do p:EnableMouse(true)end
end
local layout=W.Layout
W.Layout=function(...)local v=layout(...);K.Settings();clickThrough();return v end;N.WorkflowLayout=W.Layout
K.Settings();clickThrough()
end)(ADDON,GF)
-- GF_REFINEMENT99_END

-- GF_MAPS99_BEGIN
;(function(...)
local _,ns=...;local N,W,E,U,F,M=ns.NormalUI,ns.WindowWorkflow,ns.SharedExplorer,ns.SharedUI,ns.FarmingPlanner,ns.KnownNodePins
local AS='Interface\\AddOns\\GrindingForever\\Media\\'
local function read(fn,...)if type(fn)=='function'then local ok,a,b,c,d,e,f,g,h,i,j,k,l,m=pcall(fn,...);if ok then return a,b,c,d,e,f,g,h,i,j,k,l,m end end end
local function text(p,size,value)local t=p:CreateFontString(nil,'OVERLAY');t:SetFont('Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf',size);t:SetTextColor(.15,.09,.035);t:SetText(value or'');return t end
local function db()return ns.Forever and ns.Forever.db or GrindingForeverAnniversaryCharacterDB or ns.db end
local V={pins={},boss=nil,class='All Classes'};ns.MapControls99=V
function V.Mode()
 local d=db()
 return d and d.nodeDisplay=='Off' and 'Off' or 'World Map'
end
function V.SetMode(mode)
 if mode~='Off' and mode~='World Map' then return false end
 local d=db();if d then d.nodeDisplay=mode end
 V.map=nil;V.pending=nil
 if mode=='Off' then for _,pin in ipairs(V.pins)do pin:Hide()end end
 return true
end
function V.Cycle()return false end
if M then
 M.Enabled=function()return false end
 M.SetEnabled=function(enabled)return not enabled end
end
function V.DrawRoute(canvas,map)
 local route=F.route
 local steps=route and route.steps
 local pool=V.routeSegments or {}
 V.routeSegments=pool
 if not canvas or not steps or #steps<2 or steps[1].destination.mapID~=map then
  for _,segment in ipairs(pool) do segment:Hide() end
  V.routeLayout=nil
  V.routeReport=nil
  return
 end
 local width,height=canvas:GetWidth(),canvas:GetHeight()
 if width<=0 or height<=0 then return end
 local strata=canvas:GetFrameStrata()
 local layout=V.routeLayout
 if layout and layout.route==route and layout.canvas==canvas and layout.width==width and layout.height==height and layout.strata==strata then return end
 local count=0
 for index=2,#steps do
  local from,to=steps[index-1].destination,steps[index].destination
  if from.mapID==map and to.mapID==map and (from.x~=to.x or from.y~=to.y) then
   count=count+1
   local segment=pool[count]
   if not segment then
    segment=CreateFrame('Frame',nil,canvas)
    if not segment.CreateLine then
     V.routeReport='Native map lines unavailable on this client'
     return
    end
    segment.line=segment:CreateLine(nil,'OVERLAY')
    segment.line:SetTexture('Interface\\Buttons\\WHITE8X8')
    segment.line:SetVertexColor(.12,.055,.018,.85)
    segment.line:SetThickness(4)
    pool[count]=segment
   end
   local x1,y1=from.x*width/100,-from.y*height/100
   local x2,y2=to.x*width/100,-to.y*height/100
   local left,top=math.min(x1,x2)-4,math.max(y1,y2)+4
   segment:SetParent(canvas)
   segment:SetFrameStrata(strata)
   segment:SetFrameLevel(2010)
   segment:ClearAllPoints()
   segment:SetPoint('TOPLEFT',canvas,'TOPLEFT',left,top)
   segment:SetSize(math.abs(x2-x1)+8,math.abs(y2-y1)+8)
   segment.line:SetStartPoint('TOPLEFT',segment,x1-left,y1-top)
   segment.line:SetEndPoint('TOPLEFT',segment,x2-left,y2-top)
   segment.line:Show()
   segment:Show()
  end
 end
 for index=count+1,#pool do pool[index]:Hide() end
 V.routeLayout={route=route,canvas=canvas,width=width,height=height,strata=strata}
 V.routeReport=string.format('Map %d: %d native segments',map,count)
end
function V.UpdateWorld(elapsed)
 V.elapsed=(V.elapsed or 0)+(elapsed or 0);if V.elapsed<.5 then return end;V.elapsed=0
 local frame=WorldMapFrame;local mode=V.Mode()
 local nodesEnabled=mode=='World Map'or mode=='Both'
 local routeEnabled=F.route and F.route.steps and #F.route.steps>1
 local canvas,map
 if frame and frame:IsShown()and(nodesEnabled or routeEnabled)then
  canvas=read(frame.GetCanvas,frame)or(frame.ScrollContainer and(read(frame.ScrollContainer.GetScrollChild,frame.ScrollContainer)or frame.ScrollContainer.Child))or WorldMapDetailFrame
  map=read(frame.GetMapID,frame)
 end
 V.DrawRoute(canvas,map)
 if not nodesEnabled or not canvas or not map then V.pending=nil;for _,p in ipairs(V.pins)do p:Hide()end;return end
 local skills='';for _,kind in ipairs({'Mining','Herbalism','Fishing'})do local rank=F.Skill(kind);skills=skills..kind..':'..tostring(rank or 0)..';'end
 V.age=(V.age or 5)+.5;if V.map==map and V.skills==skills and V.age<5 then return end;V.map,V.skills,V.age=map,skills,0
 F.LoadKnown();local points,seen={},{}
 local function add(kind,x,y,name,item,observed)
  if type(x)~='number'or type(y)~='number'or x<0 or x>100 or y<0 or y>100 then return end
  local key=kind..':'..math.floor(x*100+.5)..':'..math.floor(y*100+.5);if seen[key]then return end;seen[key]=true
  points[#points+1]={x=x,y=y,kind=kind,name=name,item=item,key=key,observed=observed==true}
 end
 local observer=ns.GatheringObserver
 for _,node in pairs(observer and observer.data and observer.data.nodes or{})do
  local p=node.position;local meta=F.meta[node.sourceNodeID]
  if meta and p and p.mapID==map and not node.instanced and((node.sourceMatchedHarvests or 0)>0 or(node.observedClicks or 0)>0)then
   add(meta.kind,p.x,p.y,node.name,meta.item,true)
  end
 end
 for _,kind in ipairs({'Mining','Herbalism','Fishing'})do local skill=F.Skill(kind)
  if skill then
   for coord,id in pairs(F.known[kind]and F.known[kind][map]or{})do local meta=F.meta[id];if meta and(meta.skill or 0)<=skill then local x,y=F.Decode(coord);add(kind,x,y,meta.name or F.names[id],meta.item)end end
  end
 end
 table.sort(points,function(a,b)if a.observed~=b.observed then return a.observed end;return a.key<b.key end)
 V.pending={canvas=canvas,points=points,width=canvas:GetWidth(),height=canvas:GetHeight(),count=math.min(400,#points),cursor=1}
end
function V.RenderBatch()
 local batch=V.pending;if not batch then return end
 if V.Mode()~='Both'and V.Mode()~='World Map'then V.pending=nil;return end
 local canvas,points,width,height,count=batch.canvas,batch.points,batch.width,batch.height,batch.count
 for i=batch.cursor,math.min(count,batch.cursor+19)do local v=points[i];local p=V.pins[i]
  if not p then p=CreateFrame('Button',nil,canvas);p:SetSize(13,13);p.icon=p:CreateTexture(nil,'ARTWORK');p.icon:SetAllPoints();p:SetAlpha(.8);p:SetScript('OnEnter',function(self)if GameTooltip then GameTooltip:SetOwner(self,'ANCHOR_RIGHT');GameTooltip:AddLine(self.node.name or self.node.kind,1,.82,.3);GameTooltip:AddLine('Known gathering location; possible spawn.',.3,.85,.8);GameTooltip:Show()end end);p:SetScript('OnLeave',function()if GameTooltip then GameTooltip:Hide()end end);V.pins[i]=p end
  p:SetParent(canvas);p:SetFrameLevel(canvas:GetFrameLevel()+8);p.node=v;p.icon:SetTexture(read(C_Item and C_Item.GetItemIconByID or GetItemIcon,v.item)or'Interface\\Icons\\Trade_Mining');p:ClearAllPoints();p:SetPoint('CENTER',canvas,'TOPLEFT',v.x*width/100,-v.y*height/100);p:Show()
 end
 batch.cursor=batch.cursor+20;if batch.cursor>count then for i=count+1,#V.pins do V.pins[i]:Hide()end;V.pending=nil end
end
local worker=CreateFrame('Frame');V.worker=worker
worker:SetScript('OnUpdate',function(_,dt)
 local visible=WorldMapFrame and WorldMapFrame:IsShown()
 if not visible then
  if V.wasVisible then V.wasVisible=nil;V.UpdateWorld(.5)end
  return
 end
 V.wasVisible=true
 V.UpdateWorld(dt)
 if V.pending then V.RenderBatch() end
end)
local classes={'All Classes','Warrior','Paladin','Hunter','Rogue','Priest','Shaman','Mage','Warlock','Druid'}
local armor={Warrior={[1]=true,[2]=true,[3]=true,[4]=true,[6]=true},Paladin={[1]=true,[2]=true,[3]=true,[4]=true,[6]=true},Hunter={[1]=true,[2]=true,[3]=true},Rogue={[1]=true,[2]=true},Priest={[1]=true},Shaman={[1]=true,[2]=true,[3]=true,[6]=true},Mage={[1]=true},Warlock={[1]=true},Druid={[1]=true,[2]=true}}
local weapons={Warrior={[0]=true,[1]=true,[2]=true,[3]=true,[4]=true,[5]=true,[6]=true,[7]=true,[8]=true,[10]=true,[13]=true,[15]=true,[16]=true,[18]=true},Paladin={[0]=true,[1]=true,[4]=true,[5]=true,[6]=true,[7]=true,[8]=true},Hunter={[0]=true,[1]=true,[2]=true,[3]=true,[6]=true,[7]=true,[8]=true,[10]=true,[13]=true,[15]=true,[18]=true},Rogue={[2]=true,[3]=true,[4]=true,[7]=true,[13]=true,[15]=true,[16]=true,[18]=true},Priest={[4]=true,[10]=true,[15]=true,[19]=true},Shaman={[0]=true,[1]=true,[4]=true,[5]=true,[10]=true,[13]=true,[15]=true},Mage={[7]=true,[10]=true,[15]=true,[19]=true},Warlock={[7]=true,[10]=true,[15]=true,[19]=true},Druid={[4]=true,[5]=true,[10]=true,[13]=true,[15]=true}}
function V.ClassAllows(id,class)
 if not class or class=='All Classes'then return true end
 local name,_,_,_,_,_,_,_,equip,_,_,itemClass,sub=read(GetItemInfo,id)
 if not name then return true end -- Cache misses remain visible until real item data arrives.
 if itemClass==4 and sub and sub>=1 and sub<=6 and equip~='INVTYPE_CLOAK'then return armor[class]and armor[class][sub]==true end
 if itemClass==2 and sub then return weapons[class]and weapons[class][sub]==true end
 return true -- Shared accessories, recipes and quest items remain visible.
end
local originalSources=N.root and N.root.sourceButton:GetScript('OnClick');local originalProfessions=N.root and N.root.professionButton:GetScript('OnClick')
local function dropdown(anchor,values,callback)
 if V.menu then V.menu:Hide()end
 if not V.menu then V.menu=CreateFrame('Frame',nil,UIParent,'BackdropTemplate');V.menu.buttons={};V.menu:SetBackdrop({bgFile='Interface\\Tooltips\\UI-Tooltip-Background',edgeFile='Interface\\Tooltips\\UI-Tooltip-Border',edgeSize=12});V.menu:SetBackdropColor(.04,.035,.02,1);V.menu:SetClampedToScreen(true);V.menu:SetFrameStrata('TOOLTIP')end
 local f=V.menu;f:SetFrameLevel(N.root:GetFrameLevel()+280);f:ClearAllPoints();f:SetPoint('TOPLEFT',anchor,'BOTTOMLEFT',0,-3);f:SetSize(330,#values*30+12)
 for i,v in ipairs(values)do local b=f.buttons[i];if not b then b=N.MakeButton(f,'',314,function()end);f.buttons[i]=b end;b:SetSize(314,28);b:ClearAllPoints();b:SetPoint('TOPLEFT',f,'TOPLEFT',8,-6-(i-1)*30);b.label:SetText(v.name);b:SetScript('OnClick',function()callback(v);f:Hide()end);b:Show()end
 for i=#values+1,#f.buttons do f.buttons[i]:Hide()end;f:Show()
end
function V.Controls()
 local r=N.root;if not r then return end
 if not V.originalCaptured then originalSources=r.sourceButton:GetScript('OnClick');originalProfessions=r.professionButton:GetScript('OnClick');V.originalCaptured=true end
 if M and M.button then M.button.label:SetText('Nodes: '..V.Mode());M.button:SetScript('OnClick',V.Cycle)end
 if U.pane=='Dungeons'then
  r.sourceButton:Show();r.professionButton:Show();r.sourceButton.label:SetText((V.boss=='Select A Boss'and'Bosses'or V.boss)or'Bosses');r.professionButton.label:SetText(V.class=='All Classes'and'Class'or V.class)
  r.sourceButton:SetScript('OnClick',function()
   local d=E.dungeons[N.selectedZone];local values={{name='All Bosses'}};for _,b in ipairs(d and d.bosses or{})do values[#values+1]={name=b.name}end;if d and d.otherLoot and#d.otherLoot>0 then values[#values+1]={name='Trash/Object'}end
   dropdown(r.sourceButton,values,function(v)V.boss=v.name=='All Bosses'and nil or v.name;N.RefreshRecipes();V.Controls()end)
  end)
  r.professionButton:SetScript('OnClick',function()local values={};for _,v in ipairs(classes)do values[#values+1]={name=v}end;dropdown(r.professionButton,values,function(v)V.class=v.name;N.RefreshRecipes();V.Controls()end)end)
  if N.sourceMenu then N.sourceMenu:Hide()end;if N.professionMenu then N.professionMenu:Hide()end
 else r.sourceButton.label:SetText('Sources');r.professionButton.label:SetText('Professions');r.sourceButton:SetScript('OnClick',originalSources);r.professionButton:SetScript('OnClick',originalProfessions)end
end
local dungeonAreas={
 ['Ragefire Chasm']=2437,['The Deadmines']=1581,['Wailing Caverns']=718,
 ['Shadowfang Keep']=209,['The Stockade']=717,['Blackfathom Deeps']=719,
 Gnomeregan=721,['Razorfen Kraul']=491,['Scarlet Monastery']=796,['Razorfen Downs']=722,
 Uldaman=1337,["Zul'Farrak"]=1176,Maraudon=2100,["The Temple of Atal'Hakkar"]=1477,
 ['Blackrock Depths']=1584,['Lower Blackrock Spire']=1583,['Upper Blackrock Spire']=1583,
 ['Molten Core']=2717,['Blackwing Lair']=2677,['Dire Maul']=2557,Scholomance=2057,
 Stratholme=2017,["Zul'Gurub"]=1977,["Onyxia's Lair"]=2159,
 ["Ruins of Ahn'Qiraj"]=3429,["Ahn'Qiraj"]=3428,Naxxramas=3456,
}
local questsByArea
local function dungeonQuestRows(d,zone)
 if not questsByArea then
  questsByArea={}
  local wanted={}
  for _,area in pairs(dungeonAreas)do wanted[area]=true end
  local data=ns.ForeverQuestData
  for _,quest in pairs(data and data.quests or{})do
   local area=quest.zone_area
   if wanted[area]then
    questsByArea[area]=questsByArea[area]or{}
    table.insert(questsByArea[area],quest)
   end
  end
 end
 local rows,seen={},{}
 local faction=UnitFactionGroup('player')
 local policy=ns.ForeverQuestPlanner
 local function add(q)
  if policy and not policy.AllowsQuest(q.id,faction,q) then return end
  local name=q.title or q.name
  if not name or seen[q.id or name]then return end
  seen[q.id or name]=true
  local detail='Dungeon Quest'
  if q.min_level and q.min_level>0 then detail=detail..' · Requires Level '..q.min_level end
  rows[#rows+1]={id=q.id,name=name,source=detail,quest=true,record=q}
 end
 for _,q in ipairs(d and d.quests or{})do add(q)end
 for _,q in ipairs(questsByArea[dungeonAreas[zone] or dungeonAreas[zone:match("^([^:]+):")]]or{})do add(q)end
 table.sort(rows,function(a,b)return a.name<b.name end)
 return rows
end
ns.DungeonQuestRows=dungeonQuestRows
local refresh=N.RefreshRecipes
N.RefreshRecipes=function(...)
 if U.pane~='Dungeons'then for _,row in ipairs(N.root and N.root.dungeonLootRows or{})do row:Hide()end;local v=refresh(...);V.Controls();return v end
 local r=N.root;if not r or N.resizing then return end
 for _,b in ipairs(r.recipeRows or{})do b:Hide()end;for _,h in ipairs(r.workflowHeaders or{})do h:Hide()end
 local d=E.dungeons[N.selectedZone];if V.zone~=N.selectedZone then V.zone=N.selectedZone;V.boss='Select A Boss' end
 local rows=dungeonQuestRows(d,N.selectedZone);local function add(boss)if not V.boss or V.boss==boss.name then for _,v in ipairs(E.BossLoot(boss))do if V.ClassAllows(v[1],V.class)then rows[#rows+1]={name=v[2],itemID=v[1],source=v[3]or boss.name}end end end end
 for _,boss in ipairs(d and d.bosses or{})do add(boss)end;if d and d.otherLoot then add({name='Trash/Object',loot=d.otherLoot})end
 r.recipesText:SetText(V.boss=='Select A Boss'and'Dungeon Quests | Select A Boss For Loot'or'Dungeon Quests & Loot');N.visibleRecipes=rows;r.dungeonLootRows=r.dungeonLootRows or{};local width=math.max(100,r.recipeScroll:GetWidth()-24);r.recipeContent:SetWidth(width);local y=0
 for i,v in ipairs(rows)do local b=r.dungeonLootRows[i]
  if not b then b=CreateFrame('Button',nil,r.recipeContent);b.icon=b:CreateTexture(nil,'ARTWORK');b.icon:SetSize(26,26);b.icon:SetPoint('TOPLEFT',2,-5);b.label=text(b,17);b.label:SetPoint('TOPLEFT',36,-4);b.detail=text(b,13);r.dungeonLootRows[i]=b end
  b.record=v;b:ClearAllPoints();b:SetPoint('TOPLEFT',r.recipeContent,'TOPLEFT',0,-y);b:SetWidth(width);b.label:SetWidth(width-40);b.label:SetHeight(0);b.label:SetWordWrap(true);b.label:SetText(v.name);b.detail:ClearAllPoints();b.detail:SetPoint('TOPLEFT',b.label,'BOTTOMLEFT',0,-3);b.detail:SetWidth(width-40);b.detail:SetText(v.source);b.icon:SetTexture(v.quest and 'Interface\\GossipFrame\\AvailableQuestIcon' or read(GetItemIcon,v.itemID));local h=math.max(52,b.label:GetStringHeight()+b.detail:GetStringHeight()+14);b:SetHeight(h);b:SetScript('OnEnter',function(self)if self.record.itemID then W.Tooltip(self,self.record.itemID)end end);b:SetScript('OnLeave',function()if W.tooltip then W.tooltip:Hide()end end);b:Show();y=y+h
 end
 for i=#rows+1,#r.dungeonLootRows do r.dungeonLootRows[i]:Hide()end;r.recipeContent:SetHeight(math.max(1,y));r.recipeScroll:SetVerticalScroll(0);N.UpdateMapView();W.ScrollState();V.Controls()
end
local layout=W.Layout
W.Layout=function(...)local v=layout(...);if U.pane~='Dungeons'then for _,b in ipairs(N.root and N.root.dungeonLootRows or{})do b:Hide()end end;V.Controls();return v end;N.WorkflowLayout=W.Layout
V.Controls()
end)(ADDON,GF)
-- GF_MAPS99_END

-- GF_REFINEMENT100_BEGIN
;(function(...)
local _,ns=...;local N,W,E,U,K,R,F,V,M,G=ns.NormalUI,ns.WindowWorkflow,ns.SharedExplorer,ns.SharedUI,ns.NavigationCompass,ns.MaterialRoutes,ns.FarmingPlanner,ns.MapControls99,ns.KnownNodePins,ns.GatheringObserver
local AS='Interface\\AddOns\\GrindingForever\\Media\\'
local function read(f,...)if type(f)=='function'then local ok,a,b,c,d,e=pcall(f,...);if ok then return a,b,c,d,e end end end
local function clock()return read(GetTime)or 0 end
local function position()local c=ns.Retail and ns.Retail.Client;local p=c and c.PlayerPosition();if p and p.status=='available'then return p end end
local function dist(d,p)if not d or not p or d.mapID~=p.mapID then return end;local c=ns.Retail.Client;local a,x,y=c.WorldPosition(d.mapID,d.x,d.y);local b,xx,yy=c.WorldPosition(p.mapID,p.x*100,p.y*100);if a and a==b and x and y and xx and yy then return math.sqrt((x-xx)^2+(y-yy)^2),math.atan2(y-yy,x-xx)end end
-- Reuse historical pin rendering, fading only GF icons near the player.
if M then local update=M.Update;M.Update=function(...)local v=update(...);local now=clock();if M.fade100 and now-M.fade100<.25 then return v end;M.fade100=now;local p=position();if p then for _,pin in ipairs(M.pins)do if pin:IsShown()and pin.node then local d=dist({mapID=p.mapID,x=pin.node.x,y=pin.node.y},p);if d then pin:SetAlpha(.12+.60*math.max(0,math.min(1,(d-12)/65)))end end end end;return v end end
-- Compact grouped grids with GF's own checkbox art and labels directly below icons.
R.collapsed100=R.collapsed100 or{};local category={{'Mining','Mining'},{'Herbalism','Herbalism'},{'Skinning','Skinning'},{'Fishing','Fishing'},{'Cloth','Cloth'}}
local clothMobFloor={[2589]=5,[2592]=15,[4306]=25,[4338]=37,[14047]=48,[14256]=50}
local function canGather(m)
 if m.kind=='Cloth' then return (read(UnitLevel,'player') or 1)+5 >= (clothMobFloor[m.id] or 1) end
 local rank=F.Skill(m.kind)
 return rank~=nil and rank >= (m.skill or 1)
end
local toggleMaterial=R.ToggleMaterial
function R.ToggleMaterial(m)
 if not m or (not K.selected[m.id] and not canGather(m))then return end
 K.confirmed=nil;K.recommended=nil
 if K.recommendButton then K.recommendButton.label:SetText('Recommend a Zone')end
 toggleMaterial(m)
end
function R.Fill()
 if not R.body then return end;if not R.grid100 then for _,b in ipairs(R.buttons or{})do b:Hide()end;R.buttons={};R.grid100=true end;R.headers100=R.headers100 or{};local y,index=0,0
 K.gridHeight=math.max(1,R.menu:GetHeight()-155)
 R.body:SetWidth(math.max(1,R.menu:GetWidth()-59))
 local columns=math.max(1,math.floor(R.body:GetWidth()/66))
 local clothOrder={[2589]=1,[2592]=2,[4306]=3,[4338]=4,[14047]=5,[14256]=6}
 for _,cat in ipairs(category)do local title,kind=cat[1],cat[2];local list={};for _,m in ipairs(R.materials)do if m.kind==kind then list[#list+1]=m end end;table.sort(list,function(a,b)local ar,br=clothOrder[a.id] or a.skill or 0,clothOrder[b.id] or b.skill or 0;if ar~=br then return ar<br end;return a.name<b.name end)
  local h=R.headers100[title];if not h then h=CreateFrame('Button',nil,R.body);h.label=h:CreateFontString(nil,'OVERLAY');h.label:SetFont('Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf',18);h.label:SetTextColor(.16,.09,.03);h.label:SetPoint('LEFT',24,0);h.arrow=h:CreateTexture(nil,'ARTWORK');h.arrow:SetTexture(AS..'ControlTriangleRight');h.arrow:SetSize(12,12);h.arrow:SetPoint('LEFT',4,0);h:SetScript('OnClick',function()R.collapsed100[title]=not R.collapsed100[title];R.Fill()end);R.headers100[title]=h end
  h:ClearAllPoints();h:SetPoint('TOPLEFT',R.body,'TOPLEFT',0,-y);h:SetSize(R.body:GetWidth(),30);h.label:SetText(title);h.arrow:SetRotation(R.collapsed100[title]and 0 or-math.pi/2);h:Show();y=y+34
  if not R.collapsed100[title]then for j,m in ipairs(list)do index=index+1;local b=R.buttons[index]
   if not b then b=CreateFrame('Button',nil,R.body);b.icon=b:CreateTexture(nil,'ARTWORK');b.label=b:CreateFontString(nil,'OVERLAY');b.label:SetFont('Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf',12);b.label:SetTextColor(.16,.09,.03);b.check=CreateFrame('Button',nil,b);b.box=b.check:CreateTexture(nil,'ARTWORK');b.box:SetAllPoints();b.box:SetTexture(AS..'ControlButtonNormal');b.tick=b.check:CreateTexture(nil,'OVERLAY');b.tick:SetAllPoints();b.tick:SetTexture('Interface\\Buttons\\UI-CheckBox-Check');b.wash=b:CreateTexture(nil,'BACKGROUND');b.wash:SetAllPoints();b.wash:SetColorTexture(.03,.43,.38,.15);R.buttons[index]=b end
   b.material=m;b:ClearAllPoints();b:SetPoint('TOPLEFT',R.body,'TOPLEFT',((j-1)%columns)*66,-y-math.floor((j-1)/columns)*61);b:SetSize(64,61);b.icon:ClearAllPoints();b.icon:SetSize(32,32);b.icon:SetPoint('TOP',b,'TOP',0,-3);b.icon:SetTexture(read(C_Item and C_Item.GetItemIconByID or GetItemIcon,m.id));b.label:ClearAllPoints();b.label:SetPoint('TOPLEFT',b,'TOPLEFT',1,-37);b.label:SetWidth(62);b.label:SetHeight(24);b.label:SetJustifyH('CENTER');b.label:SetWordWrap(true);b.label:SetText(m.id==21071 and'Sagefish Pool'or m.name);b.check:ClearAllPoints();b.check:SetSize(13,13);b.check:SetPoint('BOTTOMRIGHT',b.icon,'BOTTOMRIGHT',1,-1);b.check:SetScript('OnClick',function()R.ToggleMaterial(b.material)end);b:SetScript('OnClick',function()R.ToggleMaterial(b.material)end);if b.check.SetChecked then b.check:SetChecked(K.selected[m.id]==true)end;if b.tick then b.tick:SetShown(K.selected[m.id]==true)end;b.wash:SetShown(K.selected[m.id]==true);b:SetAlpha(canGather(m) and 1 or .35);b:Show()
  end;y=y+math.ceil(#list/columns)*61 end
 end
 for i=index+1,#R.buttons do R.buttons[i]:Hide()end;R.body:SetHeight(math.max(1,y));local n=0;for _ in pairs(K.selected)do n=n+1 end;K.count:SetText(n..' Resources Selected');if K.resourceBar then K.resourceBar:SetShown(y>K.gridHeight)end
 local scroll=K.resourceScroll
 if scroll then scroll:SetVerticalScroll(math.min(scroll:GetVerticalScroll()or 0,math.max(0,y-K.gridHeight)))end
 if R.syncScroll then R.syncScroll()end
end
-- Automatically track the single selected recipe source; clicking again clears it.
local refresh=N.RefreshRecipes
N.RefreshRecipes=function(...)
 local v=refresh(...);if U.pane~='Dungeons'then for _,b in ipairs(N.root and N.root.recipeRows or{})do
  if b.compassFlag then b.compassFlag:Hide()end
  if b:IsShown()and b.record then local old=b:GetScript('OnClick');local record=b.record;local key=record.workflowKey or record.id or record.spellID or record.name
   b:SetScript('OnClick',function(self,...)
    if W.recipeSelection100==key and K.recipePin then W.recipeSelection100=nil;W.activeSource=nil;W.expandedRecipe=nil;W.selection=nil;W.mapLocation=nil;N.selectedRecipe=nil;K.Unpin(K.recipePin);N.RefreshRecipes();N.UpdateMapView();return end
    W.recipeSelection100=key;K.Unpin(K.recipePin);W.sourceSelection100=true;if old then old(self,...)end;W.sourceSelection100=nil
    local loc=record.location or record.locations and record.locations[1];if loc and loc.mapID and loc.x and loc.y then local id=K.FlagKey(record,loc);K.recipePin=id;K.pins[id]={key=id,name=loc.name or record.name,zone=loc.zone,location=loc,icon=AS..'RecipePin',pin=true};K.age=1 end
   end)
  end
 end end;return v
end
-- Verified personal harvest observations: approximate player positions, not exact spawn promises.
local loadKnown=F.LoadKnown
F.LoadKnown=function(...)local v=loadKnown(...);if not F.observed100 then F.observed100=true;F.known.Mining=F.known.Mining or{};local map=F.known.Mining[1429]or{};F.known.Mining[1429]=map;for _,p in ipairs({{40.0454,81.0809},{39.8572,79.0486},{38.9609,78.4250},{51.5584,83.7321},{50.3895,73.9230},{30.0037,60.1651},{28.0510,66.0204},{25.3579,69.1687},{25.4806,66.6410}})do map[math.floor(p[1]*100+.5)*1000000+math.floor(p[2]*100+.5)*100]=201 end end;return v end
-- Native class relic restrictions, with client-specific polearm proficiency.
local classAllows=V.ClassAllows
local allowedCache={}
local function explicitClass(id,class)
 if allowedCache[id]~=nil then return allowedCache[id]==false or allowedCache[id][class]==true end
 if not read(GetItemInfo,id)then return true end
 if not V.classScanner100 then V.classScanner100=CreateFrame('GameTooltip','GFClassRestriction100',UIParent,'GameTooltipTemplate')end
 local tip=V.classScanner100;if type(tip.SetOwner)~='function'or type(tip.ClearLines)~='function'or type(tip.SetHyperlink)~='function'then return true end;local ok=pcall(function()tip:SetOwner(UIParent,'ANCHOR_NONE');tip:ClearLines();tip:SetHyperlink('item:'..id)end);if not ok then return true end
 local n=read(tip.NumLines,tip);if type(n)~='number'or n<1 then return true end
 local template=ITEM_CLASSES_ALLOWED or'Classes: %s';local prefix=template:match('^(.-)%%s')or'Classes: '
 for i=1,n do local line=_G['GFClassRestriction100TextLeft'..i];local text=line and read(line.GetText,line);if text and text:sub(1,#prefix)==prefix then local set={};for _,name in ipairs({'Warrior','Paladin','Hunter','Rogue','Priest','Shaman','Mage','Warlock','Druid','Death Knight'})do local localized=LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[name:upper():gsub(' ','')]or name;if text:find(localized,1,true)then set[name]=true end end;allowedCache[id]=set;tip:Hide();return set[class]==true end end
 allowedCache[id]=false;tip:Hide();return true
end
V.ClassAllows=function(id,class)
 if class and class~='All Classes'and not explicitClass(id,class)then return false end
 local _,_,_,_,_,_,_,_,_,_,_,itemClass,sub=GetItemInfo(id)
 if class and class~='All Classes'and itemClass==4 and sub and sub>=7 and sub<=10 then return({[7]='Paladin',[8]='Druid',[9]='Shaman',[10]='Death Knight'})[sub]==class end
 if class=='Druid'and itemClass==2 and sub==6 then return ns.Forever~=nil end
 return classAllows(id,class)
end
-- A separate nearby resource marker never takes ownership of the loop.
local L=ns.BlendedProfessions
if L then local make=L.Make;L.Make=function(name,skill,ctx)
 local node=make(name,skill,ctx)
 if node and(node.title or''):match('^Review .+ recipes')then local yards=node.destination and E.Distance(ctx.pos,node.destination);if type(yards)~='number'or yards>100 then return nil end end
 if node and node.craftReady and name=='Blacksmithing'then local trainer=L.Trainer(name,ctx.pos);local yards=trainer and E.Distance(ctx.pos,trainer);if type(yards)~='number'or yards>100 then return nil end end
 return node
end end
-- A generic merchant is not proof of access to a blacksmith workbench.
local S,H=ns.CraftingSessions,ns.ProfessionTaskFocus
if S then local at=S.AtService;S.AtService=function(name,ctx)if name=='Blacksmithing'then local t=L.Trainer(name,ctx and ctx.pos);local d=t and ctx and E.Distance(ctx.pos,t);return type(d)=='number'and d<=100 and not ctx.unsafe end;return at(name,ctx)end end
if H then local valid=H.Valid;H.Valid=function()local n=H.node;if n and(n.title or''):match('^Review .+ recipes')then local ctx=L.Context();local d=n.destination and E.Distance(ctx.pos,n.destination);if type(d)~='number'or d>100 then H.Release('recipe review waits for profession service stop');return false end end;return valid()end end
-- Count-only progress uses the light path; changed quest stages still rebuild.
local Q=ns.RefreshScheduler
if Q then
 local process=Q.Process
 local function stages()
  local api=C_QuestLog or{};local total=read(api.GetNumQuestLogEntries or GetNumQuestLogEntries);if type(total)~='number'then return end;local rows={}
  for i=1,total do
   local info=read(api.GetInfo,i)
   if not info and type(GetQuestLogTitle)=='function'then local _,_,_,header,collapsed,complete,_,id=GetQuestLogTitle(i);info={isHeader=header,isCollapsed=collapsed,isComplete=complete,questID=id}end
   if not info or info.isHeader and info.isCollapsed then return end
   if not info.isHeader then
    if not info.questID then return end;local row={tostring(info.questID),tostring(info.isComplete)};local goals=read(api.GetQuestObjectives,info.questID)
    if type(goals)=='table'then for _,g in ipairs(goals)do row[#row+1]=tostring(g.finished)..':'..tostring(g.numRequired)end
    elseif type(GetNumQuestLeaderBoards)=='function'and type(GetQuestLogLeaderBoard)=='function'then for j=1,GetNumQuestLeaderBoards(i)do local text,kind,finished=GetQuestLogLeaderBoard(j,i);row[#row+1]=tostring(kind)..':'..tostring(finished)end
    else return end
    rows[#rows+1]=table.concat(row,'|')
   end
  end;table.sort(rows);return table.concat(rows,';')
 end
 Q.Process=function(...)if Q.pending then local signature=stages();if signature and Q.stage100==signature and Q.questDirty and not Q.full then Q.questDirty=false;Q.progress=true end;Q.stage100=signature end;return process(...)end
end
local collect=K.Collect
K.Collect=function(...)
 collect(...);local route=F.route;local p=position();if not p then return end
 local current=N.model and N.model:Current();if not route and current and current.adaptiveVendor then local d=read(ns.ProfessionGuide.Destination);local yards,bearing=dist(d,p);if yards and yards>8 then local seen=false;for _,v in ipairs(K.targets)do if v.active then seen=true end end;if not seen then table.insert(K.targets,1,{key='active',name=d.name or'Vendor',zone=d.zone,location=d,icon='Interface\\Icons\\INV_Misc_Coin_01',active=true,distance=yards,bearing=bearing})end end end
end
local D={};ns.Review100=D
function D.Menu(anchor,values,callback)
 if V.menu then V.menu:Hide()end
 if not D.menu then local f=CreateFrame('Frame',nil,UIParent,'BackdropTemplate');D.menu=f;f:SetBackdrop({bgFile='Interface\\Tooltips\\UI-Tooltip-Background',edgeFile='Interface\\Tooltips\\UI-Tooltip-Border',edgeSize=10});f:SetBackdropColor(.025,.02,.01,1);f:SetFrameStrata('TOOLTIP');f:SetClampedToScreen(true);f.buttons={};local scroll=CreateFrame('ScrollFrame',nil,f);f.scroll=scroll;scroll:SetPoint('TOPLEFT',6,-6);scroll:SetPoint('BOTTOMRIGHT',-6,6);scroll:SetClipsChildren(true);scroll:EnableMouseWheel(true);f.body=CreateFrame('Frame',nil,scroll);scroll:SetScrollChild(f.body);scroll:SetScript('OnMouseWheel',function(_,d)scroll:SetVerticalScroll(math.max(0,math.min(math.max(0,f.body:GetHeight()-scroll:GetHeight()),(scroll:GetVerticalScroll()or 0)-d*27)))end)end
 local f=D.menu;local scale=read(N.root.GetEffectiveScale,N.root)or read(N.root.GetScale,N.root)or 1;local parent=read(UIParent.GetEffectiveScale,UIParent)or 1;f:SetScale(scale/parent);f:SetFrameLevel(N.root:GetFrameLevel()+350);f:ClearAllPoints();f:SetPoint('TOPLEFT',anchor,'BOTTOMLEFT',0,-2);local width=math.max(180,anchor:GetWidth());f:SetSize(width,math.min(290,#values*27+12));f.body:SetSize(width-12,math.max(1,#values*27));f.scroll:SetVerticalScroll(0)
 for i,row in ipairs(values)do local b=f.buttons[i];if not b then b=CreateFrame('Button',nil,f.body);b.label=b:CreateFontString(nil,'OVERLAY');b.label:SetFont('Interface\\AddOns\\GrindingForever\\Media\\Naowh.ttf',17);b.label:SetTextColor(.94,.78,.42);b.label:SetPoint('LEFT',8,0);b.label:SetPoint('RIGHT',-8,0);b.label:SetJustifyH('LEFT');b.highlight=b:CreateTexture(nil,'BACKGROUND');b.highlight:SetAllPoints();b.highlight:SetColorTexture(.45,.36,.16,.4);b:SetScript('OnEnter',function(self)self.highlight:Show()end);b:SetScript('OnLeave',function(self)self.highlight:SetShown(self.selected)end);f.buttons[i]=b end;b:ClearAllPoints();b:SetPoint('TOPLEFT',f.body,'TOPLEFT',0,-(i-1)*27);b:SetSize(width-12,27);b.label:SetText(row.name);b.selected=row.selected;b.highlight:SetShown(row.selected==true);b:SetScript('OnClick',function()f:Hide();callback(row)end);b:Show()end
 for i=#values+1,#f.buttons do f.buttons[i]:Hide()end;f:Show();V.menu=f
end
local raids={'molten','onyxia','blackwing','ahnqiraj','zulaman','zulgurub','karazhan','gruul','magtheridon','serpentshrine','tempestkeeptempestkeep','theeye','hyjal','blacktemple','sunwell','barrowdeeps','naxxramas'}
local function norm(name)return(name or''):lower():gsub('[%p%s]','')end
function D.Category(name)
 local n=norm(name);if n:find('warsong')or n:find('arathibasin')or n:find('alteracvalley')or n:find('eyeofthestorm')or n:find('championshall')or n:find('halloflegends')then return'PvP'end
 for _,raid in ipairs(raids)do if n:find(raid,1,true)then return'Raids'end end;local instance=E.dungeons[name];if not instance then for key in pairs(E.dungeons)do if norm(key)==n then instance=true;break end end end;if instance or n:find('barrowdeeps')or n:find('hyjalsummit')then for _,s in ipairs(raids)do if n:find(s,1,true)then return'Raids'end end;return'Dungeons'end
end
local catalog=W.CatalogRows;local sources=W.SourceRows
W.CatalogRows=function(query)if W.aggregate100 and not query then local rows={};for _,r in ipairs(N.recipeRecords or{})do if E.Known(r)~=true then rows[#rows+1]=r end end;return rows end;return catalog(query)end
W.SourceRows=function(records,query)local agg=W.aggregate100;if not agg or query then return sources(records,query)end;local rows={};for _,r in ipairs(sources(records,true))do local loc=r.location or r.locations and r.locations[1];if loc and D.Category(loc.zone)==agg then rows[#rows+1]=r end end;return rows end
local zone=N.SetZone
N.SetZone=function(name,...)
 if name=='Dungeons'or name=='Raids'or name=='PvP'then W.aggregate100=name;N.selectedZone=name;N.root.zoneButton.label:SetText(name);N.RefreshRecipes();N.UpdateMapView();return true end
 if not W.sourceSelection100 then W.aggregate100=nil end;return zone(name,...)
end
local controls=V.Controls
V.Controls=function(...)
 controls(...);local r=N.root;if not r then return end;if U.pane~='Dungeons'and W.aggregate100 then r.zoneButton.label:SetText(W.aggregate100)end
 r.zoneButton:SetScript('OnClick',function()if D.menu and D.menu:IsShown()then D.menu:Hide();return end;local values={};if U.pane=='Dungeons'then for name in pairs(E.dungeons)do values[#values+1]={name=name}end else for name in pairs(N.mapCatalog or{})do if not D.Category(name)then values[#values+1]={name=name}end end;for _,name in ipairs({'Dungeons','Raids','PvP'})do values[#values+1]={name=name}end end;table.sort(values,function(a,b)return a.name<b.name end);D.Menu(r.zoneButton,values,function(v)N.SetZone(v.name)end)end)
 if U.pane=='Dungeons'then
  r.sourceButton.label:SetText(V.boss=='Select A Boss'and'Bosses'or V.boss or'Bosses')
  r.sourceButton:SetScript('OnClick',function()local d=E.dungeons[N.selectedZone];local values={};for _,boss in ipairs(d and d.bosses or{})do values[#values+1]={name=boss.name,selected=V.boss==boss.name}end;if d and d.otherLoot and#d.otherLoot>0 then values[#values+1]={name='Trash/Object'}end;D.Menu(r.sourceButton,values,function(v)V.boss=v.name;N.RefreshRecipes()end)end)
  r.professionButton:SetScript('OnClick',function()local values={};for _,name in ipairs({'All Classes','Warrior','Paladin','Hunter','Rogue','Priest','Shaman','Mage','Warlock','Druid'})do values[#values+1]={name=name,selected=V.class==name}end;D.Menu(r.professionButton,values,function(v)V.class=v.name;N.RefreshRecipes()end)end)
 end
end
for _,d in pairs(E.dungeons)do for _,boss in ipairs(d.bosses or{})do if boss.name=='Mutanus the Devourer'then local found=false;for _,v in ipairs(boss.loot or{})do if v.itemID==10441 then v.questID=6981;found=true end end;if not found then boss.loot[#boss.loot+1]={itemID=10441,questID=6981,sourceName=boss.name}end end end end
V.Controls()
end)(ADDON,GF)
-- GF_REFINEMENT100_END

-- GF_MENU_INPUT101_BEGIN
;(function(...)
local _,ns=...;local D,N=ns.Review100,ns.NormalUI
if not D then return end
local show=D.Menu
function D.Menu(anchor,values,callback)
 show(anchor,values,callback)
 local f=D.menu;if not f then return end
 f:EnableMouse(true);f:SetToplevel(true);f:SetFrameStrata('TOOLTIP');f:SetFrameLevel(N.root:GetFrameLevel()+400)
 if f.scroll then f.scroll:SetFrameStrata('TOOLTIP');f.scroll:SetFrameLevel(f:GetFrameLevel()+1);f.scroll:EnableMouse(true);f.scroll:EnableMouseWheel(true)end
 if f.body then f.body:SetFrameStrata('TOOLTIP');f.body:SetFrameLevel(f:GetFrameLevel()+2);f.body:EnableMouse(false)end
 for _,button in ipairs(f.buttons or{})do button:SetFrameStrata('TOOLTIP');button:SetFrameLevel(f:GetFrameLevel()+3);button:EnableMouse(true);button:RegisterForClicks('LeftButtonUp');if button.Enable then button:Enable()end end
 if f.Raise then f:Raise()end
 if C_Timer and C_Timer.After then C_Timer.After(0,function()if f:IsShown()and f.Raise then f:Raise()end end)end
end
end)(ADDON,GF)
-- GF_MENU_INPUT101_END

-- GF_BUNDLED_MAPS102_BEGIN

;(function(...)
local _,ns=...;local N=ns.NormalUI;local E=ns.SharedExplorer or ns.Forever;local U=ns.SharedUI or ns.ForeverUI
if not N or not E or not U then return end
local maps={["Ragefire Chasm"]={{["legacyLandmarks"]=false,["file"]="BlizzardRagefire.tga",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["The Deadmines"]={{["file"]="291.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="292.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Wailing Caverns"]={{["file"]="ClassicWailingCaverns.tga",["u0"]=0,["v0"]=0,["u1"]=0.978515625,["v1"]=0.65234375,["aspect"]=1.5}},["Shadowfang Keep"]={{["file"]="310.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="316.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="315.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["The Stockade"]={{["file"]="225.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.654296875,["aspect"]=1.528358208955224}},["Blackfathom Deeps"]={{["file"]="221.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="222.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="223.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Gnomeregan"]={{["file"]="226.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="227.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="228.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="229.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Razorfen Kraul"]={{["file"]="301.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Scarlet Monastery"]={{["file"]="302.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="303.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="304.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="305.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Razorfen Downs"]={{["file"]="300.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Uldaman"]={{["file"]="230.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="231.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Zul'Farrak"]={{["file"]="219.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Maraudon"]={{["file"]="280.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="281.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["The Temple of Atal'Hakkar"]={{["file"]="AtlasSunken1.tga",["u0"]=0,["v0"]=0,["u1"]=0.513671875,["v1"]=0.6806640625,["aspect"]=0.7546628407460545},{["file"]="AtlasSunken2.tga",["u0"]=0,["v0"]=0,["u1"]=0.9873046875,["v1"]=0.9345703125,["aspect"]=1.0564263322884013},{["file"]="AtlasSunken3.tga",["u0"]=0,["v0"]=0,["u1"]=0.669921875,["v1"]=0.837890625,["aspect"]=0.7995337995337995}},["Blackrock Depths"]={{["file"]="242.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="243.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Lower Blackrock Spire"]={{["file"]="250.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="251.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="252.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="253.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="254.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="255.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Upper Blackrock Spire"]={{["file"]="250.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="251.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="252.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="253.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="254.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="255.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Molten Core"]={{["file"]="232.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Blackwing Lair"]={{["file"]="287.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="288.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="289.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="290.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Dire Maul"]={{["file"]="234.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="235.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="236.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="237.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="238.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="239.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="240.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Scholomance"]={{["file"]="306.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="307.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="308.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="309.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Stratholme"]={{["file"]="317.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="318.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Zul'Gurub"]={{["file"]="233.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Onyxia's Lair"]={{["file"]="248.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Ruins of Ahn'Qiraj"]={{["file"]="247.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Ahn'Qiraj"]={{["file"]="319.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="320.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="321.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Naxxramas"]={{["file"]="166.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="162.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="163.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="164.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="165.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331},{["file"]="167.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Ruins of Lordaeron"]={{["file"]="2999.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Hall of Thanes"]={{["file"]="3065.blp",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Excavation Site: Wetlands"]={{["file"]="cb7b0553-92ce-471d-a208-76fc7d080e66.tga",["u0"]=0.00732421875,["u1"]=0.63037109375,["v0"]=0.00732421875,["v1"]=0.42333984375,["aspect"]=1.4976525821596245}},["City of Dalaran"]={{["file"]="4ea62afb-de93-4c9d-b051-834461d56c75.tga",["u0"]=0.0146484375,["u1"]=0.6376953125,["v0"]=0.01416015625,["v1"]=0.43017578125,["aspect"]=1.4976525821596245},{["file"]="29df9463-6295-4e49-9751-de8b833f2436.tga",["u0"]=0.0107421875,["u1"]=0.6337890625,["v0"]=0.01611328125,["v1"]=0.43505859375,["aspect"]=1.4871794871794872}},["The Drowned City"]={{["file"]="SantiagoDrownedCity.tga",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Krol'dok Stronghold"]={{["file"]="SantiagoKroldok.tga",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["Alcaz Prison"]={{["file"]="SantiagoAlcaz.tga",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}},["The Shaper's Terrace"]={{["file"]="SantiagoShapers.tga",["u0"]=0,["u1"]=1,["v0"]=0,["v1"]=0.6669921875,["aspect"]=1.499267935578331}}};ns.BundledDungeonMaps=maps
local function key(name)return(name or''):lower():gsub('[^%w]',''):gsub('^the','')end
local lookup={};for name,floors in pairs(maps)do lookup[key(name)]=floors end
lookup[key('Temple of Ahn Qiraj')]=maps["Ahn'Qiraj"];lookup[key('Hall of the Thanes')]=maps['Hall of Thanes'];lookup[key('Sunken Temple')]=maps["The Temple of Atal'Hakkar"];lookup[key('Blackrock Spire')]=maps['Lower Blackrock Spire']
local function attach()
 E.dungeons=E.dungeons or{}
 for name,d in pairs(E.dungeons or{})do local f=lookup[key(name)]or lookup[key(d.name)]
  if f then
   d.journalMap = d.journalMap or (d.sourceData and d.map)
   local map = {}
   for field, value in pairs(d.map or {}) do map[field] = value end
   map.floors = f
   d.gfMaps, d.map, d.floors = f, map, f
  end
 end
 for name in pairs(maps)do
  if not E.dungeons[name]then E.dungeons[name]={name=name,key=key(name),bosses={},quests={},map={bosses={}},referenceMap=true}end
  local d=E.dungeons[name];d.gfMaps=maps[name];d.map=d.map or{};d.map.floors=maps[name];d.floors=maps[name]
  local catalog=N.mapCatalog or(ns.ForeverData and ns.ForeverData.zones);if catalog then catalog[name]=catalog[name]or{name=name,instance=true}end
 end
end
attach()
local function floor() if U.pane~='Dungeons' then return end;local d=E.dungeons[N.selectedZone];local floors=lookup[key(N.selectedZone)]or(d and(d.gfMaps or lookup[key(d.name)]));return floors and(floors[U.floor or 1]or floors[1]),floors end
local aspect=N.MapAspect
if aspect then N.MapAspect=function(...)local f=floor();if f then return f.aspect end;return aspect(...)end end
-- Forever's projection reads its floor.aspect directly.
local render=ns.RenderForeverMap
local function draw(a,root)
 local f,floors=floor();local t=root.gfDungeonTexture
 if not f then if t then t:Hide()end;return render(a,root)end
 for _,set in ipairs({root.instanceTiles or{},root.mapViewport.foreverTiles or{}})do for _,v in ipairs(set)do v:Hide()end end
 root.mapImage:Hide();root.mapLabel:Hide();if root.recipePin then root.recipePin:Hide()end
 for _,pin in ipairs(root.bossPins or{})do pin:Hide()end
 if not t then t=root.mapViewport:CreateTexture(nil,'BACKGROUND');root.gfDungeonTexture=t end
 local x,y=N.MapToViewport(0,0);local r,b=N.MapToViewport(1,1);local v=root.mapViewport
 t:ClearAllPoints();t:SetPoint('TOPLEFT',v,'TOPLEFT',x*v:GetWidth(),-y*v:GetHeight());t:SetSize((r-x)*v:GetWidth(),(b-y)*v:GetHeight())
 t:SetTexture('Interface\\AddOns\\GrindingForever\\Media\\DungeonMap'..f.file);t:SetTexCoord(f.u0,f.u1,f.v0,f.v1);t:Show()
 if root.floorButton then root.floorButton:SetShown(#floors>1);root.floorButton.label:SetText('Floor '..tostring(U.floor or 1))end;return true
end
ns.RenderForeverMap=draw
for _,method in ipairs({'BuildInstances','LoadDungeonCatalog'})do if E[method]then local old=E[method];E[method]=function(...)local result=old(...);attach();return result end end end
end)(...)

-- GF_BUNDLED_MAPS102_END


-- Opt-in actions after the player opens quest dialogue or a flight map.
;(function(...)
local _,ns=...
local E,P=ns.Forever,ns.ProfessionGuide
local call=E.Call
local function enabled(key)
 return E.db and E.db[key]==true and not call(InCombatLockdown)
end
local function number(value)
 return E.Public(value) and type(value)=='number' and value or nil
end
local function selectQuest()
 local api=C_GossipInfo
 if not api then return end
 local available=enabled('autoAcceptQuests') and call(api.GetAvailableQuests)
 local active=enabled('autoTurnInQuests') and call(api.GetActiveQuests)
 local accepts,turnins={},{}
 for _,row in ipairs(type(available)=='table' and available or {})do
  local id=number(row.questID)
  if id and id>0 then accepts[id]=true end
 end
 for _,row in ipairs(type(active)=='table' and active or {})do
  local id=number(row.questID)
  if id and id>0 and E.Public(row.isComplete) and (row.isComplete==true or row.isComplete==1)then turnins[id]=true end
 end
 local function select(row)
  local id=row and row.quest
  if row and row.kind=='turnin' and turnins[id] then call(api.SelectActiveQuest,id);return true end
  if row and row.kind=='accept' and accepts[id] then call(api.SelectAvailableQuest,id);return true end
 end
 if select(P.selected)then return end
 for _,row in ipairs(P.steps or {})do if select(row)then return end end
end
local function selectGreetingQuest()
 local function choices(count, title, requireComplete)
  local matches={}
  for index=1,number(call(count)) or 0 do
   local label, complete=call(title,index)
   if E.Public(label) and type(label)=='string' and label~=''
    and (not requireComplete or E.Public(complete) and (complete==true or complete==1)) then
    if matches[label]==nil then matches[label]=index else matches[label]=false end
   end
  end
  return matches
 end
 local available=enabled('autoAcceptQuests') and choices(GetNumAvailableQuests,GetAvailableTitle) or {}
 local active=enabled('autoTurnInQuests') and choices(GetNumActiveQuests,GetActiveTitle,true) or {}
 local function select(row)
  if not row or not row.quest then return end
  local data=ns.ForeverQuestData
  local quest=data and data.quests[row.quest]
  local title=call(C_QuestLog and C_QuestLog.GetTitleForQuestID,row.quest)
  if not E.Public(title) or type(title)~='string' or title=='' then
   title=quest and quest.title or (row.title or ''):gsub('^Accept ',''):gsub('^Turn in ','')
  end
  local index, action
  if row.kind=='accept' then index,action=available[title],SelectAvailableQuest
  elseif row.kind=='turnin' then index,action=active[title],SelectActiveQuest end
  if index and type(action)=='function' then call(action,index);return true end
 end
 if select(P.selected)then return end
 for _,row in ipairs(P.steps or {})do if select(row)then return end end
end
local function takeFlight()
 if not enabled('autoFlights') or call(UnitOnTaxi,'player')then return end
 local row=P.selected
 if not row then return end
 local named=row.taxiDestination or row.flightDestination
 local money=number(call(GetMoney))
 if not money then return end
 local destination=row.destination
 local here=E.CurrentPosition()
 local speed=number(call(GetUnitSpeed,'player')) or 7
 if speed<7 then speed=7 end
 local direct=here and destination and E.Distance(here,destination)
 local best,bestSeconds
 for slot,edge in pairs(E.taxiChoices or {})do
  if edge.cost>=0 and edge.cost<=money then
   if type(named)=='string' and edge.to.name==named then best=slot;break end
   local remaining=direct and edge.seconds and E.Distance(edge.to,destination)
   if remaining then
    local seconds=edge.seconds+remaining/speed
    if seconds+15<direct/speed and (not bestSeconds or seconds<bestSeconds)then best,bestSeconds=slot,seconds end
   end
  end
 end
 if not best and type(named)=='string' then
  for slot=1,number(call(NumTaxiNodes)) or 0 do
   local name,state=call(TaxiNodeName,slot),call(TaxiNodeType,slot)
   local cost=number(call(TaxiNodeCost,slot))
   if E.Public(name) and E.Public(state) and name==named and state=='REACHABLE'
    and cost and cost>=0 and cost<=money then best=slot;break end
  end
 end
 if best then call(TakeTaxiNode,best)end
end
E.AutoGuideFlight=takeFlight
local pendingGossip
local f=CreateFrame('Frame')
f:SetScript('OnEvent',function(_,event)
 if event=='QUEST_DETAIL' and enabled('autoAcceptQuests') then
  call(AcceptQuest)
 elseif event=='QUEST_PROGRESS' and enabled('autoTurnInQuests') then
  local ready=call(IsQuestCompletable)
  if E.Public(ready) and (ready==true or ready==1)then call(CompleteQuest)end
 elseif event=='QUEST_COMPLETE' and enabled('autoTurnInQuests') then
  local choices=number(call(GetNumQuestChoices))
  if choices and choices>=0 and choices<=1 then call(GetQuestReward,choices==1 and 1 or 0)end
 elseif (event=='GOSSIP_SHOW' or event=='QUEST_GREETING') and (enabled('autoAcceptQuests') or enabled('autoTurnInQuests')) then
  local token={}
  pendingGossip=token
  local function pick()
   if pendingGossip~=token then return end
   pendingGossip=nil
   if event=='QUEST_GREETING' then selectGreetingQuest() else selectQuest() end
  end
  if C_Timer and C_Timer.After then C_Timer.After(.25,pick)else pick()end
 elseif event=='GOSSIP_CLOSED' or event=='QUEST_FINISHED' then
  pendingGossip=nil
 end
end)
for _,event in ipairs({'QUEST_DETAIL','QUEST_PROGRESS','QUEST_COMPLETE','GOSSIP_SHOW','GOSSIP_CLOSED','QUEST_GREETING','QUEST_FINISHED'})do
 call(f.RegisterEvent,f,event)
end
end)(...)

-- GF_UNIFIED_INTERLEAVING_19
;(function(...)
-- Pure planning: no game APIs, saved variables, movement, or quest completion writes.
local _, ns = ...
local Q = {}; ns.QuestGathering = Q
local secondary = {Cooking=true, ['First Aid']=true}
function Q.Enabled(db)
 return Q.Mode(db)~=nil
end
function Q.Mode(db)
 if not db then return end
 if db.pace=='Relaxed' then return 'Farming' end
 if db.journey=='Leveling' and db.pace=='Grinding' then return 'Questing' end
end
local function keys(t)
 local out={}; for k in pairs(t or {}) do out[#out+1]=k end
 table.sort(out,function(a,b)return tostring(a)<tostring(b)end); return out
end
local function copy(t)local out={};for k,v in pairs(t or {})do out[k]=v end;return out end
local function better(a,b)
 if not b then return true end
 if a.rareMissing~=b.rareMissing then return a.rareMissing<b.rareMissing end
 if a.ready~=b.ready then return a.ready end
 if a.priced~=b.priced then return a.priced end
 if a.cost~=b.cost then return a.cost<b.cost end
 return tostring(a.recipe.id)<tostring(b.recipe.id)
end
-- One bounded batch per profession, sharing an inventory ledger. Exact conversion
-- output/inputs must come from a learned recipe, not a presumed cross-client rule.
function Q.Plan(state)
 state.rare=state.rare or {};state.vendorStock=state.vendorStock or {};state.prices=state.prices or {}
 local stock=copy(state.inventory); local plans, needs, materials={},{},{}
 local conversions={}
 for _,r in ipairs(state.recipes or {})do
  if r.known and r.conversion and r.product and r.output and r.output>0 then
   conversions[r.product]=conversions[r.product]or{}; table.insert(conversions[r.product],r)
  end
 end
 local function consume(id,amount,ledger,missing,path,work)
  local take=math.min(ledger[id]or 0,amount); ledger[id]=(ledger[id]or 0)-take; amount=amount-take
  if amount<=0 then return end
  path=path or {}; if not path[id] and conversions[id] and #conversions[id]==1 then
   local r=conversions[id][1]; local inputs=keys(r.reagents)
   -- Only single-input material conversions are unambiguous; cycles fall back.
   if #inputs==1 and (r.reagents[inputs[1]]or 0)>0 then
    path[id]=true; local crafts=math.ceil(amount/r.output)
    consume(inputs[1],crafts*r.reagents[inputs[1]],ledger,missing,path,work)
    work[#work+1]={recipe=r,count=crafts}
    path[id]=nil;return
   end
  end
  missing[id]=(missing[id]or 0)+amount
 end
 for _,profession in ipairs(keys(state.skills))do
  local skill=state.skills[profession]; local best
  for _,r in ipairs(state.recipes or {})do
   if type(skill.rank)=='number'and type(skill.cap)=='number'and r.profession==profession and r.known and r.bookRank==skill.rank and next(r.reagents or {}) then
    local count
    if r.orange then
     local guaranteed=r.orangeUntil and r.orangeUntil-skill.rank or 1
     count=math.min(secondary[profession] and 10 or 5,skill.cap-skill.rank,guaranteed)
     local available=math.huge
     for id,quantity in pairs(r.reagents)do
      if type(quantity)=='number'and quantity>0 then available=math.min(available,math.floor((stock[id]or 0)/quantity))end
     end
     if available>0 then count=math.min(count,available)end
    end
    local valid=true;for _,quantity in pairs(r.reagents)do if type(quantity)~='number'or quantity<=0 then valid=false end end
    if valid and count and count>0 and count<=40 then
     local ledger=copy(stock);local missing,work={},{}
     for _,id in ipairs(keys(r.reagents))do consume(id,r.reagents[id]*count,ledger,missing,nil,work)end
     local rareMissing,cost,priced=0,0,true;local ready=true
     for id,amount in pairs(missing)do
      if state.rare[id]then rareMissing=rareMissing+amount end
      if not(state.vendorAccess and state.vendorStock[id] and state.vendorStock[id]>=amount)then ready=false end
     end
     for id,amount in pairs(r.reagents)do if state.prices[id]then cost=cost+state.prices[id]*amount*count else priced=false;cost=cost+amount*count end end
     local candidate={recipe=r,count=count,ledger=ledger,missing=missing,rareMissing=rareMissing,
      cost=cost/count,priced=priced,ready=ready,conversions=work}
     local allowed=true
     if state.localMaterials then
      for id in pairs(missing)do
       if not state.localMaterials[id]then allowed=false;break end
      end
     end
     if allowed and better(candidate,best)then best=candidate end
    end
   end
  end
  if best then
   for id,have in pairs(stock)do
    local used=have-(best.ledger[id]or 0)
    if used>0 then materials[id]=(materials[id]or 0)+used end
   end
   stock=best.ledger; plans[#plans+1]=best
   -- Merchant purchases are not assumed shared inventory. Each candidate must
   -- actually be bought before a later profession may allocate those units.
   if next(best.missing)then best.ready=false end
   for id,amount in pairs(best.missing)do
    local need=needs[id]or{id=id,have=state.inventory[id]or 0,missing=0,professions={}}
    materials[id]=(materials[id]or 0)+amount
    need.missing=need.missing+amount;need.target=need.have+need.missing;need.professions[profession]=true
    need.purchase=not state.localMaterials and (state.rare[id]or state.vendorStock[id]~=nil);needs[id]=need
   end
  end
 end
 return {plans=plans,needs=needs,materials=materials,inventory=state.inventory}
end
function Q.Counters(plan,row,sources,names)
 local out={}; if row.kind~='objective'or row.complete then return out end
 local mobs={};for _,id in ipairs(row.mobIDs or {})do mobs[id]=true end
 if row.targetID and tostring(row.targetKind):lower()=='npc'then mobs[row.targetID]=true end
 for _,id in ipairs(keys(plan.needs))do
  local need=plan.needs[id]; local relevant,fishing=false,false
  if not need.purchase then for _,source in ipairs(sources[id]or {})do
   if source.mobID and mobs[source.mobID]then relevant=true end
   if source.nearby and source.distance and source.distance<=100 and source.learned and source.eligible then relevant=true;fishing=fishing or source.fishing==true and need.professions.Cooking==true end
  end end
  if relevant then out[#out+1]={itemID=id,have=need.have,target=need.target,text=(names[id]or('Item '..id))..': '..need.have..'/'..need.target..(fishing and ' · Fishing + Cooking' or '')}end
  if #out>=3 then break end
 end
 return out
end
function Q.ShoppingList(plan,itemName,purchaseSource)
 if #plan.plans==0 then return '' end
 local lines,view={},{}
 local function add(recipe,count,section)
  local inputs={}
  for _,id in ipairs(keys(recipe.reagents))do
   inputs[#inputs+1]=(recipe.reagents[id]*count)..' '..itemName(id)
  end
  lines[#lines+1]=recipe.name..' x'..count..' - '..table.concat(inputs,', ')
  section.tiles[#section.tiles+1]={name=recipe.name,itemID=recipe.product,spellID=recipe.id,
   quantity='×'..count,details=inputs}
 end
 for _,ready in ipairs({true,false})do
  local heading
  for _,p in ipairs(plan.plans)do
   if (not not p.ready)==ready then
    if not heading then
     if #lines>0 then lines[#lines+1]='' end
     local title=ready and 'Craft In Town' or 'Craft After Gathering Nearby'
     lines[#lines+1]=title
     heading={title=title,tiles={}}
     view[#view+1]=heading
    end
    for _,work in ipairs(p.conversions)do add(work.recipe,work.count,heading)end
    add(p.recipe,p.count,heading)
   end
  end
 end
 lines[#lines+1]=''
 lines[#lines+1]='Materials (In Bags / Needed)'
 local materials={title='Materials (In Bags / Needed)',tiles={}}
 for _,id in ipairs(keys(plan.materials))do
  local name,have,needed=itemName(id),plan.inventory[id]or 0,plan.materials[id]
  lines[#lines+1]=name..'  '..have..' / '..needed
  materials.tiles[#materials.tiles+1]={name=name,itemID=id,quantity=have..'/'..needed,missing=have<needed}
 end
 if #materials.tiles>0 then view[#view+1]=materials end
 local heading=false
 for _,id in ipairs(keys(plan.needs))do
  local need=plan.needs[id]
  local source=purchaseSource and purchaseSource(id)
  if source or need.purchase then
   if not heading then
    lines[#lines+1]='';lines[#lines+1]='Buy In Town'
    heading={title='Buy In Town',lines={}}
    view[#view+1]=heading
   end
   local purchase=need.missing..' '..itemName(id)..(source and ' - '..source or '')
   lines[#lines+1]=purchase
   heading.lines[#heading.lines+1]=purchase
  end
 end
 return table.concat(lines,'\n'),view
end
function Q.Rewrite(rows,plan,options)
 local out={};for _,row in ipairs(rows or {})do
  -- Explicit manual routes and real training/quest/service actions keep their identity.
  local remove=not options.manual and row.kind=='profession'and not row.trainingRequired and not row.professionChoice and not row.integratedProfession
  if not remove then
   local n=copy(row)
   if n.quest then
    n.questGatheringOriginal=n.questGatheringOriginal or n.body or ''
    local lines={};for line in n.questGatheringOriginal:gmatch('[^\r\n]+')do
     if not line:match('^Source step ')and not line:match('^Quest ID:')and not line:match('^Location:')and not line:match('^Draenei shared starter route')and not line:match('^Faction quest route')then lines[#lines+1]=line end
    end
    n.body=table.concat(lines,'\n');if n.recommendationReason then n.body=n.body=='' and n.recommendationReason or n.body..'\n'..n.recommendationReason end;n.resourceCounters=Q.Counters(plan,n,options.sources,options.names)
    n.craftingShopping,n.craftingSections,n.craftingBody=nil,nil,nil
    if options.shopping and options.shopping~='' then
     if n.kind=='objective' and n.body~='' then n.body='Quest Objectives\n'..n.body end
     n.craftingShopping,n.craftingSections=options.shopping,options.shoppingView
     local questBody={n.body}
     n.body=(n.body~='' and n.body..'\n\n' or '')..options.shopping
     for _,counter in ipairs(n.resourceCounters)do
      for _,source in ipairs(options.sources[counter.itemID]or{})do
       if source.nearby then
        local label=(source.name or options.names[counter.itemID])..' nearby - '..math.floor(source.distance+0.5)..' yd'
        n.body=n.body..'\n'..label
        questBody[#questBody+1]=label
        break
       end
      end
     end
     n.craftingBody=table.concat(questBody,'\n')
    else
     for _,counter in ipairs(n.resourceCounters)do n.body=n.body..'\n'..counter.text end
    end
   end
   out[#out+1]=n
  end
 end
 return out
end

end)(ADDON,GF)
;(function(...)
-- Branch adapter. Uses shipped facts and observed books; never learns/crafts/targets.
local _,ns=...
local Q,P=ns.QuestGathering,ns.ProfessionGuide
local E=ns.Forever or ns.SharedExplorer
if not Q or not P or not E then return end
local R={books={},deferred={},epoch=0};Q.Runtime=R
function R.SaveBook(profession,rank,rows)
 local book={rank=rank,rows=rows}
 R.books[profession]=book
 if E.db and #rows>0 then
  E.db.craftingBooks=E.db.craftingBooks or {}
  E.db.craftingBooks[profession]=book
 end
 R.epoch=R.epoch+1
end
local F,L=ns.FarmingPlanner,ns.BlendedProfessions
local skills
local function read(fn,...)if type(fn)=='function'then local ok,a,b,c,d,e=pcall(fn,...);if ok then return a,b,c,d,e end end end
local function now()return read(GetTime)or 0 end
local function mode()return Q.Mode(E.db)end
local function manual()return F and F.route~=nil end
local function itemID(link)return type(link)=='string'and tonumber(link:match('item:(%d+)'))end
local function count(id)
 local value=read(C_Item and C_Item.GetItemCount or GetItemCount,id,false)
 return E.Public(value) and type(value)=='number' and value or 0
end
local name=E.ItemName
local function materialLabel(id)
 local label=read(GetItemInfo,id)
 if type(label)=='string'and label~=''then return label end
 local facts=ns.ForeverQuestData and ns.ForeverQuestData.names
 return facts and facts['item:'..id]
end
local function copy(t)local n={};for k,v in pairs(t or{})do n[k]=v end;return n end
local function position()return read(E.CurrentPosition)end
local function distance(a,b)return a and b and read(E.Distance,a,b)end
local function unsafe()return read(InCombatLockdown)or read(UnitAffectingCombat,'player')or read(UnitIsDeadOrGhost,'player')or read(UnitOnTaxi,'player')end
-- Only live, unlinked books supply learned recipes and current difficulty.
local function captureForeverBook()
 local api=C_TradeSkillUI
 if not api or not api.GetRecipeSchematic or not api.GetAllRecipeIDs
  or read(api.IsTradeSkillLinked) or read(api.IsTradeSkillGuild) then return end
 local info=read(api.GetChildProfessionInfo) or read(api.GetBaseProfessionInfo)
 if not E.Public(info) or type(info)~='table' then return end
 local profession=info.professionName
 local rank=info.skillLevel
 if not E.Public(profession) or not E.Public(rank) or type(profession)~='string'
  or type(rank)~='number' or rank<=0 then return end
 local ids=read(api.GetAllRecipeIDs)
 if not E.Public(ids) or type(ids)~='table' then return end
 local optimal=Enum and Enum.TradeskillRelativeDifficulty and Enum.TradeskillRelativeDifficulty.Optimal
 if optimal==nil then optimal=0 end -- Forever 1.60.1 enum value.
 local rows={}
 for _,id in ipairs(ids)do
  local recipe=read(api.GetRecipeInfo,id)
  if E.Public(recipe) and type(recipe)=='table' and E.Public(recipe.learned) and recipe.learned==true
   and E.Public(recipe.relativeDifficulty) and recipe.relativeDifficulty==optimal
   and E.Public(recipe.name) and type(recipe.name)=='string' then
   local schematic=read(api.GetRecipeSchematic,id,false)
   local slots=E.Public(schematic) and type(schematic)=='table' and schematic.reagentSlotSchematics
   if E.Public(slots) and type(slots)=='table' then
    local reagents,complete={},true
    for _,slot in ipairs(slots)do
     if slot.required then
      local choices=slot.reagents
      local material=type(choices)=='table' and #choices==1 and choices[1].itemID
      local quantity=slot.quantityRequired
      if not E.Public(material) or not E.Public(quantity) or type(material)~='number'
       or type(quantity)~='number' or quantity<=0 then complete=false;break end
      reagents[material]=(reagents[material] or 0)+quantity
     end
    end
    if complete and next(reagents)then
     rows[#rows+1]={id=id,name=recipe.name,profession=profession,known=true,bookRank=rank,
      orange=true,reagents=reagents,product=schematic.outputItemID,output=schematic.quantityMin,foreverBook=true}
    end
   end
  end
 end
 if #ids>0 then R.SaveBook(profession,rank,rows);P.dirty=true end
end
function R.CaptureBook()
 local linked=read(GetTradeSkillIsLinked)
 if linked==true or linked==1 then return end
 local profession,rank=read(GetTradeSkillLine)
 local total=read(GetNumTradeSkills)
 if type(profession)~='string'or type(rank)~='number'or type(total)~='number'or total==0 then return captureForeverBook() end
 local rows={}
 for i=1,total do
  local title,kind=read(GetTradeSkillInfo,i)
  if title and kind~='header'and kind~='subheader'then
   local link=read(GetTradeSkillRecipeLink,i)
   local id=type(link)=='string'and tonumber(link:match('enchant:(%d+)')or link:match('spell:(%d+)'))
   if id then
    local r={id=id,name=title,profession=profession,known=true,bookRank=rank,orange=kind=='optimal',reagents={},kind=kind or'unknown',index=i}
    r.product=itemID(read(GetTradeSkillItemLink,i));r.output=read(GetTradeSkillNumMade,i)
    local total=read(GetTradeSkillNumReagents,i)
    local complete=type(total)=='number'and total>0
    if complete then
     for j=1,total do
      local material=itemID(read(GetTradeSkillReagentItemLink,i,j));local _,_,quantity=read(GetTradeSkillReagentInfo,i,j)
      if not material or type(quantity)~='number'or quantity<=0 then complete=false;break end
      r.reagents[material]=(r.reagents[material]or 0)+quantity
     end
    end
    if complete then rows[#rows+1]=r end
   end
  end
 end
 -- Replacing the visible subset is conservative when the player applies filters.
 R.SaveBook(profession,rank,rows)
end
function R.CaptureCraftBook()
 local profession=read(GetCraftDisplaySkillLine);local skill=skills and skills()[profession]
 skill=skill or(P.skills or{})[profession]
 if type(profession)~='string'or not skill then return end
 local rows={}
 for i=1,read(GetNumCrafts)or 0 do
  local title,_,kind=read(GetCraftInfo,i);local link=read(GetCraftRecipeLink,i)
  local id=type(link)=='string'and tonumber(link:match('enchant:(%d+)')or link:match('spell:(%d+)'))
  if title and id and kind~='header'and kind~='subheader'then
   local r={id=id,name=title,profession=profession,known=true,bookRank=skill.rank,orange=kind=='optimal',reagents={},kind=kind or'unknown'}
   r.product=itemID(read(GetCraftItemLink,i));r.output=read(GetCraftNumMade,i)
   local total=read(GetCraftNumReagents,i)
   local complete=type(total)=='number'and total>0
   if complete then
    for j=1,total do
     local material=itemID(read(GetCraftReagentItemLink,i,j));local _,_,quantity=read(GetCraftReagentInfo,i,j)
     if not material or type(quantity)~='number'or quantity<=0 then complete=false;break end
     r.reagents[material]=(r.reagents[material]or 0)+quantity
    end
   end
   if complete then rows[#rows+1]=r end
  end
 end
 if #rows>0 then R.SaveBook(profession,skill.rank,rows) end
end
skills=function()
 if ns.Forever then return E.state and E.state.skills or P.skills or{} end
 return P.skills or{}
end
local function recipes()
 local out={}
 for profession,skill in pairs(skills())do
  local book=R.books[profession] or (E.db and E.db.craftingBooks and E.db.craftingBooks[profession])
  if book then
   for _,base in ipairs(book.rows)do
    local r=copy(base)
    if book.rank~=skill.rank then r.bookRank=skill.rank;r.orange=false;r.orangeUntil=nil end
    local cached=ns.Forever and E.recipes and E.recipes[r.id]
    if cached and cached.orangeUntilVerified then r.orangeUntil=cached.orangeUntilVerified end
    local policy=R.policies and R.policies[r.id]
    -- Optional verified use/reserve metadata; no guessing usefulness from a name.
    if policy then r.reserve=policy.reserve;r.conversion=policy.conversion end
    if r.product and r.output then
     if not r.reserve and type(GetItemInfo)=='function'and read(IsUsableItem,r.product)==true then
      local info={E.Call(GetItemInfo,r.product)}
      local slots=({INVTYPE_HEAD={1},INVTYPE_NECK={2},INVTYPE_SHOULDER={3},INVTYPE_CHEST={5},INVTYPE_ROBE={5},INVTYPE_WAIST={6},INVTYPE_LEGS={7},INVTYPE_FEET={8},INVTYPE_WRIST={9},INVTYPE_HAND={10},INVTYPE_CLOAK={15}})[info[9]]
      if slots and type(info[4])=='number'and(info[5]or 0)<=(read(UnitLevel,'player')or 0)then
       local old=read(GetInventoryItemLink,'player',slots[1]);local _,_,_,oldLevel=read(GetItemInfo,old)
       if not old or type(oldLevel)=='number'and info[4]>oldLevel then r.reserve=1 end
      end
     end
    end
    out[#out+1]=r
   end
  end
 end
 local inputs={};for _,r in ipairs(out)do for id in pairs(r.reagents)do inputs[id]=true end end
 for _,r in ipairs(out)do
  local n=0;for _ in pairs(r.reagents)do n=n+1 end
  if inputs[r.product]and n==1 and r.output and r.output>0 then r.conversion=true end
 end
 table.sort(out,function(a,b)return a.id<b.id end);return out
end
function R.Snapshot()
 if R.snapshotEpoch==R.epoch and R.snapshotCache then return R.snapshotCache end
 local s={skills=skills(),recipes=recipes(),inventory={},rare={},prices={},vendorStock={}}
 local inspected={}
 for _,r in ipairs(s.recipes)do
  if r.product then s.inventory[r.product]=count(r.product)end
  for id in pairs(r.reagents)do if not inspected[id]then inspected[id]=true
   s.inventory[id]=count(id)
   local policy=ns.MaterialAcquisitionPolicy
   s.rare[id]=policy and read(policy.ChanceMaterial,{id=id,name=name(id)})or false
   local prices=ns.CraftingEvaluation
   s.prices[id]=prices and read(prices.Price,id)
  end end
 end
 R.snapshotEpoch=R.epoch;R.snapshotCache=s
 return s
end
function R.Kind(id)
 if F then
  if F.skinSources and F.skinSources[id]then return 'Skinning'end
  if F.clothSources and F.clothSources[id]then return 'Cloth'end
  for _,m in pairs(F.meta or{})do if m.item==id then return m.kind end end
 end
end
-- Indexed once per zone, not per frame. Personal observations are refreshed on
-- gathering events; nearby-node distance checks reuse this small zone index.
function R.ZoneNodes(pos)
 if not pos or not F then return{}end
 if R.nodeMap==pos.mapID and R.nodeAt and GetTime()-R.nodeAt<5 then return R.nodes end
 R.nodeAt=GetTime()
 read(F.LoadKnown);local nodes={}
 for kind,maps in pairs(F.known or{})do
  for coord,id in pairs(maps[pos.mapID]or{})do
   local meta=F.meta and F.meta[id];local x,y=read(F.Decode,coord)
   if meta and meta.item and x and y then nodes[#nodes+1]={item=meta.item,kind=kind,skill=meta.skill or 0,location={mapID=pos.mapID,x=x,y=y,name=meta.name}}end
  end
 end
 local observer=ns.GatheringObserver
 for _,node in pairs(observer and observer.data and observer.data.nodes or{})do
  local p=node.position;local meta=F.meta[node.sourceNodeID]
  if meta and meta.item and p and p.mapID==pos.mapID and not node.instanced then
   nodes[#nodes+1]={item=meta.item,kind=meta.kind,skill=meta.skill or 0,location={mapID=pos.mapID,x=p.x,y=p.y,name=node.name}}
  end
 end
 R.nodes,R.nodeMap,R.nodeEpoch=nodes,pos.mapID,R.epoch;return nodes
end
function R.Sources(plan,pos,rows)
 local sources={}
 local mobs={}
 for _,row in ipairs(rows or{})do
  for _,id in ipairs(row.mobIDs or{})do mobs[id]=true end
  if row.targetID and row.targetKind=='npc'then mobs[row.targetID]=true end
 end
 for id in pairs(plan.needs)do
  local list={};sources[id]=list
  if F then
   for _,mob in ipairs(F.clothSources and F.clothSources[id]or{})do list[#list+1]={mobID=mob}end
   if skills().Skinning and count(7005)>0 then for _,mob in ipairs(F.skinSources and F.skinSources[id]or{})do list[#list+1]={mobID=mob}end end
  end
  for mob in pairs(mobs)do
   local items=ns.Forever and E.mobDrops and E.mobDrops[mob]
   if items and items[id]then list[#list+1]={mobID=mob}end
   for _,item in ipairs(ns.Adaptive and ns.Adaptive.dropIndex and ns.Adaptive.dropIndex[mob]or{})do if item==id then list[#list+1]={mobID=mob}end end
  end
 end
 if not next(sources) then return sources end
 local learned=skills()
 local tools={Mining=not learned.Mining or count(2901)>0,Skinning=not learned.Skinning or count(7005)>0}
 for _,node in ipairs(R.ZoneNodes(pos))do
  local list=sources[node.item]
  local skill=list and learned[node.kind]
  local yards=skill and tools[node.kind]~=false and skill.rank>=node.skill and distance(pos,node.location)
  if yards and yards<=100 then
   sources[node.item][#sources[node.item]+1]={nearby=true,distance=yards,learned=true,eligible=true,name=node.location.name,location=node.location,kind=node.kind,fishing=node.kind=='Fishing' and skill.cap and skill.rank<skill.cap}
  end
 end
 return sources
end
function R.Stop(profession,recipe)
 if unsafe()then return false end
 local pos=position()
 -- Station-dependent crafts need positive live evidence. A merchant or a city
 -- name alone is insufficient. Caller may attach verified station observations.
 local required=({Blacksmithing='Anvil',Engineering='Anvil',Cooking='Cooking Fire',Mining='Forge'})[profession]
 if required then
  if recipe and recipe.foreverBook and C_TradeSkillUI then
   local api=C_TradeSkillUI
   local info=read(api.GetChildProfessionInfo) or read(api.GetBaseProfessionInfo)
   if E.Public(info) and type(info)=='table' and E.Public(info.professionName) and info.professionName==profession then
    local requirements=read(api.GetRecipeRequirements,recipe.id)
    if E.Public(requirements) and type(requirements)=='table' and #requirements>0 then
     local ready=true
     for _,requirement in ipairs(requirements)do
      if not E.Public(requirement.met) or requirement.met~=true then ready=false;break end
     end
     if ready then return true end
    end
   end
  end
  -- Query current tool availability while the matching book is open. Never
  -- persist "near an anvil" from an old book inspection after walking away.
  local linked=read(GetTradeSkillIsLinked)
  local link=recipe and recipe.index and read(GetTradeSkillRecipeLink,recipe.index)
  local currentID=type(link)=='string'and tonumber(link:match('enchant:(%d+)')or link:match('spell:(%d+)'))
  if currentID and currentID==recipe.id and not(linked==true or linked==1)and read(GetTradeSkillLine)==profession then
   local tools={E.Call(GetTradeSkillTools,recipe.index)};local station=false;local all=true
   for i=1,#tools,2 do
    if tools[i]==required or tools[i]==_G[required=='Anvil'and'ANVIL'or required=='Forge'and'FORGE'or'COOKING_FIRE']then station=true end
    if tools[i+1]~=true and tools[i+1]~=1 then all=false end
   end
   if station and all then return true end
  end
  for _,station in ipairs(R.stations or{})do
   local yards=distance(pos,station.location)
   if station.kind==required and station.expires and station.expires>now()and yards and yards<=15 then return true end
  end
  return false
 end
 if ns.Forever then return not not read(E.CraftingStop,profession,E.state or{}) end
 return L and ns.CraftingSessions and read(ns.CraftingSessions.AtService,profession,L.Context())==true
end
local function isDeferred(id)return(R.deferred[id]or 0)>now()end
function R.CraftRows(plan)
 local out={}
 for _,p in ipairs(plan.plans)do
  local r=p.recipe;local id='interleave:craft:'..r.id
  if p.ready and R.Stop(r.profession,r)and not isDeferred(id)then
   local work=p.conversions[1]or{recipe=r,count=p.count};local action=work.recipe
   out[#out+1]={id=id,kind='profession',integratedProfession=true,profession=r.profession,category='Crafting',
    title='Craft '..work.count..' '..action.name,body='',recipe={name=action.name,spellID=action.id},craftReady=true}
  end
 end
 return out
end
function R.FarmRow(plan,sources)
 if unsafe()then return end
 local best,yards
 for id,need in pairs(plan.needs)do
  local key='interleave:gather:'..id
  if not isDeferred(key)then
   for _,source in ipairs(sources[id]or{})do
    local loc,d=source.location,source.distance
    if loc and d and (not yards or d<yards or d==yards and id<best.material)then
     yards=d
     best={id=key,kind='profession',integratedProfession=true,profession=source.kind,category='Gathering',
      material=id,materialTarget=need.target,title=name(id)..': '..need.have..'/'..need.target,
      body='Gather '..name(id)..' near '..(loc.name or 'the marked location')..'.',destination=loc}
    end
   end
  end
 end
 return best
end
function R.Apply(rows)
 if not mode()or manual()then return rows end
 local snapshot=R.Snapshot();local plan=R.plan
 local here=position()
 local active
 for _,row in ipairs(rows)do
  if row.quest and not row.complete then
   local loc=row.destination
   if row.kind=='objective' and here and loc and here.mapID==loc.mapID
    and (distance(here,loc) or math.huge)<=150 then active=row end
   break
  end
 end
 local probe={needs={}}
 for id in pairs(snapshot.inventory)do probe.needs[id]=true end
 local sources=R.Sources(probe,here,active and {active} or {})
 local mobs={}
 if active then
  for _,id in ipairs(active.mobIDs or {})do mobs[id]=true end
  if active.targetID and tostring(active.targetKind):lower()=='npc'then mobs[active.targetID]=true end
 end
 local allowed,ids={},{}
 for id,list in pairs(sources)do
  for _,source in ipairs(list)do
   if source.location or source.mobID and mobs[source.mobID]then
    allowed[id]=true;ids[#ids+1]=id;break
   end
  end
 end
 table.sort(ids)
 local signature=table.concat(ids,',')
 if not plan or R.planEpoch~=R.epoch or R.planLocalMaterials~=signature then
  local state=copy(snapshot);state.localMaterials=allowed;state.vendorStock={}
  plan=Q.Plan(state)
  R.plan=plan;R.planEpoch=R.epoch;R.planLocalMaterials=signature
 end
 if plan.shopping==nil then
  plan.waitingMaterialLabels={}
  plan.shopping,plan.shoppingView=Q.ShoppingList(plan,function(id)
   local label=materialLabel(id)
   if label then return label end
   plan.waitingMaterialLabels[id]=true
   return 'Item '..id
  end)
 end
 local base={};for _,row in ipairs(rows)do if not row.integratedProfession then base[#base+1]=row end end
 local names={};for id in pairs(plan.needs)do names[id]=name(id)end
 local out=Q.Rewrite(base,plan,{sources=sources,names=names,shopping=plan.shopping,shoppingView=plan.shoppingView})
 local additions=R.CraftRows(plan)
 if mode()=='Farming'and #additions==0 then local farm=R.FarmRow(plan,sources);if farm then additions[1]=farm end end
 -- Preserve urgent services, training and immediately available hub turn-ins.
 local at=1
 while out[at]and(out[at].urgentBags or out[at].localQuestPickup or out[at].adaptiveVendor or out[at].kind=='sell'or out[at].kind=='train'or out[at].trainingRequired or out[at].professionChoice or out[at].kind=='turnin'and(distance(position(),out[at].destination)or math.huge)<=150)do at=at+1 end
 for i=#additions,1,-1 do table.insert(out,at,additions[i])end
 return out
end
-- Suppress old skill-target generators only in the replacement modes.
if L then
 local apply=L.Apply
 L.Apply=function(...)
  if not mode()or manual()or P.active==false then return apply(...)end
  local kept={};for _,r in ipairs(P.steps or{})do if r.kind~='profession'or r.trainingRequired or r.professionChoice then kept[#kept+1]=r end end
  -- Keep actual profession acquisition/cap-training opportunities from the old
  -- provider, without retaining its independent skill-target farming milestones.
  if not unsafe()then local ctx=L.Context();for profession,skill in pairs(skills())do local r=L.Make(profession,skill,ctx);if r and r.trainingRequired then kept[#kept+1]=r end end end
  P.steps=R.Apply(kept);P.firstPending=P.steps[1]and P.steps[1].id;return P.steps
 end
 local H=ns.ProfessionTaskFocus
 if H then local valid=H.Valid;H.Valid=function(...)if mode()and not manual()then if H.ref then H.Release('quest gathering branch owns profession focus')end;return false end;return valid(...)end end
else
 for _,key in ipairs({'CatchupSteps','CraftingCatchup'})do
  local original=E[key]
  E[key]=function(...)if mode()and not manual()then return{}end;return original and original(...)end
 end
 local order=E.Order;E.Order=function(...)return R.Apply(order(...))end
end
local skip=P.Skip
P.Skip=function(...)
 local row=P.selected
 if row and row.integratedProfession then
  R.deferred[row.id]=now()+600;R.focus=nil;P.selected=nil;P.Refresh()
  if ns.NormalUI then ns.NormalUI.Resync()end;return true
 end
 return skip(...)
end
-- The compass stays quest-led in Grinding. At most two smaller historical node
-- markers supplement it, never replacing its primary target or claiming a spawn.
local compass=ns.NavigationCompass
if compass then
 local collect=compass.Collect
 local function marker(location,pos,item,key,active)
  local C=ns.Retail and ns.Retail.Client
  local i,x,y=read(C and C.WorldPosition,location.mapID,location.x,location.y)
  local j,a,b=read(C and C.WorldPosition,pos.mapID,pos.x,pos.y)
  if i and i==j and x and y and a and b then
   return{key=key,name=location.name or name(item),zone=location.zone,location=location,
    icon=read(C_Item and C_Item.GetItemIconByID or GetItemIcon,item)or'Interface\\Icons\\INV_Misc_Book_09',
    active=active,nearby=not active,distance=math.sqrt((x-a)^2+(y-b)^2),bearing=math.atan2(y-b,x-a)}
  end
 end
 compass.Collect=function(...)
  collect(...)
  if mode()~='Questing'or manual()then return end
  compass.targets=compass.targets or{}
  local pos=position();if not pos then return end
  local hasPrimary=false;for _,row in ipairs(compass.targets or{})do if row.active then hasPrimary=true end end
  local current=P.selected
  if not hasPrimary and current and current.quest and current.destination then
   local primary=marker(current.destination,pos,current.itemID or 0,'interleave:quest',true)
   if primary then table.insert(compass.targets,1,primary)end
  end
 end
end
local freshSteps=ns.NormalUI and ns.NormalUI.FreshSteps
if freshSteps then
 ns.NormalUI.FreshSteps=function(...)
  R.epoch=R.epoch+1
  return freshSteps(...)
 end
end
local originalReadBook=E.ReadBook
local worker=CreateFrame('Frame');R.worker=worker
local function readPendingBook(self)
 if GetTime()<R.bookDue then return end
 self:SetScript('OnUpdate',nil)
 R.bookDue=nil
 if R.bookDirty then R.bookDirty=nil;originalReadBook();R.CaptureBook()end
 if R.craftDirty then R.craftDirty=nil;R.CaptureCraftBook()end
end
local function queueBook()
 if not R.bookDue then worker:SetScript('OnUpdate',readPendingBook)end
 R.bookDue=GetTime()+.3
end
E.ReadBook=function()R.bookDirty=true;queueBook()end
worker:SetScript('OnEvent',function(_,event,...)
 if event=='GET_ITEM_INFO_RECEIVED'then
  local id,success=...
  local plan=R.plan
  if E.Public(id) and E.Public(success) and success~=false and success~=0 and plan and plan.waitingMaterialLabels and plan.waitingMaterialLabels[id] and materialLabel(id)then
   plan.shopping=nil
   plan.waitingMaterialLabels[id]=nil
   P.dirty=true
  end
  return
 end
 R.epoch=R.epoch+1
 if event=='TRADE_SKILL_SHOW'or event=='TRADE_SKILL_UPDATE'or event=='TRADE_SKILL_LIST_UPDATE'or event=='TRADE_SKILL_DATA_SOURCE_CHANGED'or event=='SKILL_LINES_CHANGED'then R.bookDirty=true;queueBook()end
 if event=='CRAFT_SHOW'or event=='CRAFT_UPDATE'then R.craftDirty=true;queueBook()end
end)
for _,event in ipairs({'TRADE_SKILL_SHOW','TRADE_SKILL_UPDATE','TRADE_SKILL_LIST_UPDATE','TRADE_SKILL_DATA_SOURCE_CHANGED','CRAFT_SHOW','CRAFT_UPDATE','SKILL_LINES_CHANGED','BAG_UPDATE_DELAYED','PLAYER_ENTERING_WORLD','PLAYER_EQUIPMENT_CHANGED','ZONE_CHANGED_NEW_AREA','GET_ITEM_INFO_RECEIVED'})do
 pcall(worker.RegisterEvent,worker,event)
end

end)(ADDON,GF)

;(function(...)
 local _,ns=...;local N=ns.NormalUI;if not N or not N.WorkflowLive then return end
 local live=N.WorkflowLive
 function N.WorkflowLive(step)
  local row=live(step);if not row or type(row.body)~='string'then return row end
  local copy={};for k,v in pairs(row)do copy[k]=v end
  local lines={};for line in row.body:gmatch('[^\r\n]+')do
   if line~=row.title and not line:match('^Source step ')and not line:match('^Quest ID:')then lines[#lines+1]=line end
  end
  copy.body=table.concat(lines,'\n\n');return copy
 end
end)(ADDON,GF)

-- GF_REFRESH_BUDGET_24: retain quest facts during unrelated loot/UI updates.
;(function(_,ns)
 local E,Q=ns.Forever,ns.ForeverQuestPlanner
 if not E or not Q then return end
 local revision=0;local cached;local build=Q.Build
 local events=CreateFrame('Frame')
 for _,event in ipairs({'QUEST_ACCEPTED','QUEST_TURNED_IN','QUEST_REMOVED','GOSSIP_SHOW','GOSSIP_CLOSED','QUEST_DETAIL','PLAYER_LEVEL_UP','SKILL_LINES_CHANGED','PLAYER_ENTERING_WORLD','ZONE_CHANGED_NEW_AREA','ZONE_CHANGED','UPDATE_FACTION'})do events:RegisterEvent(event)end
 events:SetScript('OnEvent',function()revision=revision+1;cached=nil end)
 local function questShape(s)
  if not s.questLogAvailable then return end
  local ids={}
  for id in pairs(s.quests)do ids[#ids+1]=id end
  table.sort(ids)
  local parts={}
  for _,id in ipairs(ids)do
   local live=s.quests[id]
   local slots={}
   for i,goal in ipairs(live.objectives or{})do
    if not(E.Public(goal.finished)and E.Public(goal.numRequired)and E.Public(goal.numFulfilled)and E.Public(goal.isOptional))then return end
    local done=goal.finished==true or type(goal.numRequired)=='number'and goal.numRequired>0 and type(goal.numFulfilled)=='number'and goal.numFulfilled>=goal.numRequired
    slots[i]=done and '1' or '0'
   end
   if not(E.Public(live.ready)and E.Public(live.complete))then return end
   parts[#parts+1]=id..':'..(Q.Ready(live)and 'ready' or table.concat(slots))
  end
  return table.concat(parts,';')
 end
 Q.Build=function(s)
  local anchor=Q.Anchor(s);local t=E.Time();local p=s.position
  local signature=tostring(s.level)..':'..tostring(s.class)..':'..tostring(s.race)..':'..tostring(s.faction)..':'..tostring(E.db and E.db.journey)..':'..tostring(E.db and E.db.pace)
  local shape=questShape(s)
  local moved=cached and E.Distance(p,cached.position)
  if shape and cached and cached.shape==shape and cached.revision==revision and cached.anchor==anchor and cached.signature==signature and t-cached.time<10 and moved and moved<100 and p.mapID==cached.position.mapID then return cached.rows end
  local rows=build(s);cached={rows=rows,shape=shape,revision=revision,anchor=anchor,signature=signature,time=t,position=p}
  return rows
 end
 local fresh=Q.Fresh
 Q.Fresh=function(...)cached=nil;revision=revision+1;return fresh(...)end
 Q.InvalidateRefreshCache=function()cached=nil;revision=revision+1 end
end)(ADDON,GF)

-- GF_QUEST_SHARED_SPACE_25: live objectives own completion; resources are optional.
;(function(_,ns)
 local E,Q,N=ns.Forever,ns.QuestGathering,ns.NormalUI
 if not E or not Q or not Q.Runtime or not N then return end
 local R=Q.Runtime
 local function clone(t)local r={};for k,v in pairs(t or{})do r[k]=v end;return r end
 -- Gathering professions must work even before a crafting book is inspected.
 -- These are soft inventory reserves, never required quest objectives.
 local seeds={Mining={{1,2770},{65,2771},{125,2772},{175,3858},{245,10620}},
  Skinning={{1,2318},{100,2319},{150,4234},{200,4304},{250,8170}},
  ['First Aid']={{1,2589},{80,2592},{150,4306},{210,4338},{260,14047}}}
 local snapshot=R.Snapshot
 function R.Snapshot()
  local s=snapshot()
  if s.sharedReserves then return s end
  s.sharedReserves={}
  for profession,tiers in pairs(seeds)do
   local skill=s.skills[profession];local id
   if skill and type(skill.rank)=='number'then
    for _,tier in ipairs(tiers)do if skill.rank>=tier[1]then id=tier[2]end end
   end
   if id then
    local have=E.Call(C_Item and C_Item.GetItemCount or GetItemCount,id,false)
    if (not E.Public or E.Public(have))and type(have)=='number'then
     s.inventory[id]=have;s.sharedReserves[id]=20
    end
   end
  end
  local herb=s.skills.Herbalism
  if herb and type(herb.rank)=='number'then
   local F=ns.FarmingPlanner
   for _,meta in pairs(F and F.meta or{})do
    if meta.kind=='Herbalism'and meta.item and type(meta.skill)=='number'and meta.skill<=herb.rank and meta.skill>=math.max(0,herb.rank-75)then
     local have=E.Call(C_Item and C_Item.GetItemCount or GetItemCount,meta.item,false)
     if (not E.Public or E.Public(have))and type(have)=='number'then s.inventory[meta.item]=have;s.sharedReserves[meta.item]=20 end
    end
   end
  end
  return s
 end
 local plan=Q.Plan
 function Q.Plan(s)
  local p=plan(s)
  for id,target in pairs(s.sharedReserves or{})do
   local have=s.inventory[id]or 0
   if have<target and not p.needs[id]then p.needs[id]={id=id,have=have,target=target,missing=target-have,professions={},optional=true}end
  end
  return p
 end
 -- All objective rows from the same quest share one card, including rows
 -- supplied by older route providers. Keep child identities for navigation.
 local apply=R.Apply
 function R.Apply(rows)
  local grouped,seen={},{}
  for _,row in ipairs(rows or{})do
   if row.quest and row.kind=='objective'and not row.complete then
    local g=seen[row.quest]
    if not g then
     g=clone(row);g.id='fq:'..row.quest..':objective:all';g.slot=nil;g.objectives={};g.mobIDs={}
     seen[row.quest]=g;grouped[#grouped+1]=g
    end
    for _,child in ipairs(row.objectives or{row})do g.objectives[#g.objectives+1]=child end
    for _,id in ipairs(row.mobIDs or{})do local found=false;for _,old in ipairs(g.mobIDs)do if old==id then found=true end end;if not found then g.mobIDs[#g.mobIDs+1]=id end end
   else grouped[#grouped+1]=row end
  end
  return apply(grouped)
 end
 local display=N.WorkflowLive
 function N.WorkflowLive(step)
  if not step or step.kind~='objective'or not step.quest or step.quest==97583 then return display(step)end
  local state=E.QuestState(step.quest)
  local goals=state and state.objectives
  if type(goals)~='table'then return display(step)end
  local row=clone(step);local lines={}
  for _,goal in ipairs(goals)do
   if (not E.Public or E.Public(goal.text)and E.Public(goal.finished)and E.Public(goal.numFulfilled)and E.Public(goal.numRequired))and goal.finished~=true and type(goal.text)=='string'and goal.text~=''then
    local label=goal.text;local have,total=goal.numFulfilled,goal.numRequired
    if type(have)=='number'and type(total)=='number'and total>0 and not label:find('%d+%s*/%s*%d+')then label=label..' ('..have..'/'..total..')'end
    lines[#lines+1]=label
   end
  end
  local data=ns.ForeverQuestData;local fact=data and data.quests and data.quests[step.quest]
  row.title=fact and fact.title or step.title
  if lines[1] then
   local label=lines[1]
   local progress=label:match('%((%d+%s*/%s*%d+)%)$') or label:match('^(%d+%s*/%s*%d+)%s+')
   row.actionHeadline=label:gsub('^%d+%s*/%s*%d+%s+',''):gsub('%s*%(%d+%s*/%s*%d+%)$','')
   row.actionContext=(progress and progress..' · ' or '')..row.title
   row.actionLine=label
  end
  if step.recommendationReason then lines[#lines+1]=step.recommendationReason end
  for _,counter in ipairs(step.resourceCounters or{})do lines[#lines+1]=counter.text end
  row.body=table.concat(lines,'\n')
  if step.craftingSections then row.craftingBody=row.body end
  if step.craftingShopping then
   row.body=(row.body~='' and row.body..'\n\n' or '')..step.craftingShopping
  end
  return row
 end
 ns.LiveObjectiveDisplay=N.WorkflowLive
end)(ADDON,GF)

-- Automatic quest marking disabled: client protected-action restriction.

-- Unified window controls, local review build.
;(function(_,ns)
local N,K,W,M,V=ns.NormalUI,ns.NavigationCompass,ns.WindowWorkflow,ns.KnownNodePins,ns.MapControls99
if not N or not K or not W or not M or not V then return end
local function sync()
 local f=N.settingsFrame;if not f then return end
 local toggle=K.worldNodesCheck
 if not toggle then
  toggle=N.MakeButton(f,'World Map Nodes',294)
  N.MakeCheckbox(toggle,false)
  K.worldNodesCheck=toggle
  toggle:SetPoint('TOPLEFT',f,'TOPLEFT',18,-390)
  toggle:SetSize(294,32)
  toggle:SetScript('OnClick',function()
   V.SetMode(V.Mode()=='Off' and 'World Map' or 'Off')
   sync()
  end)
 end
 toggle:SetCheckedVisual(V.Mode()=='World Map')
 if M.button then M.button:Hide()end
end
local settings=K.Settings
K.Settings=function(...)local v=settings(...);sync();return v end
if N.settingsFrame then N.settingsFrame:HookScript('OnShow',sync)end
local layout=W.Layout
W.Layout=function(...)
 local v=layout(...);if M.button then M.button:Hide()end
 local b=N.farmButton;if b then b:ClearAllPoints();b:SetPoint('BOTTOM',b:GetParent(),'BOTTOM',0,30);b:SetWidth(math.min(240,math.max(180,b:GetParent():GetWidth()-56)))end
 return v
end
N.WorkflowLayout=W.Layout
local function restore()
 if not Minimap then return end
 local b=_G.GrindingForeverMinimapButton
 if not b then
  b=CreateFrame('Button','GrindingForeverMinimapButton',Minimap);b:SetSize(32,32)
  local icon=b:CreateTexture(nil,'ARTWORK');icon:SetAllPoints(b);icon:SetTexture('Interface\\AddOns\\GrindingForever\\Media\\ControlForeverEmblem')
 end
 b:RegisterForClicks('LeftButtonUp','RightButtonUp')
 b:SetScript('OnClick',function(_,button)
  local S=ns.UI and ns.UI.Showcase;if not S then return end
  if button=='RightButton'then S.Show();if not N.settingsFrame:IsShown()then N.root.settings:GetScript('OnClick')()end else S.Toggle()end
 end)
 ns.db=ns.db or {};local d=ns.db;d.minimap=d.minimap or {}
 local function anchor()
  local a=math.rad(tonumber(d.minimap.minimapPos)or 140);local radius=Minimap:GetWidth()/2+10
  b:ClearAllPoints();b:SetPoint('CENTER',Minimap,'CENTER',math.cos(a)*radius,math.sin(a)*radius)
 end
 b:RegisterForDrag('LeftButton');b:SetScript('OnDragStart',function()
  b:SetScript('OnUpdate',function()
   local x,y=GetCursorPosition();local cx,cy=Minimap:GetCenter();local scale=Minimap:GetEffectiveScale()
   d.minimap.minimapPos=math.deg(math.atan2(y/scale-cy,x/scale-cx));anchor()
  end)
 end)
 b:SetScript('OnDragStop',function()b:SetScript('OnUpdate',nil);anchor()end)
 b:SetScript('OnUpdate',nil);b:SetFrameStrata('MEDIUM');b:SetFrameLevel(Minimap:GetFrameLevel()+10);anchor();b:Show();sync()
end
local f=CreateFrame('Frame');f:RegisterEvent('PLAYER_LOGIN');f:SetScript('OnEvent',restore)
end)(ADDON,GF)



-- Compact navigation and final display normalization.
;(function(_,ns)
 local N=ns.NormalUI;local W=ns.WindowWorkflow
 if not N or not W then return end
 local live=N.WorkflowLive
 N.WorkflowLive=function(step)
  local row=live(step);if not row or type(row.body)~='string'then return row end
  local function key(v)return (v or ''):lower():gsub('[%p%s]','')end
  local title=key(row.title)
  local function clean(body)
   local lines,seen={},{}
   for line in body:gmatch('[^\r\n]+')do local k=key(line);if k~=title and not seen[k]then lines[#lines+1]=line;seen[k]=true end end
   return table.concat(lines,'\n')
  end
  local copy={};for k,v in pairs(row)do copy[k]=v end
  copy.body=clean(row.body)
  if row.craftingBody then copy.craftingBody=clean(row.craftingBody)end
  return copy
 end
 local layout=W.Layout
 W.Layout=function(...)
  local value=layout(...);local r=N.root;if not r then return value end
  if not r.compactSwap31 then
   local b=N.MakeButton(r,'',22,function()W.SetView(W.recipeCompact and 'steps' or 'recipes')end)
   r.compactSwap31=b;b:SetSize(22,58);b:SetFrameLevel(r:GetFrameLevel()+30)
   b.glyph=b:CreateTexture(nil,'OVERLAY');b.glyph:SetSize(16,16);b.glyph:SetPoint('CENTER')
  end
  local b=r.compactSwap31;local recipe=W.recipeCompact==true
  b:ClearAllPoints();b:SetPoint('CENTER',recipe and r.panels[2]or r.panels[1],recipe and 'LEFT'or 'RIGHT',0,0)
  b.glyph:SetTexture((recipe and r.back.glyph or r.forward.glyph):GetTexture());b:SetShown(N.mode=='compact')
  return value
 end
 N.WorkflowLayout=W.Layout
end)(ADDON,GF)

;(function(_,ns)
local E,P,N=ns.Forever,ns.ProfessionGuide,ns.NormalUI
if not E or not P or not N then return end
local prep={dismissed={}}
ns.DungeonPrep=prep
local raid={["onyxias lair"]=true,["barrow deeps"]=true,["hyjal summit"]=true,
 ["molten core"]=true,["blackwing lair"]=true,["zulgurub"]=true,["ahnqiraj"]=true,
 ["temple of ahnqiraj"]=true,["ruins of ahnqiraj"]=true,naxxramas=true}
local function allowed(quest,level)
 local record=quest.reference or quest.record or {}
 local side=record.faction or record.side
 local faction=E.Call(UnitFactionGroup,'player')
 local _,class=E.Call(UnitClass,'player')
 local required=record.min_level or (type(record.requires)=='number' and record.requires) or 1
 return level>=required and (not record.classOnly or record.classOnly==class)
  and ((side~='Alliance' and side~='Horde') or side==faction)
  and (not ns.ForeverQuestPlanner or ns.ForeverQuestPlanner.AllowsQuest(quest.id,faction,record))
end
local function pending(instance,level)
 local rows,seen={},{}
 local data=ns.ForeverQuestData.quests
 local function add(row)
  if row.id and not seen[row.id] and allowed(row,level) then
   seen[row.id]=row
   rows[#rows+1]=row
  end
 end
 for _,row in ipairs(ns.DungeonQuestRows(instance,instance.name))do add(row)end
 for _,ref in ipairs(ns.DungeonReferencesFor(instance.name))do
  for _,fact in ipairs(ref.quests or {})do
   local row=seen[fact.id]
   if row then row.reference=fact
   else add({id=fact.id,name=fact.name,reference=fact,record=data[fact.id] or {}})end
  end
 end
 local out={}
 for _,row in ipairs(rows)do
  local state=E.QuestState(row.id)
  if allowed(row,level) and not state.inLog and not state.rewarded and state.status~='unavailable' then
   out[#out+1]=row
  end
 end
 return out
end
local function makeStep(quest,kind,loc,hint)
 local verb=kind=='accept' and 'Accept ' or kind=='turnin' and 'Turn In ' or ''
 local record=quest.record or {}
 local body=kind=='objective' and (record.objective or 'Complete the prerequisite in your quest log.')
  or hint or (loc and loc.name) or 'Location unavailable. Check the quest journal.'
 return {id='gf-dungeon-prep:'..kind..':'..quest.id,quest=quest.id,kind=kind,
  category='Dungeons',title=verb..quest.name,body=body,destination=loc}
end
local function stepsFor(instance,level)
 local steps,seen={},{}
 local data=ns.ForeverQuestData.quests
 local function step(quest,prerequisite)
  if seen[quest.id] or not allowed(quest,level) then return end
  seen[quest.id]=true
  local state=E.QuestState(quest.id)
  if state.rewarded then return end
  local start=not state.inLog
  if not start and not prerequisite then return end
  if not start and not state.ready then
   steps[#steps+1]=makeStep(quest,'objective')
   return
  end
  local hint,points=ns.DungeonQuestLocations(quest,start)
  local loc=E.Nearest(points,E.state) or points[1]
  steps[#steps+1]=makeStep(quest,start and 'accept' or 'turnin',loc,hint)
 end
 for _,quest in ipairs(pending(instance,level))do
  local chain=quest.reference and quest.reference.chain
  for _,link in ipairs(chain or {})do
   if link[1]~=quest.id then
    step({id=link[1],name=link[2] or ('Quest '..link[1]),record=data[link[1]] or {},
     reference=link[3] and {startPoint=link[3]} or nil},true)
   end
  end
  step(quest,false)
 end
 return steps
end
local function offer(level)
 local here=E.CurrentPosition()
 if not here then return end
 local best,bestDistance
 for name,instance in pairs(E.dungeons)do
  local key=ns.DungeonNameKey(name)
  if not prep.dismissed[key] and not raid[key] and instance.minimum and instance.maximum
   and level>=math.ceil((instance.minimum+instance.maximum)/2) and level<=instance.maximum then
   local entrance=ns.DungeonEntrance(instance)
   local distance=entrance and E.Distance(entrance,here)
   if distance and distance<3000 and (not bestDistance or distance<bestDistance)
    and #pending(instance,level)>0 then best,bestDistance=instance,distance end
  end
 end
 return best
end
local function finish()
 if prep.active then prep.dismissed[ns.DungeonNameKey(prep.active.name)]=true end
 prep.active=nil
 prep.resume=prep.saved
 prep.saved=nil
 prep.offer=nil
end
local refresh=P.Refresh
function P.Refresh(...)
 local normal=refresh(...)
 if not ns.DungeonQuestRows or not ns.DungeonQuestLocations or (ns.FarmingPlanner and ns.FarmingPlanner.route) then return normal end
 local level=E.Call(UnitLevel,'player') or 1
 if prep.active then
  local steps=stepsFor(prep.active,level)
  if #steps>0 then P.steps=steps;P.firstPending=steps[1].id;return steps end
  finish()
 end
 local clock=E.Call(GetTime) or 0
 if not prep.checked or clock-prep.checked>=5 or prep.level~=level then
  prep.checked,prep.level=clock,level
  local candidate=offer(level)
  if candidate~=prep.offer and candidate then
   prep.previous=N.model and N.model.index
  end
  prep.offer=candidate
 end
 if prep.offer then
  local instance=prep.offer
  local rows={{id='gf-dungeon-offer:'..instance.name,kind='dungeonPrepOffer',category='Dungeons',
   title='Get Quests for '..instance.name,body='Temporarily switch to gathering the available dungeon quests.'}}
  for _,row in ipairs(normal or {})do rows[#rows+1]=row end
  P.steps=rows;P.firstPending=rows[1].id;return rows
 end
 return normal
end
local done,skip=P.Done,P.Skip
function P.Done(...)
 if P.selected and P.selected.kind=='dungeonPrepOffer' and prep.offer then
  prep.saved=prep.previous
  if not prep.saved then
   for _,row in ipairs(P.steps or {})do
    if row.kind~='dungeonPrepOffer' then prep.saved=row.id;break end
   end
  end
  prep.active,prep.offer=prep.offer,nil
  return true
 end
 return done(...)
end
function P.Skip(...)
 if prep.active then finish();return true end
 if P.selected and P.selected.kind=='dungeonPrepOffer' and prep.offer then
  prep.dismissed[ns.DungeonNameKey(prep.offer.name)]=true;prep.offer=nil;return true
 end
 return skip(...)
end
local resync=N.Resync
function N.Resync(...)
 local value=resync(...)
 if prep.resume and N.model then
  N.model.index=prep.resume;prep.resume=nil
  N.model:Reconcile()
  N.Refresh()
 end
 return value
end
end)(ADDON,GF)
