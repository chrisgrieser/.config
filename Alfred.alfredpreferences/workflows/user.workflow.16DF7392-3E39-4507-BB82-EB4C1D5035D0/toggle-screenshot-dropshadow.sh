#!/usr/bin/env zsh
current=$(defaults read com.apple.screencapture disable-shadow)

if [[ "$current" == "0" ]]; then
	new="false"
else
	new="true"
fi
defaults write com.apple.screencapture disable-shadow -bool "$new"
killall SystemUIServer

echo -n "Drop shadow now: $new" # pass for notification
