#!/usr/bin/env osascript

on run argv
	set theList to "Supermarkt"
	set toBuy to argv as string
	tell application "Reminders"
		tell (list theList) to make new reminder at end with properties {name: toBuy}
		activate
		# quit -- to save in background instead
	end tell
	return toBuy # for notification
end run
