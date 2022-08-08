#!/usr/bin/env osascript
on run argv
	set output to ""

	if (frontmost of application "Brave Browser") then
		tell application "Brave Browser"
			set currentTabUrl to URL of active tab of front window
			set currentTabTitle to title of active tab of front window
		end tell
		set output to "[" & currentTabTitle & "](" & currentTabUrl & ")"
	end if

	return output
end run
