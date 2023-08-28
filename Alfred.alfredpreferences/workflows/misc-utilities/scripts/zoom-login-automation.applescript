#!/usr/bin/env osascript

-- start zoom & trigger SSO Login
tell application "zoom.us" to activate
delay 1
tell application "zoom.us" to activate # in case window switched

tell application "System Events"
	keystroke tab
	keystroke tab
	keystroke space
	delay 0.3
	keystroke tab
	delay 0.05
	keystroke tab
	delay 0.05
	keystroke tab
	delay 0.05
	keystroke tab
	delay 0.3
	keystroke space
	delay 0.3

	# tell application "Brave Browser"
	# 	repeat until (loading of active tab of front window is false)
	# 		delay 0.1
	# 	end repeat
	# end tell
	# delay 0.7
	# keystroke tab
	# key code 125 # down
	# key code 36 # return
	# key code 36 # return
end tell
