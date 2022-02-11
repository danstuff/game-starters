World = {}

--net settings
World.priority = 3
World.cmd = { "world", "w" }

World.set_file = "world_settings.dat"
World.set = {
    bound = 11000,
    spawn_bound = 9000,

    ship_count = 64,

    ship_dir = "resource/ships/",
    current_sector = 12345,
    action_log = {},

    warp_hold_time = 3
}

--world attributes
World.time_to_warp = 3

function World.init()
    World.time_to_warp = World.set.warp_hold_time

    World.regenerate()
end

function World.clear()
    Entity.list = {}
end

function World.regenerate()
    World.clear()

    --use sector as a seed to generate a world
    math.randomseed(World.set.current_sector)

    --create environmental entities
    local ships = 0

    Util.fordir(World.set.ship_dir,
        function(file, item)
            if ships > World.set.ship_count then 
                return 
            end

            local x = math.random(
                        -World.set.spawn_bound,
                         World.set.spawn_bound)
            local y = math.random(
                        -World.set.spawn_bound,
                         World.set.spawn_bound)

            local id = Entity.make(World.uniqueID(), x,y)
            Grid.loadTo(Entity.get(id), file)

            ships = ships + 1
        end)
end

function World.uniqueID()
	--TODO generate a unique ID number for the entity
    return math.floor(math.random() * 9999)
end

function World.update()    
    --trigger warp to new sector
    if love.keyboard.isDown("r") and Move.engineCount() >= 16 then
        World.time_to_warp = World.time_to_warp - 1
        Particle.emit(Particle.set.emit_typs.warp, Entity.x_shift, Entity.y_shift)

        if World.time_to_warp <= 0 then
            UI.setText("output", "Enter a sector ID:")
            UI.prompt("set log new_sector_id")
            --TODO
        else
            World.time_to_warp = World.set.warp_hold_time
        end
    end
end

return World
