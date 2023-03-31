#!/usr/bin/env osascript

# INFO has to be a separate script, since the next script is still considered active
# and therefore won't run before terminal is quit.
on run
	# 1) GUARD CLAUSE: IF TERMINAL NOT RUNNING, RUN NEXT SCRIPT OPENING TERMINAL
	if application "WezTerm" is not running then 
		return "not-running"
	end if

	tell application "System Events" 
		set frontProcess to (name of first process where it is frontmost)
	end tell

	# IF TERMINAL IS NOT FRONTMOST, SHOW IT AGAIN 
	else if frontProcess is not "Finder" then
		tell application "WezTerm" to activate

	# EXCEPTION: IF FINDER IS FRONTMOST, CD TO FINDER WINDOW
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

		tell application "WezTerm" to activate
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
