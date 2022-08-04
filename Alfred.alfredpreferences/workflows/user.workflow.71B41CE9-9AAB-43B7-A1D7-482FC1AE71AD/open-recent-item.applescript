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
			-- click menu item "Enclosing Folder" of menu "Go" of menu bar 1
			if (type is "p") then
				click menu item "Enclosing Folder" of menu "Go" of menu bar 1
			end if
		end if
	end tell

	return type is "p"

end run

