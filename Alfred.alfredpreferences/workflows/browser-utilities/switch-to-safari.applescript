#!/usr/bin/env osascript
tell application "Brave Browser"
	set currentTabUrl to URL of active tab of front window
end tell

tell application "Safari"
	set the URL of the current tab of the front window to currentTabUrl
	activate
end tell
