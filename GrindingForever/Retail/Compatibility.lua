-- R1 read boundary. No events, persistence or UI/navigation ownership.
-- Callers inject the client API table. This module never changes global APIs.
local Compatibility = {}

function Compatibility.New(api)
    api = api or {}
    local adapter = {}
    local function query(fn, ...)
        if type(fn) ~= "function" then return nil, "missing-api" end
        local ok, value = pcall(fn, ...)
        if not ok then return nil, "api-error" end
        return value
    end
    local function public(value)
        -- No comparisons, formatting or coercion of a value before this check.
        if type(api.issecretvalue) ~= "function" then return api.WOW_PROJECT_ID==5 end
        local ok, secret = pcall(api.issecretvalue, value)
        return ok and secret == false
    end
    local function integer(value, minimum)
        return type(value) == "number" and value == value and value < math.huge
            and value >= minimum and value % 1 == 0
    end
    function adapter.Detect()
        -- Build metadata is public. Preserve all four returns (no and/or collapse).
        local out = {flavor="UNKNOWN", recordingEnabled=false, gameplayEnabled=false}
        if type(api.GetBuildInfo) == "function" then
            local ok, version, build, _, interface = pcall(api.GetBuildInfo)
            if ok then
                if type(version)=="string" and version:match("^[%d%.]+$") then out.version=version end
                if type(build)=="string" and build:match("^%d+$") then out.build=build end
                if integer(interface, 1) then out.interface=interface end
            end
        end
        local project, mainline = api.WOW_PROJECT_ID, api.WOW_PROJECT_MAINLINE
        if out.interface==16001 then
            out.flavor="FOREVER"
        elseif type(project)=="number" and type(mainline)=="number" and project==mainline then
            out.flavor="RETAIL"
        else
            for _, key in ipairs({"WOW_PROJECT_CLASSIC", "WOW_PROJECT_BURNING_CRUSADE_CLASSIC",
                "WOW_PROJECT_WRATH_CLASSIC", "WOW_PROJECT_CATACLYSM_CLASSIC"}) do
                if type(project)=="number" and type(api[key])=="number" and project==api[key] then
                    out.flavor="CLASSIC"
                end
            end
        end
        return out
    end
    function adapter.QuestState(questID)
        if not public(questID) then return {status="unavailable"} end
        if not integer(questID, 1) then return {status="invalid-id"} end
        local quest = type(api.C_QuestLog)=="table" and api.C_QuestLog or {}
        local out = {status="unavailable"}
        for field, name in pairs({inLog="IsOnQuest", rewarded="IsQuestFlaggedCompleted",
            complete="IsComplete", ready="ReadyForTurnIn"}) do
            local value = query(quest[name], questID)
            if public(value) and type(value)=="boolean" then out[field]=value;out.status="available" end
        end
        -- Unknown flags stay absent, never false. No log enumeration or recording.
        return out
    end
    function adapter.PlayerPosition()
        local map = type(api.C_Map)=="table" and api.C_Map or {}
        local mapID = query(map.GetBestMapForUnit, "player")
        if not public(mapID) or not integer(mapID, 1) then return {status="unavailable"} end
        local out = {status="map-only", mapID=mapID}
        local position = query(map.GetPlayerMapPosition, mapID, "player")
        if not public(position) or type(position)~="table" then return out end
        local ok, x, y = pcall(function()
            if type(position.GetXY)=="function" then return position:GetXY() end
            return position.x, position.y
        end)
        if ok and public(x) and public(y) and type(x)=="number" and type(y)=="number"
            and x==x and y==y and x>=0 and x<=1 and y>=0 and y<=1 then
            out.status, out.x, out.y = "available", x, y
        end
        return out -- Normalized coordinates only; no bearing/distance/waypoint writes.
    end
    function adapter.Number(value, minimum, maximum)
        if public(value) and type(value)=="number" and value==value
            and value>=minimum and value<=maximum then return value end
    end
    function adapter.Text(value)
        if public(value) and type(value)=="string" and #value<=1024
            and not value:find("[%c]") then return value end
    end
    function adapter.Character()
        local out={}
        local function token(fn)
            if type(fn)~="function" then return end
            local ok, _, file=pcall(fn,"player")
            if ok then return adapter.Text(file) end
        end
        out.race=token(api.UnitRace);out.class=token(api.UnitClass)
        local faction=query(api.UnitFactionGroup,"player")
        if public(faction) and (faction=="Horde" or faction=="Alliance" or faction=="Neutral") then
            out.faction=faction
        end
        local level=adapter.Number(query(api.UnitLevel,"player"),1,10000)
        if level and level%1==0 then out.level=level end
        return out -- No player names, realm names or GUIDs.
    end
    function adapter.WorldPosition(mapID, x, y)
        mapID=adapter.Number(mapID,1,2147483647)
        x=adapter.Number(x,0,100);y=adapter.Number(y,0,100)
        if not mapID or mapID%1~=0 or not x or not y then return end
        local map=type(api.C_Map)=="table" and api.C_Map or {}
        if type(api.CreateVector2D)~="function" or type(map.GetWorldPosFromMapPos)~="function" then return end
        local ok, instance, position=pcall(function()
            return map.GetWorldPosFromMapPos(mapID,api.CreateVector2D(x/100,y/100))
        end)
        if not ok then return end
        instance=adapter.Number(instance,0,2147483647)
        if not instance or not public(position) or type(position)~="table" then return end
        local valid, wx, wy=pcall(function()
            if type(position.GetXY)=="function" then return position:GetXY() end
            return position.x,position.y
        end)
        if valid then
            wx=adapter.Number(wx,-1e9,1e9);wy=adapter.Number(wy,-1e9,1e9)
            if wx and wy then return instance,wx,wy end
        end
    end
    function adapter.Facing()
        return adapter.Number(query(api.GetPlayerFacing),0,2*math.pi)
    end
    return adapter
end

local _, ns = ...
if type(ns)=="table" then
    ns.Retail=ns.Retail or {}
    ns.Retail.Compatibility=Compatibility
end
return Compatibility
