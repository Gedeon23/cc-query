-- local log = require("log")

arg = {...}

query = {
    direction = {NORTH = 1, EAST = 2, SOUTH = 3, WEST = 4},
    x = 0,
    y = 0,
    z = 0,
    dir = 3,
    mode = "xray",

    start_position = {
        x = 0,
        y = 0,
        z = 0, 
    },

    black_list = {
        tags = {},
        names = {}
    },

    working_area = {
        x = {
            start = 0,
            stop = 0
        },
        y = {
            start = 0,
            stop = 0
        },
        z = {
            start = 0,
            stop = 0
        }
    },

    unmineable_blocks = {},
    vein_block = ""
}

function query.unmineable_blocks:addBlock(x, y, z)
    if not self[y] then
        self[y] = {}
    end
    if not self[y][x] then
        self[y][x] = {}
    end
    if not self[y][x][z] then
        self[y][x][z] = {}
    end
    self[y][x][z] = true
end

function query.unmineable_blocks:getBlock(x, y, z)
    local layer = self[y]
    if layer then
        local column = layer[x]
        if column then
            local block = column[z]
            if block then
                return true
            end
        end
    end
    return false
end
        

function query.black_list:addName(name)
    self.names[name] = true
end

function query.black_list:addTag(tag)
    self.tags[tag] = true
end

function query.black_list:containsName(name)
    return self.names[name] ~= nil
end

function query.black_list:containsTag(tag)
    return self.tags[tag] ~= nil
end

function query.black_list:compareBlock(block)
    local contained = self:containsName(block.name)
    for tag, v in pairs(block.tags) do
        if self:containsTag(tag) then
            contained = true
        end
    end
    return contained
end


query.black_list:addTag("c:ores")

function query:setup()
    -- log()
    -- log("starting logs")
    -- log("for", os.getComputerLabel())
    -- log("at", textutils.formatTime(os.time("local")))
    -- log()


    self.x, self.z, self.y = gps.locate()
    self.start_position.x = self.x
    self.start_position.y = self.y
    self.start_position.z = self.z

    -- coms
    rednet.open("right")

    if arg[1] then
        self.mode = arg[1]
    else
        print("what mode would you like to use? (xray/vein)")
        self.mode = read()
    end

    local length
    if arg[2] then
        length = tonumber(arg[2])
    else
        print("length?")
        length = tonumber(read())
    end

    local width
    if arg[3] then
        width = tonumber(arg[3])
    else
        print("width?")
        width = tonumber(read())
    end

    local start_depth
    if arg[4] then
        start_depth = tonumber(arg[4])
    else
        print("start at y level?")
        start_depth = tonumber(read())
    end

    local stop_depth
    if arg[5] then
        stop_depth = tonumber(arg[5])
    else 
        print("stop at y level?")
        stop_depth = tonumber(read())
    end

    -- save dimensions relativ to turtle
    self.working_area.x.start = self.x
    -- log("starting at x = "..self.working_area.x.start)
    self.working_area.x.stop = self.x + width - 1
    -- log("stopping at x = "..self.working_area.x.stop)

    self.working_area.y.start = start_depth
    self.working_area.y.stop = stop_depth

    self.working_area.z.start = self.z
    -- log("starting at z = "..self.working_area.z.start)
    self.working_area.z.stop = self.z + length - 1
    -- log("stopping at z = "..self.working_area.z.stop)

    os.sleep(4)
end

-- DESCEND
function query:descendToWorkingArea()
    for i = self.y, self.working_area.y.start + 1, -1 do
        turtle.digDown()
        turtle.down()
        self.y = self.y - 1
    end
end

function query:turn(target_direction)
    if target_direction ~= self.dir then
        -- log("turning "..target_direction.." (currently: "..self.dir..")")
        local diff = (target_direction - self.dir) % 4
        if diff == 1 or diff == -3 then
            turtle.turnRight()
        elseif diff == 3 or diff == -1 then
            turtle.turnLeft()
        elseif diff == 2 or diff == -2 then
            turtle.turnLeft()
            turtle.turnLeft()
        end
        self.dir = target_direction
    end
end

function query:mineable(dir)
    local present, block
    local mineable = true
    if dir == "down" then
        present, block = turtle.inspectDown()
    elseif dir == "up" then
        present, block = turtle.inspectUp()
    else 
        self:turn(dir)
        present, block = turtle.inspect()
    end

    if present then
        mineable = not self.black_list:compareBlock(block)
        -- log(block.name.." mineable: ", mineable)
    end

    return mineable
end


-- this function only handles a single block movement
-- returns wether the move was successful
function query:move(x, y, z)
    local target_dir = self.dir
    if x > 0 then
        target_dir = self.direction.EAST
    elseif x < 0 then
        target_dir = self.direction.WEST
    elseif z < 0 then
        target_dir = self.direction.NORTH
    elseif z > 0 then
        target_dir = self.direction.SOUTH
    elseif y > 0 then
        target_dir = "up"
    else
        target_dir = "down"
    end

    if self:mineable(target_dir) then
        if target_dir == "up" then
            while turtle.detectUp() do
                turtle.digUp()
            end
            turtle.up()
        elseif target_dir == "down" then
            while turtle.detectDown() do
                turtle.digDown()
            end
            turtle.down()
        else
            while turtle.detect() do
                turtle.dig()
            end
            turtle.forward()
        end

        self.x = self.x + x
        self.y = self.y + y
        self.z = self.z + z

        return true
    else
        cords = {x = self.x + x, y = self.y, z = self.z + z}
        if self.unmineable_blocks:getBlock(cords.x, cords.y, cords.z) then
            -- log(cords, "already in unmineable blocks")
        else
            self.unmineable_blocks:addBlock(cords.x, cords.y, cords.z)
            -- log("added to unmineable blocks:", self.unmineable_blocks)
        end
        return false
    end
end

function query:withinWorkingArea(x, y, z)
    local within_x_range = x >= self.working_area.x.start and x <= self.working_area.x.stop
    -- log("within x range ", within_x_range)
    local within_y_range = y <= self.working_area.y.start and y >= self.working_area.y.stop
    -- log("within y range ", within_y_range)
    local within_z_range = z >= self.working_area.z.start and z <= self.working_area.z.stop
    -- log("within z range ", within_z_range)
    within_working_area = within_x_range and within_y_range and within_z_range
    -- log("is "..x.." "..y.." "..z.." within working area?", within_working_area)
    return within_working_area
end

function dist(x1, y1, z1, x2, y2, z2)
    return math.abs(x1-x2) + math.abs(y1-y2) + math.abs(z1-z2)
end

function query:getPossibleEdges(x, y, z)
    local edges = {{0, 0, 1}, {0, 0, -1}, {1, 0, 0}, {-1, 0, 0}, {0, 1, 0}, {0, -1, 0}}
    local possible_edges = {}

    for i, edge in pairs(edges) do
        local cords = {x = x + edge[1], y = self.y + edge[2], z = z + edge[3]}
        local mineable = true
        if self.unmineable_blocks:getBlock(cords.x, cords.y, cords.z) then
            -- log(x, z, "is unmineable. not adding to possible edges")
            mineable = false
        end

        if self:withinWorkingArea(cords.x, cords.y, cords.z) and mineable then
            table.insert(possible_edges, edge)
            -- log("found possible edge for "..x.." "..z..": ("..edge[1].." "..edge[2]..")")
        end
    end

    return possible_edges
end


function query:astarToLocation(x, y, z)
    local paths = {{
        length = 0,
        distance = dist(x, y, z, self.x, self.y, self.z),
        route = {},
        destination = {x = self.x, y = self.y, z = self.z}
    }}
    
    local visited_blocks = {}

    function visited_blocks:addBlock(x, y, z)
        if not self[y] then
            self[y] = {}
        end
        if not self[y][x] then
            self[y][x] = {}
        end
        self[y][x][z] = true
    end

    function visited_blocks:getBlock(x, y, z)
        local layer = self[y]
        if layer then
            local column = layer[x]
            if column then
                local block = column[z]
                if block then
                    return true
                end
            end
        end
        return false
    end


    function expandPath(index, path)
        if path == nil then
            -- log("for some reason was provided nil as path maybe take a look paths", paths)
        else
            -- log("expanding path:", path)
            local edges = self:getPossibleEdges(path.destination.x, path.destination.y, path.destination.z)
            for _, edge in ipairs(edges) do
                -- log("possible edge ("..edge[1].." "..edge[2]..")")
                local new_dest = {x = path.destination.x + edge[1], y = path.destination.y + edge[2], z = path.destination.z + edge[3]}

                if not visited_blocks:getBlock(new_dest.x, new_dest.y, new_dest.z) then
                    visited_blocks:addBlock(new_dest.x, new_dest.y, new_dest.z)
                    local new_path = {
                        length = path.length + 1,
                        distance = dist(x, y, z, new_dest.x, new_dest.y, new_dest.z),
                        route = {},
                        destination = new_dest
                    }
                    for _, route_edge in ipairs(path.route) do
                        table.insert(new_path.route, route_edge)
                    end
                    table.insert(new_path.route, edge)
                    -- log("found new path", new_path, "leading to ("..new_path.destination.x, new_path.destination.z..") with length:", new_path.length)

                    if new_path.destination.x == x and new_path.destination.y == y and new_path.destination.z == z then
                        return true, new_path
                    end
                    table.insert(paths, new_path)
                end

            end
        end

        table.remove(paths, index)
        return false, nil
    end

    function minPotentialDistance()
        -- log("searching for minimal path")
        local min = paths[1]
        local index = 1
        for i, path in pairs(paths) do
            local minVal = min.length + min.distance
            local currentVal = path.length + path.distance
            -- log("min val: "..minVal.." vs currentVal: "..currentVal)
            if minVal > currentVal then
                -- log("min found:", path)
                min = path
                index = i
            end
        end
        return index, min
    end

    while true do
        local index, path = minPotentialDistance()
        if path then
            -- log("found path with minimal distance/length index = "..index)
        else
            -- log("no solution found for", x, z)
            return nil
        end


        local found, solution = expandPath(index, path)

        if found then
            return solution
        end
    end
end
        

function query:excavateLayer()
    local mining_queue = {}
    for x = self.working_area.x.start, self.working_area.x.stop do
        for z = self.working_area.z.start, self.working_area.z.stop do
            table.insert(mining_queue, {x, self.y, z})
        end
    end

    function getClosestFromQueue()
        local index = 1
        local min = mining_queue[index]
        for i, block in ipairs(mining_queue) do
            if dist(self.x, self.y, self.z, min[1], min[2], min[3]) > dist(self.x, self.y, self.z, block[1], block[2], block[3]) then
                min = block
                index = i
            end
        end

        return index, min
    end

    function removeFromMiningQueue(x, y, z)
        for i, block in pairs(mining_queue) do
            if block[1] == x and block[2] == y and block[3] == z then
                table.remove(mining_queue, i)
            end
        end
    end

    while mining_queue[1] ~= nil do
        local index, target = getClosestFromQueue()
        -- log("looking for path to", target)
        local path = self:astarToLocation(target[1], target[2], target[3])
        if path then
            for i, vec in pairs(path.route) do
                removeFromMiningQueue(self.x + vec[1], self.y + vec[2], self.z + vec[3])
                local success = query:move(vec[1], vec[2], vec[3])
                if not success then
                    break
                end
            end
        else
            removeFromMiningQueue(target[1], target[2], target[3])
        end
    end

end



function query:xray()
    query:descendToWorkingArea()
    for y = query.working_area.y.start, query.working_area.y.stop + 1, -1 do
        query:excavateLayer()
        query:move(0, -1, 0)
    end
end

function query:getCordsFromDir(dir)
    dir_to_cords = {}
    dir_to_cords[1] = {x = 0, y = 0, z = -1}
    dir_to_cords[2] = {x = 1, y = 0, z = 0}
    dir_to_cords[3] = {x = 0, y = 0, z = 1}
    dir_to_cords[4] = {x = -1, y = 0, z = 0}
    local cord_change = dir_to_cords[dir]
    return {x = self.x + cord_change.x, y = self.y + cord_change.y, z = self.z + cord_change.z}
end

function query:getFacedCords()
    return self:getCordsFromDir(self.dir)
end

function query:scan()
    surrounding_space = {}
    for i = 1, 4 do
        query:turn(self.dir + i)
        exists, block = turtle.inspect()
        if exists then
            surrounding_space[self:getFacedCords()] = block
        end
    end
    exists, block_above = turtle.inspectUp()
    if exists then
        surrounding_space[{x = self.x, y = self.y + 1, z = self.z}] = block_above
    end

    exists, block_below = turtle.inspectDown()
    if exists then
        surrounding_space[{x = self.x, y = self.y - 1, z = self.z}] = block_below
    end
    return surrounding_space
end



function query:vein()
    local exists, block = turtle.inspect()
    mining_queue = {} -- #TODO make field in query table

    function getClosestFromQueue() -- #TODO refactor into function on query field
        local index = 1
        local min = mining_queue[index]
        for i, block = pairs(mining_queue) do
            if dist(self.x, self.y, self.z, block.x, block.y, block.z) < dist(self.x, self.y, self.z, min.x, min.y, min.z) then
                index = i
                min = block
            end
        end
        return index, min
    end

    if exists then
        self.vein_block = block
        table.insert(mining_queue, self:getFacedCords())

        while mining_queue[1] do
            space = self:scan()
            for cords, block in pairs(space) do
                if block.name == self.vein_block then
                    table.insert(mining_queue, cords)
                end
            end

            local index, target = getClosestFromQueue() -- #TODO refactor into query method to avoid code reuse
            local path = self:astarToLocation(target[1], target[2], target[3])
            if path then
                for i, vec in pairs(path.route) do
                    removeFromMiningQueue(self.x + vec[1], self.y + vec[2], self.z + vec[3])
                    local success = query:move(vec[1], vec[2], vec[3])
                    if not success then
                        break
                    end
                end
            else
                removeFromMiningQueue(target[1], target[2], target[3])
            end
        end
    else
        print("no mineable block found")
    end
end



function query:start()
    if query.mode == "xray" then
        query:xray()
    elseif query.mode == "vein" then
        query:vein()
    else
        print("mode invalid")
    end
end

query:setup()
query:start()





