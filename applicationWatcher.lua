-- Application Watcher
-- listen application's events, such as keystroke and application starts

local json_encode = hs.json.encode
local json_decode = hs.json.decode

local M = {}
M.logger = hs.logger.new('applicationWatcher.lua')

local yabai = require('window')

local log = M.logger
log.setLogLevel('debug')

local HYPER = {
    'ctrl', 'alt', 'cmd', 'shift'
}
local HYPER_MINUS_SHIFT = {
    'ctrl', 'alt', 'cmd'
}

local emacsCtrlSpaceSwitchIM = hs.hotkey.new('ctrl', 'space', function()
    local topWindow = hs.window:frontmostWindow()
    if topWindow ~= nil then
        local topApp = topWindow:application()
        if topApp ~= nil then
            local bunderID = topApp:bundleID()
            logger:d('bunderID is: ', bunderID)
            if bunderID == 'org.gnu.Emacs' then
                hs.eventtap.keyStroke({
                    'ctrl'
                }, '\\')
            end
        end
    end
end)

local vscodeGitLens = hs.hotkey.new(HYPER_MINUS_SHIFT, "g", function()
    local win = hs.window.focusedWindow()
    if (win == nil) or (win:id() == nil) then return end

    local app = win:application()
    local appBundleID = app:bundleID()

    if appBundleID == 'com.microsoft.VSCode' then
        hs.eventtap.keyStroke({
            'ctrl', 'shift'
        }, 'g', app)
    end
end)

local moveAppToSpace = function(app, destSpaceLabel)
    if not app then
        log.e("app is nil")
        return
    end

    if not destSpaceLabel then
        log.e("destSpaceLabel is nil")
        return
    end

    local space = yabai:get_space_with_label(destSpaceLabel)
    if not space then
        log.e("space is nil")
        return
    end

    local appName = app:name()
    -- check space
    -- local win = app:mainWindow()
    local win = app:focusedWindow()
    if not win then
        log.ef("win is nil, appName: %s", appName)
        return
    end

    log.df("space: %s", json_encode(space))

    local oldSpace = hs.spaces.focusedSpace()
    if oldSpace == space.mId then
        log.ef("oldSpaceId: %d is equal to destSpaceId: %d",
            oldSpace, space.mId)
        return
    end

    local ok, err = hs.spaces.moveWindowToSpace(win, space.mId, true)
    if not ok then
        log.ef("error move window to space: %s", err)
        return
    end

    log.df("move %s to space: %d, oldSpace: %d",
        appName, space.mId, oldSpace)

    -- goto space
    ok, err = hs.spaces.gotoSpace(space.mId)
    if not ok then
        log.ef("error goto space: %s", err)
        return
    end

    -- focuse window
    win:focus()
end

local emacsFocusIn = function(app)
    -- move to space 2
    emacsCtrlSpaceSwitchIM:enable()
    moveAppToSpace(app, "Emacs")
    hs.timer.doAfter(3, function()
        -- make maximaze window
        local win = app and app:focusedWindow()
        if win then
            win:maximize()
        end
    end)
end

local emacsFocusOut = function(app)
    emacsCtrlSpaceSwitchIM:disable()
end

-- NOTE: Use local function for any internal funciton not exported (not included as a part of the return)
local applicationWatcher = function(appName, event, app)
    local emacsAppName = 'Emacs'
    local vsCodeAppName = "Code"

    local isEmacsApp = emacsAppName == appName
    local isVscodeApp = vsCodeAppName == appName

    log.df("event is, app: %s, event: %s, isEmacsApp: %s, isdDeactivated: %s",
        appName, event, tostring(isEmacsApp), tostring(event == hs.application.watcher.deactivated))

    -- if (event == hs.application.watcher.activated) then
    if (event == hs.application.watcher.deactivated) then
        if isEmacsApp then emacsFocusOut(app) end
        if isVscodeApp then vscodeGitLens:disable() end
        -- elseif (eventType == hs.application.watcher.launched) then
        --     if isEmacsApp then
        --             hs.eventtap.keyStroke({
        --                 'alt',
        --             }, 'F10')
        --     end
    else
        if (appName == "Finder") then
            app:selectMenuItem({
                "Window",
                "Bring All to Front"
            }) -- Bring all Finder windows forward when one gets activated
        elseif isEmacsApp then
            emacsFocusIn(app)
        elseif isVscodeApp then
            vscodeGitLens:enable()
        end
    end
end


M.watcher = hs.application.watcher.new(applicationWatcher)

local function urlEvent(eventName, params)
    local action = params and params.action
    local pid = params and params.pid
    if pid and pid ~= '' then
        pid = tonumber(pid)
    end

    log.df("pid is: %d", (params.pid or ''))

    if not pid then
        log.ef("pid is not number: %s", (params.pid or ''))
        return
    end

    local app = hs.application.applicationForPID(pid)
    if not app then
        log.ef("process does not exist")
        return
    end

    if eventName == 'Emacs' then
        if action == "FocusIn" then
            emacsFocusIn(app)
        elseif action == "FocusOut" then
            emacsFocusOut(app)
        end
    end
end

function M:start()
    log.i("Starting Application Watcher")
    M.watcher:start()

    -- bind emacs event
    hs.urlevent.bind('Emacs', urlEvent)
    return M
end

function M:stop()
    log.i("Stopping Application Watcher")
    M.watcher:stop()
    return M
end

return M
