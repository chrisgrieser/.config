# INFO to be entered in the Alfred Terminal settings (Kept here just for reference.)
# alfredpreferences://navigateto/features>terminal
--------------------------------------------------------------------------------

on alfred_script(shellCmd)
	# Launch Wezterm if needed (Appname is `WezTerm`, processname is `wezterm-gui`)
	tell application "WezTerm" to activate
	tell application "System Events"
		repeat while (name of first application process whose frontmost is true) is not "wezterm-gui"
			delay 0.05
		end repeat
	end tell

	# 1. use builtin to not trigger aliases, `-q` to suppress hooks (chpwd)
	# 2. Add `clear` to suppress the entering message
	# 3. Add leading space, so it is not saved to the history due HIST_IGNORE_SPACE
	if (text 1 thru 3 of shellCmd) is "cd " then
		set arg to text 4 thru -1 of shellCmd
		set shellCmd to " builtin cd -q " & arg & " && clear"
	end if

	# DOCS https://wezfurlong.org/wezterm/cli/cli/send-text
	do shell script ("export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ;" ¬
		& "echo '" & shellCmd & "' | wezterm cli send-text --no-paste")
end alfred_script
