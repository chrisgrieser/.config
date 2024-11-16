#!/usr/bin/env zsh
volume="$*"
# if unejectable, `unmount` says which process is blocking
msg=$(diskutil eject "$volume" || diskutil unmount "$volume" 2>&1)
success=$?

if [[ $success -eq 0 ]]; then
	echo "✅ $(basename "$volume") ejected"
else
	echo "❌ $msg"
fi
