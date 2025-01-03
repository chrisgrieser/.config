#!/usr/bin/env zsh

# show input source only if non-German
input_source_info=$(defaults read com.apple.HIToolbox.plist AppleSelectedInputSources)
if [[ "$input_source_info" == *"German"* ]]; then
	sketchybar --set "$NAME" drawing=false
elif [[ "$input_source_info" == *"Japanese"* ]]; then
	sketchybar --set "$NAME" drawing=true icon="あ"
elif [[ "$input_source_info" == *"U.S."* ]]; then
	sketchybar --set "$NAME" drawing=true icon="US"
else
	sketchybar --set "$NAME" drawing=true icon="unknown input source"
fi
