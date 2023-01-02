#!/usr/bin/env zsh

# WARN running a git command on a path watcher trigger leads to an infinite loop
# since git commands create index lock files, which again trigger the path
# watcher. Therefore, not using any path watcher but regularly running this
# script plus trigger it after sync events via Hammerspoon

cd "$DOTFILE_FOLDER" || configError="repo-path wrong"
dotfiles=$(git status --porcelain)

cd "$VAULT_PATH" || configError="repo-path wrong"
vaultfiles=$(git status --porcelain)

passPath="$PASSWORD_STORE_DIR"
[[ -z "$passPath" ]] && passPath="$HOME/.password-store"
cd "$passPath" || configError="repo-path wrong"
passfiles=$(git status --porcelain --branch | grep -Eo "\d") # to check for ahead/behind instead of untracked

if [[ "$dotfiles" =~ " m " ]]; then # changes in submodules
	icon="✴️"
elif [[ -n "$dotfiles" ]] || [[ -n "$vaultfiles" ]] || [[ -n "$passfiles" ]]; then
	icon="🔁"
else
	icon=""
fi

sketchybar --set "$NAME" icon="$icon$configError"
