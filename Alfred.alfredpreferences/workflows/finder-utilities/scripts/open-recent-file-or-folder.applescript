#!/usr/bin/env osascript
on run argv

	set input to item 1 of argv
	set itemID to ((characters 2 thru -1 of input) as string as number)
	set ftype to ((character 1 of input) as text)

	tell application "Finder" to launch -- ensure Finder runs

	tell application "System Events" to tell process "Finder"
		set frontmost to true
		if (ftype is "f") then
			click menu item itemID of menu of menu item "Recent Items" of menu "Apple" of menu bar 1
		else
			click menu item itemID of menu of menu item "Recent Folders" of menu "Go" of menu bar 1
		end if
	end tell

end run

