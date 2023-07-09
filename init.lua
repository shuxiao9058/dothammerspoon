-- hs.logger.defaultLogLevel = "info"
-- Logger setup
require("functions")

hs.logger.setGlobalLogLevel("debug")
-- hs.logger.defaultLogLevel = 'warning'
logger = hs.logger.new("Init", "debug")
hs.console.clearConsole()

package.path = package.path .. ";" .. "/Users/jiya/.luarocks/share/lua/5.3/?.lua"
package.cpath = package.cpath .. ";" .. "/Users/jiya/.config/yarn/bin/lib/lua/5.1/?.so"

-- local clocking = require 'clocking'
-- clocking.init()

function isArm64Func()
	local out = hs.execute("uname -m")
	if out then
		out = string.gsub(out, "^%s*(.-)%s*$", "%1")
		return out == "arm64"
	end

	return false
end

isArm64 = isArm64Func()

logger:d("isArm64 is:" .. tostring(isArm64 or "false"))

require("app.app"):start()

-- Hotkey definitions
local HYPER = {
	"ctrl",
	"alt",
	"cmd",
	"shift",
}
local HYPER_MINUS_SHIFT = {
	"ctrl",
	"alt",
	"cmd",
}

-- Bug-fixed Spoon that handles modal key bindings
hs.loadSpoon("ModalMgr")
-- Modified Spoon that manages modal state and UI.
hs.loadSpoon("MiroWindowsManager")

keyUpDown = function(modifiers, key)
	-- Un-comment & reload config to log each keystroke that we're triggering
	-- self.logger:d('Sending keystroke:', hs.inspect(modifiers), key)
	hs.eventtap.keyStroke(modifiers, key, 0)
end

-- Subscribe to the necessary events on the given window filter such that the
-- given hotkey is enabled for windows that match the window filter and disabled
-- for windows that don't match the window filter.
--
-- windowFilter - An hs.window.filter object describing the windows for which
--                the hotkey should be enabled.
-- hotkey       - The hs.hotkey object to enable/disable.
--
-- Returns nothing.
enableHotkeyForWindowsMatchingFilter = function(windowFilter, hotkey)
	windowFilter:subscribe(hs.window.filter.windowFocused, function()
		hotkey:enable()
	end)

	windowFilter:subscribe(hs.window.filter.windowUnfocused, function()
		hotkey:disable()
	end)
end

-- local zmc = hs.loadSpoon('zmc')

-- local ModalWrapper = require 'modal-wrapper'

-- windowHighlight = require("windowHighlight").start()
require("applicationWatcher"):start()

hs.hints.style = "vimperator"

-- local window = require 'hs.window'
local alert = require("hs.alert")
local application = require("hs.application")
local geometry = require("hs.geometry")
local grid = require("hs.grid")
local hints = require("hs.hints")
local hotkey = require("hs.hotkey")
local layout = require("hs.layout")
local window = require("hs.window")
local speech = require("hs.speech")

-- Misc configs
hs.autoLaunch(true)
hs.automaticallyCheckForUpdates(true)
hs.preferencesDarkMode(true)
hs.accessibilityState(true) -- show System Preferences if Accessibility is not enabled for Hammerspoon
hs.dockIcon(false)
hs.menuIcon(true)
hs.consoleOnTop(true)
hs.uploadCrashData(false)

-- local caffeine = hs.loadSpoon("Caffeine")
-- caffeine:bindHotkeys({toggle = {HYPER, "C"}})
-- caffeine:start()

-- -- caffeine default on
-- caffeine:clicked()

-- hs.loadSpoon('ControlEscape'):start() -- Load Hammerspoon bits from https://github.com/jasonrudolph/ControlEscape.spoon"

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

-- Power JSON Editor cmd-t work as new tab
newTabWithPowerJSONEditor = hs.hotkey.new("cmd", "t", function()
	hs.application.launchOrFocusByBundleID("com.xujiwei.powerjsoneditor")
	-- newTabWithPowerJSONEditor:disable() -- does not work without this, even though it should
	-- hs.eventtap.keyStroke({"cmd"}, "t")
	local topWindow = hs.window:frontmostWindow()
	if topWindow ~= nil then
		local topApp = topWindow:application()
		if topApp ~= nil then
			local bunderID = topApp:bundleID()
			if bunderID == "com.xujiwei.powerjsoneditor" then
				local newTabAppleScriptFile = hs.configdir .. "/applescript/powerjsoneditor_newtab.applescript"
				hs.osascript.applescriptFromFile(newTabAppleScriptFile)
			end
		end
	end
end)

hs.window.filter
	.new("Power JSON Editor")
	:subscribe(hs.window.filter.windowFocused, function()
		newTabWithPowerJSONEditor:enable()
	end)
	:subscribe(hs.window.filter.windowUnfocused, function()
		newTabWithPowerJSONEditor:disable()
	end)

local clock = hs.loadSpoon("AClock")
clock.format = "%H:%M:%S"
clock.textColor = { hex = "#00c403" }
clock.textFont = "Menlo Bold"
clock.height = 160
clock.width = 675
clock:init()

-- hs.inspect(spoon.Clocking)
hs.loadSpoon("Clocking"):start()

hs.loadSpoon("TimeMachineProgress"):start()

local utils = require("utils")
local wifi = require("wifi")

hs.hotkey.alertDuration = 0

hs.application.enableSpotlightForNameSearches(true)
--
-- Turn off Animations.
--
hs.window.animationDuration = 0

-- And now for hotkeys relating to Hyper. First, let's capture all of the functions, then we can just quickly iterate and bind them
local hyperfns = {}

hyperfns["L"] = hs.caffeinate.lockScreen

hyperfns["R"] = hs.reload

-- -- Increase / decrease flux intensity.
-- hyperfns[','] = flux.decreaseLevel
-- hyperfns['.'] = flux.increaseLevel
-- -- Lock System

-- switch
hyperfns["-"] = wifi.toggleWifi

-- hyperfns['t'] = require("blj.blj")

for _hotkey, _fn in pairs(hyperfns) do
	hs.hotkey.bind(HYPER, _hotkey, _fn)
end

-- Display Hammerspoon logo
hs.loadSpoon("FadeLogo")
spoon.FadeLogo.zoom = false
spoon.FadeLogo.image_size = hs.geometry.size(80, 80)
spoon.FadeLogo.run_time = 1.5
spoon.FadeLogo:start()

-- For debug
local function showKeyPress(tapEvent)
	local charactor = hs.keycodes.map[tapEvent:getKeyCode()]
	hs.alert.show(charactor, 1.5)
end

local keyTap = hs.eventtap.new({
	hs.eventtap.event.types.keyDown,
}, showKeyPress)

k = hs.hotkey.modal.new({
	"cmd",
	"shift",
	"ctrl",
}, "P")
function k:entered()
	hs.alert.show("Enabling Keypress Show Mode", 1.5)
	keyTap:start()
end

function k:exited()
	hs.alert.show("Disabling Keypress Show Mode", 1.5)
end

k:bind({ "cmd", "shift", "ctrl" }, "P", function()
	keyTap:stop()
	k:exit()
end)

local crypto = require("work/crypto")
crypto:start()

local mail = require("work/mail")
mail:start()

-- local convert_trans = require('my/convert_trans')
-- convert_trans:start()

-- debug only
-- log all window

-- local allWindows = hs.window.allWindows()
-- if allWindows then
--     for _, w in ipairs(allWindows) do
--         -- logger:d('title: ', w:title())
--         local app = w:application()
--         if app then
--             local bundleID = app:bundleID()
--             logger:d('title:', w:title(), ', bundleID:', bundleID, ', app name:', app:name())
--         end
--     end
-- end

-- -- debug
-- local osStr = hs.host.operatingSystemVersionString()
-- logger:d("os str: " .. (osStr or 'nil'))

-- local hostNames = hs.host.names()
-- logger:d("hostNames: " .. hs.json.encode(hostNames, true))

require("window"):start()
