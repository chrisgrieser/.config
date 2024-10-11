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
open -R "$word_file"

#───────────────────────────────────────────────────────────────────────────────
# INSERT LINE BREAKS IN TABLES
# replace `<br>` with `^l`, which is the line break token in MS Word
[[ ! -e "$word_file" ]] && return 1
open "$word_file"

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
		execute find myFind find text "<br>" replace with "^l" replace replace all

		save active document
	end tell
' &> /dev/null
