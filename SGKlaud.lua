--Klaud
--[Constansts]--
FILE_PATH = "disk/res/SG_Address_List.txt"
REQUEST_CHANNEL = 666
RESPONSE_CHANNEL = 420
--[Globals]--
Modem = nil
Drive = nil
RunBool = true
--[Functions]--

--handle recieved address list updates. Replaces entire list
function requestAddressList()
    Modem.open(RESPONSE_CHANNEL)
    Modem.transmit(REQUEST_CHANNEL,RESPONSE_CHANNEL, "")
    local event, arg1, arg2, arg3, msg, arg5 = os.pullEvent()
    local file = fs.open(FILE_PATH, "w")
    for i = 1, #msg do
        file.writeLine(msg[i])
    end
    file.close()
    Modem.close(RESPONSE_CHANNEL)
    print("[SGK]Address list recieved.")
end

function handleRecieved(msg)
    local file = fs.open(FILE_PATH, "w")
    if (file == nil) then
        error("[SGK]File not found at: " .. FILE_PATH)
    end
    for i = 1, #msg do
        file.writeLine(msg[i])
    end
    file.close()
    print("[SGK]New address list recorded.")
end

--send copy of local disk address list and start a new send timer
function handleSend(repChannel)
    local msg = {}

    --check if file exists
    local file = fs.open(FILE_PATH, "r")
    if file == nil then
        error("[SGK]File not found at: " .. FILE_PATH)
        return
    end
  
    --read
    while true do
      local line = file.readLine()
      if not line then 
        break 
      end
  
      msg[#msg+1] = line

    end
    file.close()

    Modem.transmit(repChannel,1, msg)
    print("[SGK]Address update sent on channel: " .. tostring(repChannel))
end

--[Main]--
PList = peripheral.getNames()

--find drive
for i = 1, #PList do
    if peripheral.getType(PList[i]) == "drive" then
        Drive = peripheral.wrap(PList[i])
        print("[SGK]Drive found: " .. PList[i])
        break
    end
end

--find modem and check that it's wireless
for i = 1, #PList do 
    if peripheral.getType(PList[i]) == "modem" then
        Modem = peripheral.wrap(PList[i])
        if not Modem.isWireless() then
            Modem = nil
        else 
            print("[SGK]Modem found: " .. PList[i])
        break
        end
    end
end

--error handling in case of missing peripheral
if Modem == nil then
    error("[SGK]No modem found")
end

if Drive == nil then
    error("[SGK]No Disk Drive found")
end

--disk file check
File = fs.open(FILE_PATH, "r")
if File == nil then
    File = fs.open(FILE_PATH, "w")
    print("[SGK]Address file created at: " .. FILE_PATH)
else
    print("[SGK]Address file found at: " .. FILE_PATH)
end
File.close()

--get copy of list on Klaud and start listener loop
print("[SGK]Pulling copy of list from the Klaud")
requestAddressList()
Modem.open(REQUEST_CHANNEL)
print("[SGK]Klaud has started. Listening on channel: " .. tostring(REQUEST_CHANNEL))

--listener loop
while RunBool do
    local event, arg1, arg2, arg3, arg4, arg5 = os.pullEvent()

    if event == "disk_eject" then
        error("[SGK]Disk ejected. Please re-insert and restart.")
    end
    if event == "modem_message" then
        if (arg3 ~= 1) then --if the response channel is different to the usual it's counted as a pull request
            print("[SGK]Recieved address request. D:" .. os.day() .. "T:" .. textutils.formatTime( os.time(), true ) )
            handleSend(arg3)
        else
            print("[SGK]Recieved address update. D:" .. os.day() .. "T:" .. textutils.formatTime( os.time(), true ) )
            handleRecieved(arg4)
        end
    end
end
