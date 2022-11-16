#!/usr/bin/env zsh

cd "$HOME/dotfiles" || exit 1
dotfiles=$(git status --short)
cd "$HOME/Main Vault" || exit 1
vaultfiles=$(git status --porcelain)

if [[ "$dotfiles" =~ " m " ]] ; then # changes in submodules
	icon="*🔁"
elif [[ -n "$dotfiles" ]] || [[ -n "$vaultfiles" ]] ; then
	icon="🔁"
else
	dotfiles=""
fi

sketchybar --set "$NAME" icon="$icon"



