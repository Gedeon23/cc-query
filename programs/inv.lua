local basalt = require("basalt")

inv = {
    chests = { peripheral.find("minecraft:chest") },
    barrels = { peripheral.find("minecraft:barrel") },
    items = {}
}

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

local main = basalt.createFrame()

inv:takeStock()

local flex = main:addFlexbox():setWrap("wrap"):setPosition(1,1):setSize("parent.w", "parent.h")

local aList = flex:addList()
local label = flex:addLabel()
label:setText("placeholder")
label:setFontSize(1)
for item_name, item in pairs(inv.items) do
    aList:addItem(item_name.." "..item.count, colors.lightGray, colors.black, item)
end

aList:onSelect(function(self, event, item)
    label:setText(item.args.name)
    basalt.debug(textutils.serialise(item))
end)

basalt.autoUpdate()