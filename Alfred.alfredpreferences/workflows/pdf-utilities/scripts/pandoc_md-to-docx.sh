#!/usr/bin/env zsh
set -e

md_file="$*"
output_location=$(dirname "$md_file")
word_file="$output_location/$(basename "$md_file" ".md").docx"

if [[ -f "$word_file" ]]; then
	rm -f "$word_file"
	osascript -e 'tell application "Microsoft Word" to close every window' &> /dev/null
fi

#-------------------------------------------------------------------------------

pandoc "$md_file" --output="$word_file" --verbose --fail-if-warnings=true 2>&1

open -R "$word_file"
open "$word_file"
