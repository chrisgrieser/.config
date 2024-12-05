#!/usr/bin/env zsh
set -e

# CONFIG
pdf_file="${*%\.md}_$(date +%Y-%m-%d)_CG.pdf"
#───────────────────────────────────────────────────────────────────────────────

md_file="$*"
if [[ ! "$md_file" =~ .*\.md ]]; then
	echo "⚠️ Not a markdown file"
	return 1
fi

cd "$(dirname "$md_file")" # so `--resource-path` is set

#───────────────────────────────────────────────────────────────────────────────

# INFO 
# 1. pandoc's --data-dir for the `defaults` file defined in .zshenv
# 2. Using headless chromium browser to dependency on pdf-engine for pandoc, and
#    also since they tend to be not as customizable (e.g., font size not working)
pandoc "$md_file" --output="/tmp/temp.html" --defaults="md2html" 2>&1

'/Applications/Brave Browser.app/Contents/MacOS/Brave Browser' --headless \
	--no-pdf-header-footer --print-to-pdf="$pdf_file" "/tmp/temp.html" 2>&1

open -R "$pdf_file"

rm -f "/tmp/temp.html"

#───────────────────────────────────────────────────────────────────────────────
