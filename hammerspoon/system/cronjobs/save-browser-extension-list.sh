#!/usr/bin/env zsh

# CONFIG
backup_file="$HOME/.config/+ browser-extension-configs/list-of-extensions.txt"

#───────────────────────────────────────────────────────────────────────────────

mkdir -p "$(dirname "$backup_file")"

# shellcheck disable=2010
ls "$HOME/Library/Application Support/BraveSoftware/Brave-Browser/Default/Extensions/" |
	grep -v "Temp" |
	sed "s|^|https://chrome.google.com/webstore/detail/|" \
		> "$backup_file"
