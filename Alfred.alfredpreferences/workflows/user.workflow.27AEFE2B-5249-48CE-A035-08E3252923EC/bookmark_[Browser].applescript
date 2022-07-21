#!/usr/bin/env osascript

tell application "System Events"
	tell process "Brave Browser"
		set frontmost to true
		click menu item "Bookmark This Tab…" of menu "Bookmarks" of menu bar 1
	end tell
end tell

