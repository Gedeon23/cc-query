local storage = {peripheral.find("minecraft:chest")}
local turtle_name = "turtle_0"

while true do
    for i = 1,4 do
        bool, cauldron = turtle.inspect()
        if cauldron.name == "minecraft:lava_cauldron" then
            turtle.place()
            turtle.turnLeft()
        end
    end

    for i = 16, 1, -1 do
        turtle.select(i)
        if turtle.getItemDetail().name == "minecraft:lava_bucket" then
            storage[1].pullItems(turtle_name, i)
        end
    end

    sleep(10)
end
