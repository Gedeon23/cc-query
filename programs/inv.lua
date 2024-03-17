
inv = {
    chests = { peripheral.find("minecraft:chest") },
    barrels = { peripheral.find("minecraft:barrels") },
    items = {}
}

function inv:takeStock()
    self.items = {}
    for index, barrel in pairs(self.barrels) do
        for slot, item in pairs(self.chests) do
            if items[item.name] then
                items[item.name].count = items[item.name].count + item.count
            else
                items[item.name] = {count = 0}
            end
        end
    end
end