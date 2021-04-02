set appId to "com.xujiwei.powerjsoneditor"

tell application "System Events"
	set frontApp to first application process whose frontmost is true
	set frontAppId to bundle identifier of frontApp
	if appId = frontAppId then
		set newTabBtnDesc to "new tab"
		set mainWindow to front window of frontApp
		tell mainWindow
			set tabGroup to tab group "tab bar" of mainWindow
			if tabGroup exists then
				set newTabBtn to (first button whose description is newTabBtnDesc) of tabGroup
				if newTabBtn exists then
					click newTabBtn
				end if
			end if
		end tell
	end if
end tell
