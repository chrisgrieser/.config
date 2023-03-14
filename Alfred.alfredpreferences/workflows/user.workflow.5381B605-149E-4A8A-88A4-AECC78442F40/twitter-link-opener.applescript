#!/usr/bin/env osascript
on run argv
	# set num to argv as number
	set num to 1

	tell application "System Events"
		tell process "Twitter" 
			set frontmost to true
			click menu item "Go to Top" of menu "View" of menu bar 1
		end tell
		key code 126 -- ensure we are at top
		key code 126 
		key code 126 
		repeat num times -- select nth tweet from top
			key code 125
		end repeat

		delay 0.2
		# keystroke "k" using {command down}
		tell process "Twitter" to click menu item "Open Link" of menu "Tweet" of menu bar 1
	end tell

end run
