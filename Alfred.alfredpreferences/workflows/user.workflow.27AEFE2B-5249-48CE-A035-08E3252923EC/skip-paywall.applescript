#!/usr/bin/env osascript
tell application "Brave Browser"
	set currentTabUrl to URL of active tab of front window
	set URL of active tab of front window to ("https://12ft.io/" & currentTabUrl)
end tell
