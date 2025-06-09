peripheral.find("modem", rednet.open)
local position = { x = 0, y = 0, z = 0 }
local facing = 0
local enderchest = 1
local glasschest = 2
local dirt = 3
local glass = 4
local spotloader = 5
local bucket = 4
local floorY = 253
os.sleep(1)
os.setComputerLabel("SethBot" .. os.getComputerID())
position.x, position.y, position.z = gps.locate() --{x=0,y=0,z=0}
local function main()
    local totalshafts = 1
    local currentshafts = 0
    local plugHole = true
    local lowestY = -63

    local liquids = false
    local flat = false

    local function saveTable(tablee, name)
        local file = fs.open(name, "w")
        file.write(textutils.serialize(tablee))
        file.close()
    end

    local function loadTable(name)
        local file = fs.open(name, "r")
        local data = file.readAll()
        file.close()
        return textutils.unserialize(data)
    end

    local function saveText(textt, name)
        local file = fs.open(name, "w")
        file.write(textt)
        file.close()
    end

    local function loadText(name)
        local file = fs.open(name, "r")
        local data = file.readAll()
        file.close()
        return data
    end

    local chunkStatus = "moving to location"
    if fs.exists("chunkStatus") then
        chunkStatus = loadText("chunkStatus")
    else
        saveText(chunkStatus, "chunkStatus")
    end

    local function broadcast(customStatus)
        if customStatus == nil then customStatus = chunkStatus end
        rednet.broadcast("fuel=" ..
            turtle.getFuelLevel() ..
            ", x=" ..
            position.x ..
            ", y=" ..
            position.y ..
            ", z=" .. position.z ..
            ", currentShafts=" .. currentshafts .. ", totalShafts=" .. totalshafts .. ", status=" .. customStatus,
            "SethStatus")
    end

    print("Place Dump EnderChest in slot: " .. enderchest)
    print("Place Glass EnderChest in slot: " .. glasschest)
    print("Place Dirt in slot: " .. dirt)
    print("Place Glass in slot: " .. glass)
    print("Place 4 SpotLoaders in slot: " .. spotloader)
    if liquids then print("Place Bucket in slot: " .. bucket) end

    if chunkStatus == "done" then
        print("Chunk has been completed")
        print("Press \"Y\" to start again or \"N\" to quit")
        local myTimerr = os.startTimer(10)
        --print("started timer:"..myTimerr)
        while true do
            local event, key = os.pullEvent()
            --print(event.." "..key)
            if event == "timer" and key == myTimerr then
                --print("sending broadcast")
                broadcast()
                myTimerr = os.startTimer(10)
                --print("started timer:"..myTimerr)
            elseif event == "key" and key == keys.y then
                chunkStatus = "moving to location"
                saveText(chunkStatus, "chunkStatus")
                break
            elseif event == "key" and key == keys.n then
                os.shutdown()
            end
        end
    end

    print("Press any key to continue...")

    local myTimer = os.startTimer(10)

    while true do
        local event, par1 = os.pullEvent()

        if event == "timer" and par1 == myTimer then
            print("I'm sick of waiting!")
            os.cancelTimer(myTimer)
            break
        elseif event == "key" then
            print("You pressed " .. keys.getName(par1) .. "!")
            break
        end
    end

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

        if ok then                -- if the turtle moved
            position.y = position.y - 1
        end

        return ok, err -- return the values turtle.forward normally returns
    end

    local oldUp = turtle.up
    function turtle.up()
        local ok, err = oldUp() -- Do the movement

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

    -- get the bore location closest to the miner
    local function getClosestLocation(points, b)
        local key = 1
        local distance = 9000
        for k, a in pairs(points) do
            -- try and avoid floating point operation
            local d = math.max(a.x, b.x) - math.min(a.x, b.x) +
                math.max(a.z, b.z) - math.min(a.z, b.z)

            if d < distance then
                d = math.sqrt(
                    math.pow(a.x - b.x, 2) + math.pow(a.z - b.z, 2))
                if d < distance then
                    key = k
                    distance = d
                    if distance <= 1 then
                        break
                    end
                end
            end
        end
        return { x = points[key].x, z = points[key].z, index = key } --table.remove(points, key)
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

    local function unstuck(direction)
        local unstuckY = position.y
        saveTable(position, "unstuckPosition")
        ::unstuckstart::
        while turtle.forward() == false do
            if turtle.dig() == false then
                turtle.turnRight()
            end
        end
        turtle.turnRight()
        turtle.turnRight()
        ::unstucktwo::
        if (direction == "up") then
            if turtle.up() == false then
                if turtle.digUp() == false then
                    while position.y > unstuckY do
                        turtle.down()
                    end
                    turtle.forward()
                    turtle.turnLeft()
                    goto unstuckstart
                else
                    turtle.up()
                end
            end
        elseif (direction == "down") then
            if turtle.down() == false then
                if turtle.digDown() == false then
                    while position.y < unstuckY do
                        turtle.up()
                    end
                    turtle.forward()
                    turtle.turnLeft()
                    goto unstuckstart
                else
                    turtle.down()
                end
            end
        end
        while turtle.forward() == false do
            if turtle.dig() == false then
                goto unstucktwo
            end
        end
        fs.delete("unstuckPosition")
    end

    local function checkGlass()
        if turtle.getItemCount(glasschest) < 64 then
            turtle.select(glasschest)
            while turtle.placeUp() == false do
                if turtle.digUp() == false then
                    if turtle.down() == false then
                        turtle.digDown()
                        if turtle.down() == false then
                            broadcast("stuck")
                        end
                    end
                end
            end
            turtle.select(glass)
            turtle.suckUp()
            turtle.select(glasschest)
            turtle.digUp()
            turtle.select(1)
        end
    end

    local function deposit()
        turtle.select(enderchest)
        while turtle.placeUp() == false do
            if turtle.digUp() == false then
                if turtle.down() == false then
                    turtle.digDown()
                    if turtle.down() == false then
                        broadcast("stuck")
                    end
                end
            end
        end
        for i = 4, 16 do
            turtle.select(i)
            local item = turtle.getItemDetail()
            if item ~= nil and item.name == "minecraft:coal" then
                while turtle.getFuelLevel() < 99000 and turtle.getItemCount() > 0 do
                    turtle.refuel(1)
                end
            end
            local success, reason = turtle.dropUp()
            while success == false and reason == "No space for items" or turtle.getItemCount() > 0 do
                os.sleep(1)
                success, reason = turtle.dropUp()
            end
        end
        turtle.select(enderchest)
        turtle.digUp()
    end

    local function dealwithliquids()
        if liquids == false then return end
        local success, data = turtle.inspect()
        if success and data.metadata == 0 then
            if data.name == "minecraft:lava" or data.name == "minecraft:flowing_lava" then
                turtle.select(bucket)
                turtle.place()
                turtle.refuel()
                turtle.select(1)
                if turtle.getFuelLevel() ~= 100000 then
                    print("Refueled with lava, current fuel: " .. turtle.getFuelLevel())
                end
            elseif data.name == "minecraft:water" or data.name == "galacticraftcore:crude_oil_still" then
                turtle.select(dirt)
                turtle.place()
                turtle.dig()
                turtle.select(1)
            end
        end
    end

    local function dealwithliquidsDown()
        if liquids == false then return end
        local success, data = turtle.inspectDown()
        if success and data.metadata == 0 then
            if data.name == "minecraft:lava" or data.name == "minecraft:flowing_lava" then
                turtle.select(bucket)
                turtle.placeDown()
                turtle.refuel()
                turtle.select(1)
                if turtle.getFuelLevel() ~= 100000 then
                    print("Refueled with lava, current fuel: " .. turtle.getFuelLevel())
                end
            elseif data.name == "minecraft:water" or data.name == "galacticraftcore:crude_oil_still" then
                turtle.select(dirt)
                turtle.placeDown()
                turtle.select(1)
            end
        end
    end

    local function checkAbove()
        if flat == false then return end
        local checkabove = false
        for i = 1, 4 do
            dealwithliquids()
            while turtle.detect() do
                checkabove = true
                if turtle.dig() == false then
                    break
                end
                if turtle.getItemCount(16) > 0 then
                    deposit()
                end
            end
            turtle.turnRight()
        end
        while turtle.detect() or turtle.detectUp() or checkabove do
            checkabove = false
            while turtle.up() == false do
                turtle.digUp()
            end
            for i = 1, 4 do
                dealwithliquids()
                while turtle.detect() do
                    checkabove = true
                    if turtle.dig() == false then
                        break
                    end
                    if turtle.getItemCount(16) > 0 then
                        deposit()
                    end
                end
                turtle.turnRight()
            end
        end
    end

    local function shaftmineDown()
        checkAbove()

        for i = 1, 4 do
            while turtle.detect() do
                if turtle.dig() == false then
                    break
                end
                if turtle.getItemCount(16) > 0 then
                    deposit()
                end
            end
            dealwithliquids()
            if plugHole and position.y == floorY - 1 then
                turtle.select(dirt)
                turtle.place()
                turtle.select(1)
            end
            turtle.turnRight()
        end

        while position.y > lowestY do
            dealwithliquidsDown()
            if turtle.detectDown() then
                turtle.digDown()
            end
            while turtle.down() == false do
                if turtle.digDown() == false then
                    unstuck("down")
                    broadcast("unstuckify")
                end
            end

            broadcast()

            for i = 1, 4 do
                while turtle.detect() do
                    if turtle.dig() == false then
                        break
                    end
                    if turtle.getItemCount(16) > 0 then
                        deposit()
                    end
                end
                dealwithliquids()
                if plugHole and position.y == floorY - 1 then
                    turtle.select(dirt)
                    turtle.place()
                    turtle.select(1)
                end
                turtle.turnRight()
            end
            if plugHole and position.y == floorY - 2 then
                turtle.select(glass)
                turtle.placeUp()
                turtle.select(1)
            end
        end
    end

    local function shaftmineUp()
        while position.y < floorY do
            ::shaftmineupstart::
            for i = 1, 4 do
                while turtle.detect() do
                    if turtle.dig() == false then
                        break
                    end
                    if turtle.getItemCount(16) > 0 then
                        deposit()
                    end
                end
                dealwithliquids()
                if plugHole and position.y == floorY - 1 then
                    turtle.select(dirt)
                    turtle.place()
                    turtle.select(1)
                end
                turtle.turnRight()
            end
            while turtle.up() == false do
                if turtle.digUp() == false then
                    unstuck("up")
                    broadcast("unstuckify")
                    goto shaftmineupstart
                end
            end

            broadcast()

            if plugHole and position.y == floorY then
                turtle.select(glass)
                turtle.placeDown()
                turtle.select(1)
            end
        end

        checkAbove()
    end

    local function returntofloor()
        while position.y < floorY do
            while turtle.up() == false do
                turtle.digUp()
            end
            if plugHole and position.y == floorY then
                turtle.select(glass)
                turtle.placeDown()
                turtle.select(1)
            end
            broadcast("returning to surface")
        end
    end

    --local x = -1;
    --local y = -5;

    local tempx = math.floor(position.x / 16) * 16
    local tempz = math.floor(position.z / 16) * 16

    local startx = tempx + 16;
    local startz = tempz + 16;

    local shafts = {}
    local line = ""
    local line2 = ""
    for i = tempx, startx - 1 do
        for j = tempz, startz - 1 do
            if ((i % 5) * 2 + j) % 5 == 0 then
                table.insert(shafts, { x = i, z = j });
                line = line .. "@"
                line2 = line2 .. " " .. i .. "|" .. j
            else
                line = line .. "#"
            end
        end
        --print(line .. line2)
        line2 = ""
        line = ""
    end
    totalshafts = #shafts
    if fs.exists("shaftsDB") then
        shafts = loadTable("shaftsDB")
    else
        saveTable(shafts, "shaftsDB")
    end
    currentshafts = #shafts
    --print(shafts)

    local gotolocation

    --if z is lower then before, it means ur facing north
    --if z is higher then before, it means ur facing south

    --if x is lower then before, it means ur facing west
    --if x is higher then before, it means ur facing east
    checkGlass()

    if turtle.getItemCount(1) == 0 then
        turtle.select(1)
        turtle.digUp()
        if turtle.getItemCount(1) == 0 then
            print("Unable to find a Ender Chest in inventory")
            return
        end
    end

    detectfacing()
    if fs.exists("unstuckPosition") then
        local tempPos = loadTable("unstuckPosition")
        gotoloc(tempPos)
    end
    if chunkStatus ~= "returning to floor" then
        while #shafts > 0 do
            gotolocation = getClosestLocation(shafts, position)
            if chunkStatus == "moving to location" then
                if (position.y == lowestY) then
                    gotolocation.y = lowestY
                else
                    gotolocation.y = floorY
                end
                print("Going to coords: x:" .. gotolocation.x .. ", y:" .. gotolocation.y .. ", z:" .. gotolocation.z)
                gotoloc(gotolocation)
                --turtle.placeDown()
                --shaftmine()
            end

            broadcast()

            print("Starting the shaft mine")

            if (position.y == lowestY or chunkStatus == "digging up") then
                chunkStatus = "digging up"
                saveText(chunkStatus, "chunkStatus")

                shaftmineUp()
                chunkStatus = "moving to location"
                saveText(chunkStatus, "chunkStatus")
                deposit()
            else
                if chunkStatus == "digging down" then turtle.up() end
                success, data = turtle.inspectDown()
                if data.name ~= "minecraft:glass" then
                    chunkStatus = "digging down"
                    saveText(chunkStatus, "chunkStatus")
                    shaftmineDown()
                    chunkStatus = "moving to location"
                    saveText(chunkStatus, "chunkStatus")
                end
            end

            table.remove(shafts, gotolocation.index)
            saveTable(shafts, "shaftsDB")
            currentshafts = #shafts

            broadcast()

            print("Chunk mining completion: " .. math.floor(100 - (currentshafts / totalshafts * 100)) .. "% (" ..
                totalshafts - #shafts .. "/" .. totalshafts .. ")")
        end
    end

    fs.delete("shaftsDB")

    if (position.y == lowestY or chunkStatus == "returning to floor") then
        chunkStatus = "returning to floor"
        saveText(chunkStatus, "chunkStatus")
        returntofloor()
    end

    deposit()

    gotoloc({ x = math.floor(position.x / 16) * 16, y = floorY + 1, z = math.floor(position.z / 16) * 16 })
    face(0)

    --fs.delete("chunkStatus")
    chunkStatus = "done"
    saveText(chunkStatus, "chunkStatus")

    broadcast()




    --"fuel" = 999999, "x" = 9, "y" = 69, "z" = 9, "percent" = 50, "currentShafts" = 10, "totalShafts" = 52, "status" = "digging down"
    --rednet.broadcast("fuel="..turtle.getFuelLevel()..", x="..position.x..", y="..position.y..", z="..position.y..", currentShafts="..currentshafts..", totalShafts="..totalshafts..", status="..chunkStatus)
end

function string.startsWith(String, Start)
    return string.sub(String, 1, string.len(Start)) == Start
end

local instructions = ""

local function background()
    while true do
        local id, message = rednet.receive("SethMaster")
        --if id == 0 then
        if message == "reboot" then
            os.reboot()
        elseif message == "sendid" then
            rednet.broadcast("me")
        elseif message == "remove chunkStatus" then
            fs.delete("chunkStatus")
            os.reboot()
        elseif string.startsWith(message, "goto") then
            turtle.select(spotloader)
            turtle.placeDown()
            turtle.digUp()
            while position.y < 260 do
                turtle.up()
                position.y = position.y + 1
            end
            turtle.placeUp()
            while position.y > floorY + 1 do
                turtle.down()
                position.y = position.y - 1
            end
            turtle.digDown()

            shell.run("wget", "run",
                "https://raw.githubusercontent.com/Saadar/ComputerCraftScripts/refs/heads/main/goto.lua",
                string.sub(message, 6, string.len(message)))

            turtle.select(spotloader)
            while position.y > floorY + 1 do
                turtle.down()
                position.y = position.y - 1
            end
            turtle.placeDown()
            while position.y < 260 do
                turtle.up()
                position.y = position.y + 1
            end
            turtle.digUp()
            while position.y > floorY + 1 do
                turtle.down()
                position.y = position.y - 1
            end
            turtle.placeUp()
            turtle.digDown()
            if fs.exists("chunkStatus") then fs.delete("chunkStatus") end
            os.reboot()
        end
        --end
    end
end

while true do
    parallel.waitForAny(main, background)
    if instructions ~= "" then

    end
end
