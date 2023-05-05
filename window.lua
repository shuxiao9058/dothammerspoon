local M = {}

local json_encode = hs.json.encode
local json_decode = hs.json.decode

local yabai_helper = require("yabai_helper")

local log = hs.logger.new("window")
log.setLogLevel("debug")

local max_space = 6
local remove_extra_spaces

local function getFrontApplicationName()
	local win = hs.window.focusedWindow()
	if (win == nil) or (win:id() == nil) then
		return
	end
	local app = win:application()
	return app:name()
end

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

-- get all yabai spaces
local _get_all_yabai_spaces = function(self, force)
	log.df("get all yabai spaces")

	local yabai_spaces
	local query_str = "-m query --spaces"
	local now_sec = os.time()
	local cache_time = self.spaces_info and self.spaces_info.cache_time
	if force or (not cache_time or (cache_time and now_sec - cache_time > 300)) then -- cache 5 minutes
		local task = yabai_helper:call(query_str):start():waitUntilFinished()
		if task and task.result and task.result.json then
			yabai_spaces = task.result.json
			self.spaces_info = {
				cache_time = now_sec,
				spaces = yabai_spaces,
			}
			-- log.df("spaces info: %s", json_encode(self.spaces_info))
		end
	end

	return yabai_spaces or (self.spaces_info and self.spaces_info.spaces)
end

-- label if label is nil, then get current active space
local _get_active_yabai_space = function(self)
	local yabai_spaces = self:get_all_yabai_spaces(true)
	if yabai_spaces == nil then
		return
	end

	for k, v in ipairs(yabai_spaces) do
		if v["has-focus"] then
			return v
		end
	end

	log.df("can not get active yabai space: %s", json_encode(yabai_spaces))
end

local _get_space_with_label = function(self, label)
	if not label or label == "" then
		return
	end
	local yabai_spaces = self:get_all_yabai_spaces(false)
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
					id64 = v.id64,
				}
			end
		end

		local current_space = monitor["Current Space"]
		if not current_space then
			return
		end

		if current_space.uuid == space_uuid then
			return {
				uuid = space_uuid,
				mId = current_space.ManagedSpaceID,
				id64 = current_space.id64,
				-- isActive = true
			}
		end
	end

	self.spaces_info = nil
end

function M:get_yabai_window()
	local query_str = "-m query --windows --window"
	local task = yabai_helper:call(query_str):start():waitUntilFinished()
	local result = task and task.result
	if result and result.json then
		-- log.df("task result: %s", json_encode(result.json))
		-- -- log.df("task exitCode: %d, stdout: %s, stdErr: %s",
		-- -- 	result.exitCode, result.stdOut, result.stdErr)
		return result.json
	else
		log.df("task stdOut is nil")
	end
end

function M:my_toggle_fullscreen(force)
	if getFrontApplicationName() == "Emacs" then
		hs.eventtap.keyStroke({ "alt" }, "F10")
	else
		local space = M:get_active_yabai_space()
		-- log.df("space is: %s", json_encode(space or {}))
		if space and space.type == "bsp" then
			local window = M:get_yabai_window()
			if window then
				log.df("window is: %s", json_encode(window))

				if force then
					if window["is-native-fullscreen"] then
						return
					end
				end

				if (not window["is-floating"] and force) or not force then
					-- make window to float
					yabai_helper:call("-m window --toggle float"):start():waitUntilFinished()
				end
			end

			yabai_helper:call("-m window --toggle zoom-fullscreen"):start()
		else
			local app = require("app.app")
			app:toggleMaximized(nil, nil, force)
		end
	end
end

function M:force_fullscreen()
	M:my_toggle_fullscreen(true)
end

M.get_space_with_label = _get_space_with_label

M.get_all_yabai_spaces = _get_all_yabai_spaces

M.get_active_yabai_space = _get_active_yabai_space

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
	--   yabai_helper:call( '-m window --focus stack.prev')
	--       :catch(yabaiPath, '-m window --focus stack.last')
	--       :catch(yabaiPath, '-m window --focus prev')
	--       :catch(yabaiPath, '-m window --focus last')
	--       :start()
	-- end)

	-- make floating window fill half of screen
	hs.hotkey.bind({ "shift", "alt" }, "right", function()
		yabai_helper:call("-m window --grid 1:2:1:0:1:1"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "left", function()
		yabai_helper:call("-m window --grid 1:2:0:1:1:1"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "down", function()
		yabai_helper:call("-m window --grid 2:1:1:1:1:1"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "up", function()
		yabai_helper:call("-m window --grid 2:1:1:0:1:1"):start()
	end)

	-- destroy desktop
	hs.hotkey.bind({ "cmd", "alt" }, "w", function()
		yabai_helper:call("-m space --destroy"):start()
	end)
	-- rotate tree
	hs.hotkey.bind("alt", "r", function()
		yabai_helper:call("-m space --rotate 90"):start()
	end)

	-- fast focus desktop
	hs.hotkey.bind({ "cmd", "alt" }, "x", function()
		yabai_helper:call("-m pace --focus recent"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "z", function()
		yabai_helper:call("-m pace -focus prev"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "c", function()
		yabai_helper:call("-m pace -focus next"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "1", function()
		yabai_helper:call("-m pace -focus 1"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "2", function()
		yabai_helper:call("-m pace -focus 2"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "3", function()
		yabai_helper:call("-m pace -focus 3"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "4", function()
		yabai_helper:call("-m space -focus 4"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "5", function()
		yabai_helper:call("-m space --focus 5"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "6", function()
		yabai_helper:call("-m space --focus 6"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "7", function()
		yabai_helper:call("-m space --focus 7"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "8", function()
		yabai_helper:call("-m space -focus 8"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "9", function()
		yabai_helper:call("-m space -focus 9"):start()
	end)
	hs.hotkey.bind({ "cmd", "alt" }, "0", function()
		yabai_helper:call("-m space --focus 0"):start()
	end)

	-- focus directional
	hs.hotkey.bind({ "alt" }, "H", function()
		yabai_helper:call("-m window --focus west"):start()
	end)
	hs.hotkey.bind({ "alt" }, "J", function()
		yabai_helper:call("-m window --focus south"):start()
	end)
	hs.hotkey.bind({ "alt" }, "K", function()
		yabai_helper:call("-m window --focus north"):start()
	end)
	hs.hotkey.bind({ "alt" }, "L", function()
		yabai_helper:call("-m window --focus east"):start()
	end)

	-- swap directional
	hs.hotkey.bind({ "shift", "alt" }, "H", function()
		yabai_helper:call("-m window --swap west"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "J", function()
		yabai_helper:call("-m window --swap south"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "K", function()
		yabai_helper:call("-m window --swap north"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "L", function()
		yabai_helper:call("-m window --swap east"):start()
	end)
	-- hs.hotkey.bind({ 'alt' }, "return", function() yabai_helper:call( '-m window --swap first'):start() end)

	-- focus desktop
	hs.hotkey.bind(HYPER_MINUS_SHIFT, "1", function()
		yabai_helper:call("-m space --focus 1"):start()
	end)
	hs.hotkey.bind(HYPER_MINUS_SHIFT, "2", function()
		yabai_helper:call("-m space --focus 2"):start()
	end)
	hs.hotkey.bind(HYPER_MINUS_SHIFT, "3", function()
		yabai_helper:call("-m space --focus 3"):start()
	end)
	hs.hotkey.bind(HYPER_MINUS_SHIFT, "4", function()
		yabai_helper:call("-m space --focus 4"):start()
	end)
	hs.hotkey.bind(HYPER_MINUS_SHIFT, "5", function()
		yabai_helper:call("-m space --focus 5"):start()
	end)
	hs.hotkey.bind(HYPER_MINUS_SHIFT, "6", function()
		yabai_helper:call("-m space --focus 6"):start()
	end)
	hs.hotkey.bind(HYPER_MINUS_SHIFT, "7", function()
		yabai_helper:call("-m space --focus 7"):start()
	end)
	hs.hotkey.bind(HYPER_MINUS_SHIFT, "8", function()
		yabai_helper:call("-m space --focus 8"):start()
	end)
	hs.hotkey.bind(HYPER_MINUS_SHIFT, "9", function()
		yabai_helper:call("-m space --focus 9"):start()
	end)

	-- move window to desktop
	hs.hotkey.bind({ "shift", "alt" }, "1", function()
		yabai_helper:call("-m window --space 1"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "2", function()
		yabai_helper:call("-m window --space 2"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "3", function()
		yabai_helper:call("-m window --space 3"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "4", function()
		yabai_helper:call("-m window --space 4"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "5", function()
		yabai_helper:call("-m window --space 5"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "6", function()
		yabai_helper:call("-m window --space 6"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "7", function()
		yabai_helper:call("-m window --space 7"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "8", function()
		yabai_helper:call("-m window --space 8"):start()
	end)
	hs.hotkey.bind({ "shift", "alt" }, "9", function()
		yabai_helper:call("-m window --space 9"):start()
	end)

	-- toggles
	hs.hotkey.bind({ "alt" }, "D", function()
		yabai_helper:call("-m window --toggle zoom-parent"):start()
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
	hs.hotkey.bind(HYPER, "M", function()
		M:my_toggle_fullscreen(false)
	end)
	hs.hotkey.bind({ "alt" }, "E", function()
		yabai_helper:call("-m window --toggle split"):start()
	end)

	hs.hotkey.bind({ "alt" }, "T", function()
		yabai_helper
		    :call("-m window --toggle float") -- :next(yabaiPath, '-m window --grid 4:4:1:1:2:2')
		    :next("-m window --grid 7:7:1:1:5:5") -- :next(yabaiPath, '-m window --grid 2:2:1:0:1:1')			-- :next(yabaiPath, '-m window --grid 1:1:0:0:1:1')

		    :start()
	end)

	hs.hotkey.bind({ "alt" }, "P", function()
		yabai_helper
		    :call("-m window --toggle sticky")
		    :next("-m window --toggle topmost")
		    :next("-m window --toggle pip")
		    :start()
	end)

	-- stack window
	hs.hotkey.bind({ "ctrl", "alt" }, "H", function()
		yabai_helper:call("-m window --stack west"):start()
	end)
	hs.hotkey.bind({ "ctrl", "alt" }, "J", function()
		yabai_helper:call("-m window --stack south"):start()
	end)
	hs.hotkey.bind({ "ctrl", "alt" }, "K", function()
		yabai_helper:call("-m window --stack north"):start()
	end)
	hs.hotkey.bind({ "ctrl", "alt" }, "L", function()
		yabai_helper:call("-m window --stack east"):start()
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
