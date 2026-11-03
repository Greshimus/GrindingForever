-- Deliberately empty active catalog. No legacy registration globals or pending replay.
local _,ns=...
ns.Loader={
    CleanMarkup=function(value) return type(value)=="string" and value or "" end,
    StepDisplayText=function(step) return type(step)=="table" and step.title or nil end,
    PlayerMatchesFilter=function() return false end,
}
local function empty() return {} end
local function unavailable() ns.Print("Retail catalog is empty. No guides are enabled.") end
ns.Guide={CurrentStep=function() return nil,{} end,Eligible=empty,ActiveHelpers=empty,
    Next=unavailable,Prev=unavailable,StepNext=unavailable,StepPrev=unavailable,
    SetActive=unavailable,Refresh=function() end}
