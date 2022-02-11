local Player = {}

function Player.control(player)
    if not player.enabled then return end

    --rotating left and right
    if love.keyboard.isDown("right") ~= love.keyboard.isDown("left") then
        if love.keyboard.isDown("right") then
            Ship.turn(player, 1)
        elseif love.keyboard.isDown("left") then
            Ship.turn(player, -1)
        end
    end

    --boosting increases your acceleration
    if love.keyboard.isDown("z") then
        Ship.turbo(player)
    end

    --accelerate automatically
    Ship.push(player)

    --braking
    if love.keyboard.isDown("down") or love.keyboard.isDown("lshift") then
        Ship.brake(player) 
    end

    --shooting
    if love.keyboard.isDown("x") then
        Camera.shake(1, 0.5)
        Ship.shoot(player)
    end

    --using active items
    if love.keyboard.isDown("c") then
        Ship.useactive(player)
    end
end

return Player
