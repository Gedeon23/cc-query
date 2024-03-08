query = {
    direction = {NORTH = 1, EAST = 2, SOUTH = 3, WEST = 4},
    x = 0,
    y = 0,
    z = 0,
    dir = 3,

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

    mining_queue = {},
    unmineable_blocks = {}
}

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
    self.x, self.z, self.y = gps.locate()
    self.start_position.x = self.x
    self.start_position.y = self.y
    self.start_position.z = self.z

    -- replace later with user input
    local length = 16
    local width = 16
    local start_depth = 63
    local stop_depth = 62

    -- save dimensions relativ to turtle
    self.working_area.x.start = self.x
    print("starting at x =", self.working_area.x.start)
    self.working_area.x.stop = self.x + width - 1
    print("stopping at x =", self.working_area.x.stop)

    self.working_area.y.start = start_depth
    self.working_area.y.stop = stop_depth

    self.working_area.z.start = self.z
    print("starting at z =", self.working_area.z.start)
    self.working_area.z.stop = self.z + length - 1
    print("stopping at z =", self.working_area.z.stop)

    os.sleep(4)
end

-- DESCEND
function query:descendToWorkingArea()
    for i = y, ystart, -1 do
        turtle.digDown()
        turtle.down()
        self.y = self.y - 1
    end
end

function query:turn(target_direction)
    if target_direction ~= self.dir then
        print("turning", target_direction, "(currently:", self.dir, ")")
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

function query:mineable()
    local present, block = turtle.inspect()
    local mineable = true
    if present then
        mineable = not self.black_list:compareBlock(block)
        print(block.name, "mineable:", mineable)
    end

    return mineable
end


-- this function only handles a single block movement
-- returns wether the move was successful
function query:move(x, z)
    local target_dir
    if x > 0 then
        target_dir = self.direction.EAST
    elseif x < 0 then
        target_dir = self.direction.WEST
    elseif z < 0 then
        target_dir = self.direction.NORTH
    else
        target_dir = self.direction.SOUTH
    end

    self:turn(target_dir)
    if self:mineable() then
        while turtle.detect() do
            turtle.dig()
        end
        turtle.forward()

        self.x = self.x + x
        self.z = self.z + z

        return true
    else
        self.unmineable_blocks[{x = self.x + x, y = self.y, z = self.z + z}] = true
        return false
    end
end

function query:withinWorkingArea(x, y, z)
    local within_x_range = x >= self.working_area.x.start and x <= self.working_area.x.stop
    local within_y_range = y >= self.working_area.y.start and y <= self.working_area.y.stop
    local within_z_range = z >= self.working_area.z.start and z <= self.working_area.z.stop
    within_working_area = within_x_range and withing_y_range and withing_z_range
    print("is within working area?", within_working_area)
    return within_working_area
end

-- function query.current_layer:addBlock(x ,z)

-- end

-- function query:setupLayer()
--     for x = self.working_area.x.start, self.working_area.x.stop do
--         for z = self.working_area.z.start, self.working_area.z.stop do
--             self.current_layer:addBlock(x,z)
--         end
--     end
-- end

function dist(x1, z1, x2, z2)
    return math.sqrt(math.pow(x1-x2, 2) + math.pow(z1-z2, 2))
end

function query:getPossibleEdges(x,z)
    local edges = {{0,1}, {0,-1}, {1,0}, {-1,0}}
    local possible_edges = {}

    for i, edge in pairs(edges) do
        local cords = {x = self.x + edge[1], z = self.z + edge[2]}
        local mineable = true
        if self.unmineable_blocks[cords] then
            mineable = false
        end

        if self:withinWorkingArea(cords.x, self.y, cords.z) and mineable then
            table.insert(possible_edges, edge)
            print("found possible edge for", x, z, ": (", edge[1], edge[2], ")")
        end
    end

    return possible_edges
end


function query:astarToLocation(x,z)
    local paths = {{
        length = 0,
        distance = dist(x,z, self.x, self.z),
        route = {},
        destination = {x = self.x, z = self.z}
    }}

    function expandPath(index, path)
        print("expanding path", path)
        for i, edge in pairs(self:getPossibleEdges(path.destination.x, path.destination.z)) do
            print("possible edge", edge.x, edge.z)
            local new_dest = {x = path.destination.x + edge.x, z = path.destination.z + edge.z}
            local new_path = {
                length = path.length + 1,
                distance = dist(x, z, new_dest.x, new_dest.z),
                route = path.route,
                destination = new_dest
            }
            table.insert(new_path.route, edge)
            print("found new path", new_path)
            table.insert(paths, new_path)
        end

        table.remove(paths, index)
    end

    function minPotentialDistance(paths)
        print("searching for minimal path")
        local min = paths[1]
        local index = 1
        for i, path in pairs(paths) do
            print("min:", min, "comparing to", path)
            if min.length + min.distance > path.length + path.distance then
                min = path
                index = i
            end
        end
        return index, min
    end

    while true do
        local index, path = minPotentialDistance(paths)

        if path.destination.x == x and path.destination.z == z then
            return path
        end

        expandPath(index, path)
    end
end
        

function query:excavate_layer()
end



function test()
    query:astarToLocation(-2717, 306)
end

query:setup()
test()





