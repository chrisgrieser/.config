#!/usr/bin/env osascript
tell application "System Events"
	set frontProcess to first application process whose frontmost is true
	set appName to the name of frontProcess # process to name
end tell
set appid to id of application appName # name to app to appid

set br to (linefeed & linefeed)

# app info
set output to "# App: " & appName & br & "- **bundle id**: " & appid & br

tell application "System Events"
	# window info
	set windowCount to 0
	tell frontProcess
		repeat with win in (every window)
			set windowCount to windowCount + 1
			set header to "### Window " & windowCount
			set win_name to "- **title**: \"" & (name of win) & "\""
			set win_role to "- **role**: " & (role of win) & " (" & (subrole of win) & ")"
			set win_size_arr to size of win
			set win_size to "- **size**: " & (item 1 of win_size_arr as text) & "x" & (item 2 of win_size_arr as text)
			set output to output & header & br & win_name & br & win_role & br & win_size & br & br
		end repeat
	end tell
end tell

output -- direct return
