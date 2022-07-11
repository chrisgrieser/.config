#!/usr/bin/env osascript
tell application id "com.runningwithcrayons.Alfred"
	run trigger "backup-obsidian" in workflow "de.chris-grieser.shimmering-obsidian" with argument "no sound"
	run trigger "backup-alfred-prefs" in workflow "de.chris-grieser.alfred-tweaks" with argument "no sound"
	run trigger "BibTeX Library Backup" in workflow "de.chris-grieser.alfred-bibtex-citation-picker"
end tell

-- rerun potential changes documentation update
tell application id "com.runningwithcrayons.Alfred" to run trigger "re-index-doc-search" in workflow "de.chris-grieser.shimmering-obsidian" with argument "no sound"

# LOGGING
do shell script "echo Biweekly\\ $(date '+%Y-%m-%d %H:%M') >> '/Users/chrisgrieser/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Dotfiles/Cron Jobs/some.log'"
