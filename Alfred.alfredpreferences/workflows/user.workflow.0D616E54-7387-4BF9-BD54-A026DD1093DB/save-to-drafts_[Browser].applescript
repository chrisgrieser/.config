#!/usr/bin/env osascript
on run argv
	set AppleScript's text item delimiters to ""
	set input to argv as string
	set selectionExists to (input is not "")

	if (selectionExists is false) and (frontmost of application "Brave Browser" is false) then#
		return "🛑 No Input provided."
	end if

	if (frontmost of application "Brave Browser") then
		tell application "Brave Browser"
			set currentTabUrl to URL of active tab of front window
			set currentTabTitle to title of active tab of front window
		end tell
		set mdlink to "[" & currentTabTitle & "](" & currentTabUrl & ")"
		if (selectionExists) then
			set output to "> " & input & "\n – " & mdlink
			set notif_msg to input
		else
			set output to mdlink
			set notif_msg to currentTabTitle
		end if
	else if (selectionExists) then
		set output to input
		set notif_msg to input
	end if

	tell application "Drafts" to make new draft with properties {content: output}
	return notif_msg

end run
