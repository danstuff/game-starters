local Camera = {}

Camera.target = nil

Camera.x = 0
Camera.y = 0

Camera.ox = 0
Camera.oy = 0

Camera.shaketime = 0
Camera.shakemaxt = 1
Camera.shakepower = 0

Camera.shakeoffh = 0
Camera.shakeoffv = 0

Camera.stars = {}

flicka = false

function Camera.follow(obj)
    Camera.target = obj
end

function Camera.makestars(levels)
    --create a paralax-scaled starfield
    for i=1,levels do
        starfield = {}
        for i=0,1000 do
            table.insert(starfield,
            { math.random(-1000, 1000),
            math.random(-1000, 1000) })
        end
        table.insert(Camera.stars, starfield)
    end
end

function Camera.shake(power, time)
    local rang = math.random(-math.pi, math.pi)

    Camera.shakeh = 1
    Camera.shakev = 1

    Camera.shaketime = time
    Camera.shakemaxt = time
    Camera.shakepower = power

    Camera.shakeoffh = math.random(-10,10)
    Camera.shakeoffv = math.random(-10,10)
end

function Camera.update()
    --move towards the target's position
    if Camera.target then
        Camera.x = Camera.x - (Camera.x - Camera.target.x)*0.1
        Camera.y = Camera.y - (Camera.y - Camera.target.y)*0.1
    end

    --decrement shake time to 0
    if Camera.shaketime > DEC then
        Camera.shaketime = Camera.shaketime - DEC
        
        --if time is over 0, vibrate the screen
        Camera.ox = math.cos((Camera.shaketime-Camera.shakeoffh)*50)*
        Camera.shakepower^1.4
        Camera.oy = math.cos((Camera.shaketime-Camera.shakeoffv)*50)*
        Camera.shakepower^1.4
    else
        Camera.shaketime = 0
        Camera.ox = Camera.ox * 0.5
        Camera.oy = Camera.oy * 0.5
    end
end

function Camera.drawstart()
    local fx = -Camera.x + GAME_WIDTH/2 + Camera.ox
    local fy = -Camera.y + GAME_HEIGHT/2 + Camera.oy

    love.graphics.push()

    love.graphics.setPointSize(1)
    love.graphics.setColor(1,1,1,1)

    --draw each plane of stars on a different paralax level
    local scfac = #Camera.stars+1
    for _,plane in ipairs(Camera.stars) do
        love.graphics.translate(fx/scfac, fy/scfac)
        love.graphics.points(plane)
    end

    love.graphics.translate(fx/scfac, fy/scfac)
end

function Camera.drawend()
    love.graphics.pop()
end

return Camera
