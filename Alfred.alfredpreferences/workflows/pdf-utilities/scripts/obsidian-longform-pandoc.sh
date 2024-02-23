#!/usr/bin/env zsh

# REQUIRED
# - Longform Plugin
# - Custom compile step replacing <br> with `¶` (pandoc removes <br> in table cells)
# - pandoc
# - Obsidian Advanced URI plugin
#───────────────────────────────────────────────────────────────────────────────

# 1. COMPILE LONGFORM
open "obsidian://advanced-uri?commandid=longform%253Alongform-compile-current"
sleep 0.5

# 3. RUN PANDOC
md_file=$(osascript -e 'tell application "Finder"
	set sel to (item 1 of (get selection) as text)
	return POSIX path of sel
end tell')
input_no_ext=${md_file%\.md}
date="$(date +%Y-%m-%d)"
word_file="${input_no_ext}_${date}_CG.docx"

pandoc "$md_file" --output="$word_file" --defaults="md2docx" 2>&1 || return 1
open -R "$word_file"

# 4. INSERT LINE BREAKS IN TABLES
# `^l` is the manual line break token in MS Word
open "$word_file"
sleep 0.1

osascript -e '
	tell application "Microsoft Word" 
		repeat until active document exists 
			delay 0.1 
		end repeat 
		activate 
		
		set myFind to find object of text object of active document 
		execute find myFind find text "¶" replace with "^l" replace replace all 

		save active document
	end tell 
'

# 5. CLEAN-UP
rm "$md_file"
