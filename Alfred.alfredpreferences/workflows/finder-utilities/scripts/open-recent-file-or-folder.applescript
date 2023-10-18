#!/usr/bin/env osascript
on run argv

	set theType to (system attribute "type")
	set itemID to (item 1 of argv as number)

	tell application "System Events" to tell process "Finder"
		set frontmost to true
		if (theType is "file") then
			click menu item itemID of menu of menu item "Recent Items" of menu "Apple" of menu bar 1
		else
			click menu item itemID of menu of menu item "Recent Folders" of menu "Go" of menu bar 1
		end if
	end tell

end run

