# INFO to be entered in the Alfred Terminal settings. Kept here for reference.
--------------------------------------------------------------------------------

on alfred_script(shellCommand) 
	# Launch Wezterm if needed (Appname is `WezTerm`, processname is `wezterm-gui`)
	tell application "WezTerm" to activate
	tell application "System Events"
		repeat while (name of first application process whose frontmost is true) is not "wezterm-gui"
			delay 0.05
		end repeat
	end tell

	do shell script ("echo '" & shellCommand & "' | wezterm cli send-text --no-paste")
end alfred_script
