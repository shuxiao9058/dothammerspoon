local toggleAPPs = {}

---------------------------------------------------------------
function toggleAPPs.toggleEmacs() --    toggle emacsclient if emacs daemon not started start it
   -- local win = hs.window.focusedWindow()
   -- local topApp = win:application()

   local topApp = hs.application.frontmostApplication()

   -- hs.alert.show("hhh" .. topApp:title())
   if topApp ~= nil and topApp:title() == "Emacs" and
       #topApp:visibleWindows() > 0 and not topApp:isHidden() then
      topApp:hide()
   else
      local emacsApp = hs.application.get("Emacs")
      if emacsApp == nil then
         -- ~/.emacs.d/bin/ecexec 是对emacsclient 的包装，你可以直接用emacsclient 来代替
         -- 这个脚本会检查emacs --daemon 是否已启动，未启动则启动之
         -- hs.execute("~/.emacs.d/bin/ecexec --no-wait -c") -- 创建一个窗口
         hs.execute("/usr/local/bin/emacsclient --no-wait -c") -- 创建一个窗口
         -- hs.execute("/usr/local/bin/Emacsclient_starter.pl --no-wait -c") -- 创建一个窗口
         -- 这里可能需要等待一下，以确保窗口创建成功后再继续，否则可能窗口不前置
         emacsApp = hs.application.get("Emacs")
         if emacsApp ~= nil then
            emacsApp:activate() -- 将刚创建的窗口前置
         end
         return
      end

      local wins = emacsApp:allWindows()                                           -- 只在当前space 找，
      if #wins == 0 then
         wins = hs.window.filter.new(false):setAppFilter("Emacs", {}):getWindows() -- 在所有space找，但是window.filter的bug多，不稳定
      end

      if #wins > 0 then
         for _, win in pairs(wins) do
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
         -- hs.execute("/usr/local/bin/Emacsclient_starter.pl --no-wait -c") -- 创建一个窗口
         -- 这里可能需要等待一下，以确保窗口创建成功后再继续，否则可能窗口不前置
         emacsApp = hs.application.get("Emacs")
         if emacsApp ~= nil then
            emacsApp:activate() -- 将刚创建的窗口前置
         end
      end
   end
end

return toggleAPPs
