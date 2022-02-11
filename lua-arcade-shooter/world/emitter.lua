local Emitter = {}

Emitter.mems = {}

function Emitter.newtyp(rate, time, dir, spawnrad, max, particle)
    local typ = { rate = rate, time = time, points = {} }

    --initialize a list of point templates to save during runtime
    local sfrac = spawnrad[1]/spawnrad[2]
    for i=1,max do
        --spawn in the area between the two radii
        local sc_rad = Util.rand(sfrac, 1)
        local r = spawnrad[2]*math.sqrt(sc_rad)

        local a = Util.rand(-math.pi, math.pi)
        local acos = math.cos(a)
        local asin = math.sin(a)

        --random speed within the bounds
        local vs = Util.rand(particle.spd[1], particle.spd[1])

        local va = a
        local vcos = acos
        local vsin = asin

        --randomly directed velocity if that behavior was selected
        if dir == "random" then
            va = Util.rand(-math.pi, math.pi)
            vcos = math.cos(va)
            vsin = math.sin(va)
        end

        local col = particle.cols[math.random(#particle.cols)]
        local time = Util.rand(particle.time[1], particle.time[2])
        local rad = Util.rand(particle.rad[1], particle.rad[2])

        table.insert(typ.points, 
        { x = acos*r, y = asin*r, 
        vx = vcos*vs, vy = vsin*vs, 
        col = col, time = time, rad = rad })
    end

    return typ  
end

function Emitter.new(parent, typ)
    local sys = { parent = parent,
    typ = typ, points = {}, time = typ.time, 
    first = 1, on = true, tf = 1 }

    sys.parx = parent.x
    sys.pary = parent.y

    for _,tpt in ipairs(typ.points) do
        local pt = {}
        pt.x = sys.parent.x + tpt.x
        pt.y = sys.parent.y + tpt.y

        pt.rad = tpt.rad
        pt.time = tpt.time

        pt.ref = _

        table.insert(sys.points, pt)
    end

    table.insert(Emitter.mems, sys)

    return #Emitter.mems
end

function Emitter.flick(id)
    Emitter.mems[id].on = not Emitter.mems[id].on 
end

function Emitter.newpt(sys)
    --reset the first-created pt to its original values
    local pt = sys.points[sys.first]
    local tpt = sys.typ.points[pt.ref]

    pt.x = sys.parent.x + tpt.x
    pt.y = sys.parent.y + tpt.y

    pt.rad = tpt.rad
    pt.time = tpt.time

    --move the first marker up 1
    sys.first = sys.first+1
    if sys.first > #sys.points then sys.first = 1 end
end

function Emitter.updateall()
    for _,sys in ipairs(Emitter.mems) do
        if sys.parent.enabled then sys.tf = sys.parent.tf end

        --create particles at a rate in particles per update
        if sys.on and (sys.time > 0 or sys.time <= ENDLESS) then
            for i=0,sys.typ.rate*sys.tf do
                Emitter.newpt(sys)
            end
        end

        local alive = false

        --iterate through all points, adding vel to pos
        for _,point in ipairs(sys.points) do
            if point.time > 0 then
                alive = true

                local ref = sys.typ.points[point.ref]

                --add velocity to position
                point.x = point.x+ref.vx*sys.tf
                point.y = point.y+ref.vy*sys.tf

                --count down timer and reduce radius with time
                point.time = point.time - DEC*sys.tf
                point.rad = ref.rad*(point.time/ref.time)
            end
        end

        --decrement emitter's overall timer
        sys.time = sys.time - DEC*sys.tf

        if sys.time <= 0 and sys.time > ENDLESS and not alive then
            table.remove(Emitter.mems, _)
        end

    end
end

function Emitter.drawall()
    for _,sys in ipairs(Emitter.mems) do
        for _,point in ipairs(sys.points) do
            if point.time > 0 then  
                love.graphics.setColor(sys.typ.points[point.ref].col)
                love.graphics.circle("fill", point.x, point.y, point.rad)
            end
        end
    end
end

return Emitter
