UPDATES_PER_SEC = 100

--multiply by this to put motion in pixels/units per second
PPS = 1/UPDATES_PER_SEC

--also used to decrement/increment timers
DEC = PPS
INC = PPS

--used to set timers to never run out
ENDLESS = -2000

function love.run()
    if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

    -- We don't want the first frame's dt to include time taken by love.load.
    if love.timer then love.timer.step() end
    local dt = 0

    local lag = 0

    -- Main loop time.
    return function()
        -- Update dt, as we'll be passing it to update
        if love.timer then lag = lag + love.timer.step() end

        --record total time elapsed since last update in lag
        lag = lag+dt

        --keep updating until you must draw
        while lag >= DEC do
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

            -- Call update 
            if love.update then love.update() end 

            lag = lag - DEC
        end

        collectgarbage()

        --draw to the screen
        if love.graphics and love.graphics.isActive() then
            love.graphics.origin()
            love.graphics.clear(love.graphics.getBackgroundColor())

            love.draw()

            love.graphics.present()
        end

        --sleep for a moment; gives control back to OS
        if love.timer then love.timer.sleep(0.0001) end
    end
end
