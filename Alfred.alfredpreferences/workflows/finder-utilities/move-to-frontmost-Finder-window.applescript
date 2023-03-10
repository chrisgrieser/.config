#!/usr/bin/env osascript
on run argv
	set itemPath to item 1 of argv

	tell application "Finder"
		if ((count windows) = 0) then return "No Window open"
		set targetFolder to (target of window 1 as alias)

		set sourceItem to (itemPath as POSIX file)

		move sourceItem to targetFolder with replacing
	end tell
end run
