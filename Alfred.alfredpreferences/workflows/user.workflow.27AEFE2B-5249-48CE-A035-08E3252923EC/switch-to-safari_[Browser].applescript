#!/usr/bin/env osascript
tell application "Brave Browser"
		set currentTabUrl to URL of active tab of front window
end tell


-- has to set the URL instead of "open location" (and its equivalents in Shell/JXA)
-- to prevent `finicky` stepping in
tell application "Safari"
	set the URL of the current tab of the front window to currentTabUrl
	activate
end tell
