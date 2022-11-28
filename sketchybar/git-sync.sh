#!/usr/bin/env zsh

configError=""
cd "$HOME/.config" || configError="repo-path wrong"
dotfiles=$(git status --short)
cd "$HOME/main-vault" || configError="repo-path wrong"
vaultfiles=$(git status --porcelain)

if [[ "$dotfiles" =~ " m " ]]; then # changes in submodules
	icon="*🔁"
elif [[ -n "$dotfiles" ]] || [[ -n "$vaultfiles" ]]; then
	icon="🔁"
else
	dotfiles=""
fi

sketchybar --set "$NAME" icon="$icon$configError"
