return function ()
    local runBljAppleScriptFile = hs.configdir .. "/applescript/blj2.applescript"
    hs.osascript.applescriptFromFile(runBljAppleScriptFile)
end