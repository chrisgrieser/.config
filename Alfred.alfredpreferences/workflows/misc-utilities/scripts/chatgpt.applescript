#!/usr/bin/env osascript

on run argv
	set query to argv as string
	tell application "Brave Browser"
		open location "https://chatgpt.com/?prompt=" & query
		repeat until (loading of active tab of front window is false)
			delay 0.1
		end repeat
	end tell
	tell application "System Events" to key code 36 -- return
end run
