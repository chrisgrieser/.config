#!/usr/bin/env zsh

# CONFIG
threshold_kb=100

#-------------------------------------------------------------------------------

function set_empty {
	# setting padding needed, since `drawing=false` is buggy
	sketchybar --set "$NAME" label="" icon="" \
		background.padding_right="0" icon.padding_right="0" label.padding_right="0"
}

[[ "$SENDER" = "forced" ]] && set_empty # prevent initial flickering

#───────────────────────────────────────────────────────────────────────────────

# `netstat` only outputs as stream, so using `awk`'s `exit` to return 1st value
download=$(netstat -w1 | awk '/[0-9]/ {print int($3/1024) ; exit }')
unit="k"

# only show when more than threshold
if [[ $download -lt $threshold_kb ]]; then
	set_empty
	return
fi

# switch to Mb when more than 1024kb, Gb when more than 1024kb, etc.
if [[ $download -gt 1024 ]]; then
	download=$((download / 1024))
	unit="M"
fi
if [[ $download -gt 1024 ]]; then
	download=$((download / 1024))
	unit="G"
fi

sketchybar --set "$NAME" label="${download}${unit}" icon="" \
	background.padding_right="10" icon.padding_right="3" label.padding_right="3"
