#!/usr/bin/env zsh

INPUT="$*"
ext=${INPUT##*.}
if [[ "$ext" != "pdf" ]]; then
	echo "⚠️ Selection not a PDF file"	
	return 1
fi

# send to printer
lpr "$INPUT"

# open printers to see progress
find "$HOME/Library/Printers" -name "*.app" -exec open "{}" \;
