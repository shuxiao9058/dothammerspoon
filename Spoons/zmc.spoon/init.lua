local obj = {}
obj.__index = obj

-- Metadata
obj.name = "zmc"
obj.version = "0.1"
obj.author = ""
obj.homepage = ""
obj.license = ""

--- Logger object used within the Spoon. Can be accessed to set the default log level for the messages coming from the Spoon.
obj.logger = hs.logger.new('zmc')

function obj:start(howlong)
    dofile(hs.spoons.resourcePath("windows.lua"))
end

return obj
