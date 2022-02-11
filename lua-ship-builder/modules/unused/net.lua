Net = {
    ACTION_CREATE_ENTITY = 0, --x, y, ... 
    ACTION_DELETE_ENTITY = 1, --id
    ACTION_PLACE = 2, --id, block, x, y
}

--net settings
Net.priority = 5
Net.cmd = { "net" }

Net.set_file = "net_settings.dat"
Net.set = {
    hostname = "localhost: 5678",

    cons = {
        "localhost:6789" 
    },

    msg_max = 32
}

--net attributes
Net.host = nil
Net.servers = {}

function Net.init()
    --set up server
    Net.host = Enet.host_create(Net.set.hostname)

    --as a client, connect to each server
    for i,addr in pairs(Net.set.cons) do
        table.insert(Net.servers, Net.host:connect(addr))
    end
end

function Net.reconnect()
    Net.quit()
    Net.init()
end

function Net.broadcast(entry_key, message)
    Net.host:broadcast(entry_key..message)
end

function Net.verify(entry_key, data_str)
    return string.sub(data_str, 1, 5) == entry_key
end

function Net.listen(timeout, entry_key)
    --TODO start this on a new thread
    local event = Net.host:service(timeout)

    if not event then return end

    if event.type == "connect" then
        print("Net connected: ".. event.peer)

        --verify yourself with the world's log string
        event.peer:send(entry_key)

    elseif event.type == "recieve" then
        print("Net message: " .. event.data)

        if Net.verify(entry_key, event.data) then
            event.peer:send(entry_key.."ACCEPT")

            return event.data
        else
            event.peer:send("DENY")
            event.peer:disconnect()
        end

        if event.data == "DENY" then
            event.peer:disconnect() 
        end
    end

    return ""
end

function Net.quit()
    for i,s in pairs(Net.servers) do
        s:disconnect()
    end

    Net.host:flush()
end

return Net
