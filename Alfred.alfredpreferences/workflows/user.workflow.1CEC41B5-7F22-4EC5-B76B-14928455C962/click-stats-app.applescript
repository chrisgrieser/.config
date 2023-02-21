#!/usr/bin/env osascript

on run argv
	tell application "System Events" to tell process "Stats"
		tell menu bar item (argv as number) of menu bar 1 to click
	end tell
end run
