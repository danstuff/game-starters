local Wall = {}

Wall.mems = {}

function Wall.new(x0, y0, x1, y1, onhit, time)
    wall = {}

    wall.x0 = x0
    wall.y0 = y0

    wall.x1 = x1
    wall.y1 = y1

    if onhit then
        wall.onhit = onhit
    else
        wall.onhit = Wall.spark
    end

    if time then
        wall.time = time
    else
        wall.time = ENDLESS
    end

    wall.rot = math.atan2(y1-y0, x1-x0)

    table.insert(Wall.mems, wall)
end

function Wall.newBox(x0, y0, x1, y1, cs)
    Wall.new(x0+cs+1, y0, x1-cs-1, y0)
    Wall.new(x0, y0+cs+1, x0+cs+1, y0)

    Wall.new(x1, y0+cs+1, x1, y1-cs-1)
    Wall.new(x1-cs-1, y0, x1, y0+cs+1)

    Wall.new(x1-cs-1, y1, x0+cs+1, y1)
    Wall.new(x1, y1-cs-1, x1-cs-1, y1)

    Wall.new(x0, y1-cs-1, x0, y0+cs+1)
    Wall.new(x0, y1-cs-1, x0+cs+1, y1)
end

function Wall.hit(e)
    Emitter.new(e, small_spark)
    if e == Ship.mems[playerid] then
        Camera.shake(e.spd/2, 0.5)
    end
end

function Wall.bounce(e, brakefac)
    local eline = { x0 = e.x, y0 = e.y,
    x1 = e.x+e.vx, y1 = e.y+e.vy }

    for _,wall in ipairs(Wall.mems) do
        if Physics.doLinesIntersect(eline, wall) then
            Wall.hit(e)

            --get new angle and reduce velocity
            e.rot = Physics.getBounceAngle(e.rot, wall.rot)
            e.spd = e.spd * (brakefac or 1)
            
            --convert velocity to vector coords
            e.vx = math.cos(e.rot)*e.spd
            e.vy = math.sin(e.rot)*e.spd
            break
        end
    end            

    --commit velocity to position
    e.x = e.x + e.vx*e.tf
    e.y = e.y + e.vy*e.tf
end

function Wall.updateall()
    for _,wall in ipairs(Wall.mems) do
        if wall.time > 0 then
            wall.time = wall.time - DEC
        elseif wall.time > ENDLESS then
            table.remove(Wall.mems, _)
        end
    end
end

function Wall.drawall()
    for _,wall in ipairs(Wall.mems) do
        love.graphics.setColor(1,1,1,1)
        love.graphics.line(wall.x0, wall.y0, wall.x1, wall.y1)
    end
end

return Wall
