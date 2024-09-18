#!/usr/bin/env zsh
# open bluetooth settings if blueutil is not installed
if ! command -v blueutil &>/dev/null; then
	open "x-apple.systempreferences:com.apple.BluetoothSettings"
	return 0
fi

# toggle via `blueutil`
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
address="$*"
if [[ $(blueutil --is-connected "$address") -eq 0 ]]; then
	blueutil --connect "$address"
	echo "Connecting to $address"
else
	blueutil --disconnect "$address"
	echo "Disconnecting to $address"
fi
