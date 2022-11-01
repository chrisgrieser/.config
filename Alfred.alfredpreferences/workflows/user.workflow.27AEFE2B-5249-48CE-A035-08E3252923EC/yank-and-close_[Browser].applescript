#!/usr/bin/env osascript

tell application "Brave Browser"
	set currentTab to active tab of front window
	set theURL to URL of currentTab
	close currentTab
	set the clipboard to theURL
end tell
