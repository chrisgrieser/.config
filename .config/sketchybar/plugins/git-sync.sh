#!/usr/bin/env sh

cd "$HOME/dotfiles" || exit 1
dotfiles=$(git status --porcelain | wc -l | tr -d " ")
if [[ $dotfiles -gt 0 ]] ; then
	dotfiles="⏺ "
else
	dotfiles=""
fi

cd "$HOME/Main Vault" || exit 1
vaultfiles=$(git status --porcelain | wc -l | tr -d " ")
if [[ $vaultfiles -gt 0 ]] ; then
	vaultfiles="🟣 "
else
	vaultfiles=""
fi


sketchybar --set "$NAME" label="$dotfiles$vaultfiles"



