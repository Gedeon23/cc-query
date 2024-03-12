function log(message)
    local logfile = "/log.txt"
    local file

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

return log