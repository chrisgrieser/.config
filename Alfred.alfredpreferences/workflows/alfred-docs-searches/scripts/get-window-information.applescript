#!/usr/bin/env osascript
tell application "System Events"
	set frontProcess to first application process whose frontmost is true
	set appName to the name of frontProcess # process to name
end tell
set appid to id of application appName # name to app to appid

# app info
set output to "APP  : " & appName & linefeed & "ID   : " & appid & linefeed & linefeed

tell application "System Events"
	# window info
	set windowCount to 0
	tell frontProcess
		repeat with win in (every window)
			set windowCount to windowCount + 1
			set header to "WINDOW " & windowCount
			set win_name to "TITLE: \"" & (name of win) & "\""
			set win_role to "ROLE : " & (role of win) & " (" & (subrole of win) & ")"
			set win_size_arr to size of win
			set win_size to "SIZE : " & (item 1 of win_size_arr as text) & "x" & (item 2 of win_size_arr as text)
			set output to output & header & linefeed & win_name & linefeed & win_role & linefeed & win_size ¬
					& linefeed & linefeed
		end repeat
	end tell
end tell

output -- direct return
