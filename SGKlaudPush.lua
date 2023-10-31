--KlaudPush
--[Constansts]--
FILE_PATH = "SG/res/SG_Address_List.txt"
REQUEST_CHANNEL = 666
--[Globals]--
Modem = nil
--[Functions]--

-- pushes update to the "Klaud". Replaces address files on all Klaud listener systems
function requestAddressList()
  local msg = {}
  --check if file exists
  local file = fs.open(FILE_PATH, "r")
  if file == nil then
      error("[SGKP]File not found at: " .. FILE_PATH)
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
  --send push
  Modem.transmit(REQUEST_CHANNEL,1, msg)
  print("[SGKPush]Address update sent on channel: " .. tostring(REQUEST_CHANNEL))
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
    error("[SGKPush]No modem found")
end

--main arg handler for testing this program
local args = {...}

if args[1] == "push" then
    requestAddressList()
end
