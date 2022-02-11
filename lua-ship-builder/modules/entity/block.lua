local Block = {}

local gs = 16

function Block.init()
    gs = Sprite.getGridSize()
end

function Block.toGridPos(entity, wx, wy)
    --convert world coordinates to grid relative to entity.pos
    local dx, dy = wx - entity.pos.x, wy - entity.pos.y
    local rx, ry = Util.about(entity.pos.x, entity.pos.y,
                              dx, dy, -entity.pos.r)

    local drx, dry = rx - entity.pos.x, ry - entity.pos.y

    return math.floor(drx/gs + 0.5), math.floor(dry/gs + 0.5)
end

function Block.toWorldPos(entity, gx, gy)
    --convert grid coordinates to global coords
    return Util.about(entity.pos.x, entity.pos.y,
                      gx*gs, gy*gs, entity.pos.r)
end

function Block.make(entity_id, gx, gy, typ, r, g, b)
    --add block to the batch
    local btch_i = Sprite.add(block.typ,0,0,0,0,0,0)

    --find world coords from grid coords
    local wx, wy = Block.toWorldPos(gx, gy)

    --add to the grid
    table.insert(e.grid, {
        typ = typ,

        gx, gy = gx, gy,
        wx, wy = wx, wy,

        r, g, b = r, g, b,

        btch_i = btch_i
    })
end

function Block.find(e, wx, wy)
    --for each block in the entity
    for i,blk in pairs(e.grid) do

        --return if world coords within block's bounds
        if  blk.wx ~= nil and blk.wy ~= nil  
        and blk.wx <= wx and blk.wx+gs > wx
        and blk.wy <= wy and blk.wy+gs > wy then
            return blk
        end
    end 
    
    return nil
end

function Block.place(entity, wx,wy, typ, r,g,b)
    --only place if there isnt anything there already
    local last = Block.find(e, wx, wy)
    if last == nil or last.dead == true then

        --convert to grid coords and make
        local gx, gy = Block.toGridPos(entity, wx, wy)
        Block.make(entity, gx,gy, typ, r,g,b)
        
        return true
    end

    return false
end

function Block.remove(entity, wx, wy)
    local gx, gy = Block.toGridPos(wx, wy)
    local block = Block.find(entity, wx, wy)

    if block ~= nil and block.dead ~= true then
        block.dead = true
        return block
    end

    return nil
end

function Block.cull(entity, blk, kill)
    if blk.dead == true or kill == true then 
        --remove the sprite if it had one
        if blk.btch_i ~= nil then Sprite.rem(blk.btch_i) end

        --if the block is dead remove it from grid
        if dead == true then table.remove(entity.grid, i) end
    else
        --if alive, re-calculate the block's world position
        blk.wx, blk.wy = Util.toWorldPos(gx, gy)
    end
end

function Block.upd(blk, x, y, rot)
    --get offset from entity origin
    local ox = -blk.x*gs + gs/2
    local oy = -blk.y*gs + gs/2

    --update the sprite in the batch
    if blk.btch_i ~= nil then
        Sprite.upd(blk.btch_i, blk.typ, x, y, rot, ox, oy)
    end

    --TODO emit particles
end

return Block
