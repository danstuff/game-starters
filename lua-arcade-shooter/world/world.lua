Physics = require("world/physics")

TimeField = require("world/timefield")

Active = require("world/active")

Emitter = require("world/emitter")

Wall = require("world/wall")
Arrow = require("world/arrow")

Track = require("world/track")

Ship = require("world/ship")
Player = require("world/player")

Item = require("world/item")
Bullet = require("world/bullet")

local World = {}

function World.init()
    --function order: stats, then update, draw, onhit, ondie functions

    --new weapon type: standard
    standard_shot = Bullet.newtyp(
    { spd = 500*PPS, rad = 3, len = 10, col = {1,0,0}, time = 2, 
    cost = 5, cool = 0.25 }, 
    {{ name = "charge", add = -1, time = 1 }})

    --timefield active item
    ionic_tf_active = Active.new("Ionic Time Field", 60, 2, 3,
    Active.itf_start, Active.itf_end)

    --new ship type: player ship
    player_ship = Ship.newtyp(
    { power = 100, charge = 0.1,
    speed = 500*PPS, acc = 1*PPS,
    brake = 0.97, turn = 7*PPS,
    rad = 9 })    

    --item type: adds 10 to your boost
    boost_item = Item.newtyp(
    { col = {0,0,1,1}, rad = 5 },
    Item.update, Item.draw, nil, nil)

    -- PARTICLE EMITTERS --
    --basic flame particle emitter
    small_flame = Emitter.newtyp(
    3, ENDLESS, "out", {0, 1}, 300, 
    { time = {0.1, 0.3}, rad = { 1, 4 }, spd = {0.1, 2}, 
    cols = {{1,0.5,0}, {1,0,0}} })

    --small spark for collisions
    small_spark = Emitter.newtyp(
    100, 0.01, "out", {0, 1}, 100,
    { time = {0.1, 0.2}, rad = { 1, 2 }, spd = { 1, 3 }, 
    cols = {{1,1,0}, {0.5,1,0}, {1,0.5,0}} })

    --blue ion explosions
    ion_charge = Emitter.newtyp(
    1, 0.5, "dir", {100, 110}, 100,
    { time = {0.1, 0.5}, rad = { 1, 5 }, spd = { -2, -0.1 },
    cols = {{0,0,1}, {0,0.5,1}, {0.1,0.1,0.9}} })

    ion_explosion = Emitter.newtyp(
    100, 0.01, "random", {0, 1}, 100,
    { time = {1, 2}, rad = { 1, 5 }, spd = { 3, 7 },
    cols = {{0,0,1}, {0,0.5,1}, {0.1,0.1,0.9}} })

    --big explosion for ship deaths
    fire_explosion_big = Emitter.newtyp(
    100, 0.01, "random", {0, 1}, 100,
    { time = {1, 2}, rad = { 1, 5 }, spd = { 3, 7 },
    cols = {{1,0,0}, {1,0.5,0}, {1,1,0}} })
end

function World.create()  
    --create the player's ship
    playerid = Ship.new(player_ship, 
    standard_shot, ionic_tf_active, {1, 0, 0}, 150, 150, 0)

    --make the camera follow the player's ship
    Camera.follow(Ship.mems[playerid])

    --TODO create track item spawners

    --create the track bounds, with corners
    Wall.newBox(0, 0, 2000, 900, 100) 
    Wall.newBox(150, 300, 1850, 600, 70) 

    --create obstacles
    Wall.newBox(850, 70, 1150, 230, 30)
    Wall.newBox(850, 670, 1150, 830, 30)

    --draw arrows
    Arrow.setcolor{0.6, 0.6, 1, 0.6}

    --arrows in each corner
    Arrow.new(110, 220, 50, 100, 60, -45)
    Arrow.new(1890, 220, 50, 100, 60, 45)
    Arrow.new(1890, 680, 50, 100, 60, 135)
    Arrow.new(110, 680, 50, 100, 60, 225)

    --arrows along the straightaways
    Arrow.new(500, 150, 50, 100, 60, 0)
    Arrow.new(1500, 150, 50, 100, 60, 0)
    Arrow.new(500, 750, 50, 100, 60, 180)
    Arrow.new(1500, 750, 50, 100, 60, 180)

    --create finish line and lines to track track progress
    Track.setfinish(300, 0, 300, 300, 40, 10)
    Track.newprogline(500, 0, 500, 300)
    Track.newprogline(1000, 0, 1000, 300)
    Track.newprogline(1500, 0, 1500, 300)
    Track.newprogline(1850, 450, 2000, 450)
    Track.newprogline(1500, 600, 1500, 900)
    Track.newprogline(1000, 600, 1000, 900)
    Track.newprogline(500, 600, 500, 900)
    Track.newprogline(0, 450, 150, 450)
end

function World.update()
    if not UI.lock then
        --control player
        Player.control(Ship.mems[playerid])

        --update all the objects, starting with highest priority
        Ship.updateall()
        TimeField.updateall()

        Track.updateships(Ship.mems)

        Item.updateall()
        Wall.updateall()
    end

    --cosmetics
    Arrow.updateall()
    Emitter.updateall()
end

function World.draw()
    --draw all objects starting with lowest priority
    Track.draw()
    Arrow.drawall()
    Emitter.drawall()
    Wall.drawall()

    Item.drawall()
    Ship.drawall()
end

return World
