#!/usr/bin/env zsh

PLIST_LOCATION=$(dirname "$0")
MODE="$1"
LAYOUT="$2"
DOCK_PLIST=~"/Library/Preferences/com.apple.dock.plist"

rm "$DOCK_PLIST"
cp -a "$PLIST_LOCATION/$1.plist" "$DOCK_PLIST"
defaults import com.apple.dock "$DOCK_PLIST"
sleep 0.1
killall Dock

# cp -a ~/Library/Preferences/com.apple.dock.plist "$LAYOUT.plist"
# auch in hammerspoon anpassen
