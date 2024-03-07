-- ORE CONFIG
black_list = {
    tags = {},
    names = {}
}

function black_list:addName(name)
    self.names[name] = true
end

function black_list:addTag(tag)
    self.tags[tag] = true
end

function black_list:containsName(name)
    return self.names[name] ~= nil
end

function black_list:containsTag(tag)
    return self.tags[tag] ~= nil
end

function black_list:compareBlock(block)
    contained = black_list:containsName(block.name)
    for tag, v in pairs(block.tags) do
        if black_list:containsTag(tag) then
            contained = true
        end
    end
    return contained
end


black_list:addTag("c:ores")



print("Make sure your setup looks like this")
print("^")
print("┃ length")
print("┃")
print("┃ turtle")
print("┗━━━━>")
print("chest")

os.sleep(4)

print("what length?")
length = read()
print("what width?")
width = read()
print("at what y should this turtle start?")
ystart = read()
print("at what y should this turtle stop?")
ystop = read()

direction = {NORTH = 1, EAST = 2, SOUTH = 3, WEST = 4}
dir = direction.NORTH

x, y, z = gps.locate()

-- DESCEND
function descendToWorkingArea()
    for i = y, ystart, -1 do
        turtle.digDown()
        turtle.down()
        _ENV.y = _ENV.y - 1
    end
end

function turn(target_direction)
    if target_direction ~= _ENV.dir then
        for i = _ENV.dir, target_direction do
            turtle.turnLeft()
        end
        _ENV.dir = target_direction
    end
end

function mineable()
    is_present, block = turtle.inspect()
    mineable = true
    if is_present then
        mineable = not black_list:compareBlock(block)
    end

    return mineable
end


-- this function only handles a single block movement XOR(x,z)
function move(x, z)
    if x > 0 then
        direction = _ENV.direction.EAST
    elseif x < 0 then
        direction = _ENV.direction.WEST
    elseif z < 0 then
        direction = _ENV.direction.NORTH
    else
        direction = _ENV.direction.SOUTH
    end

    turn(direction)
    if mineable then
        while turtle.detect() do
            turtle.dig()
        end
        turtle.forward()

        _ENV.x = _ENV.x + x
        _ENV.z = _ENV.z + z

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






