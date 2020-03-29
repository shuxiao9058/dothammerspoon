return function ()
    local runBljAppleScriptFile = hs.configdir .. "/applescript/blj.applescript"
    hs.osascript.applescriptFromFile(runBljAppleScriptFile)
end