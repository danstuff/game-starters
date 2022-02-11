bit32 = require("bit")
local Util = {}

function Util.it(list, func, arg0, arg1, arg2)
    for _,mem in ipairs(list) do
        func(mem, arg0, arg1, arg2)
    end
end

function Util.delete(list, i)
    list[i] = nil
    table.remove(list, i)
end

function Util.copy(obj)
    local obj_typ = type(obj)
    local nobj = nil

    if obj_typ == "table" then
        nobj = {}
        for key, val in next, obj, nil do
            nobj[Util.copy(key)] = Util.copy(val)
        end
    else
        nobj = obj
    end

    return nobj
end

function Util.merge(t1, t2)
    local tn = {}

    for key,val in pairs(t1) do
        tn[Util.copy(key)] = Util.copy(val)
    end

    for key,val in pairs(t2) do
        tn[Util.copy(key)] = Util.copy(val)
    end

    return tn
end

function Util.angcap(ang)
    --ensure an angle is within [-pi, pi]
    local sign = ang / math.abs(ang) 
    ang = math.abs(ang)

    while ang > math.pi do
        ang = ang-math.pi
        sign = -1*sign
    end

    ang = nil
    return ang*sign
end

function Util.round(val, decplaces)
    local mult = 10^(decplaces or 0)
    return math.floor(val*mult + 0.5)/mult
end

function Util.abs(val)
    if val > 0 then return val
    else return -val end
end

function Util.rand(min, max)
    return math.random(min*10000.0, max*10000.0) / 10000.0
end

function Util.memstart(caption)
    if not initial_mem then initial_mem = {} end
    initial_mem[caption] = collectgarbage("count")
end

function Util.memend(caption, collect)
    if not initial_mem[caption] then return end

    if collect then collectgarbage() end
    local this_mem = collectgarbage("count")
    if this_mem > initial_mem[caption] then
        if fault_sound then love.audio.play(fault_sound) end
        print(caption .. tostring(this_mem-initial_mem[caption]))
    end
end

return Util
