#!/usr/bin/env osascript

on run argv
	set openRemindersAfterwards to ((system attribute "openRemindersAfterwards") is "true")

	set theList to "Shopping"
	set toBuy to argv as string
	tell application "Reminders"
		show list theList
		tell (list theList) to make new reminder at end with properties {name: toBuy}
		if openRemindersAfterwards then
			activate
		else
			quit
			return toBuy # for Alfred notification
		end if
	end tell
end run
