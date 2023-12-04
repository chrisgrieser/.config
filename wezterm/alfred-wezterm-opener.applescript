# INFO to be entered in the Alfred Terminal settings (Kept here just for reference.)
# alfredpreferences://navigateto/features>terminal
--------------------------------------------------------------------------------

on alfred_script(shellCmd)
	tell application "System Events" 
		set weztermRunning to (name of processes) contains "wezterm-gui"
	end tell
	set isCd to(text 1 thru 3 of shellCmd) is "cd "
	set setPath to "export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; "

	if isCd then
		set dir to text 4 thru -1 of shellCmd
		if weztermRunning then
			do shell script (setPath & "wezterm start --cwd " & quoted form of dir)
		else
			do shell script (setPath & "builtin cd -q " & quoted form of shellCmd & " | wezterm cli send-text --no-paste")
		end
	else
		if weztermRunning then
		else
			do shell script ("export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ;" ¬
			& "echo '" & shellCmd & "' | wezterm cli send-text --no-paste")
		end if
		set arg to text 4 thru -1 of shellCmd
	else

	else
		# Launch Wezterm if needed (Appname is `WezTerm`, processname is `wezterm-gui`)
		tell application "WezTerm" to activate
		tell application "System Events"
			repeat while (name of first application process whose frontmost is true) is not "wezterm-gui"
				delay 0.05
			end repeat
		end tell
		delay 0.1 # ensure wezterm-gui is ready
		do shell script ("export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ;" ¬
			& "echo '" & shellCmd & "' | wezterm cli send-text --no-paste")
	end if


end alfred_script
