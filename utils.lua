local utils = {}

-- Helper functions

-- -- Toggle an application between being the frontmost app, and being hidden
-- function utils.toggle_application(_app)
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
-- function utils.toggleMaximized()
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
function utils.toggleMaximized()
  local win = hs.window.focusedWindow()
  -- hs.alert.show("win" .. tostring(win:application():name()))
    if (win == nil) or (win:id() == nil) then
        return
    end

    if tostring(win:application():name()) == "Emacs" then
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

-- toggle App
function utils.toggleApp(appBundleID)
   -- local win = hs.window.focusedWindow()
   -- local app = win:application()
   local app =hs.application.frontmostApplication()
   if app ~= nil and app:bundleID() == appBundleID    then
      app:hide()
      -- win:sendToBack()
   elseif app==nil then
      hs.application.launchOrFocusByBundleID(appBundleID)
   else
      -- app:activate()
      hs.application.launchOrFocusByBundleID(appBundleID)
      app=hs.application.get(appBundleID)
      if app==nil then
         return
      end
      local wins=app:visibleWindows()
      if #wins>0 then
         for k,win in pairs(wins) do
            if win:isMinimized() then
               win:unminimize()
            end
         end
      else
         hs.application.open(appBundleID)
         app:activate()
      end


      local win=app:mainWindow()
      if win ~= nil then
         win:application():activate(true)
         win:application():unhide()
         win:focus()
      end
   end
end

function utils.toggleEmacs()        --    toggle emacsclient if emacs daemon not started start it
   -- local win = hs.window.focusedWindow()
   -- local topApp = win:application()

   local topApp =hs.application.frontmostApplication()

   -- hs.alert.show("hhh" .. topApp:title())
   if topApp ~= nil and topApp:title() == "Emacs"  and #topApp:visibleWindows()>0 and not topApp:isHidden() then
      topApp:hide()
   else
      local emacsApp=hs.application.get("Emacs")
      if emacsApp==nil then
         -- ~/.emacs.d/bin/ecexec 是对emacsclient 的包装，你可以直接用emacsclient 来代替
         -- 这个脚本会检查emacs --daemon 是否已启动，未启动则启动之
         -- hs.execute("~/.emacs.d/bin/ecexec --no-wait -c") -- 创建一个窗口
         hs.execute("/usr/local/bin/emacsclient --no-wait -c") -- 创建一个窗口
         -- 这里可能需要等待一下，以确保窗口创建成功后再继续，否则可能窗口不前置
         emacsApp=hs.application.get("Emacs")
         if emacsApp ~=nil then
            emacsApp:activate()      -- 将刚创建的窗口前置
         end
         return
      end
      local wins=emacsApp:allWindows() -- 只在当前space 找，
      if #wins==0 then
         wins=hs.window.filter.new(false):setAppFilter("Emacs",{}):getWindows() -- 在所有space找，但是window.filter的bug多，不稳定
      end

      if #wins>0 then
         for _,win in pairs(wins) do

            if win:isMinimized() then
               win:unminimize()
            end

            win:application():activate(true)
            win:application():unhide()
            win:focus()
         end
      else
         -- ~/.emacs.d/bin/ecexec 是对emacsclient 的包装，你可以直接用emacsclient 来代替
         -- 这个脚本会检查emacs --daemon 是否已启动，未启动则启动之
         -- hs.execute("~/.emacs.d/bin/ecexec --no-wait -c") -- 创建一个窗口
         hs.execute("/usr/local/bin/emacsclient --no-wait -c") -- 创建一个窗口
         -- 这里可能需要等待一下，以确保窗口创建成功后再继续，否则可能窗口不前置
         emacsApp=hs.application.get("Emacs")
         if emacsApp ~=nil then
            emacsApp:activate()      -- 将刚创建的窗口前置
         end
      end
   end
end

---------------------------------------------------------------
function utils.toggleFinder()
   local appBundleID="com.apple.finder"
   local topWin = hs.window.focusedWindow()
   if topWin==nil then
      return
   end
   local topApp = topWin:application()
   -- local topApp =hs.application.frontmostApplication()

   -- The desktop belongs to Finder.app: when Finder is the active application, you can focus the desktop by cycling through windows via cmd-`
   -- The desktop window has no id, a role of AXScrollArea and no subrole
   -- and #topApp:visibleWindows()>0
   if topApp ~= nil and topApp:bundleID() == appBundleID   and topWin:role() ~= "AXScrollArea" then
      topApp:hide()
   else
      finderApp=hs.application.get(appBundleID)
      if finderApp==nil then
         hs.application.launchOrFocusByBundleID(appBundleID)
         return
      end
      local wins=finderApp:allWindows()
      local isWinExists=true
      if #wins==0  then
         isWinExists=false
      elseif  (wins[1]:role() =="AXScrollArea" and #wins==1 )  then
         isWinExists=false
      end

      -- local wins=app:visibleWindows()
      if not isWinExists then
         wins=hs.window.filter.new(false):setAppFilter("Finder",{}):getWindows()
      end


      if #wins==0 then
         hs.application.launchOrFocusByBundleID(appBundleID)
         for _,win in pairs(wins) do
            if win:isMinimized() then
               win:unminimize()
            end

            win:application():activate(true)
            win:application():unhide()
            win:focus()
         end
      else
         for _,win in pairs(wins) do
            if win:isMinimized() then
               win:unminimize()
            end

            win:application():activate(true)
            win:application():unhide()
            win:focus()
         end
      end
   end
end

function utils.urlencode(str)
   if (str) then
      str = string.gsub (str, "\n", "\r\n")
      str = string.gsub (str, "([^%w ])",
         function (c) return string.format ("%%%02X", string.byte(c)) end)
      str = string.gsub (str, " ", "+")
   end
   return str    
end

return utils
