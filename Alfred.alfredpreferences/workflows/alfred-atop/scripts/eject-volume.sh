#!/usr/bin/env zsh
volume="$*"
msg=$(diskutil eject "$volume" 2>&1)
success=$?

if [[ $success -eq 0 ]]; then
	echo "✅ $(basename "$volume") ejected"
else
	echo "❌ $msg"
fi
