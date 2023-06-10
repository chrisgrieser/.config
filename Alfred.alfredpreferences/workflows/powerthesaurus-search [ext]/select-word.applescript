#!/usr/bin/env osascript

-- workaround, since apple's float ("real") interpret , or . differently
-- depending on system language m( ...
set delayAmount to (system attribute "delay_ms") as number
set delayAmount to delayAmount/1000

tell application "System Events"
	key code 123 -- char left
	key code 124 using {option down} -- word right
	key code 123 using {option down, shift down} -- word left selection
	keystroke "c" using {command down} -- copy
end tell
delay delayAmount

the clipboard -- direct return
