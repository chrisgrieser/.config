#!/usr/bin/env zsh

# PANDOC
md_file="$*"
if [[ ! "$md_file" =~ .*\.md ]]; then
	echo "⚠️ Not a markdown file"
	return 1
fi
word_file="${md_file%\.md}_$(date +%Y-%m-%d)_CG.docx"

# so `--resource-path` is set
cd "$(dirname "$md_file")" || return 1

# INFO pandoc's --data-dir for the `defaults` file defined in .zshenv
pandoc "$md_file" --output="$word_file" --defaults="md2docx" 2>&1 || return 1

# OPEN
open -R "$word_file"
[[ ! -e "$word_file" ]] && return 1
open "$word_file"

#───────────────────────────────────────────────────────────────────────────────
# INSERT LINE BREAKS IN TABLES
# replace `¶` with `^l`, which is the line break token in MS Word
# INFO pandoc does not support line breaks in tables https://pandoc.org/MANUAL.html#extension-pipe_tables
# REQUIRED longform compile step that turns "<br>" into "¶"

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
