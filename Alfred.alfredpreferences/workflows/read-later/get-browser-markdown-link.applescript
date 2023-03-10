#!/usr/bin/env osascript
tell application "Vivaldi"
	set currentTabUrl to URL of active tab of front window
	set currentTitle to title of active tab of front window
end tell

set output to "- [ ] [" & currentTitle & "](" & currentTabUrl & ")"
