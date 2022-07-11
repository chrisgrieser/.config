#!/usr/bin/env osascript
-- this line has to appear before the "on run" line of Alfred (or other functions)
use framework "AppKit"

set allFrames to (current application's NSScreen's screens()'s valueForKey:"frame") as list

-- main screen size
set X to item 1 of item 2 of item 1 of allFrames
set Y to item 2 of item 2 of item 1 of allFrames

set topLeftX to (X * 0.15)
set topLeftY to (Y * 0.05)
set _width to (X * 0.80)
set height to (Y * 0.95)

-- resize front window
tell application "Finder" to set bounds of Finder window 1 to {topLeftX, topLeftY, _width, height}

tell application "System Events"
	tell process "Finder"
		set frontmost to true
		click menu item "as List" of menu "View" of menu bar 1
		try
			click menu item "Hide Sidebar" of menu "View" of menu bar 1
		end try
	end tell
end tell
