#!/usr/bin/env osascript

-- requires "Combined Details" being enabled
tell application "System Events" to tell process "Stats"
	tell menu bar item 1 of menu bar 1 to click
end tell
