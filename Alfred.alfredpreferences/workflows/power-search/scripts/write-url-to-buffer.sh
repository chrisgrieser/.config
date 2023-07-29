#!/usr/bin/env zsh

# shellcheck disable=2154
file="$alfred_workflow_cache/urlsToOpen.json"

echo "$*" >>"$file"

# confirmation sound
afplay "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/mic_unmute.caf" &
