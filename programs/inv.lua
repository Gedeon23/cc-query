local basalt = require("basalt")
local log = require("log")

inv = {
    chests = { peripheral.find("minecraft:chest") },
    barrels = { peripheral.find("minecraft:barrel") },
    items = {},
    ui = {
        colors = {
            bg = colors.lightGray,
            text = colors.black
        }
    },
    search_term = "",
    item_list = {}
}

function inv:buildUI()
    self.ui.main = basalt.createFrame()
    self.ui.flex = self.ui.main:addFlexbox():setDirection("row"):setWrap("wrap"):setPosition(1,1):setSize("parent.w", "parent.h")
    self.ui.leftColumn = self.ui.flex:addFlexbox():setDirection("column"):setSpacing(0)
    self.ui.rightColumn = self.ui.flex:addFlexbox():setDirection("column")
    self.ui.itemSearch = self.ui.leftColumn:addInput():setInputType("text"):setDefaultText("search"):setValue(self.search_term):onKey(function(input, event, key)
        if key == 259 then
            for _, item in pairs(self.items) do
                table.remove(item.search_distance.table, #item.search_distance.table)
                item.search_distance.distance = item.search_distance.table[#item.search_distance.table][#item.search_distance.table[#item.search_distance.table]]
            end
            self:updateItemList(input, event, key)
        elseif key == 257 then
            -- enter
            -- shift focus to list
        else
            self:updateItemSearchDistance(input, event, key)
            self.search_term = input:getValue()
            self:updateItemList(input, event, key)
        end
    end)
    self.ui.itemList = self.ui.leftColumn:addList()
    for _, item in pairs(self.item_list) do
        self.ui.itemList:addItem(item.name.." "..item.count, self.ui.colors.bg, self.ui.colors.text, item)
    end

    self.ui.itemName = self.ui.rightColumn:addLabel():setText("placeholder"):setFontSize(1)

    basalt.autoUpdate()
end

function inv:updateItemSearchDistance()
    local search_term = self.search_term
    local new_search_term = self.ui.itemSearch:getValue()
    for _, item in pairs(self.items) do
        local d = item.search_distance.table
        for i = #search_term+1, #new_search_term do
            table.insert(d, {i})
            for j = 1, #item.name do
                local a = 0
                if new_search_term:sub(i,i) ~= item.name:sub(j,j) then
                    a = 1
                end
                d[i+1][j+1] = min(d[i][j]+a, d[i][j+1]+1, d[i+1][j]+1)
            end
        end
        item.search_distance.distance = d[#new_search_term+1][#item.name+1]
    end
end

function inv:updateItemList(input, event, key)
    basalt.debug(key, " pressed input updated ", input:getValue())
    inv.ui.itemList:clear()
    local compare = function(item) return item.search_distance.distance end
    if #input:getValue() < 3 then
        self:quicksortItems(compare)
    else
        self:bubblesortItems(compare)
    end
    for _, item in pairs(self.item_list) do
        self.ui.itemList:addItem(item.name.." "..item.count, self.ui.colors.bg, self.ui.colors.text, item)
    end
end

function quicksort(list, compare)
    log("quicksort called")
    if #list < 2 then
        log("quicksort done")
        return list
    end
    local pivot_index = math.floor(#list/2)
    local pivot = list[pivot_index]
    local i = 1
    local j = #list
    while i < pivot_index and j > pivot_index do
        val_i = compare(list[i])
        val_pivot = compare(pivot)
        val_j = compare(list[j])
        if val_i > val_pivot and val_j < val_pivot then
            list[i], list[j] = list[j], list[i]
        elseif val_i > val_pivot then
            j = j - 1
        elseif val_j < val_pivot then
            i = i + 1
        else
            i = i + 1
            j = j - 1
        end
    end

    leftside = quicksort({table.unpack(list), 1, i}, compare)
    rightside = quicksort({table.unpack(list), j, #list}, compare)
    return {table.unpack(leftside), pivot, table.unpack(rightside)}
end

function inv:quicksortItems(compare)
    self.item_list = quicksort(self.item_list, compare)
end

function bubblesort(list, compare)
    local unsorted = true
    while unsorted do
        unsorted = false
        for i = 2, #list do
            val_1 = compare(list[i-1])
            val_2 = compare(list[i])
            if val_1 > val_2 then
                unsorted = true
                list[i-1], list[i] = list[i], list[i-1]
            end
        end
    end
    return list
end

function bubblesortItems(compare)
    self.item_list = bubblesort(self.item_list, compare)
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
                self.items[name].search_distance = {distance = string.len(name), table = levenshtein(name, self.search_term)}
                table.insert(self.item_list, self.items[name])
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

function inv:getItemCount(item)
    return item.count
end

function inv:getItemDistance(item)
    return item.search_distance.distance
end

function inv:printItemList()
    for item_name, item in pairs(self.items) do
        print(item_name, item.count)
    end
end

function min(...)
    list = {...}
    local min = list[1]
    for i = 2, #list do
        if min > list[i] then
            min = list[i]
        end
    end

    return min
end

function levenshtein(str1, str2)
    local d = {}
    for i = 0, #str2 do
        if i == 0 then
            local d1 = {}
            for j = 0, #str1 do
                table.insert(d1, j)
            end
            table.insert(d, d1)
        else
            table.insert(d, {i})
        end
    end

    for i = 1, #str2 do
        for j = 1, #str1 do
            a = 0
            if str1:sub(i,i) ~= str2:sub(j,j) then
                a = 1
            end
            d[i+1][j+1] = min(d[i][j]+a, d[i][j+1]+1, d[i+1][j]+1)
        end
    end

    return d
end


inv:takeStock()
inv:buildUI()