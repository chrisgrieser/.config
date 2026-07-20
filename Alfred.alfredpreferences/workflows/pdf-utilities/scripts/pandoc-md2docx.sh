#!/usr/bin/env zsh
set -e
md_file="$*"
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
output_location="$HOME/Desktop/"
word_file="$output_location/$(basename "$md_file" ".md")_$(date +%Y-%m-%d)_CG.docx"

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

sed -i '' 's/<br>/¶/g' "$md_file" # replace to insert linebreaks in tables later

#───────────────────────────────────────────────────────────────────────────────
# PANDOC

cd "$(dirname "$md_file")" # so `--resource-path` is correctly set

# INFO pandoc's --data-dir for the `defaults` file defined in .zshenv
pandoc "$md_file" --output="$word_file" --defaults="md2docx" 2>&1

open -R "$word_file"
open "$word_file"

#───────────────────────────────────────────────────────────────────────────────
# INSERT LINE BREAKS IN TABLES
# replace `¶` with `^l`, which is the line break token in MS Word
# INFO pandoc does not support line breaks in tables https://pandoc.org/MANUAL.html#extension-pipe_tables
# REQUIRED turn `<br>` into `¶` before the pandoc conversion, since the former
# is not preserved

osascript -e '
	tell application "Microsoft Word"
		set i to 0
		repeat until active document exists
			delay 0.1
			set i to i + 1
			if i > 120 then return
		end repeat
		activate

		set myFind to find object of text object of active document
		execute find myFind find text "¶" replace with "^l" replace replace all

		save active document
	end tell
' &> /dev/null
