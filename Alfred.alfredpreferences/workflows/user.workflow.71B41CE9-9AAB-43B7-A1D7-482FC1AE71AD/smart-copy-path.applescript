#!/usr/bin/env osascript
tell application "Finder"
	set sel to selection

	if ((count sel) > 1) then
		set firstItem to item 1 of sel
		set filePath to POSIX path of (firstItem as text)
	else if ((count sel) = 1) then
		set filePath to POSIX path of (sel as text)
	else
		set _windows to count windows
		if (_windows = 0) then
			set filePath to ""
		else
			set filePath to POSIX path of (target of window 1 as alias)
		end if
	end if
end tell

# direct return
filePath

