#!/usr/bin/env osascript
on run argv
	set selectedTool to item 1 of argv
	tell application "System Events" to set frontApp to (name of first process where it is frontmost)
	tell application "System Events" to tell process frontApp
		try
			set isEnabled to enabled of (menu item selectedTool of menu of menu item "Writing Tools" of menu "Edit" of menu bar 1)
			if not isEnabled then return "Writing tools not available for " & quoted form of frontApp & "."
			click (menu item selectedTool of menu of menu item "Writing Tools" of menu "Edit" of menu bar 1)
			-- Without return statement, AppleScript implicitly returns message on 
			-- previous line, which in this case is a report on the clicking of menu 
			-- items. Thus empty return is needed.
			return
		on error
			return "Writing tools not available in your country, or macOS version."
		end try
	end tell
end run
