#!/usr/bin/env osascript

tell application "YouTube" to activate
tell application "System Events"
	key code 53 -- escape
	delay 0.5
	key code 53 -- escape
	delay 0.5

	-- goto home via vimium/surfingkeys
	keystroke "g"
	keystroke "U"
end tell
