#!/usr/bin/env osascript

on run argv
	tell application "Reminders" to
	tell (list "General") make new reminder at end with properties {name: "Backup", due date: nextDate}
		quit
	end tell
end run
