#!/usr/bin/env osascript

# requires vimium/surfingkeys
tell application "YouTube" to activate
tell application "System Events"
	key code 53
	key code 53
	delay 0.5
	keystroke "g"
	keystroke "U"
end tell
