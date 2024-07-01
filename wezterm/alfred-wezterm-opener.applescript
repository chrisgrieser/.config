# INFO to be entered in the Alfred Terminal settings (Kept here just for reference.)
# alfredpreferences://navigateto/features>terminal
--------------------------------------------------------------------------------
# DOCS https://wezfurlong.org/wezterm/cli/cli/send-text
--------------------------------------------------------------------------------

on alfred_script(shellCmd)
	# LAUNCH WEZTERM IF NEEDED
	# (Appname is `WezTerm`, processname is `wezterm-gui`)
	tell application "WezTerm" to activate
	tell application "System Events"
		repeat while (name of first application process whose frontmost is true) is not "wezterm-gui"
			delay 0.05
		end repeat
	end tell
	delay 0.1 # ensure wezterm-gui is ready

	# CREATE WINDOW IF NEEDED
	tell application "System Events" to tell process "WezTerm"
		if (count of windows) is 0 then
			set frontmost to true
			click menu item "New Window" of menu "Shell" of menu bar 1
		end if
		repeat while (count of windows) is 0
			delay 0.05
		end repeat
	end tell

	# DETERMINE COMMAND
	# 1. use builtin to not trigger aliases, `-q` to suppress hooks (chpwd)
	# 2. Add `clear` to suppress the entering message
	# 3. Add leading space, so it is not saved to the history due HIST_IGNORE_SPACE
	if (text 1 thru 3 of shellCmd) is "cd " then
		set arg to text 4 thru -1 of shellCmd
		set shellCmd to " builtin cd -q " & arg & " && clear"
	end if

	# SEND COMMAND
	set exportPath to "export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; "
	do shell script (exportPath & "echo " & quoted form of shellCmd & " | wezterm cli send-text --no-paste")
end alfred_script
