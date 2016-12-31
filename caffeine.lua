print("Loading caffeine")

local imagePath =  os.getenv("HOME") .. '/.hammerspoon/assets/';
local iconAwake = imagePath .."caffeine-on.pdf"
local iconSleep = imagePath .."caffeine-off.pdf"

local obj = {}
obj.__index = obj

obj.menuBarItem = nil

function obj:start()
    self.menuBarItem = hs.menubar.new()

    self.menuBarItem:setClickCallback(self.clicked)
    self.setDisplay(hs.caffeinate.get("displayIdle"))

    return self
end

function obj.setDisplay(state)
    local result
    if state then
        result = obj.menuBarItem:setIcon(iconAwake)
    else
        result = obj.menuBarItem:setIcon(iconSleep)
    end
end

function obj.clicked()
    obj.setDisplay(hs.caffeinate.toggle("displayIdle"))
end

return obj
