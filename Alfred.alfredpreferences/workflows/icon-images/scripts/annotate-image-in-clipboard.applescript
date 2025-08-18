#!/usr/bin/env osascript

tell application "Preview" to launch
delay 0.5 -- wait for preview to open

tell application "System Events" to tell process "Preview"
	set frontmost to true
	click menu item "New from Clipboard" of menu "File" of menu bar 1
	delay 0.5 -- wait for file to load
	click menu item "Arrow" of menu of menu item "Annotate" of menu "Tools" of menu bar 1
end tell
