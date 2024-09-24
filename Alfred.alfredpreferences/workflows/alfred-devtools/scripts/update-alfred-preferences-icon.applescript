#!/usr/bin/env osascript
-- Method described here does not work for `Alfred Preferences`, for whatever reason.
-- http://codefromabove.com/2015/03/programmatically-adding-an-icon-to-a-folder-or-file/
--------------------------------------------------------------------------------

set pwd to POSIX path of ((path to me as text) & "::")
set iconpath to pwd & "Alfred Preferences.icns"

set the clipboard to POSIX file (iconpath)
set prefsPath to "/Applications/Alfred 5.app/Contents/Preferences/Alfred Preferences.app"

set alfredPrefs to (POSIX file prefsPath) as alias
tell application "Finder"
	open information window of alfredPrefs
	activate
end tell
tell application "System Events"
	key code 48
	keystroke "v" using {command down}
end tell
