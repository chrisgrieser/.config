#!/usr/bin/env zsh

pseudo_clipboard="/tmp/pseudo-clipboard/"

# clear from previous attempts
rm -r "$pseudo_clipboard"
mkdir "$pseudo_clipboard"

for arg in "$@" ; do
	cp -R "$arg" "$pseudo_clipboard"
	mv "$arg" "$HOME/.Trash" # leave copy in trash
done

osascript "$(dirname "$0")/copy-to-clipboard.applescript" "$pseudo_clipboard/"*

afplay "/System/Library/Sounds/bottle.aiff"
