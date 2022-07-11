#!/usr/bin/env osascript

tell application "System Events"
	tell process "Brave Browser"
		set frontmost to true
		click menu item "Move Tab to New Window" of menu "Tab" of menu bar 1
	end tell
end tell

