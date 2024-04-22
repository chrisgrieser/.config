#!/usr/bin/env osascript
tell application "System Events"
	tell process "Catch"
		tell menu bar item 1 of menu bar 1
			click
			click menu item "Preferences…" of menu 1
		end tell

		-- click "Add Feed" button
		delay 0.5
		click button 1 of group 1 of window 1
	end tell
end tell
