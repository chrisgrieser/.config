#!/usr/bin/env osascript
on run argv
	set AppleScript's text item delimiters to ""
	set input to argv as string
	set output to ""
	set notif_msg to "🛑 No Input provided."

	if (input is "") and (frontmost of application "Brave Browser") then
		tell application "Brave Browser"
			set currentTabUrl to URL of active tab of front window
			set currentTabTitle to title of active tab of front window
		end tell
		set output to "[" & currentTabTitle & "](" & currentTabUrl & ")"
		set notif_msg to currentTabTitle
	end if

	if (input is not "") then
		set output to input
		set notif_msg to input
	end if

	if (output is not "") then
		tell application "Drafts"
			set uuid to make new draft with properties {content: output}
		end tell
		tell application id "com.runningwithcrayons.Alfred" to set configuration "last_uuid" to value uuid in workflow (system attribute "alfred_workflow_bundleid")
	end if

	return notif_msg
end run
