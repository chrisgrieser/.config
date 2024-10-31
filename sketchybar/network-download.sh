#!/usr/bin/env zsh

# CONFIG
threshold_kb=100
#───────────────────────────────────────────────────────────────────────────────

# HACK `netstat` only outputs as stream, so using `awk`'s `exit` to return 1st value
download=$(netstat -w1 | awk '/[0-9]/ {print int($3/1024) ; exit }')
unit="k"

# only show when more than threshold
if [[ $download -lt $threshold_kb ]]; then
	sketchybar --set "$NAME" drawing=false
	return 0
fi

# switch to Mb when more than 1024kb
if [[ $download -gt 1024 ]]; then
	download=$((download / 1024))
	unit="M"
fi

sketchybar --set "$NAME" label="${download}${unit}" drawing=true
