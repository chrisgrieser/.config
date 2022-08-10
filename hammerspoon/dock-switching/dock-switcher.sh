#!/usr/bin/env zsh

PLIST_LOCATION=$(dirname "$0")
MODE="$1"
LAYOUT="$2"
DOCK_PLIST=~"/Library/Preferences/com.apple.dock.plist"

if [[ "$MODE" == "--load" ]]; then
	rm "$DOCK_PLIST"
	cp -a "$PLIST_LOCATION/$1.plist" "$DOCK_PLIST"
	defaults import com.apple.dock "$DOCK_PLIST"
	sleep 0.1
	killall Dock
elif [[ "$MODE" == "--save" ]]; then
	cp -fa ~/Library/Preferences/com.apple.dock.plist "$LAYOUT.plist"
else
	echo "Not a option."
	exit 1
fi

