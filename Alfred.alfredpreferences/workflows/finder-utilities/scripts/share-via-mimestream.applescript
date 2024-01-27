#!/usr/bin/env osascript
tell application "System Events"
	tell process "Finder"
		set frontmost to true
		click menu item "Share…" of menu "File" of menu bar 1
	end tell
	delay 0.1
	key code 48 # tab
	delay 0.1
	key code 48 # tab
	delay 0.1
	key code 49 # spacebar
end tell
