local position = { x = 0, y = 0, z = 0 }
position.x, position.y, position.z = gps.locate() --{x=0,y=0,z=0}
local facing = 0
local floorY = 254
--( 0 = +z, 1 = -x, 2 = -z, 3 = +x )
--Turning right = facing = (facing + 1) % 4
--Turning left = facing = (facing - 1) % 4
local function face(direction)
    if facing == direction then return end    -- if we're already facing the correct direction, do nothing.

    if (facing + 1) % 4 == direction then     -- turn right?
        turtle.turnRight()
    elseif (facing - 1) % 4 == direction then -- turn left?
        turtle.turnLeft()
    else                                      -- turn around?
        turtle.turnRight()
        turtle.turnRight()
    end
end

local oldForward = turtle.forward
function turtle.forward()
    local ok, err = oldForward() -- Do the movement
    if ok == false then
        turtle.dig()
        ok, err = oldForward()
    end
    if ok then                   -- if the turtle moved
        if facing == 0 then      -- facing +z
            position.z = position.z + 1
        elseif facing == 1 then  -- facing -x
            position.x = position.x - 1
        elseif facing == 2 then  -- facing -z
            position.z = position.z - 1
        else                     -- must be facing +x
            position.x = position.x + 1
        end
    end

    return ok, err -- return the values turtle.forward normally returns
end

local oldBack = turtle.back
function turtle.back()
    local ok, err = oldBack()   -- Do the movement
    if ok == false then
        turtle.turnRight()
        turtle.turnRight()
        turtle.dig()
        turtle.turnRight()
        turtle.turnRight()
        ok, err = oldBack()
    end
    if ok then                  -- if the turtle moved
        if facing == 0 then     -- facing +z
            position.z = position.z - 1
        elseif facing == 1 then -- facing -x
            position.x = position.x + 1
        elseif facing == 2 then -- facing -z
            position.z = position.z + 1
        else                    -- must be facing +x
            position.x = position.x - 1
        end
    end

    return ok, err -- return the values turtle.forward normally returns
end

local oldDown = turtle.down
function turtle.down()
    local ok, err = oldDown() -- Do the movement
    if ok == false then
        turtle.digDown()
        ok, err = oldDown()
    end

    if ok then                -- if the turtle moved
        position.y = position.y - 1
    end

    return ok, err -- return the values turtle.forward normally returns
end

local oldUp = turtle.up
function turtle.up()
    local ok, err = oldUp() -- Do the movement
    if ok == false then
        turtle.digUp()
        ok, err = oldUp()
    end

    if ok then              -- if the turtle moved
        position.y = position.y + 1
    end

    return ok, err -- return the values turtle.forward normally returns
end

local oldTurnLeft = turtle.turnLeft
function turtle.turnLeft()
    local ok, err = oldTurnLeft() -- Do the movement

    if ok then                    -- if the turtle turned
        facing = (facing - 1) % 4 -- make facing "turn left"
    end

    return ok, err -- return values turtle.turnLeft normally returns
end

local oldTurnRight = turtle.turnRight
function turtle.turnRight()
    local ok, err = oldTurnRight() -- Do the movement

    if ok then                     -- if the turtle turned
        facing = (facing + 1) % 4  -- make facing "turn left"
    end

    return ok, err -- return values turtle.turnLeft normally returns
end

local function gotoloc(location)
    if position.y < location.y then
        while position.y < location.y do
            if turtle.up() == false then turtle.digUp() end
        end
    end
    if position.y > location.y then
        face(1)
        while position.y > location.y do
            if turtle.down() == false then turtle.digDown() end
        end
    end
    --print("Position:" .. position.x .. "|" .. position.z .. " location:" .. location.x .. "|" .. location.z)
    if facing == 0 and position.z < location.z then
        while position.z < location.z do
            if turtle.forward() == false then turtle.dig() end
            --curloc.z = curloc.z+1
        end
    elseif facing == 1 and position.x > location.x then
        while position.x > location.x do
            if turtle.forward() == false then turtle.dig() end
            --curloc.x = curloc.x-1
        end
    elseif facing == 2 and position.z > location.z then
        while position.z > location.z do
            if turtle.forward() == false then turtle.dig() end
            --curloc.z = curloc.z-1
        end
    elseif facing == 3 and position.x < location.x then
        while position.x < location.x do
            if turtle.forward() == false then turtle.dig() end
            --curloc.x = curloc.x+1
        end
    end

    if position.z < location.z then
        face(0)
        while position.z < location.z do
            if turtle.forward() == false then turtle.dig() end
            --curloc.z = curloc.z+1
        end
    end
    if position.x > location.x then
        face(1)
        while position.x > location.x do
            if turtle.forward() == false then turtle.dig() end
            --curloc.x = curloc.x-1
        end
    end
    if position.z > location.z then
        face(2)
        while position.z > location.z do
            if turtle.forward() == false then turtle.dig() end
            --curloc.z = curloc.z-1
        end
    end
    if position.x < location.x then
        face(3)
        while position.x < location.x do
            if turtle.forward() == false then turtle.dig() end
            --curloc.x = curloc.x+1
        end
    end
end

local function detectfacing()
    while oldForward() == false do
        if turtle.dig() == false then
            turtle.turnRight()
        end
    end
    local newpos = {}
    newpos.x, newpos.y, newpos.z = gps.locate()
    --( 0 = +z, 1 = -x, 2 = -z, 3 = +x )
    if newpos.x > position.x then
        facing = 3
    end
    if newpos.x < position.x then
        facing = 1
    end
    if newpos.z > position.z then
        facing = 0
    end
    if newpos.z < position.z then
        facing = 2
    end
    position.x = newpos.x
    position.z = newpos.z
    os.sleep(1)
    turtle.back()
end

local function placeSpotLoadersAndMove()
    for i = 1, 15 do
        turtle.forward()
    end
    turtle.select(5)
    turtle.placeDown()
    turtle.up()
    turtle.place()
    turtle.down()
    turtle.turnRight()
    turtle.turnRight()
    for i = 1, 15 do
        turtle.forward()
    end
    turtle.digUp()
    turtle.turnRight()
    turtle.turnRight()
    for i = 1, 16 do
        turtle.forward()
    end
    turtle.down()
    turtle.turnRight()
    turtle.turnRight()
    turtle.dig()
    turtle.up()
end
local function placeSpotLoadersAndMove2()
    turtle.select(5)
    turtle.placeUp()
    turtle.down()
    turtle.place()
    turtle.up()
    for i = 1, 16 do
        turtle.forward()
    end
    turtle.placeUp()
    turtle.turnRight()
    turtle.turnRight()
    for i = 1, 15 do
        turtle.forward()
    end
    turtle.up()
    turtle.dig()
    turtle.down()
    turtle.digDown()
    turtle.turnRight()
    turtle.turnRight()
    for i = 1, 15 do
        turtle.forward()
    end
end

local arg1, arg2, arg3 = ...
if arg1 == "~" or arg1 == nil or arg1 == '' then
    arg1 = position.x
end
if arg2 == "~" or arg2 == nil or arg2 == '' then
    arg2 = position.y
end
if arg3 == "~" or arg3 == nil or arg3 == '' then
    arg3 = position.z
end


local startx = math.floor(position.x / 16) * 16
local startz = math.floor(position.z / 16) * 16

local endx = startx + 16;
local endz = startz + 16;

local gotolocation = { x = math.floor(tonumber(arg1) / 16) * 16, y = tonumber(arg2), z = math.floor(tonumber(arg3) / 16) * 16 }
detectfacing()

gotoloc({ x = startx, y = floorY, z = startz })
face(0)
local testt = 4
if turtle.getItemCount(5) < 3 then
    face(2)
    turtle.select(5)
    turtle.placeDown()
    turtle.digUp()
    turtle.up()
    if turtle.dig() == true then
        turtle.place()
        testt = 2
    else
        turtle.turnLeft()
        if turtle.dig() == true then
            turtle.place()
            testt = 1
        end
    end
    turtle.down()
end
if turtle.getItemCount(5) < 3 then
    if testt < 4 then
        face(testt)
        for i = 1, 16 do
            turtle.forward()
        end
        turtle.digUp()
        turtle.turnRight()
        turtle.turnRight()
        for i = 1, 16 do
            turtle.forward()
        end
        turtle.up()
        turtle.turnRight()
        turtle.turnRight()
        turtle.dig()
        turtle.down()
    else
        face(3)
        ::retrieveRepeat::
        for i = 1, 15 do
            turtle.forward()
        end
        turtle.up()
        turtle.dig()
        turtle.down()
        turtle.digDown()
        turtle.turnRight()
        turtle.turnRight()
        for i = 1, 15 do
            turtle.forward()
        end
        if turtle.getItemCount(5) < 3 then
            face(0)
            goto retrieveRepeat
        end
    end
    turtle.placeUp()
    turtle.digDown()
    face(0)
end
--turtle.select(5)
--turtle.digUp()

while position.x < gotolocation.x do
    face(3)
    placeSpotLoadersAndMove()
end
while position.x > gotolocation.x do
    face(1)
    placeSpotLoadersAndMove2()
end
while position.z < gotolocation.z do
    face(0)
    placeSpotLoadersAndMove()
end
while position.z > gotolocation.z do
    face(2)
    placeSpotLoadersAndMove2()
end
face(0)
