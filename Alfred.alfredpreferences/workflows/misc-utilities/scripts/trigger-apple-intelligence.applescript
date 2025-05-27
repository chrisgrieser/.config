#!/usr/bin/env osascript
on run argv
	set instruction to item 1 of argv

	tell application "System Events" to set frontApp to (name of first process where it is frontmost)

	tell application "System Events" to tell process frontapp
		set frontmost to true -- FIX app loosing focus due to Alfred's compatibility mode
		delay 0.1
		try
			set isEnabled to enabled of (menu item instruction of menu of menu item "Writing Tools" of menu "Edit" of menu bar 1)
			if not isEnabled then return "Writing tools not available for " & quoted form of frontapp & "."
			click (menu item instruction of menu of menu item "Writing Tools" of menu "Edit" of menu bar 1)
			-- Without return statement, AppleScript implicitly returns the message on
			-- previous line, which in this case is a report on the clicking of menu
			-- items. Thus empty return is needed.
			return
		on error
			return "Writing tools not available in your country or macOS version."
		end try
	end tell
end run
