#!/usr/bin/env osascript

on run argv
	set mynum to "3"
	tell application "System Events" to tell process "Stats"
	tell menu bar item (mynum as number) of menu bar 1 to click
end tell
end run
