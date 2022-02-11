Stars = {}

--star settings
Stars.priority = 5
Stars.cmd = { "stars", "sta" }

Stars.set_file = "star_settings.dat"
Stars.set = {
    width = 3840,
    height = 2560,

    sprite_width = 1280,

    neb_layers = 6,
    neb_folder = "resources/stars",

    star_layers = 10,
    stars_per_layer = 100,
    

    alpha = 0.8
}

--star attributes
Stars.nebulae = {}
Stars.neb_pos = {}
Stars.neb_vel = {}

Stars.points = {}
Stars.pt_pos = {}
Stars.pt_vel = {}

function Stars.load()
    --load the starfields
    Stars.batches = {}
    Util.fordir(Stars.set.neb_folder,
        function(file)
            local img = love.graphics.newImage(file)
            local btc = love.graphics.newSpriteBatch(img)
            table.insert(Stars.batches, btc)
        end)
end

function Stars.init()
    --load the nebs if they don't exist yet
    if Stars.batches == nil or #Stars.batches == 0 then
        Stars.load()
    end
    
    local hw = Stars.set.width/2
    local hh = Stars.set.height/2

    local sw = Stars.set.sprite_width

    --reset all nebulae and star arrays
    Stars.nebulae = {}
    Stars.neb_pos = {}
    Stars.neb_vel = {}

    Stars.points = {}
    Stars.pt_pos = {}
    Stars.pt_vel = {}

    --create parallaxing layers of nebulae
    for sprite = 1,Stars.set.neb_layers do
        table.insert(Stars.nebulae, {})
        table.insert(Stars.neb_pos, Util.pt(0,0,0))
        table.insert(Stars.neb_vel, Util.pt(0,0,0))

        --generate a grid of neb sprites
        for x = -hw, hw - sw, sw do
            for y = -hh, hh - sw, sw do
                local i = Stars.batches[sprite]:add(x, y)
                table.insert(Stars.nebulae[sprite], 
                            { ox = x, oy = y,  i = i }) 
            end
        end
    end

    --generate a number of layers of stars
    for i = 1, Stars.set.star_layers do
        table.insert(Stars.points, {})
        table.insert(Stars.pt_pos, Util.pt(0,0,0))
        table.insert(Stars.pt_vel, Util.pt(0,0,0))

        --add randomized stars
        for j = 1,Stars.set.stars_per_layer do
            local x = math.random(-hw,hw)
            local y = math.random(-hh,hh)

            local r = math.random()
            local g = math.random()
            local b = math.random()

            table.insert(Stars.points[i],
                        { x, y, r, g, b, Stars.set.alpha })
        end
    end
end

function Stars.tick()
    local hw = Stars.set.width/2
    local hh = Stars.set.height/2

    --if pos exceeded the bounds, loop it back
    function wrap(ox, oy, x, y)
        if     x + ox < -hw then ox = ox + Stars.set.width
        elseif x + ox >  hw then ox = ox - Stars.set.width
        end

        if     y + oy < -hw then oy = oy + Stars.set.height
        elseif y + oy >  hw then oy = oy - Stars.set.height
        end
    end

    --wrap nebulae and add them to the batch
    for i,neb in ipairs(Stars.nebulae) do
        Util.ptadd(Stars.neb_pos[i], Stars.neb_vel[i])
        local px = Stars.neb_pos[i].x
        local py = Stars.neb_pos[i].y

        for _,s in pairs(neb) do
            wrap(s.ox, s.oy, px, py) 

            --set the star's batch
            Stars.batches[i]:set(s.i, px + s.ox, py + s.oy)
        end
    end
    
    --wrap stars and add velocity to star pos
    for i,lyr in pairs(Stars.points) do
        Util.ptadd(Stars.pt_pos[i], Stars.pt_vel[i])
        local px = Stars.pt_pos[i].x
        local py = Stars.pt_pos[i].y

        for j,star in pairs(lyr) do
            local x = lyr[j][1]
            local y = lyr[j][2]
            wrap(x, y, px, py)
        end
    end
end

function Stars.draw()
    --draw each layer of stars
    for i,layer in pairs(Stars.points) do
        love.graphics.push()
        love.graphics.translate(Stars.pt_pos[i].x,
                                Stars.pt_pos[i].y)

        love.graphics.points(layer)

        love.graphics.pop()
    end

    --draw the nebulae
    for i,batch in pairs(Stars.batches) do
        love.graphics.draw(batch)
    end
end

function Stars.setSpeed(vx, vy)
    --set the star speed
    for i,vel in ipairs(Stars.pt_vel) do
        vel.x = -vx/math.pow(i,1.5)
        vel.y = -vy/math.pow(i,1.5)
    end

    --set the neb speed
    for i,vel in ipairs(Stars.neb_vel) do
        vel.x = -vx/math.pow(i,1.5)
        vel.y = -vy/math.pow(i,1.5)
    end
end

return Stars
