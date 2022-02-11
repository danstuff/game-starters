Timer = require("libraries/hump/timer")
Moses = require("libraries/moses/moses")
Enet = require("enet")

Util = {}

require("utility/value")
require("utility/io")

Command = require("command")

--constant metrics
SECS_PER_TICK = 0.01

PX_PER_METER = 16

METERS_PER_SECOND = PX_PER_METER * SECS_PER_TICK

METERS_PER_SECOND_SQ = math.pow(METERS_PER_SECOND, 2)

MS = METERS_PER_SECOND
MSS = METERS_PER_SECOND_SQ

ZERO_LIMIT = 0.001 --how close you can get to 0 before rounding down

TICKS_PER_UPDATE = 1 --updates happen every 5 ticks

UPDATE_RUNS = 2 --how many modules are updated per update cycle

PAUSE_INPUT = false --flag; true when UI is open

function love.run()
    if love.math then love.math.setRandomSeed(os.time()) end

    love.keyboard.setKeyRepeat(false)
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.filesystem.setIdentity("SpaceBois/")
    
    --INITIALIZATION
    Command.require()

    Command.load()

    Command.init()

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end
    local dt, lag = 0, 0
    local update_time = 0

    -- Main loop time.
    return function()
        -- Update dt, as we'll be passing it to update
        if love.timer then dt = love.timer.step() end

        --record total time elapsed since last update in lag
        lag = lag+dt

        --keep updating until you must draw
        while lag >= SECS_PER_TICK do
            -- Process events.
            if love.event then
                love.event.pump()
                for name, a,b,c,d,e,f in love.event.poll() do
                    if name == "quit" then
                        if not love.quit or not love.quit() then
                            return a or 0
                        end
                    end
                    love.handlers[name](a,b,c,d,e,f)
                end
            end

            --TICK
            Timer.update(SECS_PER_TICK)
            
            --update every x ticks
            if update_time == 0 then
                Command.update()
                update_time = TICKS_PER_UPDATE
            end

            Command.tick()

            update_time = update_time - 1
            lag = lag - SECS_PER_TICK
        end

        --draw to the screen
        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())

            --DRAW
            Window.draw()

            love.graphics.present()
        end

        --sleep for 1ms; gives control back to OS
        if love.timer then love.timer.sleep(0.0001) end
    end
end

--pass mouse wheel events to place
function love.wheelmoved(x, y)
    Place.changeSelectedBlock(y)
end

--pass mouse move events to place
function love.mousemoved(x, y)
    Place.mouseChange(x, y)
end

--pass click events to UI
function love.mousepressed(x, y, button)
    if button == 1 then
        UI.checkClick(x/Window.set.scale, y/Window.set.scale)
    end
end

--process game key press events
function gamekeypress(key)
    if key == "tab" and not PAUSE_INPUT then
        Move.toggleShip()
    elseif key == "escape" then
        UI.toggleOptions()
        PAUSE_INPUT = not PAUSE_INPUT
    end
end

function love.keypressed(key)
    UI.keypressed(key)
    gamekeypress(key)
end

function love.textinput(text)
    UI.textinput(text)
end
