Window = {}

--module attributes
Window.priority = 1
Window.cmd = { "window", "win" }

Window.set_file = "window_settings.dat"
Window.set = {
    width = 1600,
    height = 900,

    fullscreen = 0,

    vsync = 1,

    mouse_visible = 0,

    title = "Space Bois v0.0",

    scale = 2
}

Window.scale_target = Window.set.scale
Window.def_scale = Window.set.scale

Window.x_shift = 0
Window.y_shift = 0

function Window.init()
    --cap width and height
    Window.set.width = Util.range(Window.set.width, 640, 6400)
    Window.set.height = Util.range(Window.set.height, 640, 6400)

    --make sure mousevisibile is a boolean
    Window.set.mouse_visible = Util.range(Window.set.mouse_visible, 0, 1)

    --make sure fullscreen and vsync are bools
    Window.set.fullscreen = Util.sbool(Window.set.fullscreen)
    Window.set.vsync = Util.sbool(Window.set.vsync)

    --set window mode
    love.window.setMode(Window.set.width, Window.set.height, { 
                        fullscreen=Window.set.fullscreen,
                        vsync=Window.set.vsync 
                    })

    love.window.setTitle(Window.set.title)

    if Window.set.mouse_visible == 0 then
        love.mouse.setVisible(false)
    else 
        love.mouse.setVisible(true)
    end

    --set a scaled game canvas
    Window.swidth = Window.set.width/Window.set.scale
    Window.sheight = Window.set.height/Window.set.scale

    Window.makeCanvas()

    Window.scale_target = Window.set.scale
    Window.def_scale = Window.set.scale
end

function Window.setShift(x, y)
    Window.x_shift = x
    Window.y_shift = y
end

function Window.makeCanvas()
    Window.canvas = love.graphics.newCanvas(
                        Window.swidth, Window.sheight)

    Window.ui_canvas = love.graphics.newCanvas(
                        Window.set.width/Window.def_scale,
                        Window.set.height/Window.def_scale)

end

function Window.tick()
    if Window.scale_target ~= Window.set.scale then
        Window.set.scale = Window.set.scale +
            ( Window.scale_target - Window.set.scale ) * 0.1

        --if scale gets close enough to scale target, just set it
        if math.abs(Window.set.scale - Window.scale_target) < 0.1 then
            Window.set.scale = Window.scale_target
        end

        Window.swidth = Window.set.width/Window.set.scale
        Window.sheight = Window.set.height/Window.set.scale

        Window.makeCanvas()
    end
end

function Window.scaleTo(new_scale)
    Window.scale_target = new_scale
end

function Window.draw()
    love.graphics.setCanvas(Window.canvas)
    love.graphics.clear()

    Stars.draw()

    --translate so 0,0 is center of screen
    love.graphics.push()
    love.graphics.translate(
                    Window.swidth/2, 
                    Window.sheight/2)

    Particle.draw()
    Sprite.draw()

    love.graphics.pop()

    love.graphics.setCanvas(Window.ui_canvas)
    love.graphics.clear()

    UI.draw()

    love.graphics.setCanvas()
    love.graphics.draw(Window.canvas, 0,0, 0, 
                    Window.set.scale, Window.set.scale)
    love.graphics.draw(Window.ui_canvas, 0,0, 0, 
                    Window.def_scale, Window.def_scale)
end

return Window
