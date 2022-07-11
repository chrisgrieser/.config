#!/usr/bin/env osascript

# SWITCH TO DARK MODE
# only when not dark mode already
tell application "System Events"
	tell appearance preferences
		if (dark mode is false) then tell application id "com.runningwithcrayons.Alfred" to run trigger "toggle-dark-mode" in workflow "de.chris-grieser.dark-mode-toggle"
	end tell
end tell

# LOGGING
do shell script "echo Evening\\ $(date '+%Y-%m-%d %H:%M') >> '/Users/chrisgrieser/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Dotfiles/Cron Jobs/some.log'"
