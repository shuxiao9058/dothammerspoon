local _M = {}
_M._VERSION = "0.01"

local mt = { __index = _M }

--[[
 title
 message
 subTitle

    local notifyAttr = {
      alwaysPresent = true,
      setIdImage = textToImage(0x10020E),
      title = "Notmuch new mail notifications",
      subTitle = string.format("Received %d new mails since last refresh.", newMailCount),
      informativeText = info,
      withdrawAfter = 0
    }
]]
local function notifyFn(eventName, params)
    local subTitle = params.subTitle
    local message = params.message
    local title = params.title
    -- local idImagePath = params.idImagePath
    -- if not idImagePath or idImagePath == '' then
    --     idImagePath = nil
    -- end
    -- logger:e("idImagePath: " .. (idImagePath or 'nil'))

    local notifyAttr = {
        alwaysPresent = true,
        setIdImage = textToImage(0x10020E),
        title = title,
        subTitle = subTitle,
        informativeText = message,
        withdrawAfter = 0,
    }

    local notify = hs.notify.new(nil, notifyAttr)
    -- if idImagePath and idImagePath ~= '' then
    --     local idImage = hs.image.imageFromPath(idImagePath)
    --     if idImage then
    --         -- notify = notify:setIdImage(idImage)
    --         notify:setIdImage(idImage):alwaysPresent(true):autoWithdraw(false):send()
    --         logger:e("set idImage success")
    --         return
    --     else
    --         logger:e("Failed to load image from path: " .. idImagePath)
    --     end
    -- else
    --     logger:e("No idImagePath provided")
    -- end
    notify:alwaysPresent(true):autoWithdraw(false):send()
end

function _M:start()
    hs.urlevent.bind("notify", notifyFn)
end

return _M
