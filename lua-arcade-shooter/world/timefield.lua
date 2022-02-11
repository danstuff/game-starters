local TimeField = {}

MAX_TF_RANGE = 100

TimeField.mems = {}

function TimeField.new(fac, x, y, gradual, rad, time)
    table.insert(TimeField.mems, { fac = fac,
    x = x, y = y, gradual = gradual,
    rad = rad, time = time, tf = 1 })
    
    return #TimeField.mems
end

function TimeField.get(obj)
    --return rate at which time elapses in a given pos, 1 being default
    local total_fac = 0
    local fieldct = 0
    for _,field in ipairs(TimeField.mems) do
        local dist = math.sqrt((obj.x-field.x)^2 + (obj.y-field.y)^2)

        if dist <= field.rad then
            local nf = field.fac

            if gradual then
                nf = (dist/field.rad + 
                field.fac*((field.rad-dist)/field.rad))
            end

            total_fac = total_fac + nf

            fieldct = fieldct + 1
        end
    end

    --take the average of all effecting mems
    if fieldct > 0 then
        total_fac = total_fac / fieldct
    else
        total_fac = 1
    end

    return total_fac
end

function TimeField.updateall()
    for _,field in ipairs(TimeField.mems) do
        --reduce time
        field.time = field.time - DEC
        if field.time <= 0 and field.time > ENDLESS then
            table.remove(TimeField.mems, _)
        end
    end
end

return TimeField
