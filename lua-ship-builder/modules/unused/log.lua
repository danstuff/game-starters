Log = {}

--net settings
Log.priority = 3
Log.cmd = { "log" }

Log.set_file = "log_settings.dat"
Log.set = {
    sector_id = 12345,
    acts = {},

    new_sector_id = -1
}

--world attributes
Log.last_applied = 0
Log.last_sent = 0

function Log.init()
    Log.last_applied = 0
    Log.last_sent = 0
    Log.applyLog()
end

function Log.addLog(str)
    local acts = Util.split(str, "+") 

    for i,act_str in pairs(acts) do
        --overwrite similar actions
        for i,a in pairs(Log.set.acts) do
            local fc = string.find(a,",") 

            if string.sub(a,1,fc-1) == string.sub(act_str,1,fc-1) then
                a = act_str
                return
            end
        end

        table.insert(Log.set.acts, act_str)
    end
end

function Log.actSectorID(act_str)
    return tonumber(string.sub(act_str, 1, 5))
end

function Log.actEntityID(act_str)
    return string.sub(act_str, 8, string.find(act_str, ","))
end

function Log.actType(act_str)
    return string.sub(act_str, 6, 7)
end

function Log.actArgs(act_str)
    return Util.split(string.sub(act_str, 8, string.len(act_str), ","))
end

function Log.logStr(id, typ)
    --return a concatenated string of all log actions in a sector
    local str = ""

    for _,act_str in pairs(Log.set.acts) do
        if (typ == "sector" and Log.actSectorID(act_str) == id)
            or (typ == "entity" and Log.actEntityID(act_str) == id)then
            str = str .. act_str .. "+"
        end
    end

    return str
end

function Log.applyLog(i0, i1)
    if not i0 then i0 = 1 end
    if not i1 then i1 = #Log.set.acts end

    --catch up using the action log
    for i=i0,i1 do
        local a = Log.set.acts[i]
        Log.act(a)
    end

    Log.last_applied = i1
end

function Log.getLogUnsent()
    --send everything you did in the current sector
    if Log.last_sent+1 > #Log.set.acts then 
        Log.last_sent = 0
        return "" 
    end

    local log_str = ""
    local i = 0 

    for i=Log.last_sent+1,#Log.set.acts do
        if Log.actSectorID(Log.set.acts[i]) ==
            Log.set.sector_id then
            log_str = log_str .. Log.set.acts[i] .. "+"
        end

        if string.len(log_str) >= Net.set.msg_max then
            break
        end

        Log.last_sent = i

        return log_str
    end
end

function Log.applyLogNew()
    if Log.last_applied+1 > #Log.set.acts then 
        Log.last_applied = 0
        return 
    end

    Log.applyLog(Log.last_applied+1)
end

function Log.travelTo(new_sector)
    --reset last applied/sent action, add player_str to log, and apply
    Log.set.sector_id = new_sector
    Log.last_applied = 0
    Log.last_sent = 0
    Log.addLog(player_str)
    Log.applyLogNew()

    --reset net connection
    Net.reconnect()
end

function Log.act(action_str)
    --do whatever the action says to do to the world
    ---create entity:     secMKid,x,y,r,size
    ---destroy entity:    secDYid
    ---change entity pos: secSPid,x,y,r
    ---set entity block:  secSTid,gx,gy,b
    --TODO

    --if the action is for the current sector
    local current_id = Log.set.sector_id
    if Log.actSectorID(action_str) == current_id then
        local ar = Log.actArgs(action_str)
        local at = Log.actType(action_str)

        if  at == "MK" then
            Entity.make(Util.snum(ar[1]),
            Util.snum(ar[2]),
            Util.snum(ar[3]),
            Util.snum(ar[4]))

        elseif at == "KL" then
            Entity.kill(Util.snum(ar[1]))

        elseif at == "PS" or at == "BS" or at == "BR" then

            local tid = Util.snum(ar[1])
            local e = Entity.get(tid)

            if e ~= nil then
                if at == "PS" then
                    e.pos.x = Util.snum(ar[2])
                    e.pos.y = Util.snum(ar[3])
                    e.pos.r = Util.snum(ar[4])
                    e.vel.x = Util.snum(ar[5])
                    e.vel.y = Util.snum(ar[6])
                    e.vel.r = Util.snum(ar[7])
                elseif at == "BS" then
                    local blk = {
                        typ = ar[2],
                        r = ar[3],
                        g = ar[4],
                        b = ar[5]
                    }
                    Grid.setBlock(tid, blk, ar[6], ar[7])
                elseif at == "BR" then
                    Grid.removeBlock(tid, ar[2], ar[3])
                end
            end
        end
    end
end

function Log.update()    
    --broadcast all actions that happened since the last update
    Net.broadcast(Log.set.sector_id, Log.getLogUnsent())

    --listen for actions from others
    local new_act = Net.listen(5, Log.set.sector_id)
    if new_act ~= nil then Log.addLog(new_act) end

    --apply all the new actions
    Log.applyLogNew()

    --update the sector if it was changed
    if Log.set.new_sector_id >= 0 then
        Log.travelTo(Log.set.new_sector_id)
        Log.set.new_sector_id = -1
    end
end

function Log.tick()

end

return Log
