-- TBC Anniversary adapter and blended guide. Reads only; gameplay stays manual.
local _,ns=...
local D=assert(ns.TBCData)
local P={steps={},active=false,skills={},book={},selected=nil}
ns.ProfessionGuide=P
local C=ns.Retail.Client
local function read(fn,...)if type(fn)=='function'then local ok,a,b,c,d,e,f,g,h,i,j,k,l,m,n=pcall(fn,...);if ok then return a,b,c,d,e,f,g,h,i,j,k,l,m,n end end end
local function count(id)local n=read((C_Item and C_Item.GetItemCount)or GetItemCount,id,false);return type(n)=='number'and n or nil end
local function itemName(id)return read((C_Item and C_Item.GetItemInfo)or GetItemInfo,id)or('Item '..id)end
local function provider()
 if QuestieLoader and QuestieLoader.ImportModule then return read(QuestieLoader.ImportModule,QuestieLoader,'QuestieDB')end
end
local function zoneProvider()
 if QuestieLoader and QuestieLoader.ImportModule then return read(QuestieLoader.ImportModule,QuestieLoader,'ZoneDB')end
end
-- Enumerate the client geography, not a Forever zone list or modern-world maps.
for _,continent in ipairs({1414,1415,1945})do
 for _,m in ipairs(read(C_Map and C_Map.GetMapChildrenInfo,continent,3,true)or {})do
  if m.mapType==3 and type(m.name)=='string'and type(m.mapID)=='number'then
   local zones=zoneProvider();local area=zones and read(zones.GetAreaIdByUiMapId,zones,m.mapID)
   if area then D.areas[area]=m.mapID end
   D.zones[m.name]={id=area,mapID=m.mapID,v=1,aspect=1.5}
  end
 end
end
local npcCache={}
local function npc(id)
 if npcCache[id]then return npcCache[id]end
 local db=provider();if not db or not db.QueryNPCSingle then return end
 local name=read(db.QueryNPCSingle,id,'name');local spawns=read(db.QueryNPCSingle,id,'spawns');local side=read(db.QueryNPCSingle,id,'friendlyToFaction')
 if not name or type(spawns)~='table'then return end
 local out={name=name,spawns=spawns,faction=side=='A'and'Alliance'or side=='H'and'Horde'or side=='AH'and'Neutral'or nil};npcCache[id]=out;return out
end
local function locations(id,kind)
 local n=npc(id);local out={};if not n then return out end
 for area,points in pairs(n.spawns)do
  local map=D.areas[area];local zone
  for name,info in pairs(D.zones)do if info.id==area then zone=name;break end end
  if map and zone and points[1]and type(points[1][1])=='number'and type(points[1][2])=='number'then
   out[#out+1]={name=n.name,npcID=id,source=kind,faction=n.faction,mapID=map,zone=zone,x=points[1][1],y=points[1][2]}
  end
 end
 table.sort(out,function(a,b)return a.mapID<b.mapID end);return out
end
local function nearest(ids,kind)
 local pos=C.PlayerPosition();local wi,wx,wy
 if pos.status=='available'then wi,wx,wy=C.WorldPosition(pos.mapID,pos.x*100,pos.y*100)end
 local best,dist
 for _,id in ipairs(ids)do for _,v in ipairs(locations(id,kind))do
  if v.faction=='Alliance'or v.faction=='Neutral'then
   local i,x,y=C.WorldPosition(v.mapID,v.x,v.y)
   local d=wi and i==wi and x and y and math.sqrt((x-wx)^2+(y-wy)^2)or math.huge
   if not best or d<dist then best,dist=v,d end
  end
 end end
 return best,dist
end
local trainers={Blacksmithing={514,5511,4258},Mining={5513,4254},Cooking={1430,5482,1355},Fishing={1651,5493,5161},['First Aid']={2329,5484,5150}}
local primary={Blacksmithing=true,Mining=true}
local function saved()
 if not P.active then return end
 local db=GrindingForeverAnniversaryCharacterDB
 if db==nil then db={version=1,guide=D.inputHash,manual={},cursor=1};GrindingForeverAnniversaryCharacterDB=db end
 if type(db)~='table'or db.version~=1 or db.guide~=D.inputHash or type(db.manual)~='table'then
  P.session=P.session or {version=1,guide=D.inputHash,manual={},cursor=1};return P.session
 end
 return db
end
function P.ReadSkills()
 local skills={};P.primaryCount=0
 if GetProfessions and GetProfessionInfo then
  local ids={read(GetProfessions)}
  for _,index in pairs(ids)do if type(index)=='number'then
   local name,_,rank,cap,_,_,line=read(GetProfessionInfo,index)
   for _,p in ipairs(D.professions)do if line==p.skill_line then skills[p.name]={rank=rank,cap=cap,learned=true}end end
  end end
  for i=1,2 do if ids[i]then P.primaryCount=P.primaryCount+1 end end
 end
 if GetNumSkillLines and GetSkillLineInfo then
  for i=1,(read(GetNumSkillLines)or 0)do
   local name,header,_,rank,_,_,cap,_,_,_,_,_,_,line=read(GetSkillLineInfo,i)
   if not header then for _,p in ipairs(D.professions)do
    if name==p.name or line==p.skill_line then skills[p.name]={rank=rank,cap=cap,learned=true}end
   end end
  end
 end
 P.skills=skills;return skills
end
local function recipeFromBook(i,craft)
 local name,kind,_,available
 if craft then name,_,kind,_,available=read(GetCraftInfo,i)else name,kind,available=read(GetTradeSkillInfo,i)end
 if not name or kind=='header'or kind=='trivial'then return end
 local link=read(craft and GetCraftItemLink or GetTradeSkillItemLink,i)
 local product=link and tonumber(link:match('item:(%d+)'));local mats={};local enough=true;local missing=0
 for j=1,(read(craft and GetCraftNumReagents or GetTradeSkillNumReagents,i)or 0)do
  local title,_,need,have=read(craft and GetCraftReagentInfo or GetTradeSkillReagentInfo,i,j)
  local reagentLink=read(craft and GetCraftReagentItemLink or GetTradeSkillReagentItemLink,i,j)
  local id=reagentLink and tonumber(reagentLink:match('item:(%d+)'))
  if id and type(need)=='number'then
   local bags=count(id);mats[#mats+1]={id=id,name=title or itemName(id),need=need,have=bags}
   if not bags or bags<need then enough=false;missing=missing+(bags and math.max(0,need-bags)or need)end
  else enough=false end
 end
 if #mats==0 then return end
 return {name=name,product=product,mats=mats,enough=enough,missing=missing,kind=kind,available=available}
end
function P.ReadBook()
 if read(GetTradeSkillIsLinked)==true or read(C_TradeSkillUI and C_TradeSkillUI.IsTradeSkillLinked)==true then return end
 local name=read(GetTradeSkillLine)
 if name and name~='UNKNOWN'and GetNumTradeSkills then
  local values={};for i=1,(read(GetNumTradeSkills)or 0)do local r=recipeFromBook(i,false);if r then values[#values+1]=r end end
  if P.skills[name]then P.book[name]={rank=P.skills[name].rank,values=values}end
 end
 local craftName=read(GetCraftDisplaySkillLine)
 if craftName and P.skills[craftName]and GetNumCrafts then
  local values={};for i=1,(read(GetNumCrafts)or 0)do local r=recipeFromBook(i,true);if r then values[#values+1]=r end end
  P.book[craftName]={rank=P.skills[craftName].rank,values=values}
 end
end
local function candidate(name)
 local cache=P.book[name];local rows=cache and P.skills[name]and cache.rank==P.skills[name].rank and cache.values or {};local best
 for _,r in ipairs(rows)do
  local skill=P.skills[name];local known=read(IsSpellKnown,r.spellID)
  -- The open personal book, not a static source table, establishes recipe ownership.
  if not best or (r.enough and not best.enough)or(r.enough==best.enough and r.missing<best.missing)then best=r end
 end
 return best
end
local gathering={{1,'Copper',1731},{65,'Tin',1732},{75,'Silver',1733},{125,'Iron',1735},{155,'Gold',1734},{175,'Mithril',2040},{230,'Truesilver',2047},{245,'Small Thorium',324},{275,'Rich Thorium',175404},{300,'Fel Iron',181555},{325,'Adamantite',181556}}
local function miningHint(rank,route)
 local eligible;for _,v in ipairs(gathering)do if rank>=v[1]then eligible=v end end
 if not eligible then return 'Learn Mining before following a node detour.'end
 local text='Skill-eligible ore: '..eligible[2]..' (requires '..eligible[1]..'). Keep ore and stone for Blacksmithing; compare smelting against current bar needs. Enable Find Minerals manually.\n'
 local db=provider();local pos=route and route.destination
 local best,dist
 if db and db.QueryObjectSingle and pos and route.area then
  for _,node in ipairs(gathering)do if rank>=node[1]then
   local spawns=read(db.QueryObjectSingle,node[3],'spawns');local points=spawns and spawns[route.area]
   for _,p in ipairs(points or {})do if type(p[1])=='number'and type(p[2])=='number'then
    local d=(p[1]-pos.x)^2+(p[2]-pos.y)^2
    if not dist or d<dist then best={name=node[2],x=p[1],y=p[2]};dist=d end
   end end
  end end
 end
 if best then text=text..string.format('Known %s spawn near this route stop: %.1f, %.1f in %s. Potential spawn only; approach only if terrain and enemies permit.',best.name,best.x,best.y,route.zone)
 else text=text..'Follow nearby exposed deposits rather than a long detour; no suitable spawn in this route area was verified.'end
 return text
end
local function milestone(p,level)
 local curve=p.curve;local at=math.min(level,#curve-1);local target=curve[at+1]or p.target
 local ceiling=level>=50 and 375 or level>=35 and 300 or level>=20 and 225 or level>=10 and 150 or 75
 return math.min(math.max(level>=p.start and 1 or 0,target or 0),ceiling,p.target)
end
local function professionNode(p,route,id)
 local skill=P.skills[p.name];local rank=skill and skill.rank or 0;local target=milestone(p,P.character.level)
 local node={id=id,title=p.name..' - '..rank..' / '..target,category=(p.key=='mining'or p.key=='fishing')and'Gathering'or'Crafting',kind='profession',profession=p.name,target=target,level=route.level}
 if P.character.level<p.start or target==0 then node.complete=true;node.body='Training starts at level '..p.start..'.';return node end
 if skill and rank>=target then node.complete=true;node.body='On pace. Continue the quest route.';return node end
 local trainer=nearest(trainers[p.name]or {},'Trainer')
 local place=trainer and (trainer.name..' - '..trainer.zone..string.format(' (%.1f, %.1f).',trainer.x,trainer.y))or'Trainer coordinates not available. Ask a city guard for your profession trainer.'
 local lines={p.name..': '..rank..' / '..(skill and skill.cap or '?')..'. Route pacing goal: '..target..'.'}
 if not skill then
  lines[#lines+1]=(primary[p.name]and P.primaryCount>=2)and'Both primary slots are occupied. Keep your chosen professions; this guide will not replace them.'or('Learn '..p.name..' manually. '..place)
  node.destination=trainer
 elseif rank>=skill.cap then
  lines[#lines+1]='Current trained cap reached. Check the next rank requirements at a trainer or the required book/quest before crafting more.'
  if p.key=='first_aid' or p.name=='First Aid'then lines[#lines+1]='Past 150: Expert First Aid book; Alliance vendor Deneb Walker in Arathi Highlands. Further bandage manuals and the Artisan triage quest have separate requirements.'end
  node.destination=trainer
 elseif p.key=='mining'then lines[#lines+1]=miningHint(rank,route);node.destination=route.destination
 elseif p.key=='fishing'then
  if rank<75 then
   lines[#lines+1]='Use the lake east of Goldshire: train with Lee Brown, buy a pole and a Shiny Bauble from Tharynn Bouden. Stay on accessible shore away from hostile creatures. Fish can escape if your effective skill is too low.'
   lines[#lines+1]='Save Raw Brilliant Smallfish and Raw Longjaw Mud Snapper for Cooking. Buy their recipes from Tharynn Bouden; verify your known cooking recipes and skill before cooking.'
   local loc=locations(1651,'Trainer');node.destination=loc[1]
  elseif rank<150 then
   lines[#lines+1]='Fish in Stormwind canals or Ironforge after training Journeyman Fishing. These city waters supply Longjaw Mud Snapper and Bristle Whisker Catfish for Cooking. Use a lure; verify the recipe skill before cooking. Prefer the capital already on your route.'
   node.destination=nearest({5493,5161},'Trainer')
  elseif rank<225 then
   lines[#lines+1]='Expert Fishing requires The Bass and You, sold by Old Man Heming in Booty Bay. If your route reaches Dustwallow Marsh or Stranglethorn Vale, fish accessible water away from hostile patrols; keep Rockscale Cod, Spotted Yellowtail or inland Mithril Head Trout when your Cooking recipes use them. Do not travel into higher-level danger only to follow a skill goal.'
  else
   lines[#lines+1]='Past 225, complete Nat Pagle, Angler Extreme in Dustwallow Marsh at level 35 or later. After unlocking Artisan, suitable higher-level options include Feralas, Tanaris and The Hinterlands; only use them when your quest route and effective skill make the trip practical. Read the actual fishing quest for its four fish. The route target stops at 300, as configured in your export.'
  end
 else
  local r=candidate(p.name)
  if r then
   lines[#lines+1]='Suggested learned, non-gray recipe: '..r.name..'. Make one craft, then recheck skill. Skill-ups are not guaranteed.'
   for _,m in ipairs(r.mats)do lines[#lines+1]=m.need..' x '..m.name..' (bags: '..tostring(m.have or 'unknown')..')'end
  else lines[#lines+1]='Open your personal '..p.name..' profession window to read known recipes and current reagent quantities. Filtered or closed books do not prove a recipe is unknown.'end
  if p.key=='blacksmithing'then
   lines[#lines+1]='Use a Blacksmith Hammer and a nearby anvil for equipment; use a forge for smelting. Goldshire: Smith Argus, 41.7, 65.6, has the smithy. Stone-only recipes may not need an anvil. Keep useful grinding stones for later crafts.'
   if route.zone=='Elwynn Forest'then node.destination={mapID=1429,x=41.7,y=65.6,name='Goldshire smithy - anvil / forge'}end
  elseif p.key=='cooking'then lines[#lines+1]='Use a cooking fire. Prefer fish or meat already in your bags that your known recipes use. Keep quest-required meat separate from ordinary cooking ingredients.'
  elseif p.name=='First Aid'then lines[#lines+1]='Save cloth dropped by humanoids along your quest route. Use known bandages appropriate to your current skill; reserve future cloth requirements before selling excess.'end
 end
 lines[#lines+1]='Optional profession stop. Done defers this checkpoint; observed skill gains complete it automatically. Quest actions and crafting are never automated.'
 node.body=table.concat(lines,'\n\n');return node
end
local function observed(node)
 if not node.quest then
  if node.kind=='grind'then local level=ns.Level();return level and (level>node.level or level==node.level and (read(UnitXP,'player')or 0)>=(node.xp or math.huge))end
  return false
 end
 local state=C.QuestState(node.quest)
 if P.turned and P.turned[node.quest]then return true end
 if state.rewarded==true then return true end
 if node.kind=='accept'then return state.inLog==true end
 if node.kind=='objective'then
  if state.complete==true or state.ready==true then return true end
  local goals=read(C_QuestLog and C_QuestLog.GetQuestObjectives,node.quest)
  if type(goals)=='table'and node.slot and goals[node.slot]then return goals[node.slot].finished==true end
 end
 return false
end
function P.Refresh()
 P.character=C.Character();P.active=ns.Retail.ready==true and P.character.class=='PALADIN'and P.character.race=='Human'and P.character.faction=='Alliance'
 if not P.active then P.steps={};return P.steps end
 local state=saved();P.ReadSkills();P.ReadBook();P.steps={};P.firstPending=nil
 local checkpoint=0;local lastLevel=0;local lastZone
 for _,base in ipairs(D.steps)do
  local node={};for k,v in pairs(base)do node[k]=v end
  node.complete=state.manual[node.id]==true or observed(node)
  node.body=node.body..'\n\n'..(node.zone or 'Route')..' - expected level '..node.level..'. Source step '..node.routeIndex..' / '..#D.steps..'.'
  if node.quest then node.body=node.body..'\nQuest ID: '..node.quest end
  if node.destination then node.body=node.body..string.format('\nLocation: %.2f, %.2f. Arrow is straight-line guidance; follow roads and transport safely.',node.destination.x,node.destination.y)end
  if node.kind=='abandon'then node.body=node.body..'\nThis imported suggestion never abandons a quest automatically. Confirm it is appropriate before changing your log.'end
  if node.targetKind=='npc'and node.targetID and node.kind=='objective'then
   node.body=node.body..'\nHumanoid encounters may supply bandage cloth; keep any useful drops. No drop is guaranteed.'
  end
  P.steps[#P.steps+1]=node
  local trigger=node.level>=5 and (node.kind=='sell'or node.kind=='train')and(node.level>=lastLevel+5 or node.zone~=lastZone)
  if trigger then
   lastLevel=node.level;lastZone=node.zone;checkpoint=checkpoint+1
   for _,p in ipairs(D.professions)do
    local n=professionNode(p,node,'profession:'..checkpoint..':'..p.key)
    -- Checkpoints already behind the observed character remain deferrable but don't force old travel.
    n.complete=n.complete or state.manual[n.id]==true
    P.steps[#P.steps+1]=n
   end
  end
 end
 for _,n in ipairs(P.steps)do if not n.complete then P.firstPending=n.id;break end end
 P.target='route';return P.steps
end
function P.Destination()
 local n=P.selected
 if n and not n.complete and n.destination then return n.destination end
 for _,v in ipairs(P.steps)do if not v.complete then return v.destination end end
end
function P.SetEnabled()return false end
function P.Done()
 if not P.active then return false end
 local n=P.selected;if not n or n.complete then return false end
 if n.kind=='accept'or n.kind=='turnin'or n.kind=='objective'then ns.Print('Quest completion is observed from the game. Use /gf skip only if you deliberately want to defer this step.');return false end
 saved().manual[n.id]=true;return true
end
function P.Skip()if P.active and P.selected then saved().manual[P.selected.id]=true;return true end end
local function qid(id)return 'https://www.wowhead.com/tbc/spell='..id end
local seedVendors={[7751]={66,1684,5494},[7753]={66,1684,5494}}
function ns.BindTBCRecipes(N)
 if N.tbcBound then return end
 N.recipeRecords={};N.unlocatedRecipes={};local grouped={}
 for spell,f in pairs(ns.TBCRecipes)do
  local profession=ns.TBCProfessions[f.professionID]or'Unknown'
  local base={id=f.itemId or ('spell:'..spell),spellID=spell,productID=f.craftedItemId,name=f.name,profession=profession,
   requirement='Skill '..tostring(f.requiredSkill or '?'),confidence='TBC 2.5.6 client recipe; source leads need TBC/vendor verification',sourceURL=qid(spell)}
  local sourceSet={};for k,v in pairs(f.sources)do sourceSet[k]=v end
  if seedVendors[spell]then sourceSet.v=seedVendors[spell];base.confidence='TBC recipe; vendor list checked against TBC profession guide / Wowhead. Live stock and discounts may vary.'end
  for key,kind in pairs({v='Vendor',t='Trainer',d='Drop'})do
   for _,id in ipairs(sourceSet[key]or {})do
    for _,loc in ipairs(locations(id,kind))do
     if kind=='Drop'or loc.faction=='Alliance'or loc.faction=='Neutral'then
      local group=spell..':'..loc.zone
      if not grouped[group]then local copy={};for k,v in pairs(base)do copy[k]=v end;copy.zone=loc.zone;copy.locations={};copy.sources={};grouped[group]=copy end
      local record=grouped[group];record.locations[#record.locations+1]=loc;record.sources[#record.sources+1]=kind
     end
    end
   end
  end
  local db=provider()
  for _,quest in ipairs(sourceSet.q or {})do
   local finish=db and read(db.QueryQuestSingle,quest,'finishedBy')
   for _,id in ipairs(type(finish)=='table'and finish[1]or {})do
    for _,loc in ipairs(locations(id,'Quest'))do if loc.faction=='Alliance'or loc.faction=='Neutral'then
     loc.quest=read(db.QueryQuestSingle,quest,'name')or('Quest '..quest)
     local group=spell..':'..loc.zone
     if not grouped[group]then local copy={};for k,v in pairs(base)do copy[k]=v end;copy.zone=loc.zone;copy.locations={};copy.sources={};grouped[group]=copy end
     local record=grouped[group];record.locations[#record.locations+1]=loc;record.sources[#record.sources+1]='Quest'
    end end
   end
  end
  local found=false;for k in pairs(grouped)do if k:match('^'..spell..':')then found=true;break end end
  if not found then base.unlocated=true;base.sources={'Unknown'};base.acquisition='Open the TBC Wowhead recipe page for acquisition details. No validated location imported.';N.unlocatedRecipes[#N.unlocatedRecipes+1]=base end
 end
 for _,record in pairs(grouped)do N.recipeRecords[#N.recipeRecords+1]=record end
 table.sort(N.recipeRecords,function(a,b)return a.name<b.name end)
 -- Retry after optional Questie finishes loading, rather than freezing an empty location index.
 N.tbcBound=provider()~=nil
end
function ns.TBCMapTexture(mapID)
 local textures=read(C_Map and C_Map.GetMapArtLayerTextures,mapID,1)
 return type(textures)=='table'and textures[1]or 'Interface/Buttons/WHITE8X8'
end
function ns.RenderTBCMap(N,root)
 if N.unlocatedRecipe then if root.tbcTiles then for _,t in ipairs(root.tbcTiles)do t:Hide()end end;return end
 local entry=N.mapCatalog[N.selectedZone];if not entry then return end
 local layers=read(C_Map and C_Map.GetMapArtLayers,entry.mapID);local layer=layers and layers[1]
 local files=read(C_Map and C_Map.GetMapArtLayerTextures,entry.mapID,1)
 root.tbcTiles=root.tbcTiles or {}
 if not layer or not files or not layer.layerWidth or not layer.tileWidth then
  root.mapImage:Hide();for _,t in ipairs(root.tbcTiles)do t:Hide()end
  root.mapLabel:SetText('Native TBC map art unavailable');root.mapLabel:Show();return
 end
 root.mapImage:Hide();root.mapLabel:Hide();root.mapViewport:SetClipsChildren(true)
 local columns=math.ceil(layer.layerWidth/layer.tileWidth);local width,height=root.mapViewport:GetWidth(),root.mapViewport:GetHeight()
 for i,file in ipairs(files)do
  local t=root.tbcTiles[i]
  if not t then t=root.mapViewport:CreateTexture(nil,'BACKGROUND');root.tbcTiles[i]=t end
  local x=(i-1)%columns*layer.tileWidth/layer.layerWidth;local y=math.floor((i-1)/columns)*layer.tileHeight/layer.layerHeight
  local u,v=N.MapToViewport(x,y);t:SetTexture(file);t:SetTexCoord(0,1,0,1);t:ClearAllPoints()
  t:SetPoint('TOPLEFT',root.mapViewport,'TOPLEFT',u*width,-v*height)
  t:SetSize(width*layer.tileWidth/layer.layerWidth*N.mapZoom,height*layer.tileHeight/layer.layerHeight*N.mapZoom);t:Show()
 end
 for i=#files+1,#root.tbcTiles do root.tbcTiles[i]:Hide()end
end
local events=CreateFrame('Frame')
for _,event in ipairs({'QUEST_ACCEPTED','QUEST_TURNED_IN','QUEST_LOG_UPDATE','SKILL_LINES_CHANGED','TRADE_SKILL_UPDATE','CRAFT_UPDATE','BAG_UPDATE_DELAYED'})do pcall(events.RegisterEvent,events,event)end
events:SetScript('OnEvent',function(_,event,id)
 if event=='QUEST_TURNED_IN'and P.active then
  -- Observe the actual turn-in; never infer turn-in from disappearance from log.
  P.turned=P.turned or {};P.turned[id]=true
 end
 P.dirty=true
end)
local previous=SlashCmdList.GRINDINGFOREVER
SlashCmdList.GRINDINGFOREVER=function(message)
 local cmd=(message or''):lower():match('^%s*(.-)%s*$')
 if cmd=='done'or cmd=='skip'then
  if cmd=='done'then P.Done()else P.Skip()end
  if ns.NormalUI then ns.NormalUI.Resync()end
 elseif cmd=='route'then if ns.NormalUI then ns.NormalUI.Resync();ns.UI.Show()end
 else previous(message)end
end
ns.RegisterMessage('GF_LOGIN',function()
 P.Refresh()
 if ns.NormalUI then
  -- UI provides a visible completion control for manual profession/travel tasks.
  local parent=ns.NormalUI.root
 end
end)
