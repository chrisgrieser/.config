#!/bin/zsh
# Obsidian Vault Navigation via Terminal
# --------------------------------------
# requirements:
# - node
# - fzf
# - bat
# --------------------------------------
# demo: https://raw.githubusercontent.com/chrisgrieser/shimmering-obsidian/main/docs/images/terminal-vault-navigation.png
# --------------------------------------

function ob (){
	VAULT_NAME=$(basename "$VAULT_PATH")
	VAULT_PATH_LENGTH=$(echo "$VAULT_PATH" | wc -c | tr -d " ")
	SELECTED=$(find "$VAULT_PATH" -name '*.md' -not -path "*./*" | cut -c"$VAULT_PATH_LENGTH"- | fzf --preview "bat --color=always --style=snip --wrap=character --terminal-width=50 \"$VAULT_PATH\"{}" --query "$*")
	if [[ $SELECTED == "" ]] ; then
		echo "Canceled."
		return;
	fi
	URL_ENCODED_PATH=$(node --eval "console.log(encodeURIComponent(process.argv[1]))" "$SELECTED")
	URL_ENCODED_VNAME=$(node --eval "console.log(encodeURIComponent(process.argv[1]))" "$VAULT_NAME")
	open "obsidian://open?vault=$URL_ENCODED_VNAME&file=$URL_ENCODED_PATH"
}
