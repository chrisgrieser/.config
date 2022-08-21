#!/usr/bin/env osascript
tell application "System Events"
	set frontAppProcess to first application process whose frontmost is true

	tell frontAppProcess
		set win to front window
		set win_name to "\"" & (name of win)& "\""
		set win_role to (role of win) & " (" & (subrole of win) & ")"
		set win_size_arr to (size of win)
		set win_size to (item 1 of win_size_arr as text) & "x" & (item 2 of win_size_arr as text)
	end tell
end tell

set the clipboard to win_name

# direct return for displaying in Alfred
win_name & "\n" & win_size & "\n" & win_role

