-- Value-only presentation reads. This module owns no gameplay or saved state.
local _, ns = ...
ns.Presentation = ns.Presentation or {}
local function text(value)
    if type(value) == "string" and value ~= "" then return value end
end
local function read(fn, ...)
    if type(fn) ~= "function" then return nil end
    local ok, value = pcall(fn, ...)
    if ok then return value end
end
local function guideSnapshot()
    local out = {schemaVersion=1, status="no-guide"}
    local g = ns.activeGuide
    if type(g) ~= "table" then return out end
    out.identifier = text(g.key)
    local faction = text(read(ns.Faction))
    out.title = text(type(g.displayNames)=="table" and faction and g.displayNames[faction:lower()])
        or text(g.displayName) or text(g.name)
    out.character = {faction=faction, class=text(read(ns.Class))}
    local level = read(ns.Level)
    if type(level)=="number" and level==level and level>0 and level<10000 then out.character.level=level end
    local fn = type(ns.Guide)=="table" and ns.Guide.CurrentStep
    if type(fn)~="function" then out.status="unavailable";return out end
    local ok, step, steps = pcall(fn)
    if not ok or type(steps)~="table" then out.status="unavailable";return out end
    out.total = #steps
    local index = ns.activeStepIndex
    if type(index)=="number" and index%1==0 and index>=1 and index<=out.total then out.index=index end
    out.stepText = text(read(type(ns.Loader)=="table" and ns.Loader.StepDisplayText, step))
    out.status = out.total==0 and "empty" or (type(step)=="table" and out.index and "ready" or "no-step")
    return out, step, steps
end
function ns.Presentation.ReadGuide()
    local out,_,steps=guideSnapshot()
    -- Bounded value-only rows from the same filtered sequence as progress.
    -- No raw source indexes, mutable steps, selection or progression writes.
    if type(steps)=="table" and out.index then
        out.rows={}
        local first=out.index
        for i=first,math.min(#steps,first+23) do
            local value=text(read(type(ns.Loader)=="table" and ns.Loader.StepDisplayText,steps[i]))
            if value and value:gsub("^%s*%d+%.?%s*",""):gsub("[%s|\\%p]","")~="" then
                out.rows[#out.rows+1]={index=i,text=value,current=i==out.index}
            end
        end
    end
    return out
end
local function positive(v)
    return type(v)=="number" and v==v and v>0 and v<2147483647 and v%1==0
end
local function quantity(v)
    if type(v)=="number" and v==v and v>=0 and v<=1e9 then return v end
end
-- Objective data is display-only; quest references come from the matching step,
-- while names/counts must be supplied by guarded live client reads.
function ns.Presentation.ReadObjective()
    local out,step=guideSnapshot()
    out.notes={};out.quests={}
    if type(step)~="table" then return out end
    local loader=type(ns.Loader)=="table" and ns.Loader or {}
    local api=type(C_QuestLog)=="table" and C_QuestLog or {}
    local seen,notes={},{}
    for _,el in ipairs(type(step.elements)=="table" and step.elements or {}) do
        if type(el)=="table" and read(loader.PlayerMatchesFilter,el.filters or {})==true then
            if el.tag=="text" then
                local note=text(read(loader.CleanMarkup,el.text))
                if note and note~=out.stepText and not notes[note] then
                    out.notes[#out.notes+1]=note;notes[note]=true
                end
            end
            if (el.tag=="accept" or el.tag=="turnin" or el.tag=="complete") and positive(el.questId) and not seen[el.questId] then
                local id=el.questId
                seen[id]=true
                local quest={id=id,objectives={}}
                local index=read(api.GetLogIndexForQuestID or GetQuestLogIndexByID,id)
                local info=positive(index) and read(api.GetInfo,index)
                local verified=type(info)=="table" and info.questID==id and not info.isHeader
                if verified then quest.title=text(info.title) end
                if verified or read(api.IsOnQuest,id)==true then
                    local objectives=read(api.GetQuestObjectives,id)
                    if type(objectives)=="table" then
                        for i=1,32 do
                            local o=objectives[i]
                            if type(o)=="table" then
                                local count,required=quantity(o.numFulfilled),quantity(o.numRequired)
                                if count and required then
                                    quest.objectives[#quest.objectives+1]={index=i,count=count,required=required}
                                end
                            end
                        end
                    end
                end
                out.quests[#out.quests+1]=quest
            end
        end
    end
    return out
end

function ns.Presentation.ReadNavigation()
    local out={schemaVersion=1,status="unavailable"}
    local map=type(ns.Map)=="table" and ns.Map or {}
    local value=read(map.GetNavigationSnapshot)
    if type(value)~="table" then return out end
    local statuses={active=true,arrived=true,hidden=true,pending=true,
        ["no-destination"]=true,["position-unavailable"]=true,
        ["world-unavailable"]=true,["another-continent"]=true}
    if statuses[value.status] then out.status=value.status end
    if type(value.hasDestination)=="boolean" then out.hasDestination=value.hasDestination end
    if type(value.arrowShown)=="boolean" then out.arrowShown=value.arrowShown end
    if out.hasDestination then
        if positive(value.mapID) then out.mapID=value.mapID end
        for _,field in ipairs({"xPercent","yPercent"}) do
            local v=value[field]
            if type(v)=="number" and v==v and v>=0 and v<=100 then out[field]=v end
        end
        out.description=text(value.description)
        local yards=quantity(value.distanceYards)
        if yards then out.distance=yards;out.unit="yd" end
    end
    return out
end
