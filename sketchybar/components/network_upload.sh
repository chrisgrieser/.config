#!/usr/bin/env zsh

# CONFIG
threshold_kb=50
#───────────────────────────────────────────────────────────────────────────────

# `netstat` only outputs as stream, so using `awk`'s `exit` to return the 1st value
upload=$(netstat -w1 | awk '/[0-9]/ {print int($6/1024) ; exit }')
unit="k"

# GUARD eduroam bug briefly showing very high amount
if [[ ${#upload} -gt 8 ]]; then
	sketchybar --set "$NAME" label="+++" drawing=true
	return 1
fi

# only show when more than threshold
if [[ $upload -lt $threshold_kb ]]; then
	sketchybar --set "$NAME" drawing=false
	return 0
fi

# switch to Mb when more than 1024kb, Gb when more than 1024kb, etc.
if [[ $upload -gt 1024 ]]; then
	upload=$((upload / 1024))
	unit="M"
fi
if [[ $upload -gt 1024 ]]; then
	upload=$((upload / 1024))
	unit="G"
fi

sketchybar --set "$NAME" label="${upload}${unit}" drawing=true
