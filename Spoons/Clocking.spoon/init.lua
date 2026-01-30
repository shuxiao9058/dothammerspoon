--- === Clocking ===
---
local obj = {}
obj.__index = obj

-- local obj = { __gc = true }
-- --obj.__index = obj
-- setmetatable(obj, obj)
-- obj.__gc = function(t)
--     t:stop()
-- end

-- Metadata
obj.name = 'Clocking'
obj.version = '1.0'
obj.author = 'Aaron Chi <shuxiao9058@gmail.com>'
obj.homepage = 'https://github.com/Hammerspoon/Spoons'
obj.license = 'MIT - https://opensource.org/licenses/MIT'

obj.hotkeyToggle = nil
local updateTimer = nil
local menuBarItem = nil

-- function declaration
local updateClockingMenu
local startUpdatingClockingMenu

local clockingLog = hs.logger.new('clocking')

-- Internal function used to find our location, so we know where to load files from
local function script_path()
  local str = debug.getinfo(2, 'S').source:sub(2)
  return str:match('(.*/)')
end

obj.spoonPath = script_path()

-- local emacsclientPath =
--     '/Users/jiya/workspace/emacs/nextstep/Emacs.app/Contents/MacOS/bin/emacsclient'

local emacsclientPath = '/Applications/MacPorts/EmacsMac.app/Contents/MacOS/bin/emacsclient'

function obj:init() end

function obj:stop() end

function obj:start()
  -- if self.menuBarItem then
  --     self:stop()
  -- end
  updateClockingMenu()
  startUpdatingClockingMenu()
end

local function trim(s) return (s:gsub('^%s*(.-)%s*$', '%1')) end

function eval(sexp, callback)
  hs.task.new(emacsclientPath, function(exitCode, stdOut, stdErr)
    if exitCode == 0 then callback(trim(stdOut)) end
  end, {'--eval', sexp}):start()
end

updateClockingMenu = function()
  if not menuBarItem then menuBarItem = hs.menubar.new() end

  local currentApp = hs.application.get('org.gnu.Emacs')
  if not currentApp then
    logger:d('emacs is not running')
    menuBarItem:setTitle('Emacs Stopped')
    return
  end

  eval('(org-clock-is-active)', function(value)
    if value == 'nil' then
      menuBarItem:setTitle('No Task')
    else
      -- logger:d('run timer')
      eval('(org-clock-get-clock-string)',
           function(value) menuBarItem:setTitle(string.match(value, '"(.+)"')) end)
    end
  end)
  -- logger:d('time is running: ', updateTimer:running())
end

local function urlEvent(eventName, params)
  logger:d('url event: ', eventName, hs.json.encode(params))
  -- logger:d('state: ', params.state, ', status: ', params.status,
  --          ', clock_string: ', params.clockString)
  if not params then
    logger:e('params is nil')
    return
  end

  if not menuBarItem then menuBarItem = hs.menubar.new() end

  local state, status, clockString = params.state, params.status, params.clockString
  if state == '/' then state = nil end

  if status == '/' then status = nil end

  if clockString == '/' then clockString = nil end

  local currentApp = hs.application.get('org.gnu.Emacs')
  if not currentApp then
    logger:d('emacs is not running')
    menuBarItem:setTitle('Emacs Stopped')
    return
  end

  local separator = hs.styledtext.new(' | ', {font = hs.styledtext.defaultFonts.menuBar})
  -- if status == 'Pomo' then
  --     -- menuBarItem:setTitle('')
  -- end
  local focusedStyle = {
    font = hs.styledtext.defaultFonts.menuBar
    -- color = hs.drawing.color.hammerspoon.osx_green,
  }
  -- local visibleStyle = {
  --     font = hs.styledtext.defaultFonts.menuBar,
  --     color = hs.drawing.color.hammerspoon.osx_yellow,
  -- }
  -- local hasWindowsStyle = {
  --     font = hs.styledtext.defaultFonts.menuBar,
  --     color = {
  --         hex = '#ddd',
  --     },
  -- }
  -- local noWindowsStyle = {
  --     font = hs.styledtext.defaultFonts.menuBar,
  --     color = {
  --         hex = '#666',
  --     },
  -- }

  local title
  if status and status ~= '' then title = hs.styledtext.new(status, focusedStyle) end

  if clockString and clockString ~= '' then
    if title then
      title = title .. separator .. hs.styledtext.new(clockString, focusedStyle)
    else
      title = hs.styledtext.new(clockString, focusedStyle)
    end
  end

  if title then menuBarItem:setTitle(title) end
end

startUpdatingClockingMenu = function()
  -- if not updateTimer then
  --     updateTimer = hs.timer.new(10, updateClockingMenu)
  -- end

  hs.urlevent.bind('clocking', urlEvent)
  -- hs.urlevent.bind('OrgClockUpdate', urlOrgClockUpdateEvent)

  -- updateTimer:start()
end

return obj
