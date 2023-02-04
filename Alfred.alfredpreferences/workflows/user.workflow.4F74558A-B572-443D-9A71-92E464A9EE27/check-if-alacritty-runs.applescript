#!/usr/bin/env osascript

# has to be a separate script, since the next script is still considered active
# and therefore won't run before alacritty is quit.
on run
	if application "Alacritty" is not running then return "not-running"
	tell application "Alacritty" to activate

	# If finder is frontmost, cd to finder window
	tell application "System Events"
		set frontApp to (name of first process where it is frontmost)
		if frontApp is "Finder" then
			tell application "Finder"
				if ((count windows) is 0) then return
				set the clipboard to POSIX path of (target of window 1 as alias)
			end tell
			keystroke "cd '"
			delay 0.1
			keystroke "v" using {command down}
			keystroke "'"
			keystroke return
		end if
	end tell

end run
