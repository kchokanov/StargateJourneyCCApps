--PeripheralManager
--[Constansts]--
--[Globals]--
PModem = nil
--[Functions]--
function find(type)
    local list = PModem.getNamesRemote()
    local returnValue
    for i = 1, #list do
        if PModem.getTypeRemote(list[i]) == type then
            returnValue = list[i]
            break
        end
    end
    if returnValue ~= nil then
        return returnValue
    else
        error("[SGPM]Peripheral not found: " .. type)
    end
end

function callFunc(remoteName, funcName, arg1, arg2, arg3)
    return PModem.callRemote(remoteName, funcName, arg1, arg2, arg3)
end
--[Main]--
PList = peripheral.getNames()

for i = 1, #PList do
    if peripheral.getType(PList[i]) == "modem" then
        PModem = peripheral.wrap(PList[i])
        if PModem.isWireless() then
            PModem = nil
        else
            break
        end
    end
end

if PModem == nil then
    error("[SGPM] No peripherals modem found.")
end

local args = {...}

if args[1] == "list" then
    local list = PModem.getNamesRemote()
    for i = 1, #list do
        print("[SGPM]Connected to " .. list[i])
    end
end
