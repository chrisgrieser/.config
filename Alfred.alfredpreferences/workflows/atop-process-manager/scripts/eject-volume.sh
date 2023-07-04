#!/usr/bin/env zsh
volume="$*"
stdout=$(diskutil eject "$volume" 2>&1)

# notification via Alfred
# shellcheck disable=2181
if [[ "$?" -eq 0 ]]; then
	echo "✅ $volume ejected"
else
	echo "❌ $stdout"
fi
