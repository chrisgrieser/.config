#!/usr/bin/env osascript
tell application "System Events"
	set frontApp to (name of first process where it is frontmost)
	if (frontApp = "PDF Expert") then tell process frontApp to click menu item "Day" of menu of menu item "Theme" of menu "View" of menu bar 1
	if (frontApp = "Highlights") then tell process "Highlights" to click menu item "Default" of menu of menu item "PDF Appearance" of menu "View" of menu bar 1
end tell
