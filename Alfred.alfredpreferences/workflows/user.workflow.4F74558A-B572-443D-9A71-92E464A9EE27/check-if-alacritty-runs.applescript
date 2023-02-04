#!/usr/bin/env osascript

# has to be a separate script, since the next script is still considered active
# and therefore won't run before alacritty is quit.
on run
	if application "Alacritty" is running then
		tell application "Alacritty" to activate

		tell application "System Events"
			set frontApp to (name of first process where it is frontmost)
			if frontApp is "Finder" then
				tell application "Finder"
					if ((count windows) is not 0) then
						set the clipboard to POSIX path of (target of window 1 as alias)
					end if
				end tell
				keystroke "cd '"
				keystroke "v" using {command down}
				keystroke "'"
				keystroke return
			end if
		end tell

	end if

	return "not-running"
end run
