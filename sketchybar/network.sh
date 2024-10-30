#!/usr/bin/env zsh

# - INFO `upload` would be $6
# - HACK `netstat` only streams stdout, so using `awk`'s `exit` to return 1st value
download_kb=$(netstat -w1 | awk '/[0-9]/ {print int($3/1024) ; exit }')
unit="k"

# only show when more than 50kb
if [[ $download_kb -lt 50 ]]; then
	sketchybar --set "$NAME" drawing=false
	return 0
fi

# switch to Mb when more than 1024kb
if [[ $download_kb -gt 1024 ]]; then
	download_kb=$(echo "scale = 1; $download_kb / 1024" | bc)
	unit="M"
fi

sketchybar --set "$NAME" label="${download_kb}${unit}" drawing=true
