query = {
    direction = {NORTH = 1, EAST = 2, SOUTH = 3, WEST = 4}
    x, y, z = gps.locate()
    dir = direction.SOUTH
    start_position = {
        x = self.x,
        y = self.y,
        z = self.z
    }

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
    contained = self.black_list:containsName(block.name)
    for tag, v in pairs(block.tags) do
        if self.black_list:containsTag(tag) then
            contained = true
        end
    end
    return contained
end


query.black_list:addTag("c:ores")

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
        for i = self.dir, target_direction do
            turtle.turnLeft()
        end
        self.dir = target_direction
    end
end

function query:mineable()
    is_present, block = turtle.inspect()
    mineable = true
    if is_present then
        mineable = not black_list:compareBlock(block)
    end

    return mineable
end


-- this function only handles a single block movement
-- returns wether the move was successful
function query:move(x, z)
    if x > 0 then
        target_dir = self.direction.EAST
    elseif x < 0 then
        target_dir = self.direction.WEST
    elseif z < 0 then
        target_dir = self.direction.NORTH
    else
        target_dir = self.direction.SOUTH
    end

    self:turn(direction)
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
    move(0,1)
    move(0,1)
    move(1,0)
    move(0,-1)
    move(0,-1)
end

test()






