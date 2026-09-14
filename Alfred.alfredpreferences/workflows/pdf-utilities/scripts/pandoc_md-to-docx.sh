#!/usr/bin/env zsh
set -e
md_file="$*"
#-------------------------------------------------------------------------------

output_location="$HOME/Desktop/"
word_file="$output_location/$(basename "$md_file" ".md")_CG.docx"

if [[ -f "$word_file" ]]; then
	rm -f "$word_file"
	osascript -e 'tell application "Microsoft Word" to close every window' &> /dev/null
fi

# INFO pandoc's --data-dir for the `defaults` file defined in .zshenv
pandoc "$md_file" --output="$word_file" --defaults="md2docx" 2>&1

open -R "$word_file"
open "$word_file"
