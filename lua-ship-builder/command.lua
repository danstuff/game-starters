local Command = {
    --command elements
    NONE = { "none" },

    --terminate/restart game
    RESTART = { "restart", "r" },
    QUIT = { "quit", "q" },
    
    --i/o from module files
    LOAD = { "load", "l" },
    SAVE = { "save", "s" },
    INIT = { "init", "i" },

    WIPE = { "wipeout" },

    --i/o from command line
    QUERY = { "query", "qu" },
    PRINT = { "print", "pr" },

    --module configuration
    SET = { "set", "st" },
    ADD = { "add", "ad" }
}

Command.queue = {}
Command.next_upd = 1

function Command.require()
    --get all modules in the modules folder
    Command.modules = {} 
    
    Util.fordir("modules", 
        function(file)
            local pd = file:find("%.")

            if pd ~= nil and pd > 1 and
                file:sub(pd, #file) == ".lua" then

                table.insert(Command.modules,
                            require(file:sub(1, pd-1)))
            end
        end)

    --sort the modules ascending based on priority attribute
    local function comp(a, b) return a.priority < b.priority end
    Command.modules = Moses.nsorted(Command.modules, #Command.modules, comp)
end

function Command.init()
    print("Init start")

    for _,module in pairs(Command.modules) do
        print(string.format(">> %s", module.set_file))
       if module.init ~= nil then module.init() end 
    end
    
    print("Init complete")
end

function Command.load()
    print("Load start")

    --load in each module's settings
    for _,module in pairs(Command.modules) do
        print(string.format(">> %s", module.set_file))
        module.set = Util.load(module.set, module.set_file)
    end

    print("Load complete")
    
end

function Command.save()
    print("Save start")

    --write each module's settings to file
    for _,module in pairs(Command.modules) do
        print(string.format(">> %s", module.set_file))
        Util.save(module.set, module.set_file)
    end

    print("Save complete")
end

function Command.update()
    for i = Command.next_upd,Command.next_upd+UPDATE_RUNS do
        if i > #Command.modules then break end

        local module = Command.modules[i]
        if module.update ~= nil then module.update() end
    end

    Command.next_upd = Command.next_upd + UPDATE_RUNS 

    if Command.next_upd > #Command.modules then
        Command.next_upd = 1
    end
end

function Command.tick()
    Command.process()

    local last = love.timer.getTime()
    for _,module in pairs(Command.modules) do
        if module.tick ~= nil then module.tick() end
    end

end

function Command.wipeout()
    --WARNING: resets all setttings to default
    --use with caution
    Util.fordir("/",
        function(file)
            if string.find(file, ".dat") ~= nil then
                love.filesystem.remove(file)
                print(string.format("Removed %s", file))
            end

        end)

    print("Wipeout complete")
end

function Command.send(args)
    assert(type(args) == "string")

    args = args:lower()

    --split up the arg string by whitespace
    local arg_table = {}

    for str in string.gmatch(args, "([^%s]+)") do
        table.insert(arg_table, str)
    end

    --add it to the queue
    table.insert(Command.queue, arg_table)
end

function Command.is(str, command)
    --test if str matches one of command's values
    for _,name in pairs(command) do
        if str == name then return true end
    end

    return false
end

function Command.match(cmd)
    for _, module in pairs(Command.modules) do
        if Command.is(cmd, module.cmd) then
            return module
        end
    end

    return nil
end

function Command.set(module, name, value) 
    --set the module's setting to the given value 
    local mvalue = module.set[name]

    --ensure module's value exists
    if mvalue ~= nil then

        if type(mvalue) == "boolean" then
            value = Util.sbool(value)
        end

        --ensure that types match
        if type(mvalue) == type(value) then

            --set the value
            module.set[name] = value

            --save module
            Util.save(module.set, module.set_file)

            print(string.format("Set %s %s to %s",
                module.cmd[1], name, value))
        else
            print(string.format("%s is not a %s", 
                name, type(value)))
        end
    else
        print(string.format("Module %s does not have a value %s",
            module.cmd[1], name))
    end
end

function Command.add(module, name, change)
    local mvalue = module.set[name]

    if type(mvalue) == "number" then
        Command.set(module, name, mvalue + change)
    else
        print(string.format("Module %s value %s cannot be added to; not a number",
            module.cmd[1], name))
    end
end

function Command.process()
    if #Command.queue == 0 then return end

    --pull the command from the queue
    local c = Command.queue[1]
    table.remove(Command.queue, 1)

    --restarting 
    if #c >= 1 and Command.is(c[1], Command.RESTART) then 
        Command.init(true)
        love.event.quit("restart")

    --quitting
    elseif #c >= 1 and Command.is(c[1], Command.QUIT) then
        Command.init(true)
        love.event.quit()

    --saving
    elseif #c >= 1 and Command.is(c[1], Command.SAVE) then
        Command.save() 

    --loading
    elseif #c >= 1 and Command.is(c[1], Command.LOAD) then
        Command.load() 

    --initializing
    elseif #c >= 1 and Command.is(c[1], Command.INIT) then
        Command.init() 

    --clear all save files
    elseif #c >= 1 and Command.is(c[1], Command.WIPE) then
        Command.wipeout() 
        love.event.quit("restart")

    --setting values
    elseif #c >= 4 and Command.is(c[1], Command.SET) then
        
        --match the second word to a module
        local  module = Command.match(c[2])

        --set the module value
        if module ~= nil then
            Command.set(module, c[3], Util.snum(c[4]))
        else
            print(string.format("Module %s not found", c[2]))
        end

    elseif #c >= 4 and Command.is(c[1], Command.ADD) then
            
        --match the second word to a module
        local module = Command.match(c[2])

        --add to the module value
        if module ~= nil then
            Command.add(module, c[3], Util.snum(c[4]))
        else
            print(string.format("Module %s not found", c[2]))
        end

    --failed to process, do nothing
    else
        print("PASS")
    end
end

return Command
