local Arrow = {}

Arrow.mems = {}
Arrow.col = {1,1,1,0.6}

function Arrow.new(x, y, w, l, sl, rot, col)
    arrow = {}

    arrow.x = x
    arrow.y = y

    arrow.rot = rot*math.pi/180

    arrow.col = col

    arrow.scale = 1
    arrow.time = math.random(0,100)

    arrow.stem = { -(l/2), -(w/4), 
    -(l/2)+sl, -(w/4),
    -(l/2)+sl, w/4,
    -l/2, w/4 }

    arrow.head = { -(l/2)+sl, -(w/2),
    l/2, 0,
    -(l/2)+sl, w/2,
    }

    table.insert(Arrow.mems, arrow)

    return #Arrow.mems
end

function Arrow.setcolor(col)
    Arrow.col = col
end

function Arrow.updateall()
    for _,arrow in ipairs(Arrow.mems) do
        arrow.time = arrow.time + INC
        arrow.scale = math.sin(arrow.time*5)/5+1
    end
end

function Arrow.drawall()
    for _,arrow in ipairs(Arrow.mems) do
        love.graphics.setColor(Arrow.col)
        drawn = true
        love.graphics.push()
        love.graphics.translate(arrow.x, arrow.y)
        love.graphics.scale(arrow.scale)
        love.graphics.rotate(arrow.rot)
        love.graphics.polygon("fill",arrow.stem)
        love.graphics.polygon("fill",arrow.head)
        love.graphics.pop()
    end
end

return Arrow
