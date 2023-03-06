#!/usr/bin/env osascript

on run argv
	-- copy image to clipboard
	set image to item 1 of argv
	set the clipboard to (POSIX file image)

	-- open imgur and wait
	tell application "Vivaldi"
		open location "https://imgur.com/upload"
		delay 0.1
		repeat until (loading of active tab of front window is false)
			delay 0.1
		end repeat
		delay 0.1
	end tell

	-- paste image
	tell application "System Events" to keystroke "v" using {command down}
end run
