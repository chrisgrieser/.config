#!/usr/bin/env osascript

# 1. Compile Longform
open "obsidian://advanced-uri?commandid=longform%253Alongform-compile-current"
sleep 0.5

# 2. Reveal in finder
open "obsidian://advanced-uri?commandid=open-with-default-app%253Ashow"
sleep 0.1

# 3. Run pandoc command
md_file=$(osascript -e 'tell application "Finder"
	set sel to (item 1 of (get selection) as text)
	return POSIX path of sel
end tell')
input_no_ext=${md_file%\.md}
date="$(date +%Y-%m-%d)"
word_file="${input_no_ext}_${date}_CG.docx"

pandoc "$md_file" --output="$word_file" --defaults="md2docx" 2>&1 || return 1

open "$word_file"

#───────────────────────────────────────────────────────────────────────────────

# 4. Insert line breaks in tables via Find and Replace
# - `¶` gets inserted at every manual line break via the respective longform compile step
# - `^l` is the manual line break token in MS Word
osascript -e "
	tell application \"Microsoft Word\" 
		open file (POSIX path of \"$word_file\") 
		repeat until active document exists 
			delay 0.1 
		end repeat 
		
		set myFind to find object of text object of active document 
		execute find myFind find text \"¶\" replace with \"^l\" replace replace all 
		activate 
	end tell 
"
