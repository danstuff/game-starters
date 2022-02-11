Sprite = {}

--module setttings
Sprite.priority = 2
Sprite.cmd = { "sprite", "spr" }

Sprite.set_file = "sprite_settings.dat"
Sprite.set = {
    ASTRO_NORM = 2,
    ASTRO_JUMP = 3,
    ASTRO_SHIP = 4,
   
    CURSOR = 5,
    HIGHLIGHT = 6,
    
    COCKPIT = 7,

    block_min = 9, 
    STEEL = 9,
    ENGINE = 10,
    GLASS = 11,
    ROCK = 12,
    block_max = 12,

    sprite_file = "resources/sprite.png",

    grid_size = 16,
    sheet_size = 64
}

function Sprite.load()
    --load the sprite sheet
    local sheet = love.graphics.newImage(Sprite.set.sprite_file)
    Sprite.batch = love.graphics.newSpriteBatch(sheet)
end

function Sprite.init()
    if Sprite.batch == nil then
        Sprite.load()
    end

    Sprite.makeQuads()
end

function Sprite.makeQuads()
    --create a grid of quads that spans the sprite sheet
    Sprite.quads = {}

    local ss = Sprite.set.sheet_size
    local gs = Sprite.set.grid_size

    for y=0, ss - gs, gs do
        for x=0, ss - gs, gs do
            local q = love.graphics.newQuad(x, y, 
                                            gs, gs,
                                            ss, ss)
            table.insert(Sprite.quads, q)
        end
    end
end

function Sprite.getGridSize()
    return Sprite.set.grid_size
end

function Sprite.add(sprite_id, x, y, rot, ox, oy, r, g, b)
    if sprite_id == 1 then return end

    --round pos to nearest whole int
    x = math.floor(x+0.5)
    y = math.floor(y+0.5)

    --add color if needed
    if b ~= nil then
        Sprite.batch:setColor(r, g, b)
    else
        Sprite.batch:setColor(255,255,255)
    end

    --add sprite and return the sprite's batch index
    return Sprite.batch:add(Sprite.quads[sprite_id], 
                            x, y, rot, 1, 1, ox, oy)
end

function Sprite.upd(batch_index, sprite_id, x, y, rot, ox, oy)
    --round pos to nearest whole int
    x = math.floor(x+0.5)
    y = math.floor(y+0.5)

    --modify the batch index
    Sprite.batch:set(batch_index, Sprite.quads[sprite_id], 
                     x, y, rot, 1, 1, ox, oy) 
end

function Sprite.rem(batch_index)
    Sprite.batch:set(batch_index, 0,0,0,0,0)
end

function Sprite.draw()
    love.graphics.draw(Sprite.batch)
end

return Sprite
