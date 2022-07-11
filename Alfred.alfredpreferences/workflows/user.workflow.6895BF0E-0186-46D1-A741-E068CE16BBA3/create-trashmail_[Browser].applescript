#!/usr/bin/env osascript
--load
tell application "Brave Browser"
	open location "https://muellmail.com/"
	delay 0.2
	repeat until (loading of active tab of front window is false)
		delay 0.2
	end repeat
	delay 0.2
end tell

--check whether homepage or old mail
tell application "Brave Browser" to set currentTab to URL of active tab of front window

--goes to homepage, if needed
if currentTab contains ("@") then
	tell application "System Events" to keystroke tab
	delay 0.2
	tell application "System Events" to keystroke return
	delay 0.5
end if

--create random mail
tell application "System Events"
	keystroke tab
	keystroke tab
	keystroke tab
	keystroke return
end tell

--copy mail adress
delay 1
tell application "Brave Browser" to set mailTab to URL of active tab of front window

--go back
tell application "System Events"
	tell process "Brave Browser"
		set frontmost to true
		click menu item "Select Next Tab" of menu "Tab" of menu bar 1
	end tell
end tell

-- return mail adress
return mailTab
