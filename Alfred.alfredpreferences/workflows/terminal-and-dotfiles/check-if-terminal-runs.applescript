#!/usr/bin/env osascript

# INFO has to be a separate script, since the next script is still considered active
# and therefore won't run before terminal is quit.
on run
	# guard clause: if terminal not running, run next script opening terminal
	if application "alacritty" is not running then return "not-running"

	tell application "System Events" 
		set frontApp to (name of first process where it is frontmost)
	end tell

	# If terminal is frontmost, hide it again for toggling visibility via the hotkey
	if frontApp is "alacritty" then
		tell application "System Events" to tell process "alacritty" to set visible to false

	# if terminal is not frontmost, show it again 
	else if frontApp is not "Finder" then
		tell application "alacritty" to activate
	# exception: If Finder is frontmost, cd to finder window
	else
		tell application "Finder"
			if ((count windows) is 0) then return
			-- clipboard cannot be preserved if it contains non-text (image, file)
			try
				set prevClipboard to the clipboard
				set clipboardPreserved to true
			on error
				set clipboardPreserved to false
			end try
			set the clipboard to POSIX path of (insertion location as alias)
		end tell

		tell application "alacritty" to activate
		delay 0.05
		tell application "System Events"
			keystroke "cd '"
			delay 0.05
			keystroke "v" using {command down}
			keystroke "'"
			keystroke return
		end tell

		if clipboardPreserved is true then
			delay 0.05
			set the clipboard to prevClipboard
		end if
	end if

end run
