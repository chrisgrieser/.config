#!/usr/bin/env zsh

cut -d, -f1 "$HOME/.config/perma-repos.csv" |
	grep -vE ".config|.password-store" | # already cloned in previous step
	sed "s|^~|$HOME|" |
	while read -r repo; do
		location="$(dirname "$repo")"
		mkdir -p "$location"
		cd "$location" || return 1
		git clone --depth=1 git@github.com:chrisgrieser/"$(basename "$repo")"
		echo
	done
