#!/usr/bin/env osascript

tell application "System Events"
	key code 123 using {command down, shift down} -- word left selection
	keystroke "c" using {command down} -- copy
	delay 0.1 -- wait for clipboard
end tell

the clipboard -- direct return
