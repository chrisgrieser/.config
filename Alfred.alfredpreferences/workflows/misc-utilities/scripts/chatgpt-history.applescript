#!/usr/bin/env osascript

on run(argv)
	set input to argv as string
	open location "https://chatgpt.com/"
	set the clipboard to input

	tell application "Brave Browser"
		repeat until (loading of active tab of front window is false)
			delay 0.1
		end repeat
	end tell

	tell application "System Events"
		delay 0.1
		keystroke "k" using {command down} -- open search
		delay 0.3
		keystroke "v" using {command down} -- paste
	end tell
end
