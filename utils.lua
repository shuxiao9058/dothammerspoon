local utils = {}

-- Helper functions

-- -- Toggle an application between being the frontmost app, and being hidden
-- function utils:toggle_application(_app)
--     local app = hs.appfinder.appFromName(_app)
--     if not app then
--         -- FIXME: This should really launch _app
--         return
--     end
--     local mainwin = app:mainWindow()
--     if mainwin then
--         if mainwin == hs.window.focusedWindow() then
--             mainwin:application():hide()
--         else
--             mainwin:application():activate(true)
--             mainwin:application():unhide()
--             mainwin:focus()
--         end
--     end
-- end

-- -- local toggleMaximizedMap={}
-- local toggleMaximizedMap={}
-- -- hs.geometry.rect(0, -48, 400, 48)
-- function utils:toggleMaximized()
--    local win = hs.window.frontmostWindow()
--    if win ==nil then
--       return
--    end
--    local app = win:application()
--    if app:title()=="Finder" and win:role()== "AXScrollArea" then -- 如果是桌面
--       return
--    end
--    -- if app:title()=="iTerm2" then
--    --    toggleFullScreen()
--    --    return
--    -- end
--    local winKey=app:bundleID() .. tostring(win:id())
--    local curFrame = win:frame()
--    local originFrame=toggleMaximizedMap[winKey]
--    local screen = win:screen()
--    local max = screen:frame()
--    -- hs.window.setFrameCorrectness=true

--    if win:isFullScreen() then
--       win:setFullScreen(false)
--    end
--    if win:isMinimized() then
--       win:unminimize()
--    end
--    win:application():activate(true)
--    win:application():unhide()
--    win:focus()

--    win:maximize(0)           -- 0s duration (无动画马上最大化)
--    local maximizedFrame= win:frame() -- 最大化后的尺寸
--    if math.abs(maximizedFrame.w-curFrame.w)<80 and math.abs(maximizedFrame.h-curFrame.h)<80 then -- 只要窗口大小跟全屏后的尺寸相差不大就认为是全屏状态
--       if  originFrame then
--          win:setFrame(originFrame,0) -- 恢复成初始窗口大小
--       else                      -- 没有存窗口的初始大小，则随机将其调到一个位置
--          win:moveToUnit(hs.geometry.rect(math.random()*0.1,math.random()*0.1, 0.718, 0.718),0)
--       end
--    else                         -- 当前是非最大化状态，
--       if not (maximizedFrame.w-curFrame.w<0 or maximizedFrame.h-curFrame.h<0 )then -- 从fullscreen 恢复回来的则不记录其窗口大小
--          toggleMaximizedMap[winKey]=hs.geometry.copy(curFrame) -- 存储当前窗口大小
--       end
--    end
-- end
-- hs.urlevent.bind("toggleMaximized", function(eventName, params)  toggleMaximized() end)
-- Window cache for window maximize toggler
local frameCache = {}

-- Toggle current window between its normal size, and being maximized
function utils:toggleMaximized()
    local win = hs.window.focusedWindow()
    -- hs.alert.show("win" .. tostring(win:application():name()))
    if (win == nil) or (win:id() == nil) then
        return
    end

    if win:application():name() == "Emacs" then
        hs.eventtap.keyStroke({"alt"}, "F10")
        return
    end

    if frameCache[win:id()] then
        win:setFrame(frameCache[win:id()])
        frameCache[win:id()] = nil
    else
        frameCache[win:id()] = win:frame()
        win:maximize()
    end
end

function utils:urlencode(str)
    if (str) then
        str = string.gsub(str, "\n", "\r\n")
        str = string.gsub(str, "([^%w ])", function(c)
            return string.format("%%%02X", string.byte(c))
        end)
        str = string.gsub(str, " ", "+")
    end
    return str
end

return utils
