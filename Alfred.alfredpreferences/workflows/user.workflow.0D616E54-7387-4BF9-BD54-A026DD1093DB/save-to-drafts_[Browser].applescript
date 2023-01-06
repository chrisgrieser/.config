#!/usr/bin/env osascript
on run argv
	set input to argv as string

	set selectionExists to (input is not "")
	tell application "System Events" to set frontApp to (name of first process where it is frontmost)

	set hotkeyUsed to (system attribute "hotkeyUsed")
	tell application id "com.runningwithcrayons.Alfred" to remove configuration "hotkeyUsed" in workflow (system attribute "alfred_workflow_bundleid")

	if (selectionExists is false) and (frontApp is not "Brave Browser") then
		return "🛑 No Input provided."
	end if

	if (frontApp is "Brave Browser" and hotkeyUsed is "true") then
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

	-- update count in sketchybar
	do shell script ("sketchybar --trigger drafts-counter-update || true")

	return notif_msg

end run
