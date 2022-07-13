#!/usr/bin/env osascript
tell application id "com.runningwithcrayons.Alfred"
	run trigger "backup-obsidian" in workflow "de.chris-grieser.shimmering-obsidian" with argument "no sound"
	run trigger "backup-dotfiles" in workflow "de.chris-grieser.terminal-dotfiles" with argument "no sound"
end tell

-- rerun potential changes documentation update
tell application id "com.runningwithcrayons.Alfred" to run trigger "re-index-doc-search" in workflow "de.chris-grieser.shimmering-obsidian" with argument "no sound"

# LOGGING
do shell script "echo Biweekly\\ $(date '+%Y-%m-%d %H:%M') >> \"$HOME/dotfiles/Cron Jobs/some.log\""
