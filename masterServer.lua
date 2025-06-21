local colors = colors
local chat = peripheral.wrap("bottom")
local monitor = peripheral.wrap("left")
--monitor.setTextScale(0.5)
monitor.setTextScale(1)
local monitor2 = peripheral.wrap("right")
local monitor3 = peripheral.wrap("monitor_2")
peripheral.find("modem", rednet.open)
local IDs = {}
local movingToChunk = ""

function tableContains(checktable, value)
    for i = 1, #checktable do
        if (checktable[i] == value) then
            return i
        end
    end
    return false
end

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

local info = { x = 0, z = 0, count = 1, facing = 0, i = 1, k = 1 }
if fs.exists("chunkSave") then
    info = loadTable("chunkSave")
end

if fs.exists("movingToChunk") then
    movingToChunk = loadText("movingToChunk")
end
--50 x 33
local chunkTermCoords = { x = 25, z = 20 }

local function printCoords(x, z, percent)
    if x == nil and z == nil then
        if fs.exists("chunkSave") then
            local tempinfo = loadTable("chunkSave")
            x = tempinfo.x
            z = tempinfo.z
        else
            goto endOfPrintCoords
        end
    end
    local info = { x = 0, z = 0, count = 1, facing = 0, i = 1, k = 1 }
    local color = colors.red
    if percent ~= nil then
        if percent >= 95 then
            color = colors.lime
        elseif percent >= 90 then
            color = colors.green
        elseif percent >= 75 then
            color = colors.yellow
        elseif percent >= 60 then
            color = colors.orange
        elseif percent >= 45 then
            color = colors.pink
        elseif percent >= 30 then
            color = colors.magenta
        elseif percent >= 15 then
            color = colors.purple
        end
    end

    monitor2.setCursorPos(chunkTermCoords.x, chunkTermCoords.z)
    monitor2.write("X")

    while true do
        while info.k <= 2 do
            while info.i <= info.count do
                if info.facing == 0 then     -- facing +z
                    info.z = info.z - 1
                elseif info.facing == 1 then -- facing -x
                    info.x = info.x + 1
                elseif info.facing == 2 then -- facing -z
                    info.z = info.z + 1
                else                         -- must be facing +x
                    info.x = info.x - 1
                end
                if percent == nil then
                    monitor2.setCursorPos(info.x + chunkTermCoords.x, info.z + chunkTermCoords.z)
                    monitor2.write("#")
                end
                if x == info.x and z == info.z then
                    --x, z = monitor2.getCursorPos()
                    --monitor2.setCursorPos(x - 1, z)
                    monitor2.setCursorPos(info.x + chunkTermCoords.x, info.z + chunkTermCoords.z)
                    monitor2.setTextColor(color)
                    monitor2.write("@")
                    monitor2.setTextColor(colors.white)
                    return
                end

                info.i = info.i + 1
                --number = number + 1

                --os.sleep(0.1)
            end
            info.i = 1
            info.facing = (info.facing + 1) % 4
            info.k = info.k + 1
        end
        info.k = 1
        info.count = info.count + 1
    end
    ::endOfPrintCoords::
end

local function getNewCoords()
    --term.setCursorPos(info.x, info.z)
    --term.write("#")

    if fs.exists("chunkSave") then
        info = loadTable("chunkSave")
    end
    saveTable(info, "chunkSave")

    while true do
        while info.k <= 2 do
            while info.i <= info.count do
                if info.facing == 0 then     -- facing +z
                    info.z = info.z - 1
                elseif info.facing == 1 then -- facing -x
                    info.x = info.x + 1
                elseif info.facing == 2 then -- facing -z
                    info.z = info.z + 1
                else                         -- must be facing +x
                    info.x = info.x - 1
                end
                --term.setCursorPos(info.x, info.z)
                --term.write(math.random(10)-1)
                local coords = { x = info.x, z = info.z }

                info.i = info.i + 1
                saveTable(info, "chunkSave")
                --number = number + 1
                os.sleep(1)
                return coords
            end
            info.i = 1
            info.facing = (info.facing + 1) % 4
            info.k = info.k + 1
            saveTable(info, "chunkSave")
        end
        info.k = 1
        info.count = info.count + 1
        saveTable(info, "chunkSave")
    end
end
--rednet.broadcast("fuel="..turtle.getFuelLevel()..", x="..position.x..", y="..position.y..", z="..position.y..", currentShafts="..currentshafts..", totalShafts="..totalshafts..", status="..customStatus)

printCoords()

monitor.clear()
monitor.setCursorPos(1, 1)
monitor.setTextColor(colors.yellow)
monitor.write("ID DEPTH FUEL   COMPLETION")

monitor3.clear()
monitor3.setCursorPos(1, 1)
monitor3.setTextColor(colors.yellow)
monitor3.write("ID DEPTH FUEL   COMPLETION")
while true do
    local info = {}
    local id, message = rednet.receive("SethStatus")
    for k, v in string.gmatch(message, "(%w+)=([^,]+)") do
        info[k] = v
        --print(k .. "&" .. v .. "&")
    end
    local parsedID = id
    if id < 10 then parsedID = " " .. id end

    --\25 downwards arrow
    --\24 upwards arrow
    --returning to surface
    local depth = info.y
    local depthColor = colors.white
    if info.status == "digging up" then
        depth = "\24" .. depth
        depthColor = colors.lime
    elseif info.status == "digging down" then
        depth = "\25" .. depth
        depthColor = colors.green
    elseif info.status == "returning to surface" then
        depth = "\24" .. depth
        depthColor = colors.lime
    end
    for i = string.len(depth), 4 do --y
        depth = " " .. depth
    end
    info.fuel = tonumber(info.fuel)
    local fuel = info.fuel
    if fuel > 9999 then
        fuel = math.floor(fuel / 1000) .. "k"
        --elseif fuel > 999 then
        --    fuel = math.floor(fuel / 100)
        --    local tempFuel = fuel % 10
        --    fuel = math.floor(fuel / 10).."."..tempFuel.."k"
    end
    fuel = tostring(fuel)

    for i = string.len(fuel), 3 do --fuel
        fuel = " " .. fuel
    end

    local tempCurrentshafts = tonumber(info.totalShafts) - tonumber(info.currentShafts)
    if tempCurrentshafts < 10 then tempCurrentshafts = " " .. tempCurrentshafts end
    local percent = math.floor(100 - (info.currentShafts / info.totalShafts * 100))
    local completion = percent ..
        "% (" .. tempCurrentshafts .. "/" .. info.totalShafts .. ")"
    for i = string.len(completion), 11 do --completion
        completion = " " .. completion
    end

    table.sort(IDs)
    local termY = tableContains(IDs, id)
    if termY == false then
        table.insert(IDs, id)
        table.sort(IDs)
        termY = tableContains(IDs, id)
    end

    local logMonitor = monitor
    if termY > 39 then
        logMonitor = monitor3
        logMonitor.setCursorPos(1, termY - 38)
    else
        logMonitor.setCursorPos(1, termY + 1)
    end

    local status = info.status
    if status == "stuck" then
        status = "x:" .. info.x .. " z:" .. info.z .. " HELP"
        chat.sendMessageToPlayer("I'm stuck at X:" .. info.x .. " Y:" .. info.y .. " Z:" .. info.z, "Saadar",
            "SethBot" .. parsedID, "<>")
    end

    if info.status == "done" then
        print(id..": status is done")
        if movingToChunk == "" then
            print("sending command to ID:" .. id .. " to move to new chunk")
            saveText(id, "movingToChunk")
            movingToChunk = tostring(id)
            local newCoords = getNewCoords() --..newCoords.x.." "..newCoords.z
            printCoords(newCoords.x, newCoords.z)
            rednet.send(id, "goto " .. (newCoords.x * 16) .. " 260 " .. (newCoords.z * 16), "SethMaster")
        elseif movingToChunk == tostring(id) then
            status = "Moving to new chunk"
        --else
            --print(id .. " != "..movingToChunk)
        end
    end
    if info.status ~= "done" and movingToChunk == tostring(id) then
        print("moving to new chunk complete")
        saveText("", "movingToChunk")
        movingToChunk = ""
    end

    if info.status ~= "done" then
        printCoords(math.floor(info.x / 16), math.floor(info.z / 16), percent)
    end

    logMonitor.clearLine()
    logMonitor.setTextColor(colors.orange)
    logMonitor.write(parsedID)
    logMonitor.setTextColor(depthColor)
    logMonitor.write(" " .. depth)
    if (info.fuel < 1000) then
        logMonitor.setTextColor(colors.red)
    elseif (info.fuel < 10000) then
        logMonitor.setTextColor(colors.lightGray)
    else
        logMonitor.setTextColor(colors.gray)
    end
    logMonitor.write(" " .. fuel)

    logMonitor.setTextColor(colors.red)
    if percent >= 95 then
        logMonitor.setTextColor(colors.lime)
    elseif percent >= 90 then
        logMonitor.setTextColor(colors.green)
    elseif percent >= 75 then
        logMonitor.setTextColor(colors.yellow)
    elseif percent >= 60 then
        logMonitor.setTextColor(colors.orange)
    elseif percent >= 45 then
        logMonitor.setTextColor(colors.pink)
    elseif percent >= 30 then
        logMonitor.setTextColor(colors.magenta)
    elseif percent >= 15 then
        logMonitor.setTextColor(colors.purple)
    end
    logMonitor.write(" " .. completion)

    if status == "stuck" then
        logMonitor.setTextColor(colors.red)
    else
        logMonitor.setTextColor(colors.lightGray)
    end
    logMonitor.write(" " .. status)
end
--colors.white
--colors.orange
--colors.magenta
--colors.lightBlue
--colors.yellow
--colors.lime
--colors.pink
--colors.gray
--colors.lightGray
--colors.cyan
--colors.purple
--colors.blue
--colors.brown
--colors.green
--colors.red
--colors.black
