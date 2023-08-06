#!/usr/bin/env osascript

set pref_path to "/Applications/Alfred 5.app/Contents/Preferences/Alfred Preferences.app"
set custom_pref_icon_path to (system attribute "custom_pref_icon_path")

tell application "Finder"
	open information window of (pref_path as POSIX file as alias)
	activate
end tell
set the clipboard to (POSIX file custom_pref_icon_path)

delay 0.15
tell application "System Events"
	keystroke tab
	keystroke "v" using {command down}
end tell
delay 0.15
