-- A global variable for Hyper Mode
-- hyperMode = hs.hotkey.modal.new({}, 'F18')

-- -- Keybindings for launching apps in Hyper Mode
-- hyperModeAppMappings = {
--   { 'a', 'iTunes' },            -- "A" for "Apple Music"
--   { 'b', 'Google Chrome' },     -- "B" for "Browser"
--   -- { 'c', 'Slack' },             -- "C for "Chat"
--   -- { 'd', 'Remember The Milk' }, -- "D" for "Do!" ... or "Done!"
--   { 'e', 'Emacs' },         -- "E" for "Editor"
--   { 'f', 'Finder' },            -- "F" for "Finder"
--   { 'g', 'Mailplane 3' },       -- "G" for "Gmail"
--   { 't', 'iTerm' },             -- "T" for "Terminal"
-- }

-- for i, mapping in ipairs(hyperModeAppMappings) do
--   hyperMode:bind({}, mapping[1], function()
--     hs.application.launchOrFocus(mapping[2])
--   end)
-- end

-- -- Enter Hyper Mode when F17 (right option key) is pressed
-- pressedF17 = function()
--   hyperMode:enter()
-- end

-- -- Leave Hyper Mode when F17 (right option key) is released.
-- releasedF17 = function()
--   hyperMode:exit()
-- end

-- -- Bind the Hyper key
-- f17 = hs.hotkey.bind({}, 'F17', pressedF17, releasedF17)


-- -- Launch iTerm2 by pressing alt-space
-- globals["hotkey"]["iTerm"] = hs.hotkey.new({"alt"}, "space", function()
--     hs.application.open("com.googlecode.iterm2")
-- end)

-- -- Enable the hotkey if iTerm2 is not running
-- if not hs.application.find("iTerm") then
--     globals["hotkey"]["iTerm"]:enable()
-- end
