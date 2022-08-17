#!/usr/bin/env zsh

DATA_DIR=$(dirname "$0")
MODE="$1"
LAYOUT="$2"
DOCK_PLIST=~"/Library/Preferences/com.apple.dock.plist"

if [[ "$MODE" == "--load" ]]; then
	if [[ -z "$LAYOUT" ]] ; then
		echo "Layout to load is missing."
		exit 1
	fi
	rm "$DOCK_PLIST"
	cp -a "$DATA_DIR/$LAYOUT.plist" "$DOCK_PLIST"
	defaults import com.apple.dock "$DOCK_PLIST"
	sleep 0.1
	killall Dock
	echo "$LAYOUT" > "$DATA_DIR/current"
elif [[ "$MODE" == "--save" ]]; then
	if [[ -z "$LAYOUT" ]] ; then
		LAYOUT=$(ls "$DATA_DIR" | grep "current_" | cut -c9-)
		echo "Saved Layout '$LAYOUT'"
	fi
	cp -f ~/Library/Preferences/com.apple.dock.plist "$LAYOUT.plist"
else
	echo "Not a valid option."
	exit 1
fi

