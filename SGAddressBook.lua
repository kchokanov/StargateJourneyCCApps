--AddressBook
--[Constansts]--
FILE_PATH = "disk/res/SG_Address_List.txt"
FILE_PATH_WRITE = "SG/res/SG_Address_List.txt"
--[Globals]--

--[Functions]--
--local address entry class definition
local AddressEntry = {ref = "", address = {}}

function AddressEntry.new(ref, address)
    local self = setmetatable({}, AddressEntry)

    self.ref = ref
    self.address = address

    return self
end

--no fucking clue
function AddressEntry.__index(tab, key)
    return AddressEntry[key]
end

--returns address entry from line
function toAddressEntry(line)
  local address={}
  local ref = ""
  local name = true
  for str in string.gmatch(line, "[^%s]+") do
    if name then
      ref = str
      name = false
    else
    address[#address+1] = str
    end
  end
  return AddressEntry.new(ref,address)
end

  --read lines from file into address entry list. format example(name 1 2 3 4 5 6 0)
function read()
  local list = {}

  --check if file exists
  local file = fs.open(FILE_PATH, "r")
  if file == nil then
    error("[SGAB]File not found at: " .. FILE_PATH)
    return
  end

  --read
  while true do
    local line = file.readLine()
    if not line then 
      break 
    end

    list[#list+1] = toAddressEntry(line)
  end
  file.close()
  return list
end

function findAddress(ref, addressList)
  local returnValue
  for i = 1, #addressList do
    if addressList[i].ref == ref then
      returnValue = addressList[i]
      break
    end
  end
  if returnValue == nil then
    print("[SGAB]Could not find address for: " .. ref)
  end
  return returnValue
end

function newAddress(ref, address)
  insertAddress(AddressEntry.new(ref, address))
end

function insertAddress(addressEntry)
  local str = fullAddressToString(addressEntry)

  local file = fs.open(FILE_PATH_WRITE, "a")
  if file == nil then
    print("[SGAB]Write file created.")
    local file = fs.open(FILE_PATH_WRITE, "w")
  end
  file.writeLine(str)
  file.close()

  print("[SGAB]Attempting to push update to Klaud")
  if (os.loadAPI("SG/KlaudPush.lua")) then
    KlaudPush.sendUpdate()
  end
end

function fullAddressToString(addressEntry)
  if addressEntry == nil then
    return nil
  end
  local str = addressEntry.ref

  for i = 1, #addressEntry.address do
    str = str .." ".. addressEntry.address[i]
  end
  
  return str
end


function addressToString(address)
  if address == nil then
    return nil
  end
  local str = ""

  for i = 1, #address do
    str = str .. address[i] .. " "
  end
  
  return str
end

function findInFile(ref)
  return findAddress(ref, read())
end

function findToString(ref)
  return fullAddressToString(findInFile(ref))
end

function findFromAddress(address)
  local list = read()
  local queryAdd = addressToString(address)
  for i = 1, #list do
    if queryAdd == addressToString(list[i].address) then
      return list[i].ref
    end
  end
  print("[SGAB]Could not find ref for:" .. queryAdd)
  return nil
end
--[Main]--

local args = {...}
-- TODO# Would still have to manually copy file over to share addresses
if args[1] == "find" then
  local res = findToString(args[2])
  if res ~= nil then
    print("[SGAB]Found: " .. findToString(args[2]))
  end
elseif args[1] == "add" then
  print("[SGAB]Syncing to Klaud prior to pushing")
  if (os.loadAPI("SG/KlaudPull.lua")) then
    KlaudPull.requestAddressList()
  end
  local address = {}
  for i = 3, #args do
    address[#address+1] = (args[i])
  end
  print("[SGAB]Added: " .. args[2] .. ": " .. addressToString(address))
  newAddress(args[2], address)
end
