--Reset
if not (os.loadAPI("SG/PeripheralManager.lua")) then
    error("Could not find PeripheralLoad")
end

--[Constansts]--
INTERFACE = PeripheralManager.find("basic_interface")
--[Globals]--

--[Functions]--
function reset()
    PeripheralManager.callFunc(INTERFACE, "lowerChevron")

    if PeripheralManager.callFunc(INTERFACE, "isStargateConnected") then
        print("[SGR]Closing wormhole.")
        PeripheralManager.callFunc(INTERFACE, "disconnectStargate")
    end
    if PeripheralManager.callFunc(INTERFACE, "getChevronsEngaged") ~= 0 then
        print("[SGR]Unlocking all chevrons.")
        PeripheralManager.callFunc(INTERFACE, "disconnectStargate")
    end
end
--[Main]--
reset()
