#!/usr/bin/env osascript
# INFO Inpect UI-element-paths https://www.sudoade.com/gui-scripting-with-applescript/
--------------------------------------------------------------------------------

on run argv
	set query to item 1 of argv
	set the clipboard to query

	tell application "System Events" 
		tell process "Catch"
			tell menu bar item 1 of menu bar 1
				click
				click menu item "Preferences…" of menu 1
			end tell

			delay 0.5
			click button 1 of group 1 of window 1 -- click "Add Feed" button
		end

		key code 48 -- `tab` to URL field
		delay 0.1 -- wait for clipboard
		keystroke "v" using {command down}
		delay 0.1
		key code 48 using {shift down} -- shift-tab back to name
	end tell
end run
