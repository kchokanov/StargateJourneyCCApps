--KlaudPull
--[Constansts]--
FILE_PATH = "SG/res/SG_Address_List.txt"
REQUEST_CHANNEL = 666
RESPONSE_CHANNEL = 420
--[Globals]--
Modem = nil
--[Functions]--

-- pushes update to the "Klaud". Replaces address files on all Klaud listener systems
function requestAddressList()
    Modem.transmit(REQUEST_CHANNEL,RESPONSE_CHANNEL, "")
    local event, arg1, arg2, arg3, msg, arg5 = os.pullEvent()
    local file = fs.open(FILE_PATH, "w")
    for i = 1, #msg do
        file.writeLine(msg[i])
    end
    file.close()
    print("[SGKPull]New address list recieved.")
end
--[Main]--
PList = peripheral.getNames()

--check that a wireless modem is connected to the system
for i = 1, #PList do
    if peripheral.getType(PList[i]) == "modem" then
        Modem = peripheral.wrap(PList[i])
        if not Modem.isWireless() then
          Modem = nil
        else 
          break
        end
    end
end

--error handling in case of missing wireless modem
if Modem == nil then
    error("[SGKP]No modem found")
end

Modem.open(RESPONSE_CHANNEL)
--main arg handler for testing this program
local args = {...}

if args[1] == "get" then
    requestAddressList()
end
