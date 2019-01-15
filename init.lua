-- http://www.hammerspoon.org/go/#winresize
-- hammerspoon 不能实现的区分左右cmd shift等，也不能实别Fn键，
-- 这些可以与karabiner 通过Hammerspoon with URLs实现通信,即，
-- 通过karabiner 来按键，而 hammerspoon来实现相应的事件
-- 如
-- 在命令行下调用open -g "hammerspoon://someAlert?someParam=hello"
-- hs.urlevent.bind("someAlert", function(eventName, params)
--                     if params["someParam"] then
--                        hs.alert.show(params["someParam"])
--                     end
-- end)
--
-- Load the information from the Alfred configuration.
--
require("alfred")

--
-- Place all your functions and configurations here. Running "hs:upgrade" will just
-- over right the alfred.lua file. DO NOT Change the alfred.lua file!
--

local flux = require "flux"
local utils = require "utils"
local wifi = require "wifi"

-- I always end up losing my mouse pointer, particularly if it's on a monitor full of terminals.
-- This draws a bright red circle around the pointer for a few seconds
mouseCircle = require("mouseCircle"):start()

-- Replace Caffeine.app with 18 lines of Lua :D
caffeine = require("caffeine"):start()

hs.hotkey.alertDuration = 0

hs.application.enableSpotlightForNameSearches(true)
--
-- Turn off Animations.
--
hs.window.animationDuration = 0

-- Hotkey definitions
local HYPER = {"ctrl", "alt", "cmd", "shift"}
local HYPER_MINUS_SHIFT = {"ctrl", "alt", "cmd"}

-- set the keyboard layout to Dvorak
-- hs.keycodes.setLayout("Dvorak")

-- And now for hotkeys relating to Hyper. First, let's capture all of the functions, then we can just quickly iterate and bind them
hyperfns = {}

-- Increase / decrease flux intensity.
hyperfns[','] = flux.decreaseLevel
hyperfns['.'] = flux.increaseLevel
-- Lock System
hyperfns['L'] = function() hs.caffeinate.lockScreen() end
-- Sleep system
hyperfns['S'] = function() hs.caffeinate.systemSleep() end
-- hyperfns['C'] = caffeine.clicked
-- Window Hints
hyperfns['U'] = hs.hints.windowHints

-- Application hotkeys
-- hyperfns['I'] = function() utils.toggle_application("iTerm2") end
-- hyperfns['G'] = function() utils.toggle_application("Google Chrome") end
hyperfns['I'] = function() utils.toggleApp("com.googlecode.iterm2") end
hyperfns['G'] = function() utils.toggleApp("com.google.Chrome") end
-- hyperfns['W'] = function() utils.toggleApp("com.tencent.xinWeChat") end
-- hyperfns['E'] = function() utils.toggleEmacs() end
hyperfns['F'] = function() utils.toggleFinder() end
-- hyperfns['M'] = function() mouseCircle:show() end
hyperfns['M'] = function() utils.toggleMaximized() end
-- hs.hotkey.bind(hyper, "M", toggleMaximized)

-- switch
hyperfns['-'] = wifi.toggleWifi
hyperfns['C'] = caffeine.clicked
-- hs.hotkey.bind(HYPER_MINUS_SHIFT, 'C', caffeine.clicked)

hs.urlevent.bind(
    "toggleChrome",
    function(eventName, params) utils.toggleApp("com.google.Chrome") end
)
hs.urlevent.bind(
    "toggleSafari",
    function(eventName, params) utils.toggleApp("com.apple.Safari") end
)
hs.urlevent.bind(
    "toggleIterm2",
    function(eventName, params) utils.toggleApp("com.googlecode.iterm2") end
)
-- open -g "hammerspoon://toggleEmacs"
hs.urlevent.bind(
    "toggleEmacs",
    function(eventName, params) utils.toggleEmacs() end
)
-- open -g "hammerspoon://toggleFinder"
hs.urlevent.bind(
    "toggleFinder",
    function(eventName, params) utils.toggleFinder() end
)

for _hotkey, _fn in pairs(hyperfns) do hs.hotkey.bind(HYPER, _hotkey, _fn) end

-- -- hyper minus shift keybind
-- hs.hotkey.bind(HYPER_MINUS_SHIFT, 'C', caffeine.clicked)

-- all APP fullscreen with 'Command+Return'
-- hs.hotkey.bind('cmd', 'return', function() hs.window.focusedWindow():toggleFullScreen() end)

-- Spotlight-like Google search
chooser = hs.chooser.new(function(args) os.execute(string.format("open %s", args.subText)) end)
chooser:queryChangedCallback(function(query)
    query = query:gsub(" ", "+")
    chooser:choices({
        {
            ["text"] = string.format("Search Google for `%s`", query),
            ["subText"] = string.format(
                "https://www.google.com/search?q=%s",
                utils.urlencode(query)
            ),
        },
        -- {
        --     ["text"] = string.format("Search Google Finance for `%s`", query),
        --     ["subText"] = string.format("https://www.google.com/finance?q=%s", utils.urlencode(query)),
        -- },
        -- {
        --     ["text"] = string.format("Open subreddit `%s`", query),
        --     ["subText"] = string.format("https://www.reddit.com/r/%s", utils.urlencode(query)),
        -- },
    })
end)

chooser:bgDark(true)
chooser:rows(1)
lastFocus = nil
-- hs.hotkey.bind({"cmd"}, "space", function()
hs.hotkey.bind(
    HYPER,
    "space",
    function()
        if chooser:isVisible() then
            chooser:hide()
            lastFocus:focus()
        else
            lastFocus = hs.window.focusedWindow()
            chooser:show()
        end
    end
)

-- -- Keyboard Settting
-- ---- general setting
-- ------- caps to ctrl and esc
-- sendESC = true
-- maxFlag = 0
-- controlKeyTimer =
-- hs.timer.delayed.new(0.15, function() sendESC = false end)

-- controlHandler = function(evt)
--     local newMods = evt:getFlags()
--     local count = 0
--     for _ in pairs(newMods) do
--         count = count + 1
--     end
--     if maxFlag < count then maxFlag = count end
--     if  1 == maxFlag and newMods["ctrl"] then
--         sendESC = true
--         controlKeyTimer:start()
--         return true
--     end
--     if 0 == count then
--         if 1 == maxFlag and sendESC then
--             hs.eventtap.keyStroke({}, "ESCAPE", 5)
--             sendESC = false
--             maxFlag = 0
--             controlKeyTimer:stop()
--             return true
--         end
--         sendESC = false
--         maxFlag = 0
--     end
--     return false
-- end
-- controlTap = hs.eventtap.new(
--     {hs.eventtap.event.types.flagsChanged}, controlHandler)
-- controlTap:start()
-- -- end caps to ctrl and esc

-- -- Reload config
-- function reloadConfig(paths)
--     doReload = false
--     for _,file in pairs(paths) do
--         if file:sub(-4) == ".lua" then
--             print("A lua file changed, doing reload")
--             doReload = true
--         end
--     end
--     if not doReload then
--         print("No lua file changed, skipping reload")
--         return
--     end

--     hs.reload()
-- end

-- Automatically reload Hammerspoon config
-- configFileWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig)
-- configFileWatcher:start()

-- hs.hotkey.bind(HYPER, 'R',  function()
--       hs.reload()
-- end)

-- hs.alert.show("Hammerspoon Loaded")
-- Finally, show a notification that we finished loading the config successfully
hs.notify.new({
    title = 'Hammerspoon',
    informativeText = 'Config loaded'
}):send()
