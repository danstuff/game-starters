local Physics = {}

TimeField = require("world/timefield")

function Physics.getZeroedCross(line, ptx, pty)
    --position the point and line relative to the origin
    --local a = { x = line.x1 - line.x0, y = line.y1 - line.y0 }
    --local b = { x = pt.x - line.x0, y = pt.y - line.y0 }

    --calcluate the cross product of the two zeroed lines
    --positive result = left of line
    --negative result = right of line
    --zero result = on line
    return (line.x1 - line.x0)*(pty - line.y0) - (ptx - line.x0)*(line.y1 - line.y0)
end

function Physics.doLinesTouch(linea, lineb)
    local b0_res = Physics.getZeroedCross(linea, lineb.x0, lineb.y0)
    local b0_on = math.abs(b0_res) < 0.0001 
    local b0_rt = b0_res < 0 

    local b1_res = Physics.getZeroedCross(linea, lineb.x1, lineb.y1)
    local b1_on = math.abs(b1_res) < 0.0001 
    local b1_rt = b1_res < 0 

    return b0_on or b1_on or (b0_rt ~= b1_rt)
end

function Physics.getIntersection(linea, lineb)
    --set two equations of y - yo = m(x - xo) equal to each other and solve
    if linea.y1 - linea.y0 ~= 0 and linea.x1 - linea.x0 ~= 0 then 
        local ma = (linea.y1 - linea.y0) / (linea.x1 - linea.x0)
        local mb = (lineb.y1 - lineb.y0) / (lineb.x1 - lineb.x0)

        local mai = (linea.x1 - linea.x0) / (linea.y1 - linea.y0)
        local mbi = (lineb.x1 - lineb.x0) / (lineb.y1 - lineb.y0)

        local y = (linea.x0 - linea.y0/ma - lineb.x0 + lineb.y0/mb) / (mbi - mai)
        local x = (linea.y0 - linea.x0*ma - lineb.y0 + lineb.x0*mb) / (mb - ma)

        return { x = x, y = y }
    end

    return nil
end

function Physics.doBoxesIntersect(boxa, boxb)
    --simple box intersection test
    local acx = (boxa.x0 + boxa.x1)/2
    local acy = (boxa.y0 + boxa.y1)/2
    local bcx = (boxb.x0 + boxb.x1)/2
    local bcy = (boxb.y0 + boxb.y1)/2

    local wsum = math.abs(boxa.x1 - boxa.x0) + math.abs(boxb.x1 - boxb.x0)
    local hsum = math.abs(boxa.y1 - boxa.y0) + math.abs(boxb.y1 - boxb.y0)

    return
    ( math.abs(acx - bcx)*2 < wsum and
    math.abs(acy - bcy)*2 < hsum )
end

function Physics.doCirclesIntersect(x0, y0, radius0, x1, y1, radius1)
    return math.sqrt((x1-x0)^2+(y1-y0)^2) < radius0+radius1
end

function Physics.doLinesIntersect(linea, lineb)
    return Physics.doBoxesIntersect(linea, lineb)
    and Physics.doLinesTouch(linea, lineb)
    and Physics.doLinesTouch(lineb, linea)
end

function Physics.getBounceAngle(rot, wall_rot)
    --inverses of vector rotation and wall rotation 
    local inv_rot
    if rot > 0 then inv_rot = rot - math.pi
    else inv_rot = rot + math.pi end

    local inv_wrot
    if wall_rot > 0 then inv_wrot = wall_rot - math.pi
    else inv_wrot = wall_rot + math.pi end

    --angle measurements for each side of the wall
    local side0 
    if wall_rot < inv_rot then side0 = math.abs(inv_rot - wall_rot)
    else side0 = math.abs(wall_rot - inv_rot) end

    local side1
    if inv_wrot < inv_rot then side1 = math.abs(inv_rot - inv_wrot)
    else side1 = math.abs(inv_wrot - inv_rot) end

    local frot

    --use the smaller difference between sides
    if side0 < side1 then
        --ensure reflection is on same side of wall
        if inv_rot > wall_rot then
            frot = inv_wrot - side0
        else
            frot = inv_wrot + side0 
        end
    else
        if inv_rot > inv_wrot then 
            frot = wall_rot - side1
        else
            frot = wall_rot + side1
        end
    end

    return frot
end

return Physics
