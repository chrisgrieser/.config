#!/usr/bin/env osascript

tell application "System Events"
	-- cmd+alt+f5
	key code 96 using {command down, option down}
	beep
end tell
