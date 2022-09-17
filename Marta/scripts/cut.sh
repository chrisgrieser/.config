#!/usr/bin/env zsh

# clear from previous attempts
pseudo_clipboard="/tmp/pseudo-clipboard/"
rm -r "$pseudo_clipboard"
mkdir "$pseudo_clipboard"

for arg in "$@" ; do
	cp "$arg" "$pseudo_clipboard"
	mv "$arg" "$HOME/.Trash" # leave copy in trash
done

osascript "/Users/chrisgrieser/dotfiles/Marta/scripts/copy-to-clipboard.applescript" "$pseudo_clipboard/*"

afplay "/System/Library/Sounds/bottle.aiff"
