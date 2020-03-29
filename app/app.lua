-- Hotkey definitions
local HYPER = {"ctrl", "alt", "cmd", "shift"}
local HYPER_MINUS_SHIFT = {"ctrl", "alt", "cmd"}

local application = require 'hs.application'
local hotkey = require 'hs.hotkey'
local window = require 'hs.window'
local fs = require 'hs.fs'
local hints = require 'hs.hints'

-- function declaration
local toggleApp
local toggleFinder
-- local updateInputMethod
local appLangWatcher -- 检测输入法

local hyperfns = {}

-- Init.
hs.window.animationDuration = 0 -- don't waste time on animation when resize window

-- Key to launch application.
local key2app = {
    {
        key = "i",
        bundleID = 'com.googlecode.iterm2',
        lang = 'English',
        launchFunc = nil
    }, {key = "e", bundleID = 'org.gnu.Emacs', lang = 'English', 2},
    {key = "g", bundleID = 'com.google.Chrome', lang = 'English'}, {
        key = "f",
        bundleID = 'com.apple.finder',
        lang = 'English',
        launchFunc = toggleFinder
    }, {key = nil, bundleID = 'com.netease.163music', lang = 'Chinese'},
    {key = "w", bundleID = 'com.tencent.xinWeChat', lang = 'Chinese'},
    {key = nil, bundleID = 'com.tencent.WeWorkMac', lang = 'Chinese'},
    {key = "d", bundleID = 'com.kapeli.dashdoc', lang = 'English'},
    {key = nil, bundleID = 'ru.keepcoder.Telegram', lang = 'Chinese'}
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
        for _, app in pairs(key2app) do
            local key = app.key
            local bundleID = app.bundleID
            if key then
                local info = hs.application.infoForBundleID(bundleID)
                if info then
                    local bundleExec = info.CFBundleExecutable
                    logger:d("bundleExec is: " .. (bundleExec or 'nil'))

                    keystrokeString = string.format("%-10s%s", key, bundleExec)
                    logger:d("keystrokeString is:" .. keystrokeString)
                    if keystroke == "" then
                        keystroke = keystrokeString
                    else
                        keystroke = keystroke .. "\n" .. keystrokeString
                    end
                end

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

-- function launchApp(appPath)
--   application.launchOrFocus(appPath)
-- end

-- function keyStroke(modifiers, character)
--     hs.eventtap.event.newKeyEvent(modifiers, string.lower(character), true):post()
--     hs.eventtap.event.newKeyEvent(modifiers, string.lower(character), false):post()
-- end

-- first bind hyperfns
for _, app in pairs(key2app) do
    local key = app.key
    local bundleID = app.bundleID
    if key and bundleID then
        -- local launchFunc = toggleApp(bundleID)
        local launchFunc = app.launchFunc or function()
            toggleApp(bundleID)
        end
        hyperfns[key] = launchFunc
    end
end

-- then launchApp or refocus application.
for key, func in pairs(hyperfns) do
    hotkey.bind(HYPER, key, func)
end

local updateInputMethod = function()
    for _, app in pairs(key2app) do
        local bundleID = app.bundleID
        local lang = app.lang
        if bundleID and lang then
            if window.focusedWindow():application():bundleID() == bundleID then
                local currentInputMethod = hs.keycodes.currentMethod()
                logger:d("currentInputMethod is:" ..
                             (currentInputMethod or 'nil'))

                if lang == "English" then
                    logger:d("bundleID is: " .. bundleID .. ",switch to english")
                    hs.keycodes.setLayout("U.S.")
                else
                    logger:d("bundleID is: " .. bundleID .. ",switch to chinese")
                    hs.keycodes.setMethod("Squirrel")
                end
                break
            end
        end
    end

    -- Handle cursor focus and application's screen manage.
    local function appImWatcher(appName, eventType, appObject)
        -- Move cursor to center of application when application activated.
        -- Then don't need move cursor between screens.
        if (eventType == hs.application.watcher.activated) then
            -- Just adjust cursor postion if app open by user keyboard.
            updateInputMethod()
        end
    end

    -- auto change the im for the application
    imWatcher = hs.application.watcher.new(appImWatcher)
    imWatcher:start()

    -- toggle App
    -- return function
    toggleApp = function(appBundleID)
        -- local win = hs.window.focusedWindow()
        -- local app = win:application()
        local app = hs.application.frontmostApplication()
        if app ~= nil and app:bundleID() == appBundleID then
            app:hide()
            -- win:sendToBack()
        elseif app == nil then
            hs.application.launchOrFocusByBundleID(appBundleID)
        else
            -- app:activate()
            hs.application.launchOrFocusByBundleID(appBundleID)
            app = hs.application.get(appBundleID)
            if app == nil then
                return
            end
            local wins = app:visibleWindows()
            if #wins > 0 then
                for k, win in pairs(wins) do
                    if win:isMinimized() then
                        win:unminimize()
                    end
                end
            else
                hs.application.open(appBundleID)
                app:activate()
            end

            local win = app:mainWindow()
            if win ~= nil then
                win:application():activate(true)
                win:application():unhide()
                win:focus()
            end
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
    if topApp ~= nil and topApp:bundleID() == appBundleID and topWin:role() ~=
        "AXScrollArea" then
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
        elseif (wins[1]:role() == "AXScrollArea" and #wins == 1) then
            isWinExists = false
        end

        -- local wins=app:visibleWindows()
        if not isWinExists then
            wins = hs.window.filter.new(false):setAppFilter("Finder", {})
                       :getWindows()
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
