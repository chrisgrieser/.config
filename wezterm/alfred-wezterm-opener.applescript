# INFO to be entered in the Alfred Terminal settings. Kept here for reference.
--------------------------------------------------------------------------------

# q = command to be run via "Run in Terminal" command in Alfred
on alfred_script(q)
	# Launch Wezterm if needed (Appname is `WezTerm`, processname is `wezterm-gui`)
	tell application "WezTerm" to activate
	tell application "System Events"
		repeat while (name of first application process whose frontmost is true) is not "wezterm-gui"
			delay 0.05
		end repeat
	end tell

	do shell script ("export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; echo '" & q & "' | wezterm cli send-text --no-paste")
end alfred_script
