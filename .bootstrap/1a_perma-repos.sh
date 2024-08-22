#!/usr/bin/env zsh

# CONFIG
vault_dir="$HOME/vaults"

mkdir -p "$vault_dir"
cd "$vault_dir" || return 1

#───────────────────────────────────────────────────────────────────────────────

cut -d, -f2 "$HOME/.config/perma-repos.csv" |
	sed "s|^~|$HOME|" |
	grep -vE ".config|.password-store" |
	xargs basename |
	xargs -I {} git clone git@github.com:chrisgrieser/{}
