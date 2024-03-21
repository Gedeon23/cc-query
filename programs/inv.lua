local basalt = require("basalt")

inv = {
    chests = { peripheral.find("minecraft:chest") },
    barrels = { peripheral.find("minecraft:barrel") },
    items = {}
}

function inv:takeStock()
    self.items = {}
    for bIndex, barrel in pairs(self.barrels) do
        for sIndex, slot in pairs(barrel.list()) do
            if self.items[slot.name] == nil then
                self.items[slot.name] = {count = slot.count}
                self.items[slot.name].location = {}
                self.items[slot.name].location[bIndex] = {}
                self.items[slot.name].location[bIndex][sIndex] = slot.count
            else
                self.items[slot.name].count = self.items[slot.name].count + slot.count
                if self.items[slot.name].location[bIndex] == nil then
                    self.items[slot.name].location[bIndex] = {}
                    self.items[slot.name].location[bIndex][sIndex] = slot.count
                else
                    self.items[slot.name].location[bIndex][sIndex] = slot.count
                end
            end
        end
    end

    return self.items
end

function inv:getItems()
    return self.items
end

function inv:getItem(name)
    return self.items[name]
end

function inv:printItemList()
    for item_name, item in pairs(self.items) do
        print(item_name, item.count)
    end
end

local main = basalt.createFrame()
basalt.autoUpdate()

inv:takeStock()

local aList = main:addList()
for item_name, item in pairs(self.items) do
    aList:addItem(item_name.." "..item.count)
end