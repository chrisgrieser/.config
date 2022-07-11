#!/usr/bin/env osascript

# Workaround for Dark Reader & Highlights not toggling when inactive

#-------------------------------------------------------------------------------

# open tab if there is no tab open to ensure Dark Reader switches as well
set BrowserWasntRunning to false
tell application "Brave Browser"
		set tabcount to 0
		set currentURL to ""
		try
			set tabcount to number of tabs in front window
		end try
		if (tabcount > 0) then set currentURL to URL of active tab of front window

		if (tabcount is 0 or currentURL starts with "chrome:" or currentURL starts with "vivaldi:")
			open location "https://example.com/"
			repeat until (loading of active tab of front window is false)
				delay 0.1
			end repeat
			delay 0.2
			set BrowserWasntRunning to true
		end if
		delay 0.1
end tell

# toggle dark mode
tell application "System Events"
	tell appearance preferences to set dark mode to not dark mode
end tell

# close tab again
if (BrowserWasntRunning)
	delay 0.2
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

	set highlightsRunning to (name of processes) contains "Highlights"
	if (highlightsRunning is true) then
		tell process "Highlights"
			set frontmost to true
			click menu item targetView of menu of menu item "PDF Appearance" of menu "View" of menu bar 1
		end tell
	end if
end tell


