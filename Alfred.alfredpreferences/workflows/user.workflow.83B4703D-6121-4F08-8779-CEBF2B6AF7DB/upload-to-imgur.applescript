#!/usr/bin/env osascript

tell application "Vivaldi"
	open locaton "https://imgur.com/upload"
	repeat until (loading of active tab of front window is false)
		delay 0.1
	end repeat
end tell
