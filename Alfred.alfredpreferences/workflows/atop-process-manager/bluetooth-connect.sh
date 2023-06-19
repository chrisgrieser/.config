#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

address="$*"

# toggle if `blueutil` is installed, open bluetooth settings otherwise
if command -v blueutil &>/dev/null; then
	if [[ $(blueutil --is-connected "$address") -eq 0 ]]; then
		blueutil --connect "$address"
	else
		blueutil --disconnect "$address"
	fi
else
	open "x-apple.systempreferences:com.apple.BluetoothSettings"
fi
