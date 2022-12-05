#!/usr/bin/env zsh

cd "$HOME/.config" || configError="repo-path wrong"
cd "$HOME/main-vault" || configError="repo-path wrong"
cd "$HOME/.password-store" || configError="repo-path wrong"

dotfiles=$(git status --short)
vaultfiles=$(git status --porcelain)
passfiles=$(git status --porcelain)

if [[ "$dotfiles" =~ " m " ]]; then # changes in submodules
	icon="*🔁"
elif [[ -n "$dotfiles" ]] || [[ -n "$vaultfiles" ]] || [[ -n "$passfiles" ]]; then
	icon="🔁"
fi

sketchybar --set "$NAME" icon="$icon$configError"
