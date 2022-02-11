local Ship = {}

Ship.mems = {}

function Ship.newtyp(props)
    --props include max power, charge rate,
    --speed, acceleration, breaking rate, turn speed,
    --collision radius
    typ = props
    typ.effects = effects

    return typ
end

function Ship.new(typ, weapon, active, col, x, y, dir)
    local ship = { }

    ship.typ = typ
    ship.col = col

    ship.ix = x
    ship.iy = y
    ship.idir = dir or 0

    ship.weapon = weapon
    ship.active = active

    ship.vertices =
    { 0.0, 0.0, -7.1, -7.1, 10.0, 0.0, -7.1, 7.1 }

    --initialize basic variables
    Ship.spawn(ship)
    
    --cache a list of bullets for performance
    Bullet.newlist(ship, weapon, 16)

    --attactch a tail flame to the ship object 
    ship.flame = Emitter.new(ship, small_flame)

    table.insert(Ship.mems, ship)

    return #Ship.mems
end

function Ship.spawn(ship)
    --reset ship to inital values
    ship.x = ship.ix
    ship.y = ship.iy

    ship.vx = math.cos(ship.idir)
    ship.vy = math.sin(ship.idir)
    ship.rot = ship.idir
    ship.spd = 1
    ship.tf = 1

    ship.power = ship.typ.power

    ship.wepcool = 0

    ship.actcool = 0
    ship.acttime = ENDLESS

    ship.deadtime = 0
    ship.enabled = true

    ship.mods = {}
end

--SHIP MODIFICATIONS
function Ship.modify(ship, statname, mult, add, time)
    --add modifiers like poison, speed boost, etc
    mod = {}
    mod.statname = statname
    mod.mult = mult or 1
    mod.add = add or 0
    mod.time = time or 0.01

    table.insert(ship.mods, mod)
end

function Ship.getmodded(ship, original, statname)
    --return the original value with all modifiers applied
    local modded = original

    for _,mod in ipairs(ship.mods) do
        if mod.statname == statname then
            modded = modded * mod.mult + mod.add
        end
    end

    return modded
end

--SHIP CONTROLS
function Ship.turn(ship, dir)
    --rotate the velocity vector
    local turn = Ship.getmodded(ship, ship.typ.turn, "turn")
    local rot = ship.rot + dir*turn*ship.tf

    ship.vx = math.cos(rot)*ship.spd
    ship.vy = math.sin(rot)*ship.spd

    ship.rot = math.atan2(ship.vy, ship.vx)
end

function Ship.push(ship)
    --if below max speed, accelerate in the pointed direction
    local max_spd = Ship.getmodded(ship, ship.typ.speed, "speed")
    local acc = Ship.getmodded(ship, ship.typ.acc, "acc")

    if ship.spd < max_spd-acc then
        local avx = math.cos(ship.rot)*acc*ship.tf
        local avy = math.sin(ship.rot)*acc*ship.tf

        ship.vx = ship.vx + avx
        ship.vy = ship.vy + avy

        ship.spd = math.sqrt(ship.vx^2 + ship.vy^2)
    end
end

function Ship.turbo(ship)
    --turbo boosts your acceleration and max speed but costs power
    if ship.power >= 1 then
        Ship.modify(ship, "acc", 3, 0, 0)
        Ship.modify(ship, "speed", 1, 10, 0)
        ship.power = ship.power-1
    end
end

function Ship.brake(ship)
    --reduce velocity
    local brake = Ship.getmodded(ship, ship.typ.brake, "brake")
    ship.vx = ship.vx*brake
    ship.vy = ship.vy*brake
    ship.spd = math.sqrt(ship.vx^2 + ship.vy^2)
end

function Ship.shoot(ship)
    if ship.weapon then
        --create new beam if cooldown allows
        local cooldown = Ship.getmodded(ship, ship.weapon.cool, "wepcool")
        local cost = Ship.getmodded(ship, ship.weapon.cost, "wepcost")

        if ship.wepcool <= 0 and
            ship.power > ship.weapon.cost+1 then
            Bullet.shoot(ship)

            --reduce power accordingly and reset cooldown
            ship.power = ship.power - cost
            ship.wepcool = cooldown
        end
    end
end

function Ship.useactive(ship)
    if ship.active then 
        --use active item if cooldown allows
        local cooldown = Ship.getmodded(ship, ship.active.cool, "actcool")
        local cost = Ship.getmodded(ship, ship.active.cost, "actcost")

        if ship.actcool <= 0 and
            ship.power > cost then
            ship.active.startfunc(ship, ship.active)

            --reduce power accordingly and reset cooldown/time
            ship.power = ship.power - cost
            ship.actcool = cooldown
            ship.acttime = 0
        end
    end
end

--UPDATE/DRAW
function Ship.updateall()
    for _,ship in ipairs(Ship.mems) do
        --check if this ship's bullets hit another ship
        for _,targ in ipairs(Ship.mems) do
            if ship ~= targ then 
                Bullet.checkhits(ship, targ)
            end
        end

        if ship.enabled then
            --update ship position and timefield factor
            Wall.bounce(ship, 0.6)
            ship.tf = TimeField.get(ship)

            --update ship bullets
            Bullet.updatel(ship)

            --the ship stretches as it goes faster
            ship.vertices[3] = -7.1 - ship.spd*0.2
            ship.vertices[4] = -7.1 + ship.spd*0.2
            ship.vertices[5] = 10.0 + ship.spd*0.2
            ship.vertices[7] = -7.1 - ship.spd*0.2
            ship.vertices[8] = 7.1 - ship.spd*0.2

            local dec = DEC*ship.tf

            --cool down weapons
            if ship.wepcool >= 0 then
                ship.wepcool = ship.wepcool - dec
            end

            --cool down active item
            if ship.actcool >= 0 then
                ship.actcool = ship.actcool - dec

                --if active item is running, track its duration
                if ship.acttime > ENDLESS then
                    ship.acttime = ship.acttime + INC

                    local acttime = Ship.getmodded(ship,
                    ship.active.time, "acttime")

                    --if active item has timed out, call the end function
                    if ship.acttime > ship.active.time then
                        ship.active.endfunc(ship, ship.active)
                        ship.acttime = ENDLESS
                    end
                end
            end
            
            --if you died, explode, destroy mods, set respawn time
            if ship.power < 1 then
                Emitter.new(ship, fire_explosion_big)
                Emitter.flick(ship.flame)
                ship.deadtime = 5
                ship.enabled = false
            end

            --recharge power cells
            local power = Ship.getmodded(ship, ship.typ.power, "power")
            local charge = Ship.getmodded(ship, ship.typ.charge, "charge")

            if ship.power < power - charge then
                ship.power = ship.power + charge
            else
                ship.power = power
            end

            --deactivate mods if their time becomes 0
            for _,mod in pairs(ship.mods) do
                mod.time = mod.time - dec

                if mod.time < dec and mod.time > ENDLESS then
                    table.remove(ship.mods, _)
                end
            end
        else
            if ship.deadtime > 0 then
                ship.deadtime = ship.deadtime - DEC
            else
                Ship.spawn(ship)
                Emitter.flick(ship.flame)
            end
        end
    end
end

function Ship.drawall()
    for _,ship in ipairs(Ship.mems) do
        if ship.enabled then
            Bullet.drawl(ship)

            love.graphics.setColor(1,1,1,1)
            love.graphics.push()
            love.graphics.translate(ship.x, ship.y)
            love.graphics.rotate(ship.rot)
            love.graphics.polygon("fill", ship.vertices)
            love.graphics.pop()
        end
    end
end

return Ship
