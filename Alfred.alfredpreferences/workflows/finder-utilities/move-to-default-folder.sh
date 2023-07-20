#!/usr/bin/env zsh

# shellcheck disable=2154
destination="$WD"
file_in_trash="$*"

mv "$file_in_trash" "$destination"
afplay "/System/Library/Components/CoreAudio.component/Contents/SharedSupport/SystemSounds/system/Volume Mount.aif" &
