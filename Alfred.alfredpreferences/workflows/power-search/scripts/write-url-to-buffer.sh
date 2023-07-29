#!/usr/bin/env zsh

# shellcheck disable=2154 # Alfred var
buffer="$alfred_workflow_cache/multiSelectBuffer.txt"
url="$*"

# If URL is already in selection, remove it
# if it is not in selection, add it
if grep -q "$url" "$buffer"; then
	# using `grep -v` instead of `sed -i '//d'` to avoid annoying escaping issues
	grep -v "$url" "$buffer" >"$buffer".tmp
	mv "$buffer".tmp "$buffer"
	sound="mute"
else
	echo "$url" >>"$buffer"
	sound="unmute"
fi

# confirmation sound
afplay "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/mic_$sound.caf" &
