Place = {}

--astro settings
Place.priority = 5
Place.cmd = { "place", "plc" }

Place.set_file = "place_settings.dat"
Place.set = {
    inventory = { 
        { typ = 9, r = 255, g = 255, b = 255, count = 100 },
        { typ = 10, r = 255, g = 255, b = 255, count = 100 },
        { typ = 11, r = 255, g = 255, b = 255, count = 100 },
        { typ = 12, r = 255, g = 255, b = 255, count = 100 },
        { typ = 7, r = 255, g = 255, b = 255, count = 100 }
    }
}

--ship attributes
Place.selected = 1
Place.ship_range = 100

Place.mx = 0
Place.my = 0

Place.c_batch_i = nil
Place.b_batch_i = nil

function Place.init()
    Place.b_batch_i = Sprite.add(Sprite.set.STEEL, 0,0,0,0,0)
    Place.c_batch_i = Sprite.add(Sprite.set.CURSOR, 0,0,0,0,0)
end

function Place.findInvBlock(block)
    if block == nil then return nil,nil end

    for _,b in pairs(Place.set.inventory) do
        if b.typ == block.typ
        and b.r == block.r
        and b.g == block.g
        and b.b == block.b then
            return _,b
        end
    end

    return nil,nil
end

function Place.getInvCount(block)
    local i,ib = Place.findInvBlock(block) 

    if ib ~= nil then return ib.count
    else return 0 end
end

function Place.addInvCount(block, count)
    local i,ib = Place.findInvBlock(block) 

    if ib ~= nil then 
        ib.count = ib.count + count

        if ib.count <= 0 then
            table.remove(Place.set.inventory, i)
            Place.changed_block = true
        end
    else
        table.insert(Place.set.inventory, {
            typ = block.typ,
            r = block.r, g = block.g, b = block.b,
            count = count
        })
    end
end

function Place.getSelected()
    return Place.set.inventory[Place.selected]
end

function Place.drawCursor(mode)
    if mode == "block" then
        local gs = Sprite.set.grid_size

        --draw selected block at the mouse cursor
        local sb = Place.getSelected()
        if sb ~= nil then
            Sprite.upd(Place.b_batch_i, sb.typ,
                       Place.mx - gs/2, Place.my - gs/2,
                       0, 0, 0, sb.r, sb.g, sb.b)
        end

        --draw highlight
        Sprite.upd(Place.c_batch_i, Sprite.set.HIGHLIGHT,
                   Place.mx - gs/2, Place.my - gs/2)
    else
        Sprite.upd(Place.c_batch_i, Sprite.set.CURSOR, Place.mx, Place.my)
    end
end

function Place.placeBlock(block)
    if block == nil then return end

    local gs = Sprite.set.grid_size
    local mx = -Window.x_shift + Place.mx
    local my = -Window.y_shift + Place.my

    local bcount = Place.getInvCount(block)
    if bcount < 0 then return end

    --use the nearest ship to mx, my
    local near = Entity.nearest(mx, my, nil, Place.ship_range, true)

    --if you found a near entity, place block
    if near.id ~= nil then
        --if selected places successfully, remove 1
        local set = Grid.addBlock(near.id, block, mx, my)

        if set then
            Place.addInvCount(block, -1)
            Particle.emit(Particle.set.emit_typs.click, mx, my)
        end
    end
end

function Place.removeBlock()
    local gs = Sprite.set.grid_size
    local mx = -Window.x_shift + Place.mx
    local my = -Window.y_shift + Place.my

    --use the nearest ship to mx, my
    local ship_id = Entity.nearest(mx, my, nil, Place.ship_range)

    if ship_id ~= nil then
        local b = Grid.removeBlock(ship_id, mx, my)

        if b ~= nil then 
            Place.addInvCount(b, 1)
            Particle.emit(Particle.set.emit_typs.click, mx, my)
        end
    end
end

function Place.changeSelectedBlock(amount)
    if #Place.set.inventory == 0 then return end

    Place.selected = Place.selected + amount
    
    if Place.selected > #Place.set.inventory then
        Place.selected = 1 
    elseif Place.selected < 1 then
        Place.selected = #Place.set.inventory
    end
end

function Place.mouseChange(mx, my)
    Place.mx = math.floor(mx/Window.set.scale - Window.swidth/2 + 0.5)
    Place.my = math.floor(my/Window.set.scale - Window.sheight/2 + 0.5)
end

function Place.tick()
    if PAUSE_INPUT then 
        Place.drawCursor("normal")
        return 
    end

    --draw the block cursor if no ship
    if not Move.hasShip() then
        Place.drawCursor("block")

        --left click creates, right destroys
        if love.mouse.isDown(1) then
            Place.placeBlock(Place.getSelected())

        elseif love.mouse.isDown(2) then
            Place.removeBlock()
        end

    --draw the normal cursor
    else
        Place.drawCursor("normal")
    end
end

return Place
