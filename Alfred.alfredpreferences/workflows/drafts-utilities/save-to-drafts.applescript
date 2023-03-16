#!/usr/bin/env osascript
on run argv
	set input to argv as string

	set selectionExists to (input is not "")

	tell application "System Events" to set frontApp to (name of first process where it is frontmost)

	set hotkeyUsed to (system attribute "hotkeyUsed")
	tell application id "com.runningwithcrayons.Alfred" to remove configuration "hotkeyUsed" in workflow (system attribute "alfred_workflow_bundleid")

	set mode to (system attribute "mode")
	tell application id "com.runningwithcrayons.Alfred" to remove configuration "mode" in workflow (system attribute "alfred_workflow_bundleid")
	-----------------------------------------------------------------------------

	if (selectionExists is false) and (frontApp is not "Vivaldi") then
		return "🛑 No Input provided."
	end if

	if (frontApp is "Vivaldi" and hotkeyUsed is "true") then
		tell application "Vivaldi"
			set currentTabUrl to URL of active tab of front window
			set currentTabTitle to title of active tab of front window
		end tell
		set mdlink to "[" & currentTabTitle & "](" & currentTabUrl & ")"

		if (selectionExists) then
			set output to "> " & input & " " & mdlink
			set notif_msg to input
		else
			set output to mdlink
			set notif_msg to currentTabTitle
		end if

	else if (selectionExists) then
		set output to input
		set notif_msg to input
	end if

	if mode is "new" then
		tell application "Drafts" to make new draft with properties {content: output}
	else
		# INFO https://directory.getdrafts.com/a/2Hc
		open location ("drafts://x-callback-url/runAction?action=append-to-last-draft&text=" & output)
		delay 0.1
		tell application "System Events" to tell process "Drafts" to set visible to false
		set notif_msg to "" # empty to not trigger Alfred notification
	end if

	-- update count in sketchybar
	do shell script ("sketchybar --trigger drafts-counter-update || true")

	return notif_msg
end run
