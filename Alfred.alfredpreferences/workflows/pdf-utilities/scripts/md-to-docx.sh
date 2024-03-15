#!/usr/bin/env zsh

md_file="$*"
if [[ ! "$md_file" =~ .*\.md ]]; then
	echo "⚠️ Not a markdown file"
	return 1
fi

input_no_ext=${md_file%\.md}
date="$(date +%Y-%m-%d)"
word_file="${input_no_ext}_${date}_CG.docx"

# so --resource-path is set
cd "$(dirname "$md_file")" || return 1

pandoc "$md_file" --output="$word_file" --defaults="md2docx" 2>&1 || return 1
open -R "$word_file"
