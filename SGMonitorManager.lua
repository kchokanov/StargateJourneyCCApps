--MonitorManager
if not (os.loadAPI("SG/PeripheralManager.lua")) then
    error("Could not find PeripheralManager")
end
--[Constansts]--
INTERFACE = PeripheralManager.find("monitor")   --this needs to change with monitors plugged in probably
COLOUR_DEFAULT = colors.white
COLOUR_IMPORTANT = colors.yellow
COLOUR_WARNING = colors.red
COLOUR_INFO = colors.cyan
COLOUR_BACKGROUND = colors.black
COLOUR_HEADER = colors.lightGray
SCREEN_LENGTH_DEFAULT = 18 -- good for 3 tall screen
TEXT_SCALE = 1
--[Globals]--
logName = ""
ScreenLength = SCREEN_LENGTH_DEFAULT

--[Functions]--

--clear screan and reset write params, set progName and write header
function setup(name)
    logName = name
    CurserPos = 2
    PeripheralManager.callFunc(INTERFACE, "clear")
    PeripheralManager.callFunc(INTERFACE, "setBackgroundColor", COLOUR_BACKGROUND)
    PeripheralManager.callFunc(INTERFACE, "setCursorPos", 1 , 1)
    PeripheralManager.callFunc(INTERFACE, "setCursorBlink", false)
    PeripheralManager.callFunc(INTERFACE, "setTextScale", TEXT_SCALE)
    writeHeader()
end

-- reset progName and params, clear screen 
function disconnect()
    logName = ""
    ScreenLength = SCREEN_LENGTH_DEFAULT
    PeripheralManager.callFunc(INTERFACE, "setBackgroundColor", COLOUR_BACKGROUND)
    PeripheralManager.callFunc(INTERFACE, "setTextColor", COLOUR_DEFAULT)
    PeripheralManager.callFunc(INTERFACE, "clear")
end
function setScreenLength(length)
    if length < 3 then
        error("[SGMM]Screen Length value too low[3+]")
    end
    ScreenLength = length
    setup(logName)    
end

--main method for writing lines on the screen, can specify colour
function toMonitor(text, colour) 
    --if we need to scroll text, clear the header and write it post scrolling to not have lingering text when it's being overwritten
    if CurserPos == ScreenLength then
        PeripheralManager.callFunc(INTERFACE, "setCursorPos", 1, 1)
        PeripheralManager.callFunc(INTERFACE, "clearLine")
        PeripheralManager.callFunc(INTERFACE, "setCursorPos", 1, 2)
        PeripheralManager.callFunc(INTERFACE, "clearLine")
        PeripheralManager.callFunc(INTERFACE, "scroll", 1)
        writeHeader()
        PeripheralManager.callFunc(INTERFACE, "setCursorPos", 1 , CurserPos)

    else
        CurserPos = CurserPos + 1
        PeripheralManager.callFunc(INTERFACE, "setCursorPos", 1 , CurserPos)
    end    
    PeripheralManager.callFunc(INTERFACE, "setTextColor", colour)
    PeripheralManager.callFunc(INTERFACE, "write", " " .. text)
    PeripheralManager.callFunc(INTERFACE, "setTextColor", COLOUR_DEFAULT)
end

function writeInfo(text)
    toMonitor(text, COLOUR_INFO)
end

function writeWarning(text)
    toMonitor(text, COLOUR_WARNING)
end

function writeImportant(text)
    toMonitor(text, COLOUR_IMPORTANT)
end

-- creates a nice header at the top of the screen that definitly almost never breaks
function writeHeader()
    PeripheralManager.callFunc(INTERFACE, "setCursorPos", 1, 1)
    PeripheralManager.callFunc(INTERFACE, "setTextColor", COLOUR_HEADER)
    PeripheralManager.callFunc(INTERFACE, "write", " " ..logName)
    PeripheralManager.callFunc(INTERFACE, "setCursorPos", 1, 2)
    PeripheralManager.callFunc(INTERFACE, "write", "----------------------                   ")
    PeripheralManager.callFunc(INTERFACE, "setTextColor", COLOUR_DEFAULT)
end
function write(text)
    toMonitor(text, COLOUR_DEFAULT)
end
--[Main]--
local args = {...}

if args[1] == "test" then  
    setup("MonitorTest")
    write("Hello")
    writeInfo("Hello!")
    writeImportant("Hello!!")
    writeWarning("World!!!")
end
