#!/usr/bin/env zsh

rm ~/Library/Preferences/com.apple.dock.plist
cp -a "./$1.plist" ~/Library/Preferences/com.apple.dock.plist
defaults read com.apple.dock &> /dev/null # needed to refresh properly
sleep 0.1
killall Dock
