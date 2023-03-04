#!/usr/bin/env osascript

tell application "System Events"
	key code 123 using {command down, shift down} -- word left selection
	keystroke "c" using {command down} -- copy
end tell

delay 0.1 -- wait for clipboard
the clipboard -- direct return
