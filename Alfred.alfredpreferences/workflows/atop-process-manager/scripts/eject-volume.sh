#!/usr/bin/env zsh
volume="$*"

# notification via Alfred
if diskutil eject "$volume" &>/dev/null; then
	echo "✅ $volume ejected"
else
	echo "❌ $volume could not be ejected."
fi
