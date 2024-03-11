local modem = rednet.open("top")
local monitor = peripheral.find("monitor")
local cursor_y = 1
local names = {}


monitor.clear()
monitor.setCursorPos(1, 1)



while true do
    local id, message = rednet.receive()
    monitor.write(id..": "..message)
    if cursor_y < 9 then
        cursor_y = cursor_y + 1
    else
        monitor.scroll(1)
    end

    monitor.setCursorPos(1, cursor_y)
end
