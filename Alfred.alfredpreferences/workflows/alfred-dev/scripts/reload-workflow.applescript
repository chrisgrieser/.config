#!/usr/bin/env osascript

on run argv
	set workflowUid to item 1 of argv
	tell application id "com.runningwithcrayons.Alfred" 
		reload workflow workflowUid
		search
	end tell

	# reopen last keyword
	delay 0.5
	tell application "System Events"
		key code 126 # up -> this workflow's query
		key code 126 # up -> previous query
	end tell

	return workflowUid # pass back for notification
end run
