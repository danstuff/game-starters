local Bullet = {}

function Bullet.newtyp(props, effects)
    --props include speed, radius, length, color, time, cost, cooldown
    typ = props
    typ.effects = effects

    return typ
end

function Bullet.newlist(parent, typ, len)
    --attatch a bullet list to the parent
    parent.bullets = {}
    parent.bullet_first = 1

    for i=1,len do
        local bullet = { x = 0, y = 0,
        vx = 0, vy = 0, tf = 1, typ = typ }

        bullet.time = 0
        bullet.rot = 0
        bullet.rad = 0
        bullet.spd = bullet.typ.spd

        bullet.enabled = false

        table.insert(parent.bullets, bullet)
    end
end

function Bullet.shoot(parent)
    local bullet = parent.bullets[parent.bullet_first]

    local ang = parent.rot
    local vx = parent.vx+math.cos(ang)*bullet.typ.spd
    local vy = parent.vy+math.sin(ang)*bullet.typ.spd

    bullet.x = parent.x
    bullet.y = parent.y
    bullet.rot = ang

    bullet.vx = vx
    bullet.vy = vy

    bullet.time = bullet.typ.time
    bullet.rad = bullet.typ.rad

    bullet.enabled = true

    parent.bullet_first = parent.bullet_first + 1
    if parent.bullet_first > #parent.bullets then 
        parent.bullet_first = 1
    end
end

function Bullet.checkhits(parent, ship)
    for _,bull in ipairs(parent.bullets) do
        if Physics.doCirclesIntersect( ship.x, ship.y, ship.typ.rad,
            bull.x, bull.y, bull.typ.rad) then
            bull.enabled = false
            for _,eff in ipairs(bull.typ.effects) do
                Ship.modify(ship, eff.name,
                eff.mult, eff.add, eff.time)
            end
        end
    end
end

function Bullet.updatel(parent)
    for _,bull in ipairs(parent.bullets) do
        if bull.enabled then
            --update the position of the bullet from walls
            Wall.bounce(bull)
            bull.tf = TimeField.get(bull)

            --decrement time, disable if it hits 0
            bull.time = bull.time - DEC*bull.tf

            if bull.time <= 0 and bull.time > ENDLESS then 
                bull.rad = bull.rad*0.7

                if bull.rad < 0.01 then
                    bull.enabled = false
                end
            end
        end
    end
end

function Bullet.drawl(parent)
    for _,bull in ipairs(parent.bullets) do
        if bull.enabled then
            love.graphics.setColor(bull.typ.col)
            love.graphics.circle("fill", bull.x, bull.y, bull.rad)
        end
    end
end

return Bullet
