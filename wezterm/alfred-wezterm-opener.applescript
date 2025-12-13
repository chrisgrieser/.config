# INFO to be entered in the Alfred Terminal settings (Kept here just for reference.)
# alfredpreferences://navigateto/features>terminal
--------------------------------------------------------------------------------
# DOCS https://wezfurlong.org/wezterm/cli/cli/send-text
--------------------------------------------------------------------------------

on alfred_script(shellCmd)
	# LAUNCH WEZTERM IF NEEDED
	set i to 0 
	tell application "System Events" 
		repeat while (name of first application process whose frontmost is true) is not "wezterm-gui" 
			tell application "WezTerm" to activate # (Appname is `WezTerm`, processname is `wezterm-gui`)
			delay 0.05 
			if i > 100 then return 
		end repeat 
	end tell
	delay 0.1 # ensure wezterm-gui is ready

	# DETERMINE COMMAND
	if (text 1 thru 3 of shellCmd) is "cd " then
		set arg to text 4 thru -1 of shellCmd
		-- 1. leading space to suppress saving in shell history
		-- 2. `-q` to suppress post-cd-hook output
		set shellCmd to " builtin cd -q " & arg & " && clear"
	end if

	# SEND COMMAND
	set exportPath to "export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; "
	do shell script (exportPath & "echo " & quoted form of shellCmd & " | wezterm cli send-text --no-paste")
end alfred_script
