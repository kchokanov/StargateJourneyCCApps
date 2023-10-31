--ItterationDial
if not (os.loadAPI("SG/Dial.lua")) then
    error("Could not find Dial")
end
if not (os.loadAPI("SG/AddressBook.lua")) then
    error("Could not find AddressBook")
end
--[Constansts]--
ADDRESS_LENGTH = 7
--[Globals]--
excludeStartSymbolList = {0}
index = 1
--[Functions]--

-- gets address list and adds all initial address symbols to the exclusion list
function populateExclude()
    local list = AddressBook.read() -- might need a seperate file for 7 symbol addresses only
    for i = 1, #list do
        excludeStartSymbolList[#excludeStartSymbolList + 1] = list[i].address[1]
    end
end

-- itterates through all possible addresses and dials them 1 by 1. fun fact. this would take 38^6 * 40 seconds to run to completion(~33,454,845 hours)
-- ... so we're not doing that.
function doDial(address)
    print("[SGID]Attempting dial")
    if Dial.validateAndDial(address) then
        print("[SGID]Valid Address found: " .. AddressBook.addressToString(address))
        AddressBook.newAddress("SGID_found_" .. index, address)
        index = index + 1
    end
end
function addSymbol(address, currentPos)
    
    if currentPos == ADDRESS_LENGTH then
        address[currentPos] = 0
        doDial(address)
        return
    end
    for i = 1, 38 do
        sleep(0)
        --if first position, skip attempts with the excluded start symbol
        local skipFlag = false
        if currentPos == 1 then
            for j = 1, #excludeStartSymbolList do
                if i == excludeStartSymbolList[j] then
                    skipFlag = true
                end
            end
        end
        --no diplicate symbols in the address are allowed
        for j = 1, #address do
            if address[j] == i then
                skipFlag = true
            end
        end
        if not skipFlag then
            address[currentPos] = i
            addSymbol(address, currentPos + 1)
        end
    end
end


--[Main]--
populateExclude()
addSymbol({}, 1)
