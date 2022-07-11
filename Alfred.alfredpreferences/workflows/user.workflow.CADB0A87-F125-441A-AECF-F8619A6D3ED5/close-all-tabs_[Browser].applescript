#!/usr/bin/env osascript

# Close all tabs of all windows
tell application "Brave Browser"
	set windowList to every tab of every window
	repeat with tabList in windowList
		set tabList to tabList as any
		repeat with tabItr in tabList
			set tabItr to tabItr as any
			delete tabItr
		end repeat
	end repeat
end tell

# Hide (to lose focus)
tell application "System Events" to tell process "Brave Browser" to set visible to false
