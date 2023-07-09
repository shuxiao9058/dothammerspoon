-- Application Watcher
-- listen application's events, such as keystroke and application starts
local json_encode = hs.json.encode
local json_decode = hs.json.decode

local M = {}
M.logger = hs.logger.new('appWatch')

local yabai = require('window')
local myApp = require("app.app")

local log = M.logger
log.setLogLevel('debug')

local HYPER = {'ctrl', 'alt', 'cmd', 'shift'}
local HYPER_MINUS_SHIFT = {'ctrl', 'alt', 'cmd'}

local emacsCtrlSpaceSwitchIM = hs.hotkey.new('ctrl', 'space', function()
  local topWindow = hs.window:frontmostWindow()
  if topWindow ~= nil then
    local topApp = topWindow:application()
    if topApp ~= nil then
      local bunderID = topApp:bundleID()
      logger:d('bunderID is: ', bunderID)
      if bunderID == 'org.gnu.Emacs' then hs.eventtap.keyStroke({'ctrl'}, '\\') end
    end
  end
end)

local vscodeGitLens = hs.hotkey.new(HYPER_MINUS_SHIFT, "g", function()
  local win = hs.window.focusedWindow()
  if (win == nil) or (win:id() == nil) then return end

  local app = win:application()
  local appBundleID = app:bundleID()
  -- log.ef('appBundleID is: ' .. appBundleID)
  if appBundleID == 'com.microsoft.VSCode' or appBundleID == 'com.microsoft.VSCodeInsiders' then
    hs.eventtap.keyStroke({'ctrl', 'shift'}, 'g', app)
  end
end)

-- -- space control
-- local function getSpacesList()
-- 	local spaces_list = {}
-- 	local layout = hs.spaces.allSpaces()
-- 	for _, screen in ipairs(hs.screen.allScreens()) do
-- 		for _, space in ipairs(layout[screen:getUUID()]) do
-- 			table.insert(spaces_list, space)
-- 		end
-- 	end
-- 	return spaces_list
-- end

-- local function switchToSpace(index)
-- 	local space = getSpacesList()[index]
-- 	if not space then
-- 		return
-- 	end
-- 	hs.spaces.gotoSpace(space)
-- end

-- local function moveWindowToSpace(index)
-- 	local focused_window = hs.window.focusedWindow()
-- 	if not focused_window then
-- 		return
-- 	end

-- 	local space = getSpacesList()[index]
-- 	if not space then
-- 		return
-- 	end

-- 	if hs.spaces.spaceType(space) ~= "user" then
-- 		return
-- 	end

-- 	local screen = hs.screen.find(hs.spaces.spaceDisplay(space))
-- 	if not screen then
-- 		return
-- 	end

-- 	hs.spaces.moveWindowToSpace(focused_window, space)
-- 	hs.spaces.gotoSpace(space)
-- end

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
  local win = app:focusedWindow()
  if not win then
    log.ef("win is nil, appName: %s", appName)
    return
  end

  local spaceId = space.mId
  if not spaceId then
    log.ef("spaceId is nil")
    return
  end

  local spaceType = hs.spaces.spaceType(spaceId)
  if spaceType ~= "user" then
    log.ef("spaceType is not user: %s", spaceType)
    return
  end

  local screen = hs.screen.find(hs.spaces.spaceDisplay(spaceId))
  if not screen then
    log.ef("move to space, not screen")
    return
  end

  local oldSpace = hs.spaces.focusedSpace()
  if oldSpace == spaceId then
    -- log.ef("oldSpaceId: %d is equal to destSpaceId: %d",
    -- 	oldSpace, spaceId)
    return
  end

  log.df("move %s to space: %d, oldSpace: %d", appName, space.mId, oldSpace)
  local ok, err = hs.spaces.moveWindowToSpace(win, spaceId, true)
  if not ok then
    log.ef("error move window to space: %s", err)
    return
  end

  -- log.df("space: %s", json_encode(space))
  ok, err = hs.spaces.gotoSpace(spaceId)
  if not ok then
    log.ef("error goto space: %s", err)
    return
  end

  -- focuse window
  win:focus()
end

local emacsFocusIn = function(app, statup)
  if startup then
    -- move to space 2
    moveAppToSpace(app, "Emacs")
  end

  emacsCtrlSpaceSwitchIM:enable()
  myApp:updateInputMethod()
  -- hs.timer.doAfter(1, function()
  -- 	-- make maximaze window
  -- 	local win = app and app:focusedWindow()
  -- 	if win then
  -- 		win:maximize()
  -- 	end
  -- end)
end

local emacsFocusOut = function(app) emacsCtrlSpaceSwitchIM:disable() end

-- NOTE: Use local function for any internal funciton not exported (not included as a part of the return)
local applicationWatcher = function(appName, event, app)
  local emacsAppName = 'Emacs'
  local vsCodeAppName = "Code"

  local isEmacsApp = emacsAppName == appName
  local isVscodeApp = vsCodeAppName == appName
  local isBrowersApp = appName == "Google Chrome" or appName == "Firefox" or appName ==
                         "Stack Next SE" or appName == 'Safari'

  -- log.df("event is, app: %s, event: %s, isEmacsApp: %s, isdDeactivated: %s",
  --     appName, event, tostring(isEmacsApp), tostring(event == hs.application.watcher.deactivated))

  -- if (event == hs.application.watcher.activated) then
  if (event == hs.application.watcher.deactivated) then
    if isEmacsApp then emacsCtrlSpaceSwitchIM:disable() end
    if isVscodeApp then vscodeGitLens:disable() end
    -- elseif (eventType == hs.application.watcher.launched) then
    --     if isEmacsApp then
    --             hs.eventtap.keyStroke({
    --                 'alt',
    --             }, 'F10')
    --     end
  else
    if (appName == "Finder") then
      app:selectMenuItem({"Window", "Bring All to Front"}) -- Bring all Finder windows forward when one gets activated
    elseif isEmacsApp then
      emacsCtrlSpaceSwitchIM:enable()
    elseif isVscodeApp then
      vscodeGitLens:enable()
    elseif isBrowersApp then
      -- make frontMostApp maximum
      yabai:force_fullscreen()
    end
  end
end

M.watcher = hs.application.watcher.new(applicationWatcher)

local function urlEvent(eventName, params)
  local action = params and params.action
  local pid = params and params.pid
  if pid and pid ~= '' then pid = tonumber(pid) end

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
      emacsFocusIn(app, false)
    elseif action == "StartUp" then
      emacsFocusIn(app, true)
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
