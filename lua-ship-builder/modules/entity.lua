Grid = require("modules/entity/grid")
Block = require("modules/entity/block")

Entity = {}

--entity settings
Entity.priority = 3
Entity.cmd = { "entity", "ent" }

Entity.set_file = "entity_settings.dat"
Entity.set = {}

--entity attributes
Entity.list = {}
Entity.callbacks = {}

function Entity.make(id, x, y)
    table.insert(Entity.list, {
        id = id,
        grid = {},
        pos = Util.pt(x,y,0), 
        vel = Util.pt(0,0,0)
    })

    return id
end

function Entity.uniqueID()
    return math.random() * 9999
end

function Entity.get(id)
    for _,e in pairs(Entity.list) do
        if id == e.id then
            return e
        end
    end
end

function Entity.kill(id)
    Entity.get(id).grid = nil
end

function Entity.nearest(x, y, typ, max_dist, mandate)
    --variables to store state about the closest blk
    local sht = {
        id = nil,
        blk_id = nil,
        dist = max_dist,
    }

    for _, e in ipairs(Entity.list) do
        if e.id ~= 1 and e.grid ~= nil then
            for i,blk in pairs(e.grid) do
                local dx = math.pow(x - blk.wx, 2)        
                local dy = math.pow(y - blk.wy, 2)        

                local dist = math.sqrt(dx+dy)

                if dist < sht.dist then
                    sht.id = id
                    sht.blk_id = i
                    sht.dist = dist
                end
            end
        end
    end

    if sht.id == nil and mandate == true then
        return { id = Entity.make(Entity.uniqueID(), x, y),
                 blk_id = nil,
                 dist = 0 }
    end

    return sht
end

function Entity.bind(child_id, x, y, r)
    local c = Entity.get(child_id)

    c.pos.x = x
    c.pos.y = y
    c.pos.r = r
end

function Entity.update()
    for _, entity in pairs(Entity.list) do
        if #entity.grid == 0 then
            --clean up empty entity
            Grid.cull(entity, true)
            table.remove(Entity.list, _)
        else
            --clean up deleted blocks
            Grid.cull(entity)
        end
    end
end

function Entity.tick()
    for _, entity in pairs(Entity.list) do  
        --add velocity to position
        if entity.vel ~= nil 
        and (entity.vel.x ~= 0 
        or   entity.vel.y ~= 0
        or   entity.vel.r ~= 0) then
            Util.ptadd(entity.pos, entity.vel)
        end      

        --run draw calls and actions for each block
        Grid.upd(entity)
    end
end

return Entity
