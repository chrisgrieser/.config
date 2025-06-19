#!/usr/bin/env zsh

# show input source only if non-German
input_source_info=$(defaults read com.apple.HIToolbox.plist AppleSelectedInputSources)
if [[ "$input_source_info" == *"German"* ]]; then
	sketchybar --set "$NAME" drawing=false
	return 0
fi

#───────────────────────────────────────────────────────────────────────────────

if [[ "$input_source_info" == *"Japanese"* ]]; then
	display="あ"
elif [[ "$input_source_info" == *"U.S."* ]]; then
	display="US"
else
	display="input source?"
fi
sketchybar --set "$NAME" drawing=true icon="$display"
