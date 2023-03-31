# to be entered in the Alfred Terminal settings. Kept here for reference.
--------------------------------------------------------------------------------

on alfred_script(q)
	set prevClipboard to the clipboard
	delay 0.05
	set the clipboard to q

	-- INFO Appname is `WezTerm`, processname is `wezterm-gui`
	tell application "WezTerm" to activate
	tell application "System Events"
		repeat while (name of first application process whose frontmost is true) is not "wezterm-gui"
			delay 0.05
		end repeat
		delay 0.05
		keystroke "v" using {command down}
		delay 0.05
		key code 36 -- return
		delay 0.01
		if q starts with "cd " then keystroke "k" using {command down} -- clear screen
	end tell

	delay 0.05
	set the clipboard to prevClipboard
end alfred_script
