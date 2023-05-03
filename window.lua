local M = {}

local json_encode = hs.json.encode
local json_decode = hs.json.decode

local max_space = 6
local remove_extra_spaces
-- local stackline = require "stackline"
-- stackline:init()

-- require("hs.ipc")

local function getFrontApplicationName()
  local win = hs.window.focusedWindow()
  if (win == nil) or (win:id() == nil) then return end
  local app = win:application()
  return app:name()
end

-- function yabai(args)
--   hs.task.new("/opt/local/bin/yabai",nil, function(ud, ...)
--     print("stream", hs.inspect(table.pack(...)))
--     return true
--   end, args):start()
-- end

-- if hs.application("skhd") == nil then
--   -- focus window
--   hs.hotkey.bind("alt", "h", function() yabai({"-m", "window", "--focus", "west"}) end)
--   hs.hotkey.bind("alt", "j", function() yabai({"-m", "window", "--focus", "south"}) end)
--   hs.hotkey.bind("alt", "k", function() yabai({"-m", "window", "--focus", "north"}) end)
--   hs.hotkey.bind("alt", "l", function() yabai({"-m", "window", "--focus", "east"}) end)

--   -- swap windowkkk
--   hs.hotkey.bind({"shift", "alt"}, "h", function() yabai({"-m", "window", "--swap", "west"}) end)
--   hs.hotkey.bind({"shift", "alt"}, "j", function() yabai({"-m", "window", "--swap", "south"}) end)
--   hs.hotkey.bind({"shift", "alt"}, "k", function() yabai({"-m", "window", "--swap", "north"}) end)
--   hs.hotkey.bind({"shift", "alt"}, "l", function() yabai({"-m", "window", "--swap", "east"}) end)

--   -- move window
--   hs.hotkey.bind({"shift", "cmd"}, "h", function() yabai({"-m", "window", "--warp", "west"}) end)
--   hs.hotkey.bind({"shift", "cmd"}, "j", function() yabai({"-m", "window", "--warp", "south"}) end)
--   hs.hotkey.bind({"shift", "cmd"}, "k", function() yabai({"-m", "window", "--warp", "north"}) end)
--   hs.hotkey.bind({"shift", "cmd"}, "l", function() yabai({"-m", "window", "--warp", "east"}) end)

--   -- balance size of windows
--   hs.hotkey.bind({"shift", "alt"}, "0", function() yabai({"-m", "space", "--balance"}) end)

--   -- toggle window native fullscreen
--   hs.hotkey.bind({"shift", "alt"}, "f", function() yabai({"-m", "window", "--toggle", "native-fullscreen"}) end)

--   -- toggle window fullscreen zoom
--   hs.hotkey.bind("alt", "f", function()     if isEmacs() then return end
--  yabai({"-m", "window", "--toggle", "zoom-fullscreen"}) end)

--   -- make floating window fill screen
--   hs.hotkey.bind({"shift", "alt"}, "up", function() yabai({"-m", "window", "--grid", "1:1:0:0:1:1"}) end)

--   -- make floating window fill left-half of screen
--   hs.hotkey.bind({"shift", "alt"}, "left", function() yabai({"-m", "window", "--grid", "1:2:0:0:1:1"}) end)

--   -- make floating window fill right-half of screen
--   hs.hotkey.bind({"shift", "alt"}, "right", function() yabai({"-m", "window", "--grid", "1:2:1:0:1:1"}) end)

--   -- destroy desktop
--   hs.hotkey.bind({"cmd", "alt"}, "w", function() yabai({"-m", "space", "--destroy"}) end)

--   -- rotate tree
--   hs.hotkey.bind("alt", "r", function() yabai({"-m", "space", "--rotate", "90"}) end)

--   -- fast focus desktop
--   hs.hotkey.bind({"cmd", "alt"}, "x", function() yabai({"-m", "space", "--focus", "recent"}) end)
--   hs.hotkey.bind({"cmd", "alt"}, "z", function() yabai({"-m", "space", "--focus", "prev"}) end)
--   hs.hotkey.bind({"cmd", "alt"}, "c", function() yabai({"-m", "space", "--focus", "next"}) end)
--   hs.hotkey.bind({"cmd", "alt"}, "1", function() yabai({"-m", "space", "--focus", "1"}) end)
--   hs.hotkey.bind({"cmd", "alt"}, "2", function() yabai({"-m", "space", "--focus", "2"}) end)
--   hs.hotkey.bind({"cmd", "alt"}, "3", function() yabai({"-m", "space", "--focus", "3"}) end)
--   hs.hotkey.bind({"cmd", "alt"}, "4", function() yabai({"-m", "space", "--focus", "4"}) end)
--   hs.hotkey.bind({"cmd", "alt"}, "5", function() yabai({"-m", "space", "--focus", "5"}) end)
--   hs.hotkey.bind({"cmd", "alt"}, "6", function() yabai({"-m", "space", "--focus", "6"}) end)
--   hs.hotkey.bind({"cmd", "alt"}, "7", function() yabai({"-m", "space", "--focus", "7"}) end)
--   hs.hotkey.bind({"cmd", "alt"}, "8", function() yabai({"-m", "space", "--focus", "8"}) end)
--   hs.hotkey.bind({"cmd", "alt"}, "9", function() yabai({"-m", "space", "--focus", "9"}) end)
--   hs.hotkey.bind({"cmd", "alt"}, "0", function() yabai({"-m", "space", "--focus", "0"}) end)

--   -- mirror tree y-axis
--   hs.hotkey.bind("alt", "y", function()
--     if isEmacs() then return end
--     yabai({"-m", "space", "--mirror", "y-axis"}) end)

--   -- mirror tree x-axis
--   hs.hotkey.bind("alt", "x", function() yabai({"-m", "space", "--mirror", "x-axis"}) end)

--   -- toggle desktop offset
--   hs.hotkey.bind("alt", "a", function() yabai({"-m", "space", "--toggle", "padding"}); yabai({"-m", "space", "--toggle", "gap"}) end)

--   -- toggle window parent zoom
--   hs.hotkey.bind("alt", "d", function() yabai({"-m", "window", "--toggle", "zoom-parent"}) end)

--   -- toggle window border
--   hs.hotkey.bind({"shift", "alt"}, "b", function() yabai({"-m", "window", "--toggle", "border"}) end)

--   -- toggle window split type
--   hs.hotkey.bind("alt", "e", function() yabai({"-m", "window", "--toggle", "split"}) end)

--   -- toggle sticky
--   hs.hotkey.bind("alt", "s", function() yabai({"-m", "window", "--toggle", "sticky"}) end)

--   -- Reload yabai
--   hs.hotkey.bind({"ctrl", "shift", "cmd"}, "r", function() hs.execute("launchctl kickstart -k \"gui/${UID}/homebrew.mxcl.yabai\"") end)
-- -- Stack binding
--   hs.hotkey.bind({"shift", "alt"}, "n", function() hs.execute("/opt/local/bin/yabai -m window --focus stack.prev || /opt/local/bin/yabai -m window --focus prev || /opt/local/bin/yabai -m window --focus last") end)
--   hs.hotkey.bind("alt", "n", function() hs.execute("/opt/local/bin/yabai -m window --focus stack.next || /opt/local/bin/yabai -m window --focus next || /opt/local/bin/yabai -m window --focus first") end)
--   hs.hotkey.bind("alt", "tab", function() yabai({"-m", "window", "--focus", "stack.recent"}) end)
--   hs.hotkey.bind({"cmd", "ctrl"}, "left", function() hs.execute("/opt/local/bin/yabai -m window west --stack $(/opt/local/bin/yabai -m query --windows --window | /opt/local/bin/jq -r '.id')") end)
--   hs.hotkey.bind({"cmd", "ctrl"}, "down", function() hs.execute("/opt/local/bin/yabai -m window south --stack $(/opt/local/bin/yabai -m query --windows --window | /opt/local/bin/jq -r '.id')") end)
--   hs.hotkey.bind({"cmd", "ctrl"}, "up", function() hs.execute("/opt/local/bin/yabai -m window north --stack $(/opt/local/bin/yabai -m query --windows --window | /opt/local/bin/jq -r '.id')") end)
--   hs.hotkey.bind({"cmd", "ctrl"}, "right", function() hs.execute("/opt/local/bin/yabai -m window east --stack $(/opt/local/bin/yabai -m query --windows --window | /opt/local/bin/jq -r '.id')") end)
-- -- float / unfloat window and center on screen
--   hs.hotkey.bind("alt", "t", function() yabai({"-m", "window", "--toggle", "float"}); yabai({"-m", "window", "--grid", "4:4:1:1:2:2"}) end)
-- end

local HYPER = {
  'ctrl', 'alt', 'cmd', 'shift'
}
local HYPER_MINUS_SHIFT = {
  'ctrl', 'alt', 'cmd'
}

local yabaiPath = '/opt/local/bin/yabai'

local log = hs.logger.new('yabai')
log.setLogLevel('debug')

-- util functons
local function _start(self)
  return self.deepest_task:start()
end

local function _catch(self, path, argstr, callback)
  local task = hs.task.new(path, nil, hs.fnutils.split(argstr, '%s'))
  self.task:setCallback(function(exitCode, stdOut, stdErr)
    if exitCode ~= 0 then
      task:start()
    end

    callback = callback or self.callback
    if callback then
      callback(exitCode, stdOut, stdErr)
    end
  end)

  self.task = task
  return self
end

local function _next(self, path, argstr, callback)
  local task = hs.task.new(path, nil, hs.fnutils.split(argstr, '%s'))
  self.task:setCallback(function(exitCode, stdOut, stdErr)
    if exitCode == 0 then
      task:start()
    end

    callback = callback or self.callback
    if callback then
      callback(exitCode, stdOut, stdErr)
    end
  end)

  self.task = task
  return self
end

local function _call(self, path, argstr, callback)
  local task = hs.task.new(path, nil, hs.fnutils.split(argstr, '%s'))
  task:setCallback(function(exitCode, stdOut, stdErr)
    if exitCode ~= 0 then
      log.ef('error exec command: %s, exitCode: %d, stdOut: %s, stdErr: %s',
        argstr, exitCode, stdOut, stdErr)
    end

    if callback then
      callback(exitCode, stdOut, stdErr)
    end
  end
  )

  return {
    deepest_task = task,
    task = task,
    next = _next,
    catch = _catch,
    start = _start,
    callback = callback
  }
end

-- -- 同步执行命令，返回 json
-- local callsync = function(path, argstr)
--   local cmd = path .. ' ' .. argstr
--   local output, status, _, _ = hs.execute(cmd)
--   log.df("cmd: %s, output: %s", cmd, tostring(output))
--   if status then
--     local result = json_decode(output)
--     return result, status
--   end

--   return output, status
-- end


local function setup_space(idx, name)
  if not idx or not name then
    return
  end

  _call(yabaiPath, "-m query --spaces --space " .. tostring(idx),
    function(exitCode, _, _)
      if exitCode ~= 0 then
        log.df("create space: %d/%s", idx, name)
        _call(yabaiPath, "-m space --create"):start()
      end
    end):start()

  hs.timer.doAfter(5, function()
    _call(yabaiPath, string.format("-m space %d --lable %s", idx, name)):start()
  end)
end

-- 删除多余的 space
remove_extra_spaces = function()
  _call(yabaiPath, '-m query --spaces',
    function(exitCode, stdOut, _)
      if exitCode == 0 and stdOut then
        local spaces = json_decode(stdOut)
        if spaces and #spaces > max_space then
          for i = #spaces, max_space, -1 do
            -- log.df("space(%d): %s", i, json_encode(spaces[i]))
            local index = spaces[i].index or i
            local cmd_str = "-m space --destroy " .. tostring(index)
            _call(yabaiPath, cmd_str):start()
            log.df("remove space: %s, cmd_str: %s", tostring(index), cmd_str)
          end
        end
      end
    end):start()
end


local get_window_and_spaces = function()
  local topWin = hs.window.focusedWindow()
  if topWin == nil then
    log.d("topWin is nil")
    return
  end

  local topApp = topWin:application()
  if topApp == nil then
    log.d("topApp is not found")
    return
  end

  log.df("topApp is: %s, title: %s", topApp:name(), topApp:title())
end

local _get_space_with_label = function(self, label)
  if not label or label == "" then
    return
  end

  local yabai_spaces
  local query_str = '-m query --spaces'

  local now_sec = os.time()
  local cache_time = self.spaces_info and self.spaces_info.cache_time
  if not cache_time or (cache_time and now_sec - cache_time > 300) then -- cache 5 minutes
    self:call(yabaiPath, query_str, function(exitCode, stdOut, _)
      if exitCode == 0 then
        yabai_spaces = json_decode(stdOut)
        self.spaces_info = {
          cache_time = now_sec,
          spaces = yabai_spaces
        }
        log.df("yabai_spaces is: %s", json_encode(yabai_spaces))
      else
        yabai_spaces = {}
      end
    end):start()

    hs.timer.waitUntil(function() return yabai_spaces ~= nil end, function()
      log.df("yabai_spaces is: %s", json_encode(yabai_spaces or {}))
    end, 0.1)
  end

  yabai_spaces = yabai_spaces or (self.spaces_info and self.spaces_info.spaces)
  for i = 1, 5 do
    if yabai_spaces == nil then
      log.ef("yabai_spaces is nil, i: %d", i)
      hs.timer.usleep(3000) -- 3 毫秒
    end
  end

  if yabai_spaces == nil then
    log.ef("yabai_spaces is nil")
    return
  end

  local space_uuid

  for k, v in ipairs(yabai_spaces) do
    if v.label and string.lower(v.label) == string.lower(label) then
      space_uuid = v.uuid
      break
    end
  end

  if space_uuid == nil then
    return
  end

  local space_result = hs.spaces.data_managedDisplaySpaces()
  if not space_result then
    return
  end

  for k, monitor in ipairs(space_result) do
    local spaces = monitor.Spaces
    for k, v in ipairs(spaces) do
      if v.uuid == space_uuid then
        return {
          uuid = space_uuid,
          mId = v.ManagedSpaceID,
          id64 = v.id64
        }
      end
    end

    local current_space = monitor['Current Space']
    if not current_space then
      return
    end

    if current_space.uuid == space_uuid then
      return {
        uuid = space_uuid,
        mId = current_space.ManagedSpaceID,
        id64 = current_space.id64
        -- isActive = true
      }
    end
  end

  self.spaces_info = nil
end

-- function M:call(path, argstr, callback)
--   return _call(path, argstr, callback)
-- end

M.call = _call

M.get_space_with_label = _get_space_with_label

-- M.tm = hs.timer.doEvery(3, get_window_and_spaces)

-- function M:init()
--   local t = setmetatable({}, M)
--   return t
-- end

function M:start()
  log.d("Initializing window module ...")

  -- -- focus next and prev
  -- hs.hotkey.bind({ 'alt' }, "N", function()
  --   call(yabaiPath, '-m window --focus stack.next')
  --       :catch(yabaiPath, '-m window --focus stack.first')
  --       :catch(yabaiPath, '-m window --focus next')
  --       :catch(yabaiPath, '-m window --focus first')
  --       :start()
  -- end)

  hs.hotkey.bind({ 'alt', 'shift' }, "N", function()
    self:call(yabaiPath, '-m window --focus stack.prev')
        :catch(yabaiPath, '-m window --focus stack.last')
        :catch(yabaiPath, '-m window --focus prev')
        :catch(yabaiPath, '-m window --focus last')
        :start()
  end)

  -- make floating window fill half of screen
  hs.hotkey.bind({ "shift", "alt" }, "right", function() self:call(yabaiPath, "-m window --grid 1:2:1:0:1:1"):start() end)
  hs.hotkey.bind({ "shift", "alt" }, "left", function() self:call(yabaiPath, "-m window --grid 1:2:0:1:1:1"):start() end)
  hs.hotkey.bind({ "shift", "alt" }, "down", function() self:call(yabaiPath, "-m window --grid 2:1:1:1:1:1"):start() end)
  hs.hotkey.bind({ "shift", "alt" }, "up", function() self:call(yabaiPath, "-m window --grid 2:1:1:0:1:1"):start() end)

  -- destroy desktop
  hs.hotkey.bind({ "cmd", "alt" }, "w", function() self:call(yabaiPath, "-m space --destroy"):start() end)
  -- rotate tree
  hs.hotkey.bind("alt", "r", function() self:call(yabaiPath, "-m space --rotate 90"):start() end)

  -- fast focus desktop
  hs.hotkey.bind({ "cmd", "alt" }, "x", function() self:call(yabaiPath, "-m pace --focus recent"):start() end)
  hs.hotkey.bind({ "cmd", "alt" }, "z", function() self:call(yabaiPath, "-m pace -focus prev"):start() end)
  hs.hotkey.bind({ "cmd", "alt" }, "c", function() self:call(yabaiPath, "-m pace -focus next"):start() end)
  hs.hotkey.bind({ "cmd", "alt" }, "1", function() self:call(yabaiPath, "-m pace -focus 1"):start() end)
  hs.hotkey.bind({ "cmd", "alt" }, "2", function() self:call(yabaiPath, "-m pace -focus 2"):start() end)
  hs.hotkey.bind({ "cmd", "alt" }, "3", function() self:call(yabaiPath, "-m pace -focus 3"):start() end)
  hs.hotkey.bind({ "cmd", "alt" }, "4", function() self:call(yabaiPath, "-m space -focus 4"):start() end)
  hs.hotkey.bind({ "cmd", "alt" }, "5", function() self:call(yabaiPath, "-m space --focus 5"):start() end)
  hs.hotkey.bind({ "cmd", "alt" }, "6", function() self:call(yabaiPath, "-m space --focus 6"):start() end)
  hs.hotkey.bind({ "cmd", "alt" }, "7", function() self:call(yabaiPath, "-m space --focus 7"):start() end)
  hs.hotkey.bind({ "cmd", "alt" }, "8", function() self:call(yabaiPath, "-m space -focus 8"):start() end)
  hs.hotkey.bind({ "cmd", "alt" }, "9", function() self:call(yabaiPath, "-m space -focus 9"):start() end)
  hs.hotkey.bind({ "cmd", "alt" }, "0", function() self:call(yabaiPath, "-m space --focus 0"):start() end)


  -- focus directional
  hs.hotkey.bind({ 'alt' }, "H", function() self:call(yabaiPath, '-m window --focus west'):start() end)
  hs.hotkey.bind({ 'alt' }, "J", function() self:call(yabaiPath, '-m window --focus south'):start() end)
  hs.hotkey.bind({ 'alt' }, "K", function() self:call(yabaiPath, '-m window --focus north'):start() end)
  hs.hotkey.bind({ 'alt' }, "L", function() self:call(yabaiPath, '-m window --focus east'):start() end)

  -- swap directional
  hs.hotkey.bind({ 'shift', 'alt' }, "H", function() self:call(yabaiPath, '-m window --swap west'):start() end)
  hs.hotkey.bind({ 'shift', 'alt' }, "J", function() self:call(yabaiPath, '-m window --swap south'):start() end)
  hs.hotkey.bind({ 'shift', 'alt' }, "K", function() self:call(yabaiPath, '-m window --swap north'):start() end)
  hs.hotkey.bind({ 'shift', 'alt' }, "L", function() self:call(yabaiPath, '-m window --swap east'):start() end)
  hs.hotkey.bind({ 'alt' }, "return", function() self:call(yabaiPath, '-m window --swap first'):start() end)

  -- -- focus desktop
  -- hs.hotkey.bind({'alt'}, "1", function() self:call(yabaiPath, '-m space --focus 1'):start() end)
  -- hs.hotkey.bind({'alt'}, "2", function() self:call(yabaiPath, '-m space --focus 2'):start() end)
  -- hs.hotkey.bind({'alt'}, "3", function() self:call(yabaiPath, '-m space --focus 3'):start() end)
  -- hs.hotkey.bind({'alt'}, "4", function() self:call(yabaiPath, '-m space --focus 4'):start() end)
  -- hs.hotkey.bind({'alt'}, "5", function() self:call(yabaiPath, '-m space --focus 5'):start() end)
  -- hs.hotkey.bind({'alt'}, "6", function() self:call(yabaiPath, '-m space --focus 6'):start() end)
  -- hs.hotkey.bind({'alt'}, "7", function() self:call(yabaiPath, '-m space --focus 7'):start() end)
  -- hs.hotkey.bind({'alt'}, "8", function() self:call(yabaiPath, '-m space --focus 8'):start() end)
  -- hs.hotkey.bind({'alt'}, "9", function() self:call(yabaiPath, '-m space --focus 9'):start() end)

  -- focus desktop
  hs.hotkey.bind({ 'alt' }, "1", function() self:call(yabaiPath, '-m space --focus 1'):start() end)
  hs.hotkey.bind({ 'alt' }, "2", function() self:call(yabaiPath, '-m space --focus 2'):start() end)
  hs.hotkey.bind({ 'alt' }, "3", function() self:call(yabaiPath, '-m space --focus 3'):start() end)
  hs.hotkey.bind({ 'alt' }, "4", function() self:call(yabaiPath, '-m space --focus 4'):start() end)
  hs.hotkey.bind({ 'alt' }, "5", function() self:call(yabaiPath, '-m space --focus 5'):start() end)
  hs.hotkey.bind({ 'alt' }, "6", function() self:call(yabaiPath, '-m space --focus 6'):start() end)
  hs.hotkey.bind({ 'alt' }, "7", function() self:call(yabaiPath, '-m space --focus 7'):start() end)
  hs.hotkey.bind({ 'alt' }, "8", function() self:call(yabaiPath, '-m space --focus 8'):start() end)
  hs.hotkey.bind({ 'alt' }, "9", function() self:call(yabaiPath, '-m space --focus 9'):start() end)


  -- move window to desktop
  hs.hotkey.bind({ 'shift', 'alt' }, "1", function() self:call(yabaiPath, '-m window --space 1'):start() end)
  hs.hotkey.bind({ 'shift', 'alt' }, "2", function() self:call(yabaiPath, '-m window --space 2'):start() end)
  hs.hotkey.bind({ 'shift', 'alt' }, "3", function() self:call(yabaiPath, '-m window --space 3'):start() end)
  hs.hotkey.bind({ 'shift', 'alt' }, "4", function() self:call(yabaiPath, '-m window --space 4'):start() end)
  hs.hotkey.bind({ 'shift', 'alt' }, "5", function() self:call(yabaiPath, '-m window --space 5'):start() end)
  hs.hotkey.bind({ 'shift', 'alt' }, "6", function() self:call(yabaiPath, '-m window --space 6'):start() end)
  hs.hotkey.bind({ 'shift', 'alt' }, "7", function() self:call(yabaiPath, '-m window --space 7'):start() end)
  hs.hotkey.bind({ 'shift', 'alt' }, "8", function() self:call(yabaiPath, '-m window --space 8'):start() end)
  hs.hotkey.bind({ 'shift', 'alt' }, "9", function() self:call(yabaiPath, '-m window --space 9'):start() end)

  -- toggles
  hs.hotkey.bind({ 'alt' }, "D", function() self:call(yabaiPath, '-m window --toggle zoom-parent'):start() end)

  -- hs.hotkey.bind("alt", "y", function()
  -- 		       local appName = getFrontApplicationName()
  -- 			 if appName == "Emacs" then
  -- 				 log:d("front application: " .. (appName or 'nil'))
  -- 				          hs.eventtap.keyStroke({'alt'}, 'y')
  -- 				 return end
  --     call(yabaiPath "-m pace -mirror -axis"):start() end)

  -- mirror tree x-axis
  --  hs.hotkey.bind("alt", "x", function()
  --   if getFrontApplicationName() == "Emacs" then return end
  --   ("-m", "space", "--mirror", "x-axis"}) end)

  -- hs.hotkey.bind({'alt'}, "F", function() call(yabaiPath, '-m window --toggle zoom-fullscreen'):start() end)
  hs.hotkey.bind(HYPER, "M", function()
    if getFrontApplicationName() == "Emacs" then
      hs.eventtap.keyStroke({ 'alt' }, 'F10')
    else
      self:call(yabaiPath, '-m window --toggle zoom-fullscreen'):start()
    end
  end)
  hs.hotkey.bind({ 'alt' }, "E", function() self:call(yabaiPath, '-m window --toggle split'):start() end)

  hs.hotkey.bind({ 'alt' }, "T", function()
    self:call(yabaiPath, '-m window --toggle float')
    -- :next(yabaiPath, '-m window --grid 4:4:1:1:2:2')
        :next(yabaiPath, '-m window --grid 7:7:1:1:5:5')
    -- :next(yabaiPath, '-m window --grid 2:2:1:0:1:1')
    -- :next(yabaiPath, '-m window --grid 1:1:0:0:1:1')
        :start()
  end)

  hs.hotkey.bind({ 'alt' }, "P", function()
    self:call(yabaiPath, '-m window --toggle sticky')
        :next(yabaiPath, '-m window --toggle topmost')
        :next(yabaiPath, '-m window --toggle pip')
        :start()
  end)

  -- stack window
  hs.hotkey.bind({ 'ctrl', 'alt' }, "H", function() self:call(yabaiPath, '-m window --stack west'):start() end)
  hs.hotkey.bind({ 'ctrl', 'alt' }, "J", function() self:call(yabaiPath, '-m window --stack south'):start() end)
  hs.hotkey.bind({ 'ctrl', 'alt' }, "K", function() self:call(yabaiPath, '-m window --stack north'):start() end)
  hs.hotkey.bind({ 'ctrl', 'alt' }, "L", function() self:call(yabaiPath, '-m window --stack east'):start() end)

  -- hs.hotkey.bind({ 'ctrl', 'alt' }, "D", function()
  --   local output, _, _, _ = hs.execute(yabaiPath .. ' -m query --displays --display')
  --   log.d(output)
  --   output, _, _, _ = hs.execute(yabaiPath .. ' -m query --spaces --space')
  --   log.d(output)
  --   output, _, _, _ = hs.execute(yabaiPath .. ' -m query --windows --window')
  --   log.d(output)
  -- end)

  -- hs.timer.doEvery(3, get_window_and_spaces)
  -- M.tm:start()

  -- local spaceMap = {
  --   { idx = 1, name = "Emacs" },
  --   { idx = 2, name = "Code" },
  --   { idx = 3, name = "Web" },
  --   { idx = 4, name = "Social" },
  --   { idx = 5, name = "Media" },
  --   { idx = 6, name = "Other" },
  -- }

  -- remove_extra_spaces()

  -- for _, space in ipairs(spaceMap) do
  --   log.df("space: %s", json_encode(space))
  --   if space and space.idx and space.name then
  --     setup_space(space.idx, space.name)
  --   end
  -- end

  -- local rules = {
  --   -- floating apps and windows
  --   -- [[-m rule --add app="^System Settings$" manage=off]],
  --   [[-m rule --add app="^Cryptomator$" manage=off]],
  --   [[-m rule --add app="^NIIMBOT$" manage=off]],
  --   [[-m rule --add app="^Emacs$" title!='^$' manage=on]],

  --   -- move some apps automatically to specific spaces
  --   [[-m rule --add app="^Safari$" space=3]],
  --   [[-m rule --add app="^Firefox$" space=3]],
  --   [[-m rule --add app="^Telegram$" space=4]],
  --   [[-m rule --add app="^Messages$" space=4]],
  --   [[-m rule --add app="^Music$" space=5]],
  --   [[-m rule --add app="^Spotify$" space=5]],
  --   [[-m rule --add app="^Infuse$" space=5]],
  --   -- [[ -m rule --add app="^Transmission$" space=6]],
  -- }

  -- -- init rules
  -- for _, rule in ipairs(rules) do
  -- 	  log.df("rule: %s", rule)
  --   call(yabaiPath, rule):start()
  -- end
end

return M
