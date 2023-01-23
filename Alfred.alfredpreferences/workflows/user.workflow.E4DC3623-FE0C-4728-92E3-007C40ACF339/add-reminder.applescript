#!/usr/bin/env osascript

on run argv
	set theList to (system attribute "theList")
	set reminderText to (system attribute "reminderText")
	set inDays to argv as string
	set dueDate to (current date) + inDays * (60 * 60 * 24)
	tell application "Reminders"
		tell (list theList) to make new reminder at end with properties {name:reminderText, allday due date: dueDate}
		quit
	end tell
end run
