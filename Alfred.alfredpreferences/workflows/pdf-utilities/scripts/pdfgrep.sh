#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
# shellcheck disable=2154

# get filename from Highlights.app
pdfpath=$(osascript -e '
	tell application "System Events"
		tell process "Highlights"
			if (count of windows) > 0 then set frontWindow to name of front window
		end tell
	end tell
	return text item 1 of frontWindow
'


osascript -l JavaScript "./scripts/pdfgrep.js" "$*" "$pdfpath" 
