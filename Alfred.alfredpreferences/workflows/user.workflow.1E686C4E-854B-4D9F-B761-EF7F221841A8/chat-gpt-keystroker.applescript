#!/usr/bin/env osascript

on run argv
	set input to argv as string
	open location "https://chat.openai.com/chat"
	delay 0.02

	tell application "Brave Browser"
		repeat until (loading of active tab of front window is false)
			delay 0.1
		end repeat
	end tell
	tell application "System Events"
		keystroke tab
	end tell
end run
