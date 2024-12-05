#!/usr/bin/env zsh

md_file="$*"
if [[ ! "$md_file" =~ .*\.md ]]; then
	echo "⚠️ Not a markdown file"
	return 1
fi
pdf_file="${md_file%\.md}_$(date +%Y-%m-%d)_CG.pdf"

# so `--resource-path` is set
cd "$(dirname "$md_file")" || return 1

# INFO pandoc's --data-dir for the `defaults` file defined in .zshenv
pandoc "$md_file" --output="$pdf_file" --defaults="md2pdf" 2>&1 || return 1
open -R "$pdf_file"

#───────────────────────────────────────────────────────────────────────────────
