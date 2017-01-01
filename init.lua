local flux = require "flux"
local utils = require "utils"

-- I always end up losing my mouse pointer, particularly if it's on a monitor full of terminals.
-- This draws a bright red circle around the pointer for a few seconds
mouseCircle = require("mouseCircle"):start()

-- Replace Caffeine.app with 18 lines of Lua :D
caffeine = require("caffeine"):start()

hs.hotkey.alertDuration=0
hs.window.animationDuration = 0

-- Hotkey definitions
local HYPER = {"ctrl", "alt", "cmd", "shift"}
local HYPER_MINUS_SHIFT = {"ctrl", "alt", "cmd"}

-- set the keyboard layout to Programmer Dvorak
hs.keycodes.setLayout("Programmer Dvorak")

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

hyperfns['M'] = function() mouseCircle:show() end

for _hotkey, _fn in pairs(hyperfns) do
    hs.hotkey.bind(HYPER, _hotkey, _fn)
end

-- all APP fullscreen with 'Command+Return'
hs.hotkey.bind('cmd', 'return', function() hs.window.focusedWindow():toggleFullScreen() end)


-- Spotlight-like Google search
chooser = hs.chooser.new(function(args)
    os.execute(string.format("open %s", args.subText))
end)
chooser:queryChangedCallback(function(query)
    query = query:gsub(" ", "+")
    chooser:choices({
        {
           ["text"] = string.format("Search Google for `%s`", query),
            ["subText"] = string.format("https://www.google.com/search?q=%s", utils.urlencode(query)),
        },
        {
            ["text"] = string.format("Search Google Finance for `%s`", query),
            ["subText"] = string.format("https://www.google.com/finance?q=%s", utils.urlencode(query)),
        },
        {
            ["text"] = string.format("Open subreddit `%s`", query),
            ["subText"] = string.format("https://www.reddit.com/r/%s", utils.urlencode(query)),
        },
    })
end)
chooser:bgDark(true)
chooser:rows(3)
lastFocus = nil
-- hs.hotkey.bind({"cmd"}, "space", function()
hs.hotkey.bind(HYPER, "space", function()
    if chooser:isVisible() then
        chooser:hide()
        lastFocus:focus()
    else
        lastFocus = hs.window.focusedWindow()
        chooser:show()
    end
end)

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



