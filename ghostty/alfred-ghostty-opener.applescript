on alfred_script(shellCmd)
	# ensure ghostty is running, since shortcut fails if not
	tell application "System Events"
		if not (name of processes contains "ghostty") then
			tell application "Ghostty" to activate
			delay 0.1
		end if
	end tell

	-- run the shortcut
	tell application "Shortcuts"  to run shortcut named "ghostty-input" with input shellCmd
end alfred_script
