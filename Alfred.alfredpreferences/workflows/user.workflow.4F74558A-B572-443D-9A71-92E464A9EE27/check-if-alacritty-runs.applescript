#!/usr/bin/env osascript

# INFO has to be a separate script, since the next script is still considered active
# and therefore won't run before alacritty is quit.
on run
	if application "Alacritty" is not running then return "not-running"

	# If finder is frontmost, cd to finder window
	tell application "System Events"
		set frontApp to (name of first process where it is frontmost)
	end tell

	if frontApp is "Finder" then
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

		tell application "Alacritty" to activate
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
	else
		tell application "Alacritty" to activate
	end if

end run
