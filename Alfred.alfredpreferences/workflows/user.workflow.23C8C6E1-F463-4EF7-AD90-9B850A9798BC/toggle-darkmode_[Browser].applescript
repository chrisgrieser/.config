#!/usr/bin/env osascript

# Workaround for Dark Reader & Highlights not toggling when inactive

#-------------------------------------------------------------------------------

# open tab if there is no tab open to ensure Dark Reader switches as well
tell application "Brave Browser"
		set openblank to false
		if ((count of window) is 0) then
			set openblank to true
		else
			set currentURL to URL of active tab of front window
			if (currentURL starts with "chrome:" or currentURL starts with "vivaldi:")
				set openblank to true
			end if
		end if

		if (openblank) then
			open location "http://www.blankwebsite.com/"
			delay 0.3
			set BrowserWasntRunning to true
		end if
		delay 0.1
end tell

# toggle dark mode
tell application "System Events"
	tell appearance preferences to set dark mode to not dark mode
end tell

# close tab again
if (openblank)
	delay 0.3
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

# Log
do shell script "echo \"$(date '+%Y-%m-%d %H:%M') 🌒 Dark Mode: manual toggle\" >> \"$HOME/dotfiles/Cron Jobs/some.log\""
