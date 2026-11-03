-- Isolated TBC Anniversary bootstrap. The Classic bootstrap is not part of this build.
local ADDON,ns=...
_G.GrindingForever=ns
ns.name=ADDON;ns.version="1.4.8-retail-r1";ns.build=ns.Retail.Target.buildID
ns.game="UNKNOWN";ns.guides={};ns.routes={};ns.functions={};ns.DB={}
ns.Native={gameplayEnabled=false}
ns.Print=function(message)
    if DEFAULT_CHAT_FRAME then DEFAULT_CHAT_FRAME:AddMessage("|cffc49a58Grinding Forever:|r "..message) end
end
local client=ns.Retail.Compatibility.New(_G)
ns.Retail.Client=client
ns._listeners={}
function ns.RegisterMessage(event,fn)
    ns._listeners[event]=ns._listeners[event] or {}
    table.insert(ns._listeners[event],fn)
end
function ns.SendMessage(event,...)
    for _,fn in ipairs(ns._listeners[event] or {}) do
        local ok=pcall(fn,event,...)
        if not ok then ns.Print("TBC event handler failed; stop client testing and report the event.") end
    end
end
function ns.PlayerPosition()
    local value=client.PlayerPosition()
    if value.status=="available" then return value.mapID,value.x*100,value.y*100 end
    return value.mapID,nil,nil
end
function ns.QuestDone(id) return client.QuestState(id).rewarded end
function ns.IsOnQuest(id) return client.QuestState(id).inLog end
function ns.Faction() return client.Character().faction or "Unknown" end
function ns.Race() return client.Character().race or "Unknown" end
function ns.Class() return client.Character().class or "Unknown" end
function ns.Level() return client.Character().level end
function ns.StripColors(value)
    return type(value)=="string" and value:gsub("|c%x%x%x%x%x%x%x%x",""):gsub("|r","") or ""
end
local function initialize()
    if ns.Retail.initialized then return end
    ns.Retail.initialized=true
    local identity=client.Detect();ns.Retail.identity=identity
    local target=ns.Retail.Target
    ns.gameVersion=identity.interface
    if identity.flavor~="CLASSIC" or WOW_PROJECT_ID~=target.projectID
        or identity.interface~=target.interface or identity.version~=target.version or identity.build~=target.build then
        ns.Retail.blocked=true
        ns.Print("TBC Anniversary inactive: client does not match the reviewed target. No settings loaded.")
        return
    end
    ns.game="TBC"
    local db,writable,message=ns.Retail.Storage.Open(GrindingForeverAnniversaryDB)
    ns.db=db;ns.Retail.storageWritable=writable
    if writable then GrindingForeverAnniversaryDB=db end
    ns.Retail.ready=true
    ns.SendMessage("GF_LOADED")
    if message then ns.Print(message) end
end
local boot=CreateFrame("Frame")
boot:RegisterEvent("ADDON_LOADED");boot:RegisterEvent("PLAYER_LOGIN");boot:RegisterEvent("PLAYER_ENTERING_WORLD")
boot:SetScript("OnEvent",function(_,event,name)
    if event=="ADDON_LOADED" and name==ADDON then initialize()
    elseif ns.Retail.ready then
        if event=="PLAYER_LOGIN" then
            ns.SendMessage("GF_LOGIN");ns.Print("TBC Anniversary: Pally Master 1-70 ready. Quest actions advance from game observations. /gf done confirms manual steps.")
        elseif event=="PLAYER_ENTERING_WORLD" then ns.SendMessage("GF_ENTERING_WORLD") end
    end
end)
SLASH_GRINDINGFOREVER1="/grindingforever";SLASH_GRINDINGFOREVER2="/gf"
SlashCmdList.GRINDINGFOREVER=function(message)
    if not ns.Retail.ready then ns.Print("TBC Anniversary inactive; verify the reviewed target client.");return end
    message=(message or ""):lower():match("^%s*(.-)%s*$")
    if message=="ui original" then ns.UI.Showcase.Original()
    elseif message=="ui showcase" or message:match("^ui showcase%s") then ns.UI.Showcase.Command(message:sub(12))
    elseif message=="" or message=="toggle" then ns.UI.Toggle()
    elseif message=="show" then ns.UI.Show()
    elseif message=="hide" then ns.UI.Hide()
    elseif message=="arrow" then ns.Map.ToggleArrow()
    elseif message=="guides" or message=="eligible" then ns.Print("Pally Master: Human Paladin, 1-70, Blacksmithing/Mining/Cooking/Fishing/First Aid.")
    elseif message=="diagnose" then ns.Print("Retail R1 target matched; catalog=0 recording=disabled gameplay=disabled.")
    elseif message:match("^native") then ns.Print("Observer, Recorder and native gameplay are unavailable in this alpha.")
    else ns.Print("TBC Anniversary commands: show, hide, toggle, arrow, guides, diagnose, ui original, ui showcase.") end
end
