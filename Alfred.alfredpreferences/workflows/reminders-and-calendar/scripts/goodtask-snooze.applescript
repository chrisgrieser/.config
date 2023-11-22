#!/usr/bin/env osascript

tell application "System Events" to tell process "GoodTask"
	set frontmost to true
	click menu item "Tomorrow" of menu of menu item "Quick Actions" of menu "Edit" of menu bar 1
end tell
