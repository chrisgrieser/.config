#!/usr/bin/env zsh
#───────────────────────────────────────────────────────────────────────────────
# INFO pandoc's --data-dir defined in .zshenv
#───────────────────────────────────────────────────────────────────────────────

md_file="$*"
if [[ ! "$md_file" =~ .*\.md ]]; then
	echo "⚠️ Not a markdown file"
	return 1
fi

pdf_file="${md_file%.*}_CG.pdf"
pandoc "$md_file" --output="$pdf_file" --defaults="md2pdf" 2>&1 &&
	open -R "$pdf_file"
