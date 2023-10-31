--Dial
--Based on Povstalec's example dial program[https://github.com/Povstalec/StargateJourney-ComputerCraft-Programs/blob/main/StargateDialing.lua]
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
--[Globals]--

--[Functions]--
function sgInput(address)

    if PeripheralManager.callFunc(INTERFACE, "isStargateConnected") then
        MonitorManager.write(" ")
        MonitorManager.writeWarning("ERR: Stargate is connected")
        error("[SGD]Stargate is connected")
    end
    if PeripheralManager.callFunc(INTERFACE, "getChevronsEngaged") ~= 0 then
        MonitorManager.write(" ")
        MonitorManager.writeWarning("ERR: Chevrons are locked")
        error("[SGD]Chevrons are locked")
    end
   
    for i = 1,#address do
        --rotation is decided based on which side of the ring corresponding to the last locked symbol the next one is
        local nextPosition = address[i]
        local currOpposite = PeripheralManager.callFunc(INTERFACE, "getCurrentSymbol")
        --current opposite has to be within the bounds of the symbol count [39]
        if currOpposite < 19 then
            currOpposite = currOpposite + 19
        else
            currOpposite = currOpposite - 19
        end

        if nextPosition > currOpposite then
            PeripheralManager.callFunc(INTERFACE, "rotateClockwise", nextPosition)
        else
            PeripheralManager.callFunc(INTERFACE, "rotateAntiClockwise", nextPosition)
        end 

        while(not PeripheralManager.callFunc(INTERFACE, "isCurrentSymbol", nextPosition))
        do
            --wait till the symbol is in position. sleep() is to stop errors
            sleep(0)
        end
        
        --magic code do not touch
        sleep(1)
        PeripheralManager.callFunc(INTERFACE, "raiseChevron")
        sleep(1)
        PeripheralManager.callFunc(INTERFACE, "lowerChevron")
        sleep(1)

        if i == #address then
            MonitorManager.write(" ")
            MonitorManager.writeImportant("Chevron " .. i .. " locked.")
            print("[SGD]Chevron " .. i .. " locked.")
        else
            if i == 1 then
                MonitorManager.setScreenLength(#address * 2 + 2)
            end
            MonitorManager.write(" ")
            MonitorManager.writeInfo("Chevron " .. i .. " encoded.")
            print("[SGD]Chevron " .. i .. " encoded.")
        end
    end
    --Connection confimation and closing timer
    sleep(4)
    if PeripheralManager.callFunc(INTERFACE, "isStargateConnected") then
       return true
    else
        return false
    end
end

function dialWrap(address)
    if sgInput(address) then
        print("[SGD]Wormhole established.")
        MonitorManager.setScreenLength(5)
        local earlyFlag = false
        for i = 1, 39 do
            if not PeripheralManager.callFunc(INTERFACE, "isStargateConnected") then
                print("[SGD]Connection closed early")
                earlyFlag = true
                break
            end
            MonitorManager.write("")
            MonitorManager.writeImportant("Wormhole established.")
            MonitorManager.writeWarning("Closing in: " .. 39 - i .."s")
            sleep(1)
        end
        
        if not earlyFlag then
            print("[SGD]Wormhole closing.")
            PeripheralManager.callFunc(INTERFACE, "disconnectStargate")
            MonitorManager.write(" ")
            MonitorManager.writeImportant("Wormhole closed.")
            MonitorManager.write(" ")
            sleep(4)
            MonitorManager.disconnect()
        else
            MonitorManager.write(" ")
            MonitorManager.writeWarning("Connection closed early.")
            MonitorManager.write(" ")
            sleep(4)
            MonitorManager.disconnect()
        end
        return true
    else
        MonitorManager.setScreenLength(4)
        MonitorManager.write(" ")
        MonitorManager.writeImportant("Could not establish wormhole.")
        print("[SGD]Could not establish wormhole.") 
        sleep(4)
        MonitorManager.disconnect()
        return false
    end
end

function validateAndDial(address)
    if #address < 7 or #address > 9 then
        error("[SGD]Address length out of bounds [7-9]")
    end
    for i = 1, #address do
        address[i] = tonumber(address[i])
        if(address[i] < 0 or address[i] > 38) then
            error("[SGD]Address symbol out of bounds [0-38]")
        end
    end

    if(address[#address] ~= 0) then
        error("[SGD]Adress must end with Point of Origin[0]")
    end

    MonitorManager.setup("SG-Dialing Sequence")
    MonitorManager.setScreenLength(4)
    MonitorManager.write(" ")
    MonitorManager.writeInfo("Starting dialing sequence.")
    print("[SGD]Starting Dial to: " .. AddressBook.addressToString(address))
    return dialWrap(address)
end

--[Main]--
local args = {...}

if #args == 1 then
    validateAndDial(AddressBook.findInFile(args[1]).address)
elseif #args > 6 then
    validateAndDial(args)
end
