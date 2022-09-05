#!/usr/bin/env zsh
current=$(defaults read com.apple.screencapture disable-shadow)

if [[ "$current" == "1" ]]; then
	new="false"
else
	new="true"
fi
defaults write com.apple.screencapture disable-shadow -bool "$new"
killall SystemUIServer

echo "Drop shadow now: $new"
