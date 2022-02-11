Move = {}

--movement settings
Move.priority = 4
Move.cmd = { "move" }

Move.set_file = "move_settings.dat"
Move.set = {
    ship_id = nil,

    def_acc = 0.5 * METERS_PER_SECOND_SQ,
    def_turn_acc = 5 * METERS_PER_SECOND_SQ,

    def_max_spd = 5 * METERS_PER_SECOND,
    def_max_turn_spd = 0.05 * METERS_PER_SECOND,

    brake_friction = 0.99,
    turn_friction = 0.80,

    ship_grab_range = 100,

    blocks_per_engine = 20,

    x = 0,
    y = 0,
    r = 0,

    outfit = { 2, 3, 4 },

    bound = 10000

    --TODO pull out window scale factor
    --TODO pull out key presses
}

Move.acc = Move.set.def_acc
Move.turn_acc = Move.set.def_turn_acc

Move.max_spd = Move.set.def_max_spd
Move.max_turn_spd = Move.set.def_max_turn_spd

Move.speed = 0
Move.turn_speed = 0

function Move.init()
    Move.sprite = Move.set.outfit[1]
    Move.batch_id = Sprite.add(Move.sprite, 0,0,0,0,0)
end

function Move.accel(dir)
    --accelerate in the direction, either -1 (back) or 1 (forward)
    if math.abs(Move.speed + Move.acc*dir) <= Move.max_spd then
        Move.speed = Move.speed + Move.acc*dir
    end
end

function Move.turn(dir)
    --dir is either -1 (ccw) or 1 (cw)
    if (dir ==  1 and Move.turn_speed < Move.max_turn_spd)
    or (dir == -1 and Move.turn_speed > -Move.max_turn_spd) then
        Move.turn_speed = Move.turn_speed + Move.turn_acc * dir
    end
end

function Move.brake()
    --reduce velocity with a tween
    Move.speed = Util.zlim(Move.speed * Move.set.brake_friction)
end

function Move.enterNearestCockpit()
    --find the nearest cockpit
    local near = Entity.nearest(
                    Move.set.x, Move.set.y,
                    Sprite.set.COCKPIT,
                    Move.set.ship_grab_range)

    --set the ship id to the cockpit's entity id
    Move.ship_id = near.id

    if not Move.hasShip() then return end

    --stop the player
    Move.speed = 0
    Move.turn_speed = 0

    Window.scaleTo(1)
end

function Move.exitShip()
    Move.ship_id = nil
    Window.scaleTo(2)
end

function Move.hasShip()
    return Move.ship_id ~= nil
end

function Move.toggleShip()
    if Move.hasShip() then
        Move.exitShip()
    else
        Move.enterNearestCockpit()
    end
end

function Move.wrapWorld()
    function wrap(val)
        if val > Move.set.bound then
            return -Move.set.bound
        elseif val < -Move.set.bound then
            return Move.set.bound
        end

        return val
    end

    Move.set.x = wrap(Move.set.x)
    Move.set.y = wrap(Move.set.y)
end

function Move.getShipMaxSpd()
    --max speed is a function of overall weight and # of engines
    local blockfac = 
        (Grid.getBlockCount(Move.ship_id, Sprite.set.ENGINE) -
         Grid.getBlockCount(Move.ship_id) /
         Move.blocks_per_engine)*10

    if blockfac < 0 then blockfac = 0 end

    return Move.def_max_spd * blockfac
end

function Move.update()    
    if PAUSE_INPUT then return end

    Move.sprite = Move.set.outfit[1]

    --if you exceeded the bounds, wrap
    Move.wrapWorld()

    if Move.hasShip() then
        --calculate maximum speed
        Move.max_spd = Move.getShipMaxSpd()

        --use sprite 3: the ship sprite
        Move.sprite = Move.set.outfit[3]
    else
        --reset speed+acceleration to default
        Move.acc = Move.set.def_acc 
        Move.max_spd = Move.set.def_max_spd
        Move.max_turn_spd = Move.set.def_max_turn_spd
    end
	
    --emit jetpack flame and use jump sprite
    if not Move.hasShip() and love.keyboard.isDown("w") then
        Move.sprite = Move.set.outfit[2]
        Particle.emit(Particle.set.emit_typs.flame, Move.set.x, Move.set.y)
        Particle.emit(Particle.set.emit_typs.smoke, Move.set.x, Move.set.y)
    end
end

function Move.handleInput()
    if PAUSE_INPUT then return end

    --WASD moves the player, lshift slows player down 
    if love.keyboard.isDown("w") then Move.accel( 1) end
    if love.keyboard.isDown("s") then Move.accel(-1) end

    if love.keyboard.isDown("a") then Move.turn(-1) end
    if love.keyboard.isDown("d") then Move.turn( 1) end

    if love.keyboard.isDown("lshift") then Move.brake() end
end

function Move.tick()
    Move.handleInput()

    --add some environment turn friction to player
    Move.turn_speed = Util.zlim(Move.turn_speed * Move.set.turn_friction)
    
    --calculate velocity
    local vx = Move.speed * math.cos(Move.set.r)
    local vy = Move.speed * math.sin(Move.set.r)

    --add velocity to position
    Move.set.x = Move.set.x + vx
    Move.set.y = Move.set.y + vy
    Move.set.r = Move.set.r + Move.turn_speed

    if Move.hasShip() then
        --bind the ship to the player
        Entity.bind(Move.ship_id, 
                    Move.set.x,
                    Move.set.y, 
                    Move.set.r)

        --TODO rotate player around ship center
    else
        --update player sprite in batch
        local gs = Sprite.getGridSize()
        Sprite.upd(Move.batch_id, Move.sprite, 
                   0,0, Move.set.r, gs/2,gs/2)
    end
    
    --center window on the player
    Window.setShift(-Move.set.x, -Move.set.y)

    --animate stars with parallax
    Stars.setSpeed(vx, vy)
end

return Move
