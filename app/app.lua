local M = {}

local log = hs.logger.new("app")
log.setLogLevel("debug")

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

local application = require("hs.application")
local hotkey = require("hs.hotkey")
local window = require("hs.window")
local fs = require("hs.fs")
local hints = require("hs.hints")

-- function declaration
local toggleApp
local toggleFinder
local appImWatcher -- 检测输入法
local toggleMaximized -- 最大化窗口
local gitLens -- vscode toggle gitLens

local launchEmacs = function()
	-- local launchEmacsCmd =
	--     [[do shell script "nohup /Applications/Emacs.app/Contents/MacOS/Emacs --dump-file=\"$HOME/.emacs.d/.local/cache/dump/emacs.pdump\" --load=\"$HOME/.emacs.d/pdump-init.el\" > /dev/null 2>&1 &"]]
	-- local launchEmacsCmd =
	--     [[do shell script "nohup open $HOME/workspace/emacs/nextstep/Emacs.app > /dev/null 2>&1 &"]]

	-- local launchEmacsCmd =
	--     [[do shell script "nohup /Applications/MacPorts/EmacsMac.app/Contents/MacOS/Emacs.sh > /dev/null 2>&1 &"]]
	local launchEmacsCmd = [[do shell script "open /Applications/MacPorts/Emacs.app"]]

	-- if isArm64 then
	-- local launchEmacsCmd =
	--     [[do shell script "nohup /Applications/MacPorts/EmacsMac.app/Contents/MacOS/Emacs.sh --dump-file=\"$HOME/.emacs.d/.local/cache/dump/emacs.pdump\" --load=\"$HOME/.emacs.d/pdump-init.el\" > /dev/null 2>&1 &"]]
	-- end

	-- [[do shell script "nohup /usr/local/opt/emacs-mac/Emacs.app/Contents/MacOS/Emacs.sh --dump-file=\"$HOME/.emacs.d/.local/cache/dump/emacs.pdump\" --load=\"$HOME/.emacs.d/pdump-init.el\" > /dev/null 2>&1 &"]]
	hs.osascript.applescript(launchEmacsCmd)
	-- local launchEmacsCmd = "nohup /usr/local/bin/zsh /usr/local/opt/emacs-mac/Emacs.app/Contents/MacOS/Emacs.sh --dump-file=\"$HOME/.emacs.d/.local/cache/dump/emacs.pdump\" --load=\"$HOME/.emacs.d/pdump-init.el\" > /dev/null 2>&1 &"
	-- local launchEmacsCmd =
	--     "/usr/local/bin/zsh /usr/local/opt/emacs-mac/Emacs.app/Contents/MacOS/Emacs.sh --dump-file=\"$HOME/.emacs.d/.local/cache/dump/emacs.pdump\" --load=\"$HOME/.emacs.d/pdump-init.el\" > /dev/null 2>&1 &"
	-- hs.execute(launchEmacsCmd)
end

local hyperfns = {}

-- Init.
hs.window.animationDuration = 0 -- don't waste time on animation when resize window

-- Key to launch application.
local appSettings = {
	-- {
	--     key = "i",
	--     bundleID = 'com.googlecode.iterm2',
	--     lang = 'English',
	--     launchFunc = nil,
	--     maximize = true
	-- },
	{
		key = nil,
		bundleID = "net.kovidgoyal.kitty",
		lang = "English",
		launchFunc = nil,
		maximize = true,
	},
	{
		key = "t",
		bundleID = "com.github.wez.wezterm",
		lang = "English",
		launchFunc = nil,
		maximize = true,
	}, -- {
	--  key = 'e',
	--  bundleID = 'com.github.wez.wezterm',
	--  -- bundleID = 'org.gnu.Emacs',
	--  lang = 'English',
	--  -- launchFunc = launchEmacs,
	--  maximize = false
	-- }
	-- ,
	{
		key = "e",
		-- bundleID = 'com.github.wez.wezterm',
		bundleID = "org.gnu.Emacs",
		lang = "English",
		-- launchFunc = launchEmacs,
		maximize = false,
		spaceId = 2,
	},
	--  {
	--     key = "g",
	--     bundleID = 'com.google.Chrome',
	--     lang = 'English'
	-- },
	{
		key = "f",
		bundleID = "org.mozilla.firefox",
		lang = "English",
		launchFunc = nil,
		maximize = true,
	},
	{
		key = "v",
		bundleID = "com.microsoft.VSCode",
		lang = "English",
		launchFunc = nil,
		maximize = true,
	},
	{
		key = "s",
		bundleID = "com.stack-beta.io",
		lang = "English",
		launchFunc = nil,
		maximize = true,
	}, --  {
	--     key = nil,
	--     bundleID = 'com.netease.163music',
	--     lang = 'Chinese'
	-- },
	{
		-- key = "w",
		bundleID = "com.tencent.xinWeChat",
		lang = "Chinese",
	},
	{
		key = nil,
		bundleID = "com.tencent.WeWorkMac",
		lang = "Chinese",
	},
	{
		key = "d",
		bundleID = "com.kapeli.dashdoc",
		lang = "English",
	},
	{
		key = nil,
		bundleID = "ru.keepcoder.Telegram",
		lang = "Chinese",
		maximize = true,
	},
	{
		key = nil,
		bundleID = "com.apple.Safari",
		lang = "English",
		maximize = true,
	},
	{
		key = nil,
		bundleID = "com.devon-technologies.think3",
		lang = "Chinese",
		-- maximize = true
	},
	{
		key = nil,
		bundleID = "com.sublimetext.3",
		lang = "English",
		maximize = true,
	},
}

-- Show launch application's keystroke.
local showAppKeystrokeAlertId = ""

-- Show launch application's keystroke.
local showAppKeystrokeAlertId = ""
local function showAppKeystroke()
	if showAppKeystrokeAlertId == "" then
		-- Show application keystroke if alert id is empty.
		local keystroke = ""
		local keystrokeString = ""
		for _, app in pairs(appSettings) do
			local key = app.key
			local bundleID = app.bundleID
			if key then
				local appName = hs.application.nameForBundleID(bundleID)
				if appName then
					logger:d("appName is: " .. (appName or "nil"))

					keystrokeString = string.format("%-10s%s", key, appName)
					logger:d("keystrokeString is:" .. keystrokeString)
					if keystroke == "" then
						keystroke = keystrokeString
					else
						keystroke = keystroke .. "\n" .. keystrokeString
					end
				end
			end
		end

		showAppKeystrokeAlertId = hs.alert.show(keystroke, hs.alert.defaultStyle, hs.screen.mainScreen(), 10)
	else
		-- Otherwise hide keystroke alert.
		hs.alert.closeSpecific(showAppKeystrokeAlertId)
		showAppKeystrokeAlertId = ""
	end
end

-- first bind hyperfns
for _, app in pairs(appSettings) do
	local key = app.key
	local bundleID = app.bundleID
	if key and bundleID then
		-- local launchFunc = app.launchFunc or function()
		--     toggleApp(app)
		-- end
		hyperfns[key] = function()
			toggleApp(app)
		end
	end
end

function M:updateInputMethod()
	local focusedWindow = window.focusedWindow()
	if not focusedWindow then
		return
	end

	local currentApplication = focusedWindow:application()
	if not currentApplication then
		return
	end

	local currentBundleID = currentApplication:bundleID()
	if not currentBundleID then
		return
	end

	for _, app in pairs(appSettings) do
		local bundleID = app.bundleID
		local lang = app.lang
		if bundleID and lang then
			if currentBundleID == bundleID then
				local currentInputMethod = hs.keycodes.currentMethod()
				local currentLayout = hs.keycodes.currentLayout()
				-- logger:d('currentLayout: ' .. (currentLayout or 'nil') ..
				--              ',currentInputMethod: ' ..
				--              (currentInputMethod or 'nil'))

				if lang == "English" and (currentLayout ~= "U.S." or currentInputMethod) then
					logger:d("bundleID is: " .. bundleID .. ",switch to english")
					hs.keycodes.setLayout("U.S.")
				elseif lang == "Chinese" and currentInputMethod ~= "Squirrel" then
					-- logger:d('bundleID is: ' .. bundleID .. ',switch to chinese')
					hs.keycodes.setMethod("Squirrel")
				end

				break
			end
		end
	end
end

-- Window cache for window maximize toggler
local frameCache = {}

function M:toggleMaximized(win, startup, force)
	local app
	if not win then
		app = hs.application.frontmostApplication()
		win = app:mainWindow()
	else
		app = win:application()
	end

	if not app then
		return
	end

	local appName = app:name()

	if not win then
		return
	end

	if not win:isMaximizable() then
		log.ef("win can not maximaze, appName: %s", appName)
		return
	end

	local currentApplication = win:application()
	if not currentApplication then
		return false
	end
	local appName = currentApplication:name()
	local currentBundleID = currentApplication:bundleID()
	if not startup then
		-- if win:isMinimized() then
		-- 	win = win:unminimize()
		-- end

		-- win:maximize()
		if frameCache[win:id()] then
			if not force then
				win:setFrame(frameCache[win:id()])
				frameCache[win:id()] = nil
			else
				log.df("force maximize window, appName: %s", appName)
			end
		else
			frameCache[win:id()] = win:frame()
		end
		return
	end

	if startup then
		for _, app in ipairs(appSettings) do
			if currentBundleID == app.bundleID and app.maximize then
				-- logger:d('create filter')
				if appName == "Emacs" then
					-- hs.eventtap.keyStroke({
					--     'alt'
					-- }, 'F10')
					-- local spaces = hs.spaces.allSpaces()
					-- hs.spaces.moveWindowToSpace()
					-- hs.spaces.gotoSpace(spaceID)
				else
					win:maximize()
				end
				return true
			end
		end
	end
end

-- Maximize window when specify application started.
local windowCreateFilter = hs.window.filter.new():setDefaultFilter()
windowCreateFilter:subscribe(hs.window.filter.windowCreated, function(win, ttl, last)
	-- if not win then return false end
	M:toggleMaximized(win, true, nil)
end)

-- toggle App
toggleApp = function(app)
	local appBundleID = app.bundleID
	local currentApp = hs.application.frontmostApplication()
	local launchFunc = app.launchFunc

	if launchFunc == nil then
		launchFunc = function()
			hs.application.launchOrFocusByBundleID(appBundleID)
		end
	end

	-- 如果指定程序在最前面，则 hide
	if currentApp ~= nil and currentApp:bundleID() == appBundleID then
		currentApp:hide()
	else
		currentApp = hs.application.get(appBundleID)
		-- local apps = hs.application.applicationsForBundleID(appBundleID)
		-- if apps ~= nil then
		--     currentApp = apps[1]
		--     for _, app in ipairs(apps) do
		--         logger:d("len(apps) = ", #apps, ", appId: ", app:pid())
		--     end
		-- end

		-- logger:d('currentApp is: ' .. tostring(currentApp))
		if currentApp == nil then
			launchFunc()
			currentApp = hs.application.get(appBundleID)
		end

		if currentApp == nil then
			return
		end

		local wins = currentApp:visibleWindows()
		if #wins > 0 then
			for k, win in pairs(wins) do
				if win:isMinimized() then
					win:unminimize()
				end
			end
		else
			currentApp:activate()
		end

		local win = currentApp:mainWindow()
		if win ~= nil then
			win:application():activate(true)
			win:application():unhide()
			win:focus()
		end
	end
end

toggleFinder = function()
	local appBundleID = "com.apple.finder"
	local topWin = hs.window.focusedWindow()
	if topWin == nil then
		return
	end
	local topApp = topWin:application()
	-- local topApp =hs.application.frontmostApplication()

	-- The desktop belongs to Finder.app: when Finder is the active application, you can focus the desktop by cycling through windows via cmd-`
	-- The desktop window has no id, a role of AXScrollArea and no subrole
	-- and #topApp:visibleWindows()>0
	if topApp ~= nil and topApp:bundleID() == appBundleID and topWin:role() ~= "AXScrollArea" then
		topApp:hide()
	else
		finderApp = hs.application.get(appBundleID)
		if finderApp == nil then
			hs.application.launchOrFocusByBundleID(appBundleID)
			return
		end
		local wins = finderApp:allWindows()
		local isWinExists = true
		if #wins == 0 then
			isWinExists = false
		elseif wins[1]:role() == "AXScrollArea" and #wins == 1 then
			isWinExists = false
		end

		-- local wins=app:visibleWindows()
		if not isWinExists then
			wins = hs.window.filter.new(false):setAppFilter("Finder", {}):getWindows()
		end

		if #wins == 0 then
			hs.application.launchOrFocusByBundleID(appBundleID)
			for _, win in pairs(wins) do
				if win:isMinimized() then
					win:unminimize()
				end

				win:application():activate(true)
				win:application():unhide()
				win:focus()
			end
		else
			for _, win in pairs(wins) do
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

-- launchEmacs = function()
--     hs.execute("/Applications/Emacs.app/Contents/MacOS/Emacs.sh --dump-file=\"/Users/jiya/.emacs.d/emacs.pdmp\" --script \"/Users/jiya/.emacs.d/pdump-init.el\"", nil)
--     -- hs.execute(
--     --     "/usr/local/bin/zsh /Applications/Emacs.app/Contents/MacOS/Emacs.sh")
-- end

-- Handle cursor focus and application's screen manage.
M.appImWatcher = function(appName, eventType, appObject)
	-- Move cursor to center of application when application activated.
	-- Then don't need move cursor between screens.
	if eventType == hs.application.watcher.activated then
		-- Just adjust cursor postion if app open by user keyboard.
		M:updateInputMethod()
	end
end

function M:start()
	hs.urlevent.bind("toggleEmacs", function(eventName, params)
		local emacsAPPCfg = {
			key = "e",
			bundleID = "org.gnu.Emacs",
			lang = "English",
			launchFunc = launchEmacs,
			maximize = false,
		}

		toggleApp(emacsAPPCfg)
	end)

	-- -- maximize window
	-- hyperfns['M'] = function() toggleMaximized() end

	--
	-- hyperfns['g'] = function() gitLens() end

	-- Window Hints
	hyperfns["h"] = hs.hints.windowHints
	hyperfns["Z"] = showAppKeystroke

	-- then launchApp or refocus application.
	for key, func in pairs(hyperfns) do
		hotkey.bind(HYPER, key, func)
	end

	-- auto change the im for the application
	hs.application.watcher.new(M.appImWatcher):start()
end

return M
