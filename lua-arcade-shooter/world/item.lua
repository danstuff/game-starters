local Item = {}

Item.spawners = {}

function Item.newtyp(props, effects)
    --props include radius, color, TODO draw behavior, poly points 
    typ = props
    typ.effects = effects

    return typ
end

function Item.newspawner(x0, y0, x1, y0, avx, avy, chance, times, typs, len) 
    --create a new spawning area, which randomly creates items within a box
    spawner = { x0 = x0, y0 = y0,
    x1 = x1, y1 = y1,
    avx = avx, avy = avy,
    chance = chance, times = times, items = {}, first = 1 }

    for i=0,len do
        local item = { x = x, y = y,
        vx = vx, vy = vy, tf = 1 }

        item.typ = spawner.typs[math.random(0, #spawner.typs)]
        item.time = 0
        item.enabled = false

        table.insert(spawner.items, item) 
    end

    table.insert(Item.spawners, spawner) 
end

function Item.spawn()
    --reset and re-enable an item if spawn chance triggered
    for _,spawner in ipairs(Item.spawners) do
        if math.random(0,100)/100 <= spawner.chance then
            local item = spawner.items[spawner.first]

            item.x = Util.rand(x0, x1)
            item.y = Util.rand(y0, y1)

            item.vx = Util.rand(avx-2, avx+2)
            item.vy = Util.rand(avy-2, avy+2)

            item.time = Util.rand(spawner.times[1], spawner.times[2]) 

            item.enabled = true 

            spawner.first = spawner.final_rot+1
            if spawner.first > #spawner.items then spawner.first = 1 end
        end
    end
end

function Item.checkhits(e)
    --loop through all spawners and items, then apply modifiers if collided
    for _,spawner in ipairs(Item.spawners) do
        for _,item in ipairs(spawner.items) do
            if item.enabled and 
                Physics.doCirclesIntersect(
                e.x, e.y, e.typ.rad,
                item.x, item.y, item.typ.rad) then

                item.enabled = false
                for _,eff in ipairs(item.typ.effects) do
                    Ship.modify(ship, eff.name,
                    eff.mult, eff.add, eff.time)
                end
            end
        end
    end
end

function Item.updateall()
    --loop all items/spawners and decrement each timer
    for _,spawner in ipairs(Item.spawners) do
        for _,item in ipairs(spawner.items) do
            if item.enabled then
                --check for wall hits, update timefield
                Wall.bounce(item, 0)
                item.tf = TimeField.get(item)

                item.time = item.time - DEC*item.tf

                if item.time <= 0 and item.time > ENDLESS then
                    item.enabled = false
                end
            end
        end
    end
end

function Item.drawall()
    --loop all items/spawners and draw
    for _,spawner in ipairs(Item.spawners) do
        for _,item in ipairs(spawner.items) do
            if item.enabled then
                love.graphics.setColor(item.typ.col)
                love.graphics.circle("fill", item.x, item.y, e.typ.rad)
            end
        end
    end
end

return Item
