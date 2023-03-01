#!/usr/bin/env osascript

tell application "System Events"
	key code 123 -- char left
	key code 124 using {option down} -- word right
	key code 123 using {option down, shift down} -- word left selection
	keystroke "c" using {command down} -- copy
end tell
delay 1

the clipboard -- direct return
