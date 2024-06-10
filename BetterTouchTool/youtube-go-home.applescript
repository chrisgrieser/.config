#!/usr/bin/env osascript

# requires vimium
tell application "YouTube" to activate
tell application "System Events"
	key code 53
	key code 53
	delay 0.3
	keystroke "g"
	keystroke "U"
end tell
