#!/usr/bin/env osascript
on run argv
	set itemPath to ((item 1 of argv) as POSIX file)
	tell application "Finder" to delete itemPath
end run
