#!/usr/bin/env osascript

tell application "System Events"
	key code 123 using {command down, shift down} -- visual line
	keystroke "a" using {control down, shift down} -- logical line
	keystroke "c" using {command down} -- copy
end tell

delay 0.1 -- wait for clipboard
the clipboard -- direct return
