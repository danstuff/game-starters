local UI = {}

local debug = true
UI.lock = true
UI.statetime = 0

UI.starttext = ""
UI.startboxslide = 0

UI.gametime = 0
UI.time_str = ""

UI.color = {1, 1, 1}

function UI.updategame(player)
    UI.statetime = UI.statetime + INC 

    --update the timer in the top right
    if not player.finished then
        local time_ms = math.floor((UI.gametime*100)%60)
        local time_s = math.floor(UI.gametime%60)
        local time_m = math.floor(UI.gametime/60)
        UI.time_str = string.format("%02d:%02d:%02d", time_m, time_s, time_ms)

        if UI.statetime > 3.1 then
            UI.gametime = UI.gametime + INC
        end
    end

    --3, 2, 1, GO! for races
    if UI.statetime < 5 then
        UI.lock = true

        if UI.statetime < 1.1 then
            UI.starttext = "3"
        elseif UI.statetime < 2.1 then
            UI.starttext = "2"
        elseif UI.statetime < 3.1 then
            UI.starttext = "1"
        else
            UI.lock = false
            UI.starttext = "GO!"
        end

        if UI.starttext == "GO!" then
            UI.startboxslide = UI.startboxslide*0.95
        else
            local cbs = UI.startboxslide
            UI.startboxslide =  cbs + (GAME_WIDTH - cbs)*0.05
        end
    else
        UI.lock = false
    end

    if player then
        --UI turns red when power is dangerously low
        if player.power < player.typ.power*0.25 then
            UI.color = {1, 0, 0}
        end

        --shake progressively more as you use energy
        if player.enabled then
            if player.power < player.typ.power*0.10 then
                Camera.shake(5, 0.5)
            elseif player.power < player.typ.power*0.25 then
                Camera.shake(1, 0.5)
            end
        end

        if player.finished then
        end

        if UI.color ~= {1, 1, 1} then
            UI.color[1] = UI.color[1] + (UI.color[1] + 1)*0.01
            UI.color[2] = UI.color[2] + (UI.color[2] + 1)*0.01
            UI.color[3] = UI.color[3] + (UI.color[3] + 1)*0.01
        end
    end
end

function UI.drawgame(player)
    local w = GAME_WIDTH
    local h = GAME_HEIGHT

    love.graphics.setColor(UI.color)

    --print FPS if in debug mode
    if debug then
        local fps = tostring(love.timer.getFPS(), 0, 0)
        love.graphics.printf( fps.. " FPS", 0, 0, w, "center")
    end

    --draw the player's stats to the screen
    if player then
        --active item box
        love.graphics.setColor({0,0,0})
        love.graphics.rectangle("fill", 0, 0, 50, 50)

        love.graphics.setColor(UI.color)
        love.graphics.rectangle("line", 0, 0, 50, 50)
        love.graphics.printf("USE", 0, 0, 50, "center")
        love.graphics.printf(player.active.name, 0, 12, 50, "center")

        --draw the cooldown time as a shadow on the active item box
        love.graphics.setColor({0,0,0,0.7})
        local cooly = (player.actcool / player.active.cool)*50
        love.graphics.rectangle("fill", 0, 50-cooly, 50, cooly) 

        --power bar
        love.graphics.setColor(UI.color)
        love.graphics.printf("POWER", 0, h-25, w, "center")
        love.graphics.rectangle("fill", w/2, h-12, player.power, 6)
        love.graphics.rectangle("fill", w/2, h-12, -player.power, 6)

        --lap timer
        love.graphics.printf("LAP " .. tostring(player.laps or 1) .. " - " .. UI.time_str,
        0, 0, w, "right")

        --draw WRONG WAY!
        if player.wrongway then
            love.graphics.setColor({1,0,0})
            love.graphics.printf("WRONG WAY!", 0, h/2-24, w, "center")
        end
    end

    --draw 321GO!
    if UI.statetime < 5 then
        love.graphics.setColor(UI.color)
        love.graphics.rectangle("fill", 0, h/2-35, UI.startboxslide, 70)
        love.graphics.setColor({0,0,0})
        love.graphics.rectangle("fill", 0, h/2-30, UI.startboxslide, 60)

        love.graphics.setColor(UI.color)
        love.graphics.setFont(font_med)
        love.graphics.printf(UI.starttext, 0, h/2-24, w, "center")
        love.graphics.setFont(font_sml)
    end

    love.graphics.setColor({1, 1, 1})
end

return UI
