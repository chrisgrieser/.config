#!/usr/bin/env osascript

# INFO use "Finder window" instead of "window" to target only regular
# windows https://www.reddit.com/r/applescript/comments/uz9axo/comment/iayjrn4/?context=3

on run argv
	set itemPath to item 1 of argv

	tell application "Finder"
		if ((count Finder windows) = 0) then return "No Window open"
		set targetFolder to (target of Finder window 1 as alias)

		set sourceItem to (itemPath as POSIX file)
		move sourceItem to targetFolder with replacing

	end tell
end run
