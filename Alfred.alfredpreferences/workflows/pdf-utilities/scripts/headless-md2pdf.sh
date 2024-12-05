#!/usr/bin/env zsh
set -e
md_file="$*"
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
pdf_file="${md_file%\.md}_$(date +%Y-%m-%d)_CG.pdf"
headless_browser="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser"
#───────────────────────────────────────────────────────────────────────────────

if [[ ! "$md_file" =~ .*\.md ]]; then
	echo "⚠️ Not a markdown file"
	return 1
fi

cd "$(dirname "$md_file")" # so `--resource-path` is set

#───────────────────────────────────────────────────────────────────────────────

# 1. pandoc's --data-dir for the `defaults` file defined in .zshenv
# 2. Using headless chromium browser to dependency on pdf-engine for pandoc, and
#    also since they tend to be not as customizable (e.g., font size not working)
pandoc "$md_file" --output="/tmp/temp.html" --defaults="md2html" 2>&1
"$headless_browser" --headless \
	--no-pdf-header-footer --print-to-pdf="$pdf_file" "/tmp/temp.html"
open -R "$pdf_file"
rm -f "/tmp/temp.html"
