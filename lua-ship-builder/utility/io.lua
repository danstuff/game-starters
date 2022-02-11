--SYMBOLS
local ft = ".dat" --type of file to write

local eq = " = " -- how equals is represented in-file

local nl = "\r\n" --newline symbol

local td = "@@" --table reference symbol

local gd = "##" --grid reference symbol
local gv = "," --grid value divider

function sset(line, target, value)
    if type(target) == "boolean" then
        value = Util.sbool(value)
    end

    if type(target) == type(value) then
        target = value
    else
        print("Type mismatch, ignoring "..line)
    end
end

--loop recursively over a directory, perform function on files
function Util.fordir(dir, func, behavior)
    local list = {}
    local dir_items = love.filesystem.getDirectoryItems(dir)
    
    for _, item in ipairs(dir_items) do
        local file = dir .. "/" .. item
        local info = love.filesystem.getInfo(file)

        if info.type == "file" then
            func(file, item)
        elseif info.type == "directory" 
        and behavior == "recursive" then
            Util.fordir(file, func)
        end
    end

    return list
end

--load in an object in the form of name = value
function Util.load(object, filename)
    if love.filesystem.getInfo(filename) == nil or object == nil then
        print("File not found: "..filename)
        return object
    end

    for line in love.filesystem.lines(filename) do
        if line == nil then break

        elseif line:find(eq) then
            local bef_eq = Util.bef(line, eq)
            local aft_eq = Util.snum(Util.aft(line, eq))

            --if its a table reference, recursively load it
            if bef_eq:find(td) then
                --remove the table deliminator and load
                bef_eq = Util.snum(string.gsub(bef_eq, td, ""))
                sset(line, object[bef_eq], Util.load(object[bef_eq], aft_eq))

            else
                bef_eq = Util.snum(bef_eq)
                sset(line, object[bef_eq], aft_eq)
            end
        else
            print("Invalid line "..line)
        end
    end

    return object
end

--save an object in the form of name = value
function Util.save(object, filename)
    love.filesystem.newFile(filename)

    local content = ""

    for name, value in pairs(object) do
        if type(value) ~= "table" then
            content = content .. name .. eq .. tostring(value) .. nl
        else 
            --tables recursively get their own files
            local folder = string.gsub(filename, ft, "")
            local tfn = folder .. "/" .. name .. ft

            love.filesystem.createDirectory(folder)

            content = content .. td .. name .. eq .. tfn .. nl
            Util.save(value, tfn)
        end
    end

    love.filesystem.write(filename, content)
end

