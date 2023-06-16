#!/usr/bin/env osascript

-- start zoom & trigger SSO Login
tell application "zoom.us" to activate
delay 1.5
tell application "zoom.us" to activate # in case window switched

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

	-- this part only works on vivaldi, since it fills the forms properly
	delay 0.7
	set frontApp to (name of first process where it is frontmost)
	if frontApp is not "Vivaldi" then return
	keystroke tab
	keystroke tab
	keystroke tab
	keystroke space
end tell
