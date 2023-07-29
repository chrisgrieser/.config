# INFO to be entered in the Alfred Terminal settings
# alfredpreferences://navigateto/features>terminal
# (Kept here just for reference.)
--------------------------------------------------------------------------------

on alfred_script(shellCmd)
	# Launch Wezterm if needed (Appname is `WezTerm`, processname is `wezterm-gui`)
	tell application "WezTerm" to activate
	tell application "System Events"
		repeat while (name of first application process whose frontmost is true) is not "wezterm-gui"
			delay 0.05
		end repeat
	end tell

	# Add `clear` if it is just a `cd` command, because it looks cleaner
	set command to text 1 thru 2 of shellCmd
	set isMultiCmd to (shellCmd contains "|" or shellCmd contains "&&" or shellCmd contains ";")
	if command is "cd" and not isMultiCmd then 
		set shellCmd to shellCmd & " && clear"
	end if

	do shell script ("export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; echo '" & shellCmd & "' | wezterm cli send-text --no-paste")
end alfred_script
