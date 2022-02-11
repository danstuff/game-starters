local Track = {}

Track.progress = {}
Track.proglines = {}

Track.time = 0

local debug = true

function Track.setfinish(x0, y0, x1, y1, width, boxsz)
    Track.finish = { x0 = x0, y0 = y0, 
    x1 = x1, y1 = y1, width = width, boxsz = boxsz }
end

function Track.newprogline(x0, y0, x1, y1)
    table.insert(Track.proglines, { x0 = x0, y0 = y0, x1 = x1, y1 = y1 })
end

function Track.updateships(slist)
    Track.time = Track.time + INC

    for _,ship in ipairs(slist) do
        ship.laps = ship.laps or 1

        local sline = { x0 = ship.x, y0 = ship.y,
        x1 = ship.x+ship.vx, y1 = ship.y+ship.vy }

        for _,pline in ipairs(Track.proglines) do
            if Physics.doLinesIntersect(sline, pline) then
                ship.progress = ship.progress or 0

                if ship.progress ~= _-1 then
                    ship.wrongway = true
                else
                    ship.wrongway = false
                    ship.progress = _
                end
            end
        end

        --if you hit finish, add a lap
        if Physics.doLinesIntersect(sline, Track.finish) and
            ship.progress == #Track.proglines then
            if ship.laps == 3 then
                ship.finished = true
                ship.progress = 0
                print("FINISH")
            else
                ship.laps = ship.laps + 1
                ship.progress = 0
            end
        end
    end
end

function Track.draw()
    --draw the checkered finish line
    local f = Track.finish
    local fh = f.y1-f.y0
    local black = false

    if not f then return end

    for x=0,f.width-f.boxsz,f.boxsz do
        for y=0,fh-f.boxsz,f.boxsz do
            if black then love.graphics.setColor({0,0,0,1})
            else love.graphics.setColor({1,1,1}) end

            black = not black
            love.graphics.rectangle("fill", 
            f.x0+x, f.y0+y, f.boxsz, f.boxsz)
        end

        if ((fh-f.boxsz) / f.boxsz) % 2 ~= 0 then
            black = not black
        end
    end

    if debug then
        for _,line in ipairs(Track.proglines) do
            love.graphics.setColor({0,0,1})
            love.graphics.line(line.x0, line.y0, line.x1, line.y1)
        end
    end
end

return Track
