--Observer
if not (os.loadAPI("SG/PeripheralManager.lua")) then
    error("Could not find PeripheralManager")
end
if not (os.loadAPI("SG/MonitorManager.lua")) then
    error("Could not find MonitorManager")
end
if not (os.loadAPI("SG/AddressBook.lua")) then
    error("Could not find AddressBook")
end
--[Constansts]--
INTERFACE = PeripheralManager.find("basic_interface")
LOG_PATH = "disk/log/"
--[Globals]--
logName = "SGO_" .. os.day() .. ".log"
runBool = true
day = os.day()
--[Functions]--

-- find if incoming address is in the book and make the text extra red if not
function handleIncomingConn(fromAddress)
    fromAddress[#fromAddress+1] = 0
    local ref = AddressBook.findFromAddress(fromAddress)
    MonitorManager.write("")
    if ref == nil then
        ref = "UNKNOWN"
        MonitorManager.writeWarning(getTime() .. "INCOMING Wormhole: " .. ref)
    else
        MonitorManager.writeImportant(getTime() .. "INCOMING Wormhole: " .. ref)
    end
    Logger("Inc. Dial - " .. AddressBook.addressToString(fromAddress) .. ", " .. ref)
    
end

-- log and display outgoing connection. Be extra upset again if it's not in the Address Book
function handleOutgoingConn(toAddress)
    toAddress[#toAddress+1] = 0
    local ref = AddressBook.findFromAddress(toAddress)
    MonitorManager.write("")
    if ref == nil then
        ref = "UNKNOWN"
        MonitorManager.writeWarning(getTime() .. "OUTGOING Wormhole: " .. ref)
    else
        MonitorManager.writeInfo(getTime() .. "OUTGOING Wormhole: " .. ref)
    end
    Logger("Out. Dial - " .. AddressBook.addressToString(toAddress) .. ", " .. ref)
end

function handleConnEnd(code)
    MonitorManager.write("")
    MonitorManager.writeInfo(getTime() .. "Wormhole closed.[" .. code .. "]")
    Logger("Conn. Closed - " .. code)
end

-- handels incoming entities. If it's a player take special note of it
function handleIncomingEnt(type, name, uuid)
    if type == "minecraft:player" then 
        MonitorManager.write("")
        MonitorManager.writeImportant(getTime() .. "INCOMING Traveler: " .. name)
        Logger("Inc. Plr. - " .. name)
    else
        MonitorManager.write("")
        MonitorManager.writeImportant(getTime() .. "INCOMING Entity: " .. type)
        Logger("Inc. Ent. - " .. type)
    end
end

-- handels outgoing entities. If it's a player take special note of it
function handleOutgoingEnt(type, name, uuid, wasDisintegrated)
    if type == "minecraft:player" then 
        MonitorManager.write("")
        MonitorManager.writeImportant(getTime() .. "OUTGOING Traveler: " .. name)
        Logger("Inc. Plr. - " .. name .. " D:" .. tostring(wasDisintegrated))
    else
        MonitorManager.write("")
        MonitorManager.writeInfo(getTime() .. "OUTGOING Entity: " .. type)
        Logger("Inc. Ent. - " .. type .. " D:" .. tostring(wasDisintegrated))
    end
end

function handleChevron(chevron, symbol, isIncoming)
    print("[SGO]Chevron engaged:" .. chevron .. ", S[" .. symbol .. "]")
end

-- reused KAPI log format. File should be created when program starts
function Logger(msg)   -- adds msg as timestamped line in log file
    print("[SGO]" .. msg)
    local file = fs.open(LOG_PATH .. logName, "a")
    if (file == nil) then
        error("Could not open log for:" .. logName)
    end
    file.writeLine(getDateTime() .. msg .. "\n") -- cute, but really long
    file.close()
end

function getDateTime()
    return "[D:" .. os.day() .. " T:" .. textutils.formatTime( os.time(), true ) .. "]: "
end

function getTime()
    return "[" .. textutils.formatTime( os.time(), true ) .. "]"
end
--[Main]--

--Logger setup
local LoggerPath = LOG_PATH .. logName   -- clear log
local file = fs.open(LoggerPath, "w")
if (file == nil) then
    error("Could not open log for:" .. logName)
end
file.writeLine("")
file.close()

--Monitor setup
MonitorManager.setup("SG-Observer")
MonitorManager.setScreenLength(26)
--Listener Loop
while runBool do
    if day ~= os.day() then
        logName = "SGO_" .. os.day() .. ".log"
        day = os.day()
    end
    local event, arg1, arg2, arg3, arg4 = os.pullEvent()

    if event == "stargate_incoming_wormhole" then
        handleIncomingConn(arg1)    
    end
    if event == "stargate_outgoing_wormhole" then
        handleOutgoingConn(arg1)    
    end
    if event == "stargate_disconnected" then
        handleConnEnd(arg1)    
    end
    if event == "stargate_deconstructing_entity" then
        handleOutgoingEnt(arg1, arg2, arg3, arg4)    
    end
    if event == "stargate_reconstructing_entity" then
        handleIncomingEnt(arg1, arg2, arg3)    
    end
    if event == "stargate_chevron_engaged" then
        handleChevron(arg1, arg2, arg3)    
    end
end
