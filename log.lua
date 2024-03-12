function log(...)
    local args = {...}
    local logfile = "/log.txt"
    local file

    message = listToString(args)

    if fs.exists(logfile) then
        file = fs.open(logfile, "a")
    else
        file = fs.open(logfile, "w")
    end

    print(message)
    rednet.broadcast(message, "log")
    file.writeLine(message)
    file.close()
end

function listToString(list)
    local result = ""
    local seperator = ""
    for i, v in pairs(list) do
        if type(v) == "table" then
            result = result..seperator..tableToString(v)
        else
            result = result..seperator..tostring(v)
        end
        seperator = " "
    end

    return result
end


function tableToString(tbl)
    local result = "{"
    local seperator = ""
    for k, v in pairs(tbl) do
        result = result..seperator..tostring(k)..": "
        if type(v) == "table" then
            result = result..tableToString(v)
        else
            result = result..tostring(v)
        end
        seperator = ", "
    end
    result = result.."}"
    return result
end

return log