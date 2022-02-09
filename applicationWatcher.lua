-- Application Watcher
local module = {}
module.logger = hs.logger.new('applicationWatcher.lua')


local emacsCtrlSpaceSwitchIM = hs.hotkey.new('ctrl', 'space', function()
    -- hs.application.launchOrFocusByBundleID("com.gnu.Emacs")
    -- logger:d('xxxxxxxxxxxxxxxxxxxx')
    local topWindow = hs.window:frontmostWindow()
    if topWindow ~= nil then
        -- logger:d('topWindow is not nil')

        local topApp = topWindow:application()
        if topApp ~= nil then
            local bunderID = topApp:bundleID()
            logger:d('bunderID is: ', bunderID)
            if bunderID == 'org.gnu.Emacs' then
                hs.eventtap.keyStroke({
                    'ctrl',
                }, '\\')
            end
        end
    end
end
)

-- -- Define a callback function to be called when application events happen
-- local function emacsIMWatcherCallback(appName, eventType, appObject)
--   logger:d('appName: ', appName, ', eventType: ', eventType)
--   if (appName == "Emacs") then
--     if (eventType == hs.application.watcher.activated) then
--       emacsCtrlSpaceSwitchIM:enable()
--     elseif (eventType == hs.application.watcher.deactivated) then
--       emacsCtrlSpaceSwitchIM:disable()
--     end
--   else
--       emacsCtrlSpaceSwitchIM:disable()
--   end
-- end

-- Create and start the application event watcher
-- hs.application.watcher.new(emacsIMWatcherCallback):start()

-- NOTE: Use local function for any internal funciton not exported (not included as a part of the return)
local function applicationWatcher(appName, eventType, appObject)
    local emacsAppName = 'Emacs'
    local isEmacsApp = emacsAppName == appName
    
    if (eventType == hs.application.watcher.activated) then
        if (appName == "Finder") then
            appObject:selectMenuItem({"Window", "Bring All to Front"}) -- Bring all Finder windows forward when one gets activated
        elseif isEmacsApp then
          emacsCtrlSpaceSwitchIM:enable()
        end
    elseif (eventType == hs.application.watcher.deactivated) then
        if isEmacsApp then
          emacsCtrlSpaceSwitchIM:disable()
        end
    elseif (eventType == hs.application.watcher.launched) then
        if isEmacsApp then
                hs.eventtap.keyStroke({
                    'alt',
                }, 'F10')
        end
    end
end

module.watcher = hs.application.watcher.new(applicationWatcher)

module.start = function()
    module.logger.i("Starting Application Watcher")
    module.watcher:start()
    return module
end

module.stop = function()
    module.logger.i("Stopping Application Watcher")
    module.watcher:stop()
    return module
end

return module
