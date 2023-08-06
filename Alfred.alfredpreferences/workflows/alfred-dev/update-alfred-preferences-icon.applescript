#!/usr/bin/env osascript
# shellcheck disable=2154

set pref_path to "/Applications/Alfred 5.app/Contents/Preferences/Alfred Preferences.app"
set envvar to (system attribute "envvar")

tell application "Finder"
		open information window of (pref_path as POSIX file as alias)
		activate
	end tell
	set the clipboard to POSIX file "$custom_pref_icon_path/Alfred Preferences.icns"

	sleep 0.15
	osascript -e 'tell application "System Events"
		keystroke tab
		keystroke "v" using {command down}
	end tell'
	sleep 0.15
