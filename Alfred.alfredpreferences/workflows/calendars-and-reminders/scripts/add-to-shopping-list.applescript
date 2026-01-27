#!/usr/bin/env osascript
on run argv
	set theList to (system attribute "shopping_list")
	set toBuy to argv as string

	tell application "Reminders"
		show list theList
		tell (list theList) to make new reminder at end with properties {name: toBuy}
		quit
		return toBuy # for Alfred notification
	end tell
end run
