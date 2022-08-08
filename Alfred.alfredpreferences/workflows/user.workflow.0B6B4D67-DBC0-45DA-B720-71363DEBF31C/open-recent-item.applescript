#!/usr/bin/env osascript
on run argv

	set input to item 1 of argv
	set itemID to ((characters 2 thru -1 of input) as number)
	set type to ((character 1 of input) as text)

	tell application "System Events" to tell process "Finder"
		if (type is "f") then
			click menu item itemID of menu of menu item "Recent Items" of menu "Apple" of menu bar 1
		else
			set frontmost to true
			click menu item itemID of menu of menu item "Recent Folders" of menu "Go" of menu bar 1
		end if
	end tell

	-- for whatever reason, this only works reliably when separated from the if clauses above m(
	if (type is "p") then
		tell application "System Events"
			tell process "Finder"
				set frontmost to true
				click menu item "Enclosing Folder" of menu "Go" of menu bar 1
			end tell
		end tell
	end if


end run

