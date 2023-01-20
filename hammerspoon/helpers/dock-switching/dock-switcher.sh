#!/usr/bin/env zsh

DATA_DIR=$(dirname "$0")
MODE="$1"
LAYOUT="$2"
DOCK_PLIST="$HOME/Library/Preferences/com.apple.dock.plist"
DOCK_CONFIG="$DATA_DIR/$LAYOUT.plist" 

#-------------------------------------------------------------------------------

if [[ "$MODE" == "--load" ]]; then
	if [[ -z "$LAYOUT" ]] ; then
		echo "Layout to load is missing."
		exit 1
	elif [[ ! -e "$DOCK_CONFIG" ]]; then
		echo "Layout '$LAYOUT' does not exist."
		exit 1
	fi
	rm "$DOCK_PLIST" || exit 1
	cp -a "$DOCK_CONFIG" "$DOCK_PLIST"
	defaults import com.apple.dock "$DOCK_PLIST"
	sleep 0.1
	killall Dock
	echo "Loaded layout '$LAYOUT'"
elif [[ "$MODE" == "--save" ]]; then
	if [[ -z "$LAYOUT" ]] ; then
		echo "Layout to save is missing."
		exit 1
	fi
	cp -f "$DOCK_PLIST" "$DOCK_CONFIG"
	echo "Saved as '$LAYOUT'"
else
	echo "Not a valid option."
	exit 1
fi

