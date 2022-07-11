#!/usr/bin/env osascript

on run argv
	set distance to argv as number
	tell application "System Events"
		keystroke tab
		delay 0.1
		repeat distance times
			key code 126
			delay 0.05
		end repeat
	end tell
end run
