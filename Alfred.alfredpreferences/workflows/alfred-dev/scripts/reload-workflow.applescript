#!/usr/bin/env osascript

on run argv
	set workflowUid to item 1 of argv
	tell application id "com.runningwithcrayons.Alfred" to reload workflow workflowUid
	return workflowUid # pass back for notification
end run
