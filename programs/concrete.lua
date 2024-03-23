local chest = peripheral.find("minecraft:chest")
local turtle_name

function getPowder(chest)
    local inv = chest.list()
    for slot, item in pairs(inv) do
        if string.find(item.name, "powder") ~= nil then
            chest.pushItems(turtle_name, slot)
            return true
        end
    end
    return false
end    

while true do
    local stuff_todo = getPowder(chest)            

    if stuff_todo then
        while string.find(turtle.getItemDetail().name, "powder") do
            turtle.place()
            turtle.dig()
        end
        chest.pullItems(turtle_name, 1)
        chest.pullItems(turtle_name, 2)
    else
        os.sleep(10)
    end
end