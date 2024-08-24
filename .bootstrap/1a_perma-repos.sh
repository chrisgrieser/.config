#!/usr/bin/env zsh

cut -d, -f2 "$HOME/.config/perma-repos.csv" |
	grep -vE ".config|.password-store" | # already cloned in previous step
	sed "s|^~|$HOME|" |
	while read -r repo; do
		location="$(dirname "$repo")"
		mkdir -p "$location"
		cd "$location" || return 1
		git clone --depth=1 git@github.com:chrisgrieser/"$(basename "$repo")"
		echo
	done

# contains info on all the vaults, so they do not have to be added manually
cp -f ./obsidian.json "$HOME/Library/Application Support/obsidian/obsidian.json"
