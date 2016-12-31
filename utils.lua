local utils = {}

-- Helper functions

-- Toggle an application between being the frontmost app, and being hidden
function utils.toggle_application(_app)
    local app = hs.appfinder.appFromName(_app)
    if not app then
        -- FIXME: This should really launch _app
        return
    end
    local mainwin = app:mainWindow()
    if mainwin then
        if mainwin == hs.window.focusedWindow() then
            mainwin:application():hide()
        else
            mainwin:application():activate(true)
            mainwin:application():unhide()
            mainwin:focus()
        end
    end
end

return utils
