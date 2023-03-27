#!/usr/bin/env osascript

on run argv
	set theList to "Supermarkt"
	set toBuy to argv as string
	tell application "Reminders"
		activate
		show list theList
		tell (list theList) to make new reminder at end with properties {name: toBuy}
	end tell
	return toBuy # for notification
end run
