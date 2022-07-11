#!/usr/bin/env osascript

# Check with Catch
# this prevents having the catch icon on all the time
tell application "Catch"
	launch
	delay 7
	quit
end tell

# SLEEP TIMER
do shell script "killall \"YouTube\" || true"
tell application "Brave Browser"
	if ((count of window) is not 0)
		if ((count of tab of front window) is not 0)
			set currentTabUrl to URL of active tab of front window
			if (currentTabUrl contains "youtu") then close active tab of front window
		end if
	end if
end tell

delay 1

# SWITCH TO LIGHT MODE
tell application "System Events"
	tell appearance preferences
		if (dark mode is true) then tell application id "com.runningwithcrayons.Alfred" to run trigger "toggle-dark-mode" in workflow "de.chris-grieser.dark-mode-toggle"
	end tell
end tell

# BUSYCAL RESTART
# to ensure menubar icon is there
tell application "Busycal"
	activate
	delay 5
	quit
end tell

# LOGGING
do shell script "echo Morning\\ $(date '+%Y-%m-%d %H:%M') >> '/Users/chrisgrieser/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Dotfiles/Cron Jobs/some.log'"
