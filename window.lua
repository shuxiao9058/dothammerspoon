


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

local function _catch(self, path, argstr)
  local task = hs.task.new(path, nil, hs.fnutils.split(argstr, '%s'))
  self.task:setCallback(function(exitCode, stdOut, stdErr)
    if exitCode ~= 0 then
      task:start()
    end
  end)

  self.task = task
  return self
end

local function _next(self, path, argstr)
  local task = hs.task.new(path, nil, hs.fnutils.split(argstr, '%s'))
  self.task:setCallback(function(exitCode, stdOut, stdErr)
    if exitCode == 0 then
      task:start()
    end
    -- log.df("exitCode: %d", exitCode)
    log.d("stdOut: " .. (stdOut or 'nil') .. ", stdErr: " .. (stdErr or 'nil'))
  end)

  self.task = task
  return self
end

local function call(path, argstr)
  local task = hs.task.new(path, nil, hs.fnutils.split(argstr, '%s'))

  return {
    deepest_task = task,
    task = task,
    next = _next,
    catch = _catch,
    start = _start,
  }
end

-- focus next and prev
hs.hotkey.bind({'alt'}, "N", function()
  call(yabaiPath, '-m window --focus stack.next')
  :catch(yabaiPath, '-m window --focus stack.first')
  :catch(yabaiPath, '-m window --focus next')
  :catch(yabaiPath, '-m window --focus first')
  :start()
end)

hs.hotkey.bind({'alt', 'shift'}, "N", function()
  call(yabaiPath, '-m window --focus stack.prev')
  :catch(yabaiPath, '-m window --focus stack.last')
  :catch(yabaiPath, '-m window --focus prev')
  :catch(yabaiPath, '-m window --focus last')
  :start()
end)

-- make floating window fill right-half of screen
hs.hotkey.bind({"shift", "alt"}, "right", function() call(yabaiPath, "-m window --grid 1:2:1:0:1:1") end)

-- focus directional
hs.hotkey.bind({'alt'}, "H", function() call(yabaiPath, '-m window --focus west'):start() end)
hs.hotkey.bind({'alt'}, "J", function() call(yabaiPath, '-m window --focus south'):start() end)
hs.hotkey.bind({'alt'}, "K", function() call(yabaiPath, '-m window --focus north'):start() end)
hs.hotkey.bind({'alt'}, "L", function() call(yabaiPath, '-m window --focus east'):start() end)

-- swap directional
hs.hotkey.bind({'shift', 'alt'}, "H", function() call(yabaiPath, '-m window --swap west'):start() end)
hs.hotkey.bind({'shift', 'alt'}, "J", function() call(yabaiPath, '-m window --swap south'):start() end)
hs.hotkey.bind({'shift', 'alt'}, "K", function() call(yabaiPath, '-m window --swap north'):start() end)
hs.hotkey.bind({'shift', 'alt'}, "L", function() call(yabaiPath, '-m window --swap east'):start() end)

-- focus desktop
hs.hotkey.bind({'alt'}, "1", function() call(yabaiPath, '-m space --focus 1'):start() end)
hs.hotkey.bind({'alt'}, "2", function() call(yabaiPath, '-m space --focus 2'):start() end)
hs.hotkey.bind({'alt'}, "3", function() call(yabaiPath, '-m space --focus 3'):start() end)
hs.hotkey.bind({'alt'}, "4", function() call(yabaiPath, '-m space --focus 4'):start() end)
hs.hotkey.bind({'alt'}, "5", function() call(yabaiPath, '-m space --focus 5'):start() end)
hs.hotkey.bind({'alt'}, "6", function() call(yabaiPath, '-m space --focus 6'):start() end)
hs.hotkey.bind({'alt'}, "7", function() call(yabaiPath, '-m space --focus 7'):start() end)
hs.hotkey.bind({'alt'}, "8", function() call(yabaiPath, '-m space --focus 8'):start() end)
hs.hotkey.bind({'alt'}, "9", function() call(yabaiPath, '-m space --focus 9'):start() end)

-- move window to desktop
hs.hotkey.bind({'shift', 'alt'}, "1", function() call(yabaiPath, '-m window --space 1'):start() end)
hs.hotkey.bind({'shift', 'alt'}, "2", function() call(yabaiPath, '-m window --space 2'):start() end)
hs.hotkey.bind({'shift', 'alt'}, "3", function() call(yabaiPath, '-m window --space 3'):start() end)
hs.hotkey.bind({'shift', 'alt'}, "4", function() call(yabaiPath, '-m window --space 4'):start() end)
hs.hotkey.bind({'shift', 'alt'}, "5", function() call(yabaiPath, '-m window --space 5'):start() end)
hs.hotkey.bind({'shift', 'alt'}, "6", function() call(yabaiPath, '-m window --space 6'):start() end)
hs.hotkey.bind({'shift', 'alt'}, "7", function() call(yabaiPath, '-m window --space 7'):start() end)
hs.hotkey.bind({'shift', 'alt'}, "8", function() call(yabaiPath, '-m window --space 8'):start() end)
hs.hotkey.bind({'shift', 'alt'}, "9", function() call(yabaiPath, '-m window --space 9'):start() end)

-- toggles
hs.hkey.bind({'alt'}, "D", function() call(yabaiPath, '-m window --toggle zoom-parent'):start() end)

-- hs.hotkey.bind({'alt'}, "F", function() call(yabaiPath, '-m window --toggle zoom-fullscreen'):start() end)
hs.hotkey.bind(HYPER, "M", function() 
    if getFrontApplicationName() == "Emacs" then
         hs.eventtap.keyStroke({'alt'}, 'F10')
    else
      call(yabaiPath, '-m window --toggle zoom-fullscreen'):start()
    end
   end )
hs.hotkey.bind({'alt'}, "E", function() call(yabaiPath, '-m window --toggle split'):start() end)

hs.hotkey.bind({'alt'}, "T", function()
  call(yabaiPath, '-m window --toggle float')
  :next(yabaiPath, '-m window --grid 4:4:1:1:2:2')
  :start()
end)

hs.hotkey.bind({'alt'}, "P", function()
  call(yabaiPath, '-m window --toggle sticky')
  :next(yabaiPath, '-m window --toggle topmost')
  :next(yabaiPath, '-m window --toggle pip')
  :start()
end)

-- stack window
hs.hotkey.bind({'ctrl', 'alt'}, "H", function() call(yabaiPath, '-m window --stack west'):start() end)
hs.hotkey.bind({'ctrl', 'alt'}, "J", function() call(yabaiPath, '-m window --stack south'):start() end)
hs.hotkey.bind({'ctrl', 'alt'}, "K", function() call(yabaiPath, '-m window --stack north'):start() end)
hs.hotkey.bind({'ctrl', 'alt'}, "L", function() call(yabaiPath, '-m window --stack east'):start() end)

hs.hotkey.bind({'ctrl', 'alt'}, "D", function()
  local output, _, _, _ = hs.execute(yabaiPath .. ' -m query --displays --display')
  log.d(output)
  output, _, _, _ = hs.execute(yabaiPath .. ' -m query --spaces --space')
  log.d(output)
  output, _, _, _ = hs.execute(yabaiPath .. ' -m query --windows --window')
  log.d(output)
end)


