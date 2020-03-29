-- hs.logger.defaultLogLevel = "info"
-- Logger setup
require('functions')



hs.logger.setGlobalLogLevel('verbose')
-- hs.logger.defaultLogLevel = 'warning'
logger = hs.logger.new('Init', 'verbose')
hs.console.clearConsole()
-- local logger = hs.logger.new("init", "debug")

require 'app.app'


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

-- caffeine default on
caffeine:setDisplay(true)

hs.loadSpoon('ControlEscape'):start() -- Load Hammerspoon bits from https://github.com/jasonrudolph/ControlEscape.spoon"

-- ---------------
-- Global Bindings
-- ---------------


-- local seal = hs.loadSpoon('Seal')

-- seal:loadPlugins({
--     "apps", "useractions", 'tunnelblick', 'network_locations', -- 'snippets',
--     'macos', 'hammerspoon'
-- })

-- -- seal:bindHotkeys({toggle = {HYPER, 'space'}})

-- -- local seal = spoon.Seal
-- seal.plugins.useractions.actions = {
--     ["rebootmac"] = {
--         fn = hs.caffeinate.restartSystem,
--         -- hotkey = { hyper2, "r" },
--         keyword = "restart"
--         -- icon = swisscom_logo,
--     },
--     ["shutdownmac"] = {
--         fn = hs.caffeinate.shutdownSystem,
--         -- hotkey = { hyper2, "r" },
--         keyword = "shutdown"
--     },
--     ["haltmac"] = {
--         fn = hs.caffeinate.shutdownSystem,
--         -- hotkey = { hyper2, "r" },
--         keyword = "halt"
--     },
--     ["lockmac"] = {
--         fn = hs.caffeinate.lockScreen,
--         -- hotkey = { hyper2, "r" },
--         keyword = "lock"
--     }
-- }

-- seal:refreshAllCommands()
-- seal:start()

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
local hyperfns = {}

hyperfns['L'] = hs.caffeinate.lockScreen

-- -- Increase / decrease flux intensity.
-- hyperfns[','] = flux.decreaseLevel
-- hyperfns['.'] = flux.increaseLevel
-- -- Lock System

-- Window Hints
hyperfns['U'] = hs.hints.windowHints

-- -- Application hotkeys
-- hyperfns['G'] = function()
--     utils:toggle_application("Google Chrome")
-- end
-- hyperfns['I'] = function()
--     utils:toggleApp("com.googlecode.iterm2")
-- end
-- hyperfns['G'] = function()
--     utils:toggleApp("com.google.Chrome")
-- end
-- hyperfns['W'] = function()
--     utils:toggleApp("com.tencent.xinWeChat")
-- end
-- hyperfns['E'] = function()
--     utils:toggleApp("org.gnu.Emacs")
-- end

-- hyperfns['F'] = function()
--     -- utils:toggleApp("com.apple.finder")
--     utils:toggleFinder()
-- end
hyperfns['M'] = function()
    utils:toggleMaximized()
end
-- hs.hotkey.bind(hyper, "M", toggleMaximized)

-- switch
hyperfns['-'] = wifi.toggleWifi

hyperfns['z'] = showAppKeystroke

for _hotkey, _fn in pairs(hyperfns) do
    hs.hotkey.bind(HYPER, _hotkey, _fn)
end

-- Maximize window when specify application started.
local maximizeApps = {
    "/Applications/iTerm.app", "/usr/local/opt/emacs-mac/Emacs.app"
    -- "/Applications/Google Chrome.app"
    -- "/System/Library/CoreServices/Finder.app"
}

-- local windowCreateFilter = hs.window.filter.new():setDefaultFilter()
-- windowCreateFilter:subscribe(hs.window.filter.windowCreated,
--                              function(win, ttl, last)
--     for index, value in ipairs(maximizeApps) doJ∆
--         if win:application():path() == value then
--             win:maximize()
--             return true
--         end
--     end
-- end)

-- Display Hammerspoon logo
hs.loadSpoon('FadeLogo')
spoon.FadeLogo.zoom = false
spoon.FadeLogo.image_size = hs.geometry.size(80, 80)
spoon.FadeLogo.run_time = 1.5
spoon.FadeLogo:start()
