#!/usr/bin/env osascript
#!/usr/bin/env osascript
tell application "Finder"
	if (count windows) is 0 then
		activate
		tell application "System Events"
			tell process "Finder" to click menu item "New Finder Window" of menu "File" of menu bar 1
		end tell
		delay 0.1
	end if
	set currentDir to POSIX path of (target of Finder window 1 as alias)
end tell

set command to "TO_TOUCH=\"" & currentDir & "Untitled\" ; touch \"$TO_TOUCH\" ; open -R \"$TO_TOUCH\""

do shell script command

tell application "System Events"
	tell process "Finder" to click menu item "Rename" of menu "File" of menu bar 1
end tell
