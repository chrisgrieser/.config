#!/usr/bin/env zsh

INPUT="$*"
ext=${INPUT##*.}
if [[ "$ext" != "pdf" ]]; then
	echo "⚠️ Selection not a PDF file"	
	return 1
fi

# send to printer
lpr "$INPUT"

# see progress
open -a "/System/Applications/Utilities/Print Center.app"
