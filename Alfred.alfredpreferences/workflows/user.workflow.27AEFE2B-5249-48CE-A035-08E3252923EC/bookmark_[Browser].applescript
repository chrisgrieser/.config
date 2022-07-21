#!/usr/bin/env osascript

-- has to be done via AppleScript instead of keystroke, since ⌘D is already
-- mapped to sth else via Karabiner
tell application "System Events"
	tell process "Brave Browser"
		set frontmost to true
		click menu item "Bookmark This Tab…" of menu "Bookmarks" of menu bar 1
	end tell
end tell

