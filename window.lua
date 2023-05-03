local M = {}

local json_encode = hs.json.encode
local json_decode = hs.json.decode

local max_space = 6
local remove_extra_spaces

local function getFrontApplicationName()
	local win = hs.window.focusedWindow()
	if (win == nil) or (win:id() == nil) then return end
	local app = win:application()
	return app:name()
end

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
local function _start(self) return self.deepest_task:start() end

local function _catch(self, path, argstr, callback)
	local task = hs.task.new(path, nil, hs.fnutils.split(argstr, '%s'))
	self.task:setCallback(function(exitCode, stdOut, stdErr)
		if exitCode ~= 0 then task:start() end

		callback = callback or self.callback
		if callback then callback(exitCode, stdOut, stdErr) end
	end)

	self.task = task
	return self
end

local function _next(self, path, argstr, callback)
	local task = hs.task.new(path, nil, hs.fnutils.split(argstr, '%s'))
	self.task:setCallback(function(exitCode, stdOut, stdErr)
		if exitCode == 0 then task:start() end

		callback = callback or self.callback
		if callback then callback(exitCode, stdOut, stdErr) end
	end)

	self.task = task
	return self
end

local function _call(self, path, argstr, callback)
	local task = hs.task.new(path, nil, hs.fnutils.split(argstr, '%s'))
	task:setCallback(function(exitCode, stdOut, stdErr)
		if exitCode ~= 0 then
			log.ef(
				'error exec command: %s, exitCode: %d, stdOut: %s, stdErr: %s',
				argstr, exitCode, stdOut, stdErr)
		end

		if callback then callback(exitCode, stdOut, stdErr) end
	end)

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
	if not idx or not name then return end

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
	_call(yabaiPath, '-m query --spaces', function(exitCode, stdOut, _)
		if exitCode == 0 and stdOut then
			local spaces = json_decode(stdOut)
			if spaces and #spaces > max_space then
				for i = #spaces, max_space, -1 do
					-- log.df("space(%d): %s", i, json_encode(spaces[i]))
					local index = spaces[i].index or i
					local cmd_str = "-m space --destroy " .. tostring(index)
					_call(yabaiPath, cmd_str):start()
					log.df("remove space: %s, cmd_str: %s", tostring(index),
						cmd_str)
				end
			end
		end
	end):start()
end

-- get all yabai spaces
local _get_all_yabai_spaces = function(self)
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

		hs.timer.waitUntil(function() return yabai_spaces ~= nil end,
			function()
				log.df("yabai_spaces is: %s", json_encode(yabai_spaces or {}))
			end, 0.1)
	end

	yabai_spaces = yabai_spaces or
	    (self.spaces_info and self.spaces_info.spaces)
	for i = 1, 5 do
		if yabai_spaces == nil then
			log.ef("yabai_spaces is nil, i: %d", i)
			hs.timer.usleep(3000) -- 3 毫秒
		end
	end
	return yabai_spaces
end


-- label if label is nil, then get current active space
local _get_active_yabai_space = function(self)
	local yabai_spaces = self:get_all_yabai_spaces()
	if yabai_spaces == nil then
		return
	end

	for k, v in ipairs(yabai_spaces) do
		if v['has-focus'] and v['is-visible'] then
			return v
		end
	end
end

local _get_space_with_label = function(self, label)
	if not label or label == "" then return end
	local yabai_spaces = self:get_all_yabai_spaces()
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

	if space_uuid == nil then return end

	local space_result = hs.spaces.data_managedDisplaySpaces()
	if not space_result then return end

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
		if not current_space then return end

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

local my_toggle_fullscreen = function()
	if getFrontApplicationName() == "Emacs" then
		hs.eventtap.keyStroke({ 'alt' }, 'F10')
	else
		local space = M:get_active_yabai_space()
		if space and space == 'bsp' then
			self:call(yabaiPath, '-m window --toggle zoom-fullscreen'):start()
		else
			local app = require("app.app")
			app:toggleMaximized(nil, nil)
		end
	end
end

M.call = _call

M.get_space_with_label = _get_space_with_label

M.get_all_yabai_spaces = _get_all_yabai_spaces

M.get_active_yabai_space = _get_active_yabai_space

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

	-- hs.hotkey.bind({ 'alt', 'shift' }, "N", function()
	--   self:call(yabaiPath, '-m window --focus stack.prev')
	--       :catch(yabaiPath, '-m window --focus stack.last')
	--       :catch(yabaiPath, '-m window --focus prev')
	--       :catch(yabaiPath, '-m window --focus last')
	--       :start()
	-- end)

	-- make floating window fill half of screen
	hs.hotkey.bind({ "shift", "alt" }, "right", function()
		self:call(yabaiPath, "-m window --grid 1:2:1:0:1:1"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "left", function()
		self:call(yabaiPath, "-m window --grid 1:2:0:1:1:1"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "down", function()
		self:call(yabaiPath, "-m window --grid 2:1:1:1:1:1"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "up", function()
		self:call(yabaiPath, "-m window --grid 2:1:1:0:1:1"):start()
	end)

	-- destroy desktop
	hs.hotkey.bind({ "cmd", "alt" }, "w", function()
		self:call(yabaiPath, "-m space --destroy"):start()
	end)
	-- rotate tree
	hs.hotkey.bind("alt", "r", function()
		self:call(yabaiPath, "-m space --rotate 90"):start()
	end)

	-- fast focus desktop
	hs.hotkey.bind({ "cmd", "alt" }, "x", function()
		self:call(yabaiPath, "-m pace --focus recent"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "z", function()
		self:call(yabaiPath, "-m pace -focus prev"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "c", function()
		self:call(yabaiPath, "-m pace -focus next"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "1", function()
		self:call(yabaiPath, "-m pace -focus 1"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "2", function()
		self:call(yabaiPath, "-m pace -focus 2"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "3", function()
		self:call(yabaiPath, "-m pace -focus 3"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "4", function()
		self:call(yabaiPath, "-m space -focus 4"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "5", function()
		self:call(yabaiPath, "-m space --focus 5"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "6", function()
		self:call(yabaiPath, "-m space --focus 6"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "7", function()
		self:call(yabaiPath, "-m space --focus 7"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "8", function()
		self:call(yabaiPath, "-m space -focus 8"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "9", function()
		self:call(yabaiPath, "-m space -focus 9"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "0", function()
		self:call(yabaiPath, "-m space --focus 0"):start()
	end)

	-- focus directional
	hs.hotkey.bind({ 'alt' }, "H", function()
		self:call(yabaiPath, '-m window --focus west'):start()
	end)
	hs.hotkey.bind({ 'alt' }, "J", function()
		self:call(yabaiPath, '-m window --focus south'):start()
	end)
	hs.hotkey.bind({ 'alt' }, "K", function()
		self:call(yabaiPath, '-m window --focus north'):start()
	end)
	hs.hotkey.bind({ 'alt' }, "L", function()
		self:call(yabaiPath, '-m window --focus east'):start()
	end)

	-- swap directional
	hs.hotkey.bind({ 'shift', 'alt' }, "H", function()
		self:call(yabaiPath, '-m window --swap west'):start()
	end)
	hs.hotkey.bind({ 'shift', 'alt' }, "J", function()
		self:call(yabaiPath, '-m window --swap south'):start()
	end)
	hs.hotkey.bind({ 'shift', 'alt' }, "K", function()
		self:call(yabaiPath, '-m window --swap north'):start()
	end)
	hs.hotkey.bind({ 'shift', 'alt' }, "L", function()
		self:call(yabaiPath, '-m window --swap east'):start()
	end)
	-- hs.hotkey.bind({ 'alt' }, "return", function() self:call(yabaiPath, '-m window --swap first'):start() end)

	-- focus desktop
	hs.hotkey.bind({ 'alt' }, "1", function()
		self:call(yabaiPath, '-m space --focus 1'):start()
	end)
	hs.hotkey.bind({ 'alt' }, "2", function()
		self:call(yabaiPath, '-m space --focus 2'):start()
	end)
	hs.hotkey.bind({ 'alt' }, "3", function()
		self:call(yabaiPath, '-m space --focus 3'):start()
	end)
	hs.hotkey.bind({ 'alt' }, "4", function()
		self:call(yabaiPath, '-m space --focus 4'):start()
	end)
	hs.hotkey.bind({ 'alt' }, "5", function()
		self:call(yabaiPath, '-m space --focus 5'):start()
	end)
	hs.hotkey.bind({ 'alt' }, "6", function()
		self:call(yabaiPath, '-m space --focus 6'):start()
	end)
	hs.hotkey.bind({ 'alt' }, "7", function()
		self:call(yabaiPath, '-m space --focus 7'):start()
	end)
	hs.hotkey.bind({ 'alt' }, "8", function()
		self:call(yabaiPath, '-m space --focus 8'):start()
	end)
	hs.hotkey.bind({ 'alt' }, "9", function()
		self:call(yabaiPath, '-m space --focus 9'):start()
	end)

	-- move window to desktop
	hs.hotkey.bind({ 'shift', 'alt' }, "1", function()
		self:call(yabaiPath, '-m window --space 1'):start()
	end)
	hs.hotkey.bind({ 'shift', 'alt' }, "2", function()
		self:call(yabaiPath, '-m window --space 2'):start()
	end)
	hs.hotkey.bind({ 'shift', 'alt' }, "3", function()
		self:call(yabaiPath, '-m window --space 3'):start()
	end)
	hs.hotkey.bind({ 'shift', 'alt' }, "4", function()
		self:call(yabaiPath, '-m window --space 4'):start()
	end)
	hs.hotkey.bind({ 'shift', 'alt' }, "5", function()
		self:call(yabaiPath, '-m window --space 5'):start()
	end)
	hs.hotkey.bind({ 'shift', 'alt' }, "6", function()
		self:call(yabaiPath, '-m window --space 6'):start()
	end)
	hs.hotkey.bind({ 'shift', 'alt' }, "7", function()
		self:call(yabaiPath, '-m window --space 7'):start()
	end)
	hs.hotkey.bind({ 'shift', 'alt' }, "8", function()
		self:call(yabaiPath, '-m window --space 8'):start()
	end)
	hs.hotkey.bind({ 'shift', 'alt' }, "9", function()
		self:call(yabaiPath, '-m window --space 9'):start()
	end)

	-- toggles
	hs.hotkey.bind({ 'alt' }, "D", function()
		self:call(yabaiPath, '-m window --toggle zoom-parent'):start()
	end)

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
	hs.hotkey.bind(HYPER, "M", my_toggle_fullscreen)
	hs.hotkey.bind({ 'alt' }, "E", function()
		self:call(yabaiPath, '-m window --toggle split'):start()
	end)

	hs.hotkey.bind({ 'alt' }, "T", function()
		self:call(yabaiPath, '-m window --toggle float') -- :next(yabaiPath, '-m window --grid 4:4:1:1:2:2')
		    :next(yabaiPath, '-m window --grid 7:7:1:1:5:5') -- :next(yabaiPath, '-m window --grid 2:2:1:0:1:1')
		-- :next(yabaiPath, '-m window --grid 1:1:0:0:1:1')
		    :start()
	end)

	hs.hotkey.bind({ 'alt' }, "P", function()
		self:call(yabaiPath, '-m window --toggle sticky'):next(yabaiPath,
			'-m window --toggle topmost')
		    :next(yabaiPath, '-m window --toggle pip'):start()
	end)

	-- stack window
	hs.hotkey.bind({ 'ctrl', 'alt' }, "H", function()
		self:call(yabaiPath, '-m window --stack west'):start()
	end)
	hs.hotkey.bind({ 'ctrl', 'alt' }, "J", function()
		self:call(yabaiPath, '-m window --stack south'):start()
	end)
	hs.hotkey.bind({ 'ctrl', 'alt' }, "K", function()
		self:call(yabaiPath, '-m window --stack north'):start()
	end)
	hs.hotkey.bind({ 'ctrl', 'alt' }, "L", function()
		self:call(yabaiPath, '-m window --stack east'):start()
	end)

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
