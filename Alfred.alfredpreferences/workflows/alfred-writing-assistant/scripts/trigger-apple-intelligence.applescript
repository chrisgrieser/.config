#!/usr/bin/env osascript
on run argv
	set selectedTool to item 1 of argv
	try
		tell application "System Events" to tell (first process where it is frontmost) 
			click menu item selectedTool of menu of menu item "Writing Tools" of menu "Edit" of menu bar 1 
		end tell
	on error errorText
		-- log "Apple Intelligence error: " & errorText
		-- for Alfred notification
		return "Apple Intelligence writing tools not available in the country, macOS version, or app."
	end try
end run
