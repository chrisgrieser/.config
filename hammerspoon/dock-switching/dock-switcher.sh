#!/usr/bin/env zsh

PLIST_LOCATION=$(dirname "$0")
rm ~/Library/Preferences/com.apple.dock.plist
cp -a "$PLIST_LOCATION/$1.plist" ~/Library/Preferences/com.apple.dock.plist
defaults import com.apple.dock ~/Library/Preferences/com.apple.dock.plist
sleep 0.1
killall Dock
