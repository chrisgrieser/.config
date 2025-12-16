#!/usr/bin/env zsh

cut -d, -f1 "$HOME/.config/perma-repos.csv" |
	grep -vE ".config|.password-store" | # exclude the ones already cloned in previous step
	sed "s|^~|$HOME|" |
	while read -r repo; do
		parent="$(dirname "$repo")"
		mkdir -p "$parent"
		cd "$parent" || return 1
		git clone git@github.com:chrisgrieser/"$(basename "$repo")"
		echo
	done
