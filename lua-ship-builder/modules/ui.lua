UI = {}

--movement settings
UI.priority = 4
UI.cmd = { "ui" }

UI.set_file = "ui_settings.dat"
UI.set = {
    font_file_small = "resources/silkscreen.ttf",
    font_size_small = 8,

    font_file_large = "resources/athensclassic.ttf",
    font_size_large = 22
}

UI.texts_small = {}
UI.texts_large = {}

UI.options_open = false
UI.option_changed = false

UI.entering_command = false
UI.command_string = ""

function UI.init()
    UI.option_changed = false

    UI.loadFonts()
    UI.closeOptions()
end

function UI.wipe()
    UI.texts_small = {}
    UI.texts_large = {}
end

function UI.loadFonts()
    --load fonts
    UI.font_small = love.graphics.newFont(
    UI.set.font_file_small,
    UI.set.font_size_small)

    UI.font_large = love.graphics.newFont(
    UI.set.font_file_large,
    UI.set.font_size_large)
end

function UI.newText(text, x, y, w, size, id, command)
    if size == "large" then
        table.insert(UI.texts_large, {
            x = x, y = y,
            text = text
        })
    else
        table.insert(UI.texts_small, {
            x = x, y = y, w = w, 
            text = text, id = id,
            command = command
        })
    end
end

function UI.openOptions()
    UI.wipe()

    local tx = 10
    local ox = 100
    local px = 160
    local mx = 140

    UI.option_changed = false

    UI.newText("OPTIONS", tx, 10, 0, "large")

    UI.newText("Window Width", tx, 40, 0, "small")
    UI.newText("640", ox, 40, 0, "small", "wwidth")
    UI.newText("+", px, 40, 8, "small", "", "add window width 64")
    UI.newText("-", mx, 40, 8, "small", "", "add window width -64")

    UI.newText("Window Height", tx, 60, 0, "small")
    UI.newText("480", ox, 60, 0, "small", "wheight")
    UI.newText("+", px, 60, 8, "small", "", "add window height 64")
    UI.newText("-", mx, 60, 8, "small", "", "add window height -64")

    UI.newText("Vsync", tx, 80, 0, "small")
    UI.newText("OFF", ox, 80, 0, "small", "vsync")
    UI.newText("+", px, 80, 8, "small", "", "set window vsync true")
    UI.newText("-", mx, 80, 8, "small", "", "set window vsync false")

    UI.newText("Fullscreen", tx, 100, 0, "small")
    UI.newText("OFF", ox, 100, 0, "small", "fullscreen")
    UI.newText("+", px, 100, 8, "small", "", "set window fullscreen true")
    UI.newText("-", mx, 100, 8, "small", "", "set window fullscreen false")

    UI.newText("Sound Volume", tx, 120, 0, "small")
    UI.newText("10", ox, 120, 0, "small", "soundvol")
    UI.newText("+", px, 120, 8, "small", "", "add audio sound_vol 1")
    UI.newText("-", mx, 120, 8, "small", "", "add audio sound_vol -1")

    UI.newText("Music Volume", tx, 140, 0, "small")
    UI.newText("10", ox, 140, 0, "small", "musicvol")
    UI.newText("+", px, 140, 8, "small", "", "add audio music_vol 1")
    UI.newText("-", mx, 140, 8, "small", "", "add audio music_vol -1")

    UI.readOptions()
end

function UI.closeOptions()
    UI.wipe()

    UI.newText("Alpha Version, Do Not Distribute", 10, 10, 0, "small")

    UI.newText("0 m/s", 10, 32, 0, "small", "speed")

    UI.newText("", 10, Window.sheight-32, 0, "small", "output")
    UI.newText("", 10, Window.sheight-10, 0, "small", "entry")

    if UI.option_changed == true then 
        Command.send("init")
    end
end

function UI.toggleOptions()
    UI.options_open = not UI.options_open

    if UI.options_open then UI.openOptions()
    else UI.closeOptions() end
end

function UI.readOptions()
    UI.setText("wwidth", tostring(Window.set.width))
    UI.setText("wheight", tostring(Window.set.height))

    if Window.set.vsync == true then
        UI.setText("vsync", "ON")
    else 
        UI.setText("vsync", "OFF")
    end

    if Window.set.fullscreen == true then
        UI.setText("fullscreen", "ON")
    else 
        UI.setText("fullscreen", "OFF")
    end

    UI.setText("soundvol", tostring(Audio.set.sound_vol))
    UI.setText("musicvol", tostring(Audio.set.music_vol))

end

function UI.setText(id, new_text)
    for i,t in pairs(UI.texts_small) do
        if t.id == id then
            t.text = new_text
            return
        end
    end
end

function UI.checkClick(mx, my)
    local fs = UI.set.font_size_small
    for i,t in pairs(UI.texts_small) do
        if t.x <= mx and t.x + t.w >= mx
        and t.y <= my and t.y + fs >= my 
        and t.command ~= nil then
            Command.send(t.command)
            UI.option_changed = true
        end
    end
end

function UI.drawTexts(list, font)
    --loop and draw all texts in list
    love.graphics.setFont(font)

    for i,t in pairs(list) do
        love.graphics.print(t.text, t.x, t.y)
    end
end

function UI.prompt(cmd_str)
    --TODO
end

function UI.keypressed(key)
    --toggle command entry on enter
    if key == "return" and love.keyboard.isDown("lctrl") then 
        UI.entering_command = not UI.entering_command 

        if command_string ~= "" then
            Command.send(UI.command_string)
            UI.command_string = ""
            UI.setText("entry", "")
        end
    end

    --remove a character from command on backspace
    if key == "backspace" and UI.entering_command then
        command_string = 
        command_string:sub(1, #command_string-1)
        UI.setText("entry",">"..command_string)
    end

    if UI.entering_command then return end
end

function UI.textinput(text)
    if not UI.entering_command then return end

    --add text input to command and print
    UI.command_string = UI.command_string .. text
    UI.setText("entry",">"..UI.command_string)
end

function UI.update()
    if UI.option_changed == true then
        UI.readOptions()
        UI.option_changed = false
    end

    UI.setText("speed", tostring(math.floor(Move.speed / METERS_PER_SECOND)) .. " m/s")
end

function UI.draw()
    --draw small and large texts
    UI.drawTexts(UI.texts_small, UI.font_small)
    UI.drawTexts(UI.texts_large, UI.font_large)
end

return UI
