#!/usr/bin/env zsh
set -e
md_file="$*"
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
output_location="$HOME/Desktop/"
word_file="$output_location/${md_file%\.md}_$(date +%Y-%m-%d)_CG.docx"

#───────────────────────────────────────────────────────────────────────────────
# PREPARE
if [[ ! "$md_file" =~ .*\.md ]]; then
	echo "⚠️ Not a markdown file"
	return 1
fi

if [[ -f "$word_file" ]]; then
	rm -f "$word_file"
	osascript -e 'tell application "Microsoft Word" to close every window' &> /dev/null
fi

#───────────────────────────────────────────────────────────────────────────────
# PANDOC

cd "$(dirname "$md_file")" # so `--resource-path` works correctly is set

# INFO pandoc's --data-dir for the `defaults` file defined in .zshenv
pandoc "$md_file" --output="$word_file" --defaults="md2docx" 2>&1

open -R "$word_file"
open "$word_file"
