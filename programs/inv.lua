inv = {
    chests = { peripheral.find("minecraft:chest") },
    barrels = { peripheral.find("minecraft:barrel") },
    items = {}
}

function inv:takeStock()
end

function inv:getItems()
    self.items = {}
    for bIndex, barrel in pairs(self.barrels) do
        for sIndex, slot in pairs(barrel.list()) do
            if self.items[slot.name] == nil then
                self.items[slot.name] = {count = slot.count}
                self.items[slot.name].location = {}
                slef.items[slot.name].location[bIndex] = {sIndex}
            else
                self.items[slot.name].count = self.items[slot.name] + slot.count
                table.insert(self.items[slot.name].location[bIndex], sIndex)
            end
        end
    end

    return self.items
end

print(textutils.serialise(inv:getItems()))
