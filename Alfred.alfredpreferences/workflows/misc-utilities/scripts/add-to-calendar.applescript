#!/usr/bin/env osascript

on run argv
	set the clipboard to item 1 of argv
	tell application "Calendar" to activate

	tell application "System Events" to tell process "Calendar"
		-- wait till Calendar is ready
		set frontmost to true
		repeat until ((count of windows) > 0)
			delay 0.1
		end repeat

		-- insert text
		click menu item "New Event or Reminder" of menu "File" of menu bar 1
		delay 0.1
		keystroke "v" using {command down}
		delay 0.25
		key code 36 -- enter
	end tell
end run
