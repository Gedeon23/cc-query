log = require("log")

inv = {
    chests = { peripheral.find("minecraft:chest") },
    barrels = { peripheral.find("minecraft:barrels") },
    items = {}
}

function inv:takeStock()
    self.items = {}
    for index, barrel in pairs(self.barrels) do
        log(barrel.list())
    end
end