#!/usr/bin/env osascript

# Workaround for Dark Reader & Highlights not toggling when inactive

#-------------------------------------------------------------------------------

-- ensure tab is open (otherwise Dark Reader Toggle won't work)
tell application "Brave Browser"
	if application "Brave Browser" is not running then
		launch
		delay 1
	end if
	if ((count of window) is 0) then
		open location "chrome://newtab/"
		delay 0.1
		set tabOpened to true
	else
		set tabOpened to false
	end if
end tell

# toggle dark mode
tell application "System Events"
	tell appearance preferences to set dark mode to not dark mode
	keystroke "d" using {shift down, option down} -- Dark Reader global hotkey
end tell

# close tab again
if (tabOpened)
	delay 0.1
	tell application "Brave Browser" to close active tab of front window
end if

# Make Highlights.app get the same mode as the OS mode (if running)
tell application "System Events"
	tell appearance preferences to set isDark to dark mode
	if (isDark is false) then
		set targetView to "Default"
	else
		set targetView to "Night"
	end if

	set highlightsRunning to ((name of processes) contains "Highlights")
	if (highlightsRunning is true) then
		tell process "Highlights"
			set frontmost to true
			click menu item targetView of menu of menu item "PDF Appearance" of menu "View" of menu bar 1
		end tell
	end if
end tell

