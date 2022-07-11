#!/usr/bin/env osascript

tell application "Finder"
	set hideAfter to false
	if ((count window) is 0) or ((count window) is 1)
		set hideAfter to true
	end if
	close Finder window 1
end tell

# Hide (to lose focus)
if (hideAfter is true)
	tell application "System Events" to tell process "Finder" to set visible to false
end if
