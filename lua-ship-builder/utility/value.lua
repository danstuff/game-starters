--get what's left of a string before a key
function Util.bef(str, key)
    if str:find(key) == nil then return str end
    return str:sub(1, str:find(key)-1)
end

--get what's left of a string after a key
function Util.aft(str, key)
    if str:find(key) == nil then return "" end
    return str:sub(str:find(key)+#key, #str)
end

--if a string can be converted to a number, convert it
function Util.snum(val)
    if val == "true" then return 1 end
    if val == "false" then return 0 end
    if val == "nil" then return nil end

    if tonumber(val) == nil then return val
    else return tonumber(val) end
end

function Util.sbool(val)
    if val == 0 or val == "false" then return false end
    if val == 1 or val == "true" then return true end
    return val
end

--cap a number to a specfic range
function Util.range(val, min, max)
    if val > max then return max
    elseif val < min then return min end
    return val
end

--split a string based on a substring
function Util.split(str, sub)
    local tbl = {}

    --default to whitespace
    if sub == nil then sub = "%s" end

    for s in string.gmatch(str, "([^"..sub.."]+)") do
        table.insert(tbl, Util.snum(s))
    end

    return tbl
end

--position builder function
function Util.pt(x, y, r)
    return { x = x, y = y, r = r}
end

--sum two positions
function Util.ptadd(a, b)
    a.x = a.x + b.x
    a.y = a.y + b.y
    a.r = a.r + b.r
end

--round to a certain # of decimals
function Util.rou(val, dp)
    local dig = math.pow(10, dp)
    return math.floor(val*dig + 0.5)/dig
end

--limit how small a value can get before it becomes 0
function Util.zlim(val)
    if math.abs(val) < ZERO_LIMIT then
        val = 0
    end

    return val
end

--rotate one point about another
function Util.about(px, py, dx, dy, rot, ox, oy)
    if rot == 0 then return px+dx, py+dy end

    --pre-calculate sin and cos of rot
    local esinr = math.sin(rot)
    local ecosr = math.cos(rot)

    --appply offset if one exists
    if ox ~= nil then dx = dx+ox end
    if oy ~= nil then dy = dy+oy end

    --make sure dividing by 0 isnt a problem
    if dx == 0 then dx = 0.00000000000001 end
    if dy == 0 then dy = 0.00000000000001 end

    --preserve the sign of the x value
    local sx = dx/math.abs(dx)

    --calculate slope
    local m = dy/dx

    --calculate amplitude
    local amp = math.sqrt(dx*dx + dy*dy)

    --calculate rotated position
    local div = math.sqrt(1 + m*m)
    local cosr = (ecosr - m*esinr) / div
    local sinr = (m*ecosr + esinr) / div

    --round to nearest x, y
    local wx = px + math.floor(sx * amp * cosr + 0.5)
    local wy = py + math.floor(sx * amp * sinr + 0.5)

    --remove offset if one exists
    if ox ~= nil then wx = wx-ox end
    if oy ~= nil then wy = wy-oy end

    return wx, wy
end

--for testing function performance
local start_time = nil
function Util.perfCheck(func_name)
    if start_time == nil then
        start_time = love.timer.getTime()
    else
        local dt_ms = (love.timer.getTime() - start_time)*1000
        start_time = nil

        if dt_ms > 0.1 then 
            print(func_name.." took "..dt_ms.."ms!!!")
        else
            print(func_name.." took "..dt_ms.."ms")
        end
    end
end
