#!/usr/bin/env zsh

selection=$(osascript -e 'tell application "Finder" to return POSIX path of (selection as alias)')
ext=${selection##*.}
if [[ "$ext" == "bkp" ]]; then
	mv "$selection" "${selection:0:4}"	
else
	mv "$selection" "$selection.bkp"	
fi
