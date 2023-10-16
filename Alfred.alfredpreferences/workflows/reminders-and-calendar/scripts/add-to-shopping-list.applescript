#!/usr/bin/env osascript

on run argv

	set theList to "Shopping"
	set toBuy to argv as string
	tell application "Reminders"
		show list theList
		tell (list theList) to make new reminder at end with properties {name: toBuy}
		quit
	end tell

	return toBuy # for notification
end run
