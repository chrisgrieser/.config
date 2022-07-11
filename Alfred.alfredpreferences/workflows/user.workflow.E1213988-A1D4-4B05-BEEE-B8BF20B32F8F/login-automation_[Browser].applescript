#!/usr/bin/env osascript

-- start zoom & trigger SSO Login
tell application "zoom.us" to activate
delay 1
tell application "System Events"
	keystroke tab
	keystroke space
	delay 0.2
	keystroke tab
	keystroke tab
	keystroke tab
	keystroke tab
	keystroke space
	delay 0.7
	keystroke return
end tell

