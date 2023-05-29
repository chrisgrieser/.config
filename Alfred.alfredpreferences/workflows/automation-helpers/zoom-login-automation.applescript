#!/usr/bin/env osascript

-- start zoom & trigger SSO Login
on run
	tell application "zoom.us" to activate
	delay 1
	tell application "System Events"
		keystroke tab
		keystroke tab
		keystroke space
		delay 0.2
		keystroke tab
		keystroke tab
		keystroke tab
		keystroke tab
		keystroke space
	end tell

	-- this part only works on vivaldi, since it preloads
	delay 0.7
	tell application "System Events" to set frontApp to (name of first process where it is frontmost)
	if frontApp is not "Vivaldi" then return
	tell application "System Events" to
		keystroke tab
		keystroke tab
		keystroke tab
		keystroke space
	end tell
end run
