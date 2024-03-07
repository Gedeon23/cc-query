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
    }
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
    self.x, self.y, self.z = gps.locate()
    self.start_position.x = self.x
    self.start_position.y = self.y
    self.start_position.z = self.z
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
        for i = self.dir, target_direction do
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
        return false
    end
end

function test()
    query:move(0,1)
    query:move(0,1)
    query:move(1,0)
    query:move(0,-1)
    query:move(0,-1)
end

query:setup()
test()






