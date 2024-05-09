#!/usr/bin/env osascript

on run argv
	set workflowUid to item 1 of argv
	tell application id "com.runningwithcrayons.Alfred" to reload workflow workflowUid

	# reopen last keyword
	tell application id "com.runningwithcrayons.Alfred" to search
	delay 0.5
	tell application "System Events" to key code 126 # up

	return workflowUid # pass back for notification
end run
