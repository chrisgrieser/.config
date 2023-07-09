#!/usr/bin/env zsh
volume="$*"
msg=$(diskutil eject "$volume" 2>&1)

# notification via Alfred
# shellcheck disable=2181
if [[ $? -eq 0 ]]; then
	echo "✅ $volume ejected"
else
	echo "❌ $msg"
fi
