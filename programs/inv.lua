local basalt = require("basalt")

inv = {
    chests = { peripheral.find("minecraft:chest") },
    barrels = { peripheral.find("minecraft:barrel") },
    items = {}
    ui = {}
}

function inv:buildUI()
    self.ui.main = basalt.createFrame()
    self.ui.flex = main:addFlexbox():setWrap("wrap"):setPosition(1,1):setSize("parent.w", "parent.h")
    self.ui.leftColumn = flex:addFlexbox():setDirection("column"):setSpacing(0)
    self.ui.rightColumn = flex:addFlexbox():setDirection("column")
    self.ui.itemSearch = leftColumn:addInput():setInputType("text"):onChar(function(self, event, char)
        inv:updateItemList()
    )
    self.ui.itemList = leftColumn:addList()
    self.ui.itemName = rightColumn:addLabel():setText("placeholder"):setFontSize(1)

    basalt.autoUpdate()
end

function prettifyName(name)
    local beginning = string.find(name, ":") + 1
    return name:sub(beginning, string.len(name)):gsub("_", " ")
end

function inv:takeStock()
    self.items = {}
    for bIndex, barrel in pairs(self.barrels) do
        for sIndex, slot in pairs(barrel.list()) do
            local name = prettifyName(slot.name)
            if self.items[name] == nil then
                self.items[name] = {count = slot.count}
                self.items[name].name = name
                self.items[name].location = {}
                self.items[name].location[bIndex] = {}
                self.items[name].location[bIndex][sIndex] = slot.count
            else
                self.items[name].count = self.items[name].count + slot.count
                if self.items[name].location[bIndex] == nil then
                    self.items[name].location[bIndex] = {}
                    self.items[name].location[bIndex][sIndex] = slot.count
                else
                    self.items[name].location[bIndex][sIndex] = slot.count
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


inv:takeStock()
inv:buildUI()