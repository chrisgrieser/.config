#!/usr/bin/env osascript
tell application "System Events"
	tell process "Catch"
		tell menu bar item 1 of menu bar 1
			click
			click menu item "Preferences…" of menu 1
		end tell
	end tell

	-- Add new feed
	delay 0.1
	key code 48 -- tab
	key code 49 -- spacebar
end tell
