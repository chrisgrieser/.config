#!/usr/bin/env zsh

cd "$HOME/dotfiles" || exit 1
dotfiles=$(git status --porcelain)
cd "$HOME/Main Vault" || exit 1
vaultfiles=$(git status --porcelain)
if [[ -n "$dotfiles" ]] || [[ -n "$vaultfiles" ]] ; then
	icon="ﮛ"
else
	dotfiles=""
fi

sketchybar --set "$NAME" icon="$icon"



