local storage = {peripheral.find("minecraft:chest")}
local turtle_name = "turtle_0"
local bucket_storage = peripheral.find("minecraft:barrel")

while true do
    for i = 1,4 do
        bool, cauldron = turtle.inspect()
        if cauldron.name == "minecraft:lava_cauldron" then
            turtle.place()
        end
        turtle.turnLeft()
    end

    for i = 16, 1, -1 do
        turtle.select(i)
        local item = turtle.getItemDetail()
        if item then
            if item.name == "minecraft:lava_bucket" then
                storage[1].pullItems(turtle_name, i)
            end
        end
    end

    local missing_buckets = 16 - turtle.getItemCount()
    bucket_storage.pushItems(turtle_name, 1, missing_buckets)

    sleep(100)
end
