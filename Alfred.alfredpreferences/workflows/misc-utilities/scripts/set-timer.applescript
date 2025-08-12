#!/usr/bin/env osascript
on run argv
	set minutes to item 1 of argv
	open location "https://www.timerminutes.com/" & minutes & "-minutes-timer"
	delay 0.1

	# wait until tab is loaded
	tell application "Brave Browser"
		repeat until (loading of active tab of front window is false)
			delay 0.1
		end repeat
	end tell

	tell application "System Events" 
		key code 48 # tab
		key code 48 # tab
		delay 0.1
		key code 36 # return
	end tell
end run
