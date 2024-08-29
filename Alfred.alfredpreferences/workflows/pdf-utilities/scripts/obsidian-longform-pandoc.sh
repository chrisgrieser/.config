#!/usr/bin/env zsh

# REQUIRED
# - Longform Plugin
# - pandoc
#───────────────────────────────────────────────────────────────────────────────

# 1. RUN PANDOC
md_file=$(osascript -e 'tell application "Finder"
	set sel to (item 1 of (get selection) as text)
	return POSIX path of sel
end tell')
if [[ ! -e "$md_file" ]]; then
	echo "⚠️ File not recognized."
	return 1
fi

input_no_ext=${md_file%\.md}
date="$(date +%Y-%m-%d)"
word_file="${input_no_ext}_${date}_CG.docx"

# cd, so --resource-path is set
cd "$(dirname "$md_file")" || return 1

pandoc "$md_file" --output="$word_file" --defaults="md2docx" 2>&1 || return 1
rm "$md_file"

# 2. INSERT LINE BREAKS IN TABLES
# `^l` is the manual line break token in MS Word
open -R "$word_file"
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
'
