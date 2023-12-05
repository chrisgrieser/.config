# INFO to be entered in the Alfred Terminal settings (Kept here just for reference.)
# alfredpreferences://navigateto/features>terminal
--------------------------------------------------------------------------------
# DOCS https://wezfurlong.org/wezterm/cli/cli/send-text
--------------------------------------------------------------------------------

on alfred_script(shellCmd)
	set setPath to "export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH ; "
	set isCd to(text 1 thru 3 of shellCmd) is "cd "
	tell application "System Events"
		set weztermRunning to (name of processes) contains "wezterm-gui"
	end tell

	if isCd and weztermRunning then
		set dir to text 4 thru -1 of shellCmd
		do shell script (setPath & "wezterm start --cwd " & quoted form of dir)
		return
	end

	if isCd then
		set dir to text 4 thru -1 of shellCmd
		set shellCmd to "builtin cd -q " & dir & " && clear"
	end if
	if not weztermRunning then
		tell application "WezTerm" to activate
		tell application "System Events"
			repeat while (name of first application process whose frontmost is true) is not "wezterm-gui"
				delay 0.05
			end repeat
		end tell
		delay 0.1
	end if

	tell application "WezTerm" to activate
	do shell script (setPath & "echo " & quoted form of shellCmd & " | wezterm cli send-text --no-paste")
end alfred_script
