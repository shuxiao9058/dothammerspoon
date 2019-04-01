-- hs.logger.defaultLogLevel = "info"
local logger = hs.logger.new("init", "debug")

-- Hotkey definitions
local HYPER = {"ctrl", "alt", "cmd", "shift"}
local HYPER_MINUS_SHIFT = {"ctrl", "alt", "cmd"}

local caffeine = hs.loadSpoon("Caffeine")
caffeine:bindHotkeys({toggle = {HYPER, "C"},})
caffeine:start()

local seal = hs.loadSpoon('Seal')

seal:loadPlugins({
    "apps",
    "useractions",
    'tunnelblick',
    'network_locations',
    -- 'snippets',
    'macos',
    'hammerspoon'
})

seal:bindHotkeys({toggle = {HYPER, 'space'}})

-- -- local seal = spoon.Seal
-- seal.plugins.useractions.actions = {
--     ["rebootmac"] = {
--         fn = hs.caffeinate.restartSystem,
--         -- hotkey = { hyper2, "r" },
--         keyword = "restart",
--         -- icon = swisscom_logo,
--     },
--     ["shutdownmac"] = {
--         fn = hs.caffeinate.shutdownSystem,
--         -- hotkey = { hyper2, "r" },
--         keyword = "shutdown",
--     },
--     ["haltmac"] = {
--         fn = hs.caffeinate.shutdownSystem,
--         -- hotkey = { hyper2, "r" },
--         keyword = "halt",
--     },
--     ["lockmac"] = {
--         fn = hs.caffeinate.lockScreen,
--         -- hotkey = { hyper2, "r" },
--         keyword = "lock",
--     },
-- }

seal:refreshAllCommands()
seal:start()

-- Disable window size transition animations
hs.window.animationDuration = 0.0
-- Install:andUse(
--     "MiroWindowsManager",
--     {
--         hotkeys = {
--             up = {HYPER, "k"},
--             right = {HYPER, "l"},
--             down = {HYPER, "j"},
--             left = {HYPER, "h"},
--             fullscreen = {HYPER, "m"}
--         }
--     }
-- )

-- Install:andUse(
--     "TextClipboardHistory",
--     {
--         config = {show_in_menubar = false},
--         hotkeys = {toggle_clipboard = {HYPER, "v"}},
--         start = true
--     }
-- )

local clock = hs.loadSpoon("AClock")
clock.format = "%H:%M:%S"
clock.textColor = {hex = "#00c403"}
clock.textFont = "Menlo Bold"
clock.height = 160
clock.width = 675
clock:init()

-- clock. -- -- FadeLogo is last to ensure that it confirms hammerspoon has fully loaded successfully
-- Install:andUse(
--     "FadeLogo",
--     {
--         config = {fade_in_time = 0, run_time = 0, fade_out_time = 0.4},
--         start = true
--     }
-- )
-- hs.loadSpoon("Caffeine")
-- spoon.Caffeine:bindHotkeys({toggle = {HYPER, "C"},})
-- spoon.Caffeine:start()
-- hs.loadSpoon("Caffeine")
-- spoon.Caffeine:bindHotkeys({toggle = {{"⌥", "⌃", "⇧"}, "c"}})
-- spoon.Caffeine:start()
-- -- -- Turn off Caffeine if screen is locked or system sent to sleep
-- -- init.caffeine_screen_lock_watcher = hs.caffeinate.watcher.new(function(event)
-- --     if spoon.Caffeine and (event == hs.caffeinate.watcher["screensDidLock"] or event == hs.caffeinate.watcher["systemWillSleep"]) then
-- --         if hs.caffeinate.get("displayIdle") then
-- --             spoon.Caffeine.clicked()
-- --             logger.i(hs.caffeinate.watcher[event] .. " and spoon.Caffeine on; turning it off")
-- --         end
-- --     end
-- -- end):start()
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
-- caffeine = require("caffeine"):start()

hs.hotkey.alertDuration = 0

hs.application.enableSpotlightForNameSearches(true)
--
-- Turn off Animations.
--
hs.window.animationDuration = 0

-- set the keyboard layout to Dvorak
-- hs.keycodes.setLayout("Dvorak")

-- And now for hotkeys relating to Hyper. First, let's capture all of the functions, then we can just quickly iterate and bind them
hyperfns = {}

-- Increase / decrease flux intensity.
hyperfns[','] = flux.decreaseLevel
hyperfns['.'] = flux.increaseLevel
-- Lock System

-- hyperfns['L'] = function() hs.caffeinate.lockScreen() end
-- Sleep system
-- hyperfns['S'] = function() hs.caffeinate.systemSleep() end
-- hyperfns['C'] = caffeine.clicked
-- Window Hints
hyperfns['U'] = hs.hints.windowHints

-- Application hotkeys
-- hyperfns['I'] = function() utils.toggle_application("iTerm2") end
-- hyperfns['G'] = function() utils.toggle_application("Google Chrome") end
hyperfns['I'] = function()
    utils.toggleApp("com.googlecode.iterm2")
end
hyperfns['G'] = function()
    utils.toggleApp("com.google.Chrome")
end
-- hyperfns['W'] = function() utils.toggleApp("com.tencent.xinWeChat") end
hyperfns['E'] = function()
    utils.toggleEmacs()
end
hyperfns['F'] = function()
    utils.toggleFinder()
end
-- hyperfns['M'] = function() mouseCircle:show() end
hyperfns['M'] = function()
    utils.toggleMaximized()
end
-- hs.hotkey.bind(hyper, "M", toggleMaximized)

-- switch
hyperfns['-'] = wifi.toggleWifi
-- hyperfns['C'] = caffeine.clicked
-- hs.hotkey.bind(HYPER_MINUS_SHIFT, 'C', caffeine.clicked)

hs.urlevent.bind(
    "toggleChrome",
    function(eventName, params)
        utils.toggleApp("com.google.Chrome")
    end
)
hs.urlevent.bind(
    "toggleSafari",
    function(eventName, params)
        utils.toggleApp("com.apple.Safari")
    end
)
hs.urlevent.bind(
    "toggleIterm2",
    function(eventName, params)
        utils.toggleApp("com.googlecode.iterm2")
    end
)

-- open -g "hammerspoon://toggleEmacs"
hs.urlevent.bind(
    "toggleEmacs",
    function(eventName, params)
        utils.toggleEmacs()
    end
)

-- open -g "hammerspoon://toggleFinder"
hs.urlevent.bind(
    "toggleFinder",
    function(eventName, params)
        utils.toggleFinder()
    end
)

for _hotkey, _fn in pairs(hyperfns) do
    hs.hotkey.bind(HYPER, _hotkey, _fn)
end

-- -- hyper minus shift keybind
-- hs.hotkey.bind(HYPER_MINUS_SHIFT, 'C', caffeine.clicked)

-- -- Finally, show a notification that we finished loading the config successfully
-- hs.notify.new({
--     title = 'Hammerspoon',
--     informativeText = 'Config loaded'
-- }):send()
