#!/usr/bin/env osascript
on run argv
	set itemID to item 1 of argv as number
	tell application "System Events" to tell (process 1 where frontmost is true)
		click menu item itemID of menu of menu item "Recent Items" of menu "Apple" of menu bar 1
	end tell
end run
