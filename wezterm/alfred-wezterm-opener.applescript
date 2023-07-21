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
	
	# PATH modification needed for intel macs
	do shell script ("export PATH=:/usr/local/bin:$PATH ; echo '" & shellCmd & "' | wezterm cli send-text --no-paste")
end alfred_script
