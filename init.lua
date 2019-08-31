-- hs.logger.defaultLogLevel = "info"
-- Logger setup
require('functions')

hs.logger.setGlobalLogLevel('warning')
hs.logger.defaultLogLevel = 'warning'
logger = hs.logger.new('Init')
hs.console.clearConsole()
-- local logger = hs.logger.new("init", "debug")

-- Hotkey definitions
local HYPER = {"ctrl", "alt", "cmd", "shift"}
local HYPER_MINUS_SHIFT = {"ctrl", "alt", "cmd"}

-- Bug-fixed Spoon that handles modal key bindings
hs.loadSpoon('ModalMgr')
-- Modified Spoon that manages modal state and UI.
hs.loadSpoon('MiroWindowsManager')

-- local ModalWrapper = require 'modal-wrapper'

-- windowHighlight = require("windowHighlight").start()
applicationWatcher = require("applicationWatcher").start()

hs.hints.style = 'vimperator'

-- local window = require 'hs.window'
local alert = require 'hs.alert'
local application = require 'hs.application'
local geometry = require 'hs.geometry'
local grid = require 'hs.grid'
local hints = require 'hs.hints'
local hotkey = require 'hs.hotkey'
local layout = require 'hs.layout'
local window = require 'hs.window'
local speech = require 'hs.speech'

-- Misc configs
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.preferencesDarkMode(true)
hs.accessibilityState(true) -- show System Preferences if Accessibility is not enabled for Hammerspoon
hs.dockIcon(false)
hs.menuIcon(false)
hs.consoleOnTop(true)
hs.uploadCrashData(false)

local caffeine = hs.loadSpoon("Caffeine")
caffeine:bindHotkeys({toggle = {HYPER, "C"}})
caffeine:start()


hs.loadSpoon('ControlEscape'):start() -- Load Hammerspoon bits from https://github.com/jasonrudolph/ControlEscape.spoon"

-- ---------------
-- Global Bindings
-- ---------------
hs.hotkey.bind(HYPER, 'L', 'Lock', hs.caffeinate.lockScreen)

local seal = hs.loadSpoon('Seal')

seal:loadPlugins({
    "apps", "useractions", 'tunnelblick', 'network_locations', -- 'snippets',
    'macos', 'hammerspoon'
})

seal:bindHotkeys({toggle = {HYPER, 'space'}})

-- local seal = spoon.Seal
seal.plugins.useractions.actions = {
    ["rebootmac"] = {
        fn = hs.caffeinate.restartSystem,
        -- hotkey = { hyper2, "r" },
        keyword = "restart"
        -- icon = swisscom_logo,
    },
    ["shutdownmac"] = {
        fn = hs.caffeinate.shutdownSystem,
        -- hotkey = { hyper2, "r" },
        keyword = "shutdown"
    },
    ["haltmac"] = {
        fn = hs.caffeinate.shutdownSystem,
        -- hotkey = { hyper2, "r" },
        keyword = "halt"
    },
    ["lockmac"] = {
        fn = hs.caffeinate.lockScreen,
        -- hotkey = { hyper2, "r" },
        keyword = "lock"
    }
}

seal:refreshAllCommands()
seal:start()

-- Disable window size transition animations
hs.window.animationDuration = 0.3
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

local utils = require "utils"
local wifi = require "wifi"

hs.hotkey.alertDuration = 0

hs.application.enableSpotlightForNameSearches(true)
--
-- Turn off Animations.
--
hs.window.animationDuration = 0

-- And now for hotkeys relating to Hyper. First, let's capture all of the functions, then we can just quickly iterate and bind them
hyperfns = {}

-- -- Increase / decrease flux intensity.
-- hyperfns[','] = flux.decreaseLevel
-- hyperfns['.'] = flux.increaseLevel
-- -- Lock System

-- Window Hints
hyperfns['U'] = hs.hints.windowHints

-- Application hotkeys
-- hyperfns['I'] = function() utils.toggle_application("iTerm2") end
-- hyperfns['G'] = function() utils.toggle_application("Google Chrome") end
-- hyperfns['I'] = function() utils.toggleApp("com.googlecode.iterm2") end
-- hyperfns['G'] = function() utils.toggleApp("com.google.Chrome") end
-- hyperfns['W'] = function() utils.toggleApp("com.tencent.xinWeChat") end
-- hyperfns['E'] = function() utils.toggleEmacs() end
hyperfns['F'] = function() utils.toggleFinder() end
hyperfns['M'] = function() utils.toggleMaximized() end
-- hs.hotkey.bind(hyper, "M", toggleMaximized)

-- switch
hyperfns['-'] = wifi.toggleWifi

hs.urlevent.bind("toggleChrome",
                 function(eventName, params) utils.toggleApp("com.google.Chrome") end)
hs.urlevent.bind("toggleSafari",
                 function(eventName, params) utils.toggleApp("com.apple.Safari") end)
hs.urlevent.bind("toggleIterm2",
                 function(eventName, params)
    utils.toggleApp("com.googlecode.iterm2")
end)

-- Key to launch application.
local key2App = {
    h = {'/Applications/iTerm.app', 'English', 2},
    j = {'/Applications/Emacs.app', 'English', 2},
    k = {'/Applications/Google Chrome.app', 'English', 1},
    l = {'/System/Library/CoreServices/Finder.app', 'English', 1},
    c = {'/Applications/Kindle.app', 'English', 2},
    n = {'/Applications/NeteaseMusic.app', 'Chinese', 1},
    w = {'/Applications/WeChat.app', 'Chinese', 1},
    e = {'/Applications/企业微信.app', 'Chinese', 1},
    s = {'/Applications/System Preferences.app', 'English', 1},
    d = {'/Applications/Dash.app', 'English', 1},
    b = {'/Applications/MindNode.app', 'Chinese', 1},
    p = {'/Applications/Preview.app', 'Chinese', 2},
    a = {'/Applications/wechatwebdevtools.app', 'English', 2},
    m = {'/Applications/Sketch.app', 'English', 2}
}

-- Show launch application's keystroke.
local showAppKeystrokeAlertId = ""

local function showAppKeystroke()
    if showAppKeystrokeAlertId == "" then
        -- Show application keystroke if alert id is empty.
        local keystroke = ""
        local keystrokeString = ""
        for key, app in pairs(key2App) do
            keystrokeString = string.format("%-10s%s", key:upper(),
                                            app[1]:match("^.+/(.+)$"):gsub(
                                                ".app", ""))

            if keystroke == "" then
                keystroke = keystrokeString
            else
                keystroke = keystroke .. "\n" .. keystrokeString
            end
        end

        showAppKeystrokeAlertId = hs.alert.show(keystroke,
                                                hs.alert.defaultStyle,
                                                hs.screen.mainScreen(), 10)
    else
        -- Otherwise hide keystroke alert.
        hs.alert.closeSpecific(showAppKeystrokeAlertId)
        showAppKeystrokeAlertId = ""
    end
end

hs.hotkey.bind(HYPER, "z", showAppKeystroke)

-- Maximize window when specify application started.
local maximizeApps = {
    "/Applications/iTerm.app"
    -- "/Applications/Google Chrome.app"
    -- "/System/Library/CoreServices/Finder.app"
}

-- local windowCreateFilter = hs.window.filter.new():setDefaultFilter()
-- windowCreateFilter:subscribe(hs.window.filter.windowCreated,
--                              function(win, ttl, last)
--     for index, value in ipairs(maximizeApps) do
--         if win:application():path() == value then
--             win:maximize()
--             return true
--         end
--     end
-- end)

-- -- Manage application's inputmethod status.
-- local function Chinese()
--     -- hs.keycodes.currentSourceID("im.rime.inputmethod.Squirrel")
--     hs.keycodes.setMethod('Squirrel')
-- end

-- local function English() -- hs.keycodes.currentSourceID("com.apple.keylayout.ABC")
--     hs.keycodes.setLayout('U.S.')
-- end

-- -- Build better app switcher.
-- switcher = hs.window.switcher.new(hs.window.filter.new():setAppFilter('Emacs',
--                                                                       {
--     allowRoles = '*',
--     allowTitles = 1
-- }), -- make emacs window show in switcher list
-- {
--     showTitles = false, -- don't show window title
--     thumbnailSize = 200, -- window thumbnail size
--     showSelectedThumbnail = false, -- don't show bigger thumbnail
--     backgroundColor = {0, 0, 0, 0.8}, -- background color
--     highlightColor = {0.3, 0.3, 0.3, 0.8} -- selected color
-- })

-- hs.hotkey.bind("alt", "tab", function()
--     switcher:next()
--     updateFocusAppInputMethod()
-- end)
-- hs.hotkey.bind("alt-shift", "tab", function()
--     switcher:previous()
--     updateFocusAppInputMethod()
-- end)

-- function updateFocusAppInputMethod()
--     for key, app in pairs(key2App) do
--         local appPath = app[1]
--         local inputmethod = app[2]

--         if window.focusedWindow():application():path() == appPath then
--             if inputmethod == 'English' then
--                 English()
--             else
--                 Chinese()
--             end

--             break
--         end
--     end
-- end

-- local function Chinese() hs.keycodes.setMethod('Squirrel') end
-- local function English() hs.keycodes.setLayout('U.S.') end

-- local appInputMethod = {
--     Hammerspoon             = English,
--     Emacs                   = English,
--     iTerm2                  = English,
--     ['Sublime Text']        = English,
--     Dash                    = English,
--     Safari                  = English,
--     WeChat                  = Chinese,
--     QQ                      = Chinese,
--     AliWangwang             = Chinese
-- }

-- return hs.application.watcher.new(function(appName, eventType, appObject)
--   if (eventType == hs.application.watcher.activated) then
--     if (appName == 'Finder') then
--       -- Bring all Finder windows forward when one gets activated
--       appObject:selectMenuItem({'Window', 'Bring All to Front'})
--     end

--     for app, fn in pairs(appInputMethod) do
--       if app == appName then
--         fn()
--       end
--     end
--   end
-- end)

-- auto change the im for the application callback
-- https://github.com/sjkyspa/env/commit/37545c53186a7be586d7c1878067c247d3b5716c
apps = {
    {name = 'Emacs', im = 'EN'}, {name = 'iTerm2', im = 'EN'},
    {name = 'Google Chrome', im = 'EN'}, {name = 'Wechat', im = 'CN'},
    {name = 'OmniFocus', im = 'CN'}
}

function ims(name, etype, app)
    if (etype == hs.application.watcher.activated) then
        config = filter(function(item)
            return string.match(name:lower(), item.name:lower())
        end, apps)

        if next(config) == nil then
        else
            local current = hs.keycodes.currentMethod()
            if (current == nil and string.match(config[1].im, "CN")) then
                hs.keycodes.setMethod("Squirrel")
            elseif (current ~= nil and string.match(config[1].im, "EN")) then
                hs.keycodes.setLayout("U.S.")
            end
        end
    end
end

-- auto change the im for the application
imWatcher = hs.application.watcher.new(ims)
imWatcher:start()

for _hotkey, _fn in pairs(hyperfns) do hs.hotkey.bind(HYPER, _hotkey, _fn) end

-- Display Hammerspoon logo
hs.loadSpoon('FadeLogo')
spoon.FadeLogo.zoom = false
spoon.FadeLogo.image_size = hs.geometry.size(80, 80)
spoon.FadeLogo.run_time = 1.5
spoon.FadeLogo:start()
