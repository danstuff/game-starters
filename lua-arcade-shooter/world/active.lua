local Active = {}

function Active.new(name, cost, time, cool, startfunc, endfunc)
    local active = { name = name,
    cost = cost,
    time = time,
    cool = cool,
    startfunc = startfunc,
    endfunc = endfunc }

    return active
end

--functions for individual active items
--ionic timefield
function Active.itf_start(e, active)
    tfid = TimeField.new(0.001, e.x, e.y, false, 50, active.time)
    Emitter.new(TimeField.mems[tfid], ion_charge)

    Ship.modify(e, "turn", 1000, 0, active.time*0.01)
    Ship.modify(e, "wepcool", 0.001, 0, active.time*0.01)
end

function Active.itf_end(e, active)
    Emitter.new(e, ion_explosion)
end

return Active
