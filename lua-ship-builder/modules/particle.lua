Particle = {}

--particle settings
Particle.priority = 6
Particle.cmd = { "particle", "par" }

Particle.set_file = "particle_settings.dat"
Particle.set = {
    max = 1024,

    emit_typs = {
        flame = { 
            r = { 1, 1 },
            g = { 0, 1 },
            b = { 0, 0 },
            a = { 0, 1 },
            rad = { 0, 3 },
            vel = { 1, 1.1 },
            rate = { 1000, 2000 },
            time = { 50, 200 }
        },

        smoke = {
            r = { 0.7, 1 },
            g = { 0.7, 1 },
            b = { 0.7, 1 },
            a = { 0, 1 },
            rad = { 2, 4 },
            vel = { 0.5, 1 },
            rate = { 1000, 2000 },
            time = { 100, 500 }
        },

        click = {
            r = { 0.7, 1 },
            g = { 0.7, 1 },
            b = { 0.7, 1 },
            a = { 0, 1 },
            rad = { 2, 4 },
            vel = { 0.5, 1 },
            rate = { 1000, 2000 },
            time = { 100, 500 }
        }
    }
}

--particle attributes
Particle.list = {}
Particle.stat = {}
Particle.nexti = 1

Particle.ticks = 0

Particle.emit_off_x = -1000000
Particle.emit_off_y = -1000000

function Particle.init()
    --Particle.emit_off_x = World.set.bound*2
    --Particle.emit_off_y = World.set.bound*2
end

function Particle.emit(etyp, x, y)
    local ppt = math.floor(math.random(
                    etyp.rate[1],
                    etyp.rate[2]) * SECS_PER_TICK + 0.5)
    if ppt == 0 then return end

    for i=1,ppt do
        local p = Particle.list[Particle.nexti]

        function rnd(min, max)
            return math.floor(math.random(min*100, max*100) + 0.5)/100
        end

        function rvec(min, max)
            local r = rnd(min, max)
            local a = rnd(-math.pi,math.pi)

            return r * math.cos(a), r * math.sin(a)
        end

        --randomly generate position
        local px, py = rvec(etyp.rad[1], etyp.rad[2])
        px, py =  px + x, py + y

        --randomly generate color
        local pr = rnd(etyp.r[1], etyp.r[2])
        local pg = rnd(etyp.g[1], etyp.g[2])
        local pb = rnd(etyp.b[1], etyp.b[2])
        local pa = rnd(etyp.a[1], etyp.a[2])

        --randomly determine velocity
        local pvx, pvy = rvec(etyp.vel[1], etyp.vel[2])
        pvx, pvy = pvx * MS, pvy * MS
        
        --randomly determine decay time
        local pt = Particle.ticks +  math.floor(
                        math.random(etyp.time[1],
                                    etyp.time[2])+0.5)

        --add particle to list
        Particle.list[Particle.nexti] = 
            { px, py, pr, pg, pb, pa,
              t = pt, vx = pvx, vy = pvy }
        --increment and loop nexti
        Particle.nexti = Particle.nexti + 1 

        if Particle.nexti >= Particle.set.max then
            Particle.nexti = 1
        end
    end
end

function Particle.tick()
    Particle.ticks = Particle.ticks+1

    for id, p in pairs(Particle.list) do
        if p.t < Particle.ticks then
            p[1] = Particle.emit_off_x
            p[2] = Particle.emit_off_y
        else
            p[1] = p[1] + p.vx
            p[2] = p[2] + p.vy
        end
    end
end

function Particle.draw()
    love.graphics.push()
    love.graphics.translate(Window.x_shift, Window.y_shift)

    love.graphics.points(Particle.list)

    love.graphics.pop()
end

return Particle
