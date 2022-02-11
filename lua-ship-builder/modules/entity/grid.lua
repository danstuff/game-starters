local Grid = {}

function Grid.loadTo(entity, filename)
    if love.filesystem.getInfo(filename) == nil then
        print("File not found: "..filename)
        return grid
    end

    for line in love.filesystem.lines(filename) do
        if string.find(line, gv) ~= nil then
            local line_vals = Util.split(line, gv) 

            if #line_vals >= 3 then
                local gx = line_vals[1]
                local gy = line_vals[2]
                local typ = line_vals[3]

                local r = line_vals[4]
                local g = line_vals[5]
                local b = line_vals[6]

                Block.make(entity, gx,gy, typ, r,g,b)
            else
                print("Invalid grid line "..line)
            end
        else
            print("Invalid grid line "..line)
        end
    end

    return grid
end

function Grid.place(entity, wx,wy, typ, r,g,b)
    return Block.place(entity, wx,wy, typ, r,g,b)
end

function Grid.remove(entity, wx,wy)
    return Block.remove(entity, wx,wy)
end

function Grid.countTyp(entity, typ)
    local c = 0

    for i,blk in pairs(entity.grid) do
        if blk.typ == typ or typ == nil then c = c+1 end
    end

    return c
end

function Grid.cull(entity, kill)
    --clean up deleted blocks
    for i,blk in pairs(entity.grid) do
        Block.cull(entity, blk, kill)
    end
end

function Grid.upd(entity)
    local posx = Window.x_shift + entity.pos.x
    local posy = Window.y_shift + entity.pos.y

    for _,blk in pairs(entity.grid) do
        Block.upd(blk, posx, posy, entity.pos.r)
    end
end

return Grid
