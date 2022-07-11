#!/usr/bin/env osascript

on run
	if (frontmost of application "Finder" is not true) then return (system attribute "working_folder")

	tell application "Finder" to if (count of windows is 0) then return (system attribute "working_folder")

	tell application "Finder"
		set targetLocation to target of Finder window 1 as alias
		return (POSIX path of targetLocation)
	end tell
end run
