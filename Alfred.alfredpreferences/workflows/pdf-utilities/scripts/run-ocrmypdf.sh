#!/usr/bin/env zsh
# shellcheck disable=2154

if ! command -v ocrmypdf &>/dev/null; then
	print "ocrmypdf not installed." 
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────
lang="$*"
path_no_ext=${input_path%.*}
out_path="${path_no_ext}_ocr.pdf"

osascript -e 'display notification "" with title "⏳ Running OCRmyPDF"'

ocrmypdf --language="$lang" "$input_path" "$out_path"

#───────────────────────────────────────────────────────────────────────────────
# success sound & reveal file
open -R "$out_path"
afplay "/System/Library/Sounds/Blow.aiff" &
