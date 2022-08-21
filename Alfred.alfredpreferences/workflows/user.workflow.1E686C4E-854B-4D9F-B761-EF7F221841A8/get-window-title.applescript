#!/usr/bin/env osascript
tell application "System Events" to set frontAppProcess to first application process whose frontmost is true

# Tell the *process* to count its windows and return its front window's name.
tell frontAppProcess
	if (count of windows) > 0 then
		set window_name to name of front window
	end if
end tell

set the clipboard to window_name

# direct return for displaying in Alfred
window_name
