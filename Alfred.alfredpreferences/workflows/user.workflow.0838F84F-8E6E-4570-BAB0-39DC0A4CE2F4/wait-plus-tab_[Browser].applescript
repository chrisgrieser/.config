#!/usr/bin/env osascript
delay 0.1
tell application "Brave Browser"
	repeat until (loading of active tab of front window is false)
		delay 0.05
	end repeat
end tell

tell application "System Events" to keystroke tab
