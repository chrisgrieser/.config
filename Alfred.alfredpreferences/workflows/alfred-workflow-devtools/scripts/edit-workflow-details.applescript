#!/usr/bin/env osascript
tell application "System Events" to tell process "Alfred Preferences"
	tell table 1 of scroll area 1 of splitter group 1 of window "Alfred Preferences"
		perform action "AXShowMenu"
end tell
	delay 0.3
	keystroke "Edit"
	key code 36 -- Enter
end tell
