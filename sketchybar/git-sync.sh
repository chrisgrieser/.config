#!/usr/bin/env zsh

configError=""
cd "$DOTFILE_FOLDER" || configError="repo-path wrong"
dotfiles=$(git status --short)
cd "$VAULT_PATH" || configError="repo-path wrong"
vaultfiles=$(git status --porcelain)

passPath="$PASSWORD_STORE_DIR"
[[ -z "$passPath" ]] && passPath="$HOME/.password-store"
cd "$passPath" || configError="repo-path wrong"
passfiles=$(git status --porcelain --branch | grep -Eo "\d") # to check for ahead/behind instead of untracked

if [[ "$dotfiles" =~ " m " ]]; then # changes in submodules
	icon="🔁*"
elif [[ -n "$dotfiles" ]] || [[ -n "$vaultfiles" ]] || [[ -n "$passfiles" ]]; then
	icon="🔁"
fi

sketchybar --set "$NAME" icon="$icon$configError"
