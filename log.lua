function log(message)
    local logfile = "/log.txt"

    if fs.exists(logfilfe) then
        local file = fs.open(logfile, "a")
    else
        local file = fs.open(logfile, "w")
    end

    print(message)
    rednet.broadcast(message, "log")
    file.writeLine(message)
    file.close()
end

return log