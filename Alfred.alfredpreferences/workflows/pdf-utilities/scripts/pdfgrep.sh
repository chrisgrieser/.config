#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
# shellcheck disable=2154

# get filename from Highlights.app
pdfname=$(osascript -e '
	tell application "System Events" to tell process "Highlights"
		return name of front window
	end tell' |
	sed -E 's/(.*.pdf) – .*/\1/')

# shellcheck disable=2154
pdfpath=$(find "$pdf_folder" -type f -name "$pdfname" | head -n1)

# ("find " & (quoted form of pdfFolder) & " -type f -name " & (quoted form of filename))
osascript -l JavaScript "./scripts/pdfgrep.js" "$*" "$pdfpath"
