#!/usr/bin/env zsh

rm ~/Library/Preferences/com.apple.dock.plist
cp -a "./$1.plist" ~/Library/Preferences/com.apple.dock.plist
defaults import com.apple.dock ~/Library/Preferences/com.apple.dock.plist
sleep 0.1
killall Dock
