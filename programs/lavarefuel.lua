local storage = {peripheral.find("minecraft:chest")}
local bucket_storage = peripheral.find("minecraft:barrel")

local fuel_needed = turtle.getFuelLimit() - turtle.getFuelLevel()
local buckets_needed = math.floor(fuel_needed/1000)


local transferred = 0
for _, unit in pairs(storage) do
    for i = 1,27 do
        if buckets_needed ~= 0 then
            pushed = unit.pushItems("turtle_1", i)
            transferred = transferred + pushed
            buckets_needed = buckets_needed - pushed
            turtle.refuel()
            bucket_storage.pullItems("turtle_1", 1)
        end
    end
end