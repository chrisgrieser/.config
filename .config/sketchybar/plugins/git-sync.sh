#!/usr/bin/env zsh

cd "$HOME/dotfiles" || exit 1
dotfiles=$(git status --porcelain)
if [[ -n "$dotfiles" ]] ; then
	dotfiles="⏺ "
else
	dotfiles=""
fi

cd "$HOME/Main Vault" || exit 1
vaultfiles=$(git status --porcelain)
if [[ -n "$vaultfiles" ]] ; then
	vaultfiles="🟪 "
else
	vaultfiles=""
fi


sketchybar --set "$NAME" icon="$dotfiles $vaultfiles"



