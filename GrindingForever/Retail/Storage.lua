-- Separate Retail settings only. No Classic reads/migration, cursors or recordings.
local _,ns=...
local S={}
ns.Retail.Storage=S
local function defaults()
    return {schemaVersion=1,showWindow=true,arrow=false,framePoint={"CENTER",0,120},
        arrowPoint={"CENTER",0,80},minimap={hide=false}}
end
local function finite(v) return type(v)=="number" and v==v and math.abs(v)<1e7 end
local points={CENTER=true,TOP=true,BOTTOM=true,LEFT=true,RIGHT=true,
    TOPLEFT=true,TOPRIGHT=true,BOTTOMLEFT=true,BOTTOMRIGHT=true}
local function point(v)
    return type(v)=="table" and points[v[1]] and finite(v[2]) and finite(v[3])
        and (v[4]==nil or points[v[4]])
end
local function size(v)
    return type(v)=="table" and finite(v[1]) and finite(v[2]) and v[1]>0 and v[2]>0
end
local function layout(v)
    if v==nil then return true end
    if type(v)~="table" or v.schemaVersion~=1 then return false end
    for _,key in ipairs({"main","zone"}) do
        local row=v[key]
        if row~=nil then
            if type(row)~="table" then return false end
            for _,field in ipairs({"width","height","left","bottom","x","y"}) do
                if row[field]~=nil and not finite(row[field]) then return false end
            end
            if row.visible~=nil and type(row.visible)~="boolean" then return false end
        end
    end
    return true
end
function S.Open(raw)
    if raw==nil then return defaults(),true end
    if type(raw)~="table" or getmetatable(raw)~=nil or raw.schemaVersion~=1 then
        return defaults(),false,"Unsupported Retail settings preserved; using session settings."
    end
    for _,field in ipairs({"showWindow","arrow"}) do
        if raw[field]~=nil and type(raw[field])~="boolean" then
            return defaults(),false,"Malformed Retail settings preserved; using session settings."
        end
    end
    if (raw.framePoint~=nil and not point(raw.framePoint))
        or (raw.arrowPoint~=nil and not point(raw.arrowPoint))
        or (raw.frameSize~=nil and not size(raw.frameSize))
        or not layout(raw.showcaseLayout)
        or (raw.minimap~=nil and (type(raw.minimap)~="table"
            or (raw.minimap.hide~=nil and type(raw.minimap.hide)~="boolean"))) then
        return defaults(),false,"Malformed Retail settings preserved; using session settings."
    end
    -- Preserve unknown fields and supported saved object identity; never prune data.
    for key,value in pairs(defaults()) do if raw[key]==nil then raw[key]=value end end
    return raw,true
end
