#!/usr/bin/env osascript
tell application "System Events"
	set frontApp to first application process whose frontmost is true
	set appName to the name of frontApp
	set output to appName & "\n\n"

	tell frontApp
		repeat with win in (every window)
			set win_name to "\"" & (name of win) & "\""
			set win_role to (role of win) & " (" & (subrole of win) & ")"
			set win_size_arr to (size of win)
			set win_size to (item 1 of win_size_arr as text) & "x" & (item 2 of win_size_arr as text)
			set output to output & win_name & "\n" & win_size & "\n" & win_role & "\n\n"
		end repeat
	end tell
end tell

output -- direct return

