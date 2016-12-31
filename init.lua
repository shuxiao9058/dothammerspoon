local flux = require "flux"
local utils = require "utils"

-- Replace Caffeine.app with 18 lines of Lua :D
caffeine = require("caffeine"):start()

hs.hotkey.alertDuration=0
hs.window.animationDuration = 0

-- set the keyboard layout to Programmer Dvorak
hs.keycodes.setLayout("Programmer Dvorak")

-- Hotkey definitions
local HYPER = {"ctrl", "alt", "cmd", "shift"}
local HYPER_MINUS_SHIFT = {"ctrl", "alt", "cmd"}

-- And now for hotkeys relating to Hyper. First, let's capture all of the functions, then we can just quickly iterate and bind them
hyperfns = {}

-- Increase / decrease flux intensity.
hyperfns[','] = flux.decreaseLevel
hyperfns['.'] = flux.increaseLevel
-- Lock System
hyperfns['L'] = function() hs.caffeinate.lockScreen() end 
-- Sleep system
hyperfns['S'] = function() hs.caffeinate.systemSleep() end 
hyperfns['C'] = caffeine.clicked
-- Window Hints
hyperfns['H'] = hs.hints.windowHints

-- Application hotkeys
hyperfns['I'] = function() utils.toggle_application("iTerm2") end
hyperfns['G'] = function() utils.toggle_application("Google Chrome") end

for _hotkey, _fn in pairs(hyperfns) do
    hs.hotkey.bind(HYPER, _hotkey, _fn)
end

-- all APP fullscreen with 'Command+Return'
hs.hotkey.bind('cmd', 'return', function() hs.window.focusedWindow():toggleFullScreen() end)

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

-- hs.hotkey.bind(HYPER, 'R',  function()
--       hs.reload()
-- end)

-- hs.alert.show("Hammerspoon Loaded")
-- Finally, show a notification that we finished loading the config successfully
hs.notify.new({
      title='Hammerspoon',
        informativeText='Config loaded'
    }):send()



