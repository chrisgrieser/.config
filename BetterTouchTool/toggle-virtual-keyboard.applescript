#!/usr/bin/env osascript

-- prevent accidentally triggering this when not on Projector
tell application "Image Events"
	launch
	set countDisplays to count displays
	quit
end tell
if countDisplays > 1 then
	-- cmd+alt+f5
	tell application "System Events" to key code 96 using {command down, option down}
end if
