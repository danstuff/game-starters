Util = require("util")
Loop = require("loop")

Camera = require("camera")

UI = require("ui")

World = require("world/world")

--TODO implement a global maximum particle value

WINDOW_WIDTH = 960
WINDOW_HEIGHT = 700

GAME_WIDTH = 480
GAME_HEIGHT = 350 

local steps = 0
local initial = love.timer.getTime()

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)

    --graphics configuration
    love.graphics.setBackgroundColor(0,0,0)
    love.graphics.setLineStyle("rough")

    --create small canvas for pixelated look
    main_canvas = love.graphics.newCanvas(GAME_WIDTH, GAME_HEIGHT)
    main_canvas:setFilter("nearest","nearest")

    --load the font
    font_sml = love.graphics.newFont("VCR OSD Mono.ttf", 12, "mono")
    font_med = love.graphics.newFont("VCR OSD Mono.ttf", 48, "mono")
    love.graphics.setFont(font_sml)

    --load fault sound
    local fault_data = love.sound.newSoundData("fault.wav")
    fault_sound = love.audio.newSource(fault_data)

    --generate a starfield for the background
    Camera.makestars(3)

    --initialize global object list and types
    World.init()
    World.create()
end

function love.update()
    Camera.update()
    World.update() 
    UI.updategame(Ship.mems[playerid])

    --steps = steps + 1
    if steps >= 100 then
        print("mem: " ..tostring(collectgarbage("count")) .. 
        " at " .. tostring(love.timer.getTime()-initial) .. " s")
        steps = 0
    end
end

function love.draw()
    --draw to scaled canvas
    love.graphics.setCanvas(main_canvas)
    love.graphics.clear()

    --draw the world relative to camera's position
    Camera.drawstart()

    World.draw()

    Camera.drawend()

    --draw user interface
    UI.drawgame(Ship.mems[playerid])

    --draw to final canvas
    love.graphics.setCanvas()
    love.graphics.draw(main_canvas, 0,0,0, 2,2)
end
