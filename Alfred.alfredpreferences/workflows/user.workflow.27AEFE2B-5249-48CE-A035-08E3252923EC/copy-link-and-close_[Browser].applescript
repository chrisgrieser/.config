#!/usr/bin/env osascript
tell application "Brave Browser"
	set currentTabUrl to URL of active tab of front window
	close active tab of front window
end tell

set the clipboard to currentTabUrl

-- direct return for notification
currentTabUrl
