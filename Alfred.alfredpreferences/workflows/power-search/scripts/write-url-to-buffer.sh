#!/usr/bin/env zsh

# shellcheck disable=2154
multi_select_buffer="$alfred_workflow_cache/multiSelectBuffer.txt"

url="$*"

# If URL is already in selection, remove it
# if it is not in selection, add it
if grep -q "$url" "$multi_select_buffer"; then
	sed -i '' "/$url/d" "$multi_select_buffer"
	sound="mute"
else
	echo "$url" >>"$multi_select_buffer"
	sound="unmute"
fi

# confirmation sound
afplay "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/mic_$sound.caf" &
