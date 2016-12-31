hs.hotkey.alertDuration=0
hs.window.animationDuration = 0

hyper = {"cmd", "alt", "ctrl", "shift"}

-- set the keyboard layout to Programmer Dvorak
hs.keycodes.setLayout("Programmer Dvorak")
loggerinfo = hs.logger.new('My Settings', 'info')

-- require 'keyboard-layout-init.lua'
-- require('hyper')
require('caffeine')

-- Lock System
hs.hotkey.bind(hyper, 'L', 'Lock system', function() hs.caffeinate.lockScreen() end)
-- Sleep system
hs.hotkey.bind(hyper, 'S', 'Put system to sleep',function() hs.caffeinate.systemSleep() end)

-- Window Hints
-- hs.hints.style = 'vimperator'
hs.hotkey.bind(hyper, 'H', 'Show window hints', hs.hints.windowHints)

-- Reload config
function reloadConfig(paths)
    doReload = false
    for _,file in pairs(paths) do
        if file:sub(-4) == ".lua" then
            print("A lua file changed, doing reload")
            doReload = true
        end
    end
    if not doReload then
        print("No lua file changed, skipping reload")
        return
    end

    hs.reload()
end

-- Automatically reload Hammerspoon config
configFileWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
configFileWatcher:start()

hs.hotkey.bind(hyper, 'R',  function()
      hs.reload()
end)

-- hs.alert.show("Hammerspoon Loaded")
-- Finally, show a notification that we finished loading the config successfully
hs.notify.new({
      title='Hammerspoon',
        informativeText='Config loaded'
    }):send()



