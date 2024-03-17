local modem = rednet.open("top")
local monitor = peripheral.find("monitor")
local cursor_y = 1
local names = {}
local terminal_width, terminal_height = monitor.getSize()
local number_of_rows = terminal_height * 6 - 2

monitor.clear()
monitor.setCursorPos(1, 1)



while true do
    local id, message = rednet.receive("log")
    monitor.write(id..": "..message)
    if cursor_y < number_of_rows then
        cursor_y = cursor_y + 1
    else
        monitor.scroll(1)
    end

    monitor.setCursorPos(1, cursor_y)
end
