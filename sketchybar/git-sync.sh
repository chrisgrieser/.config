#!/usr/bin/env zsh

# shellcheck disable=2034
GIT_OPTIONAL_LOCKS=0

# INFO to prevent constantly calling `git status`, which prevents other git processes
# from running due to lock (happens sometimes even with optional locks)
# FROM_PATCHWATCHER gets set when called from hammerspoon. 
# WARN running a git command on a path watcher trigger leads to an infinite loop
# since git commands create index lock files, which again trigger the path 
# watcher, therefore this workaround seems necessary
if [[ "$FROM_PATHWATCHER" -eq 1 ]]; then
	sketchybar --set "$NAME" icon="🔁"
	exit 0
fi

configError=""

cd "$DOTFILE_FOLDER" || configError="repo-path wrong"
dotfiles=$(git status --porcelain)

cd "$VAULT_PATH" || configError="repo-path wrong"
vaultfiles=$(git status --porcelain)

passPath="$PASSWORD_STORE_DIR"
[[ -z "$passPath" ]] && passPath="$HOME/.password-store"
cd "$passPath" || configError="repo-path wrong"
passfiles=$(git status --porcelain --branch | grep -Eo "\d") # to check for ahead/behind instead of untracked

if [[ -n "$dotfiles" ]] || [[ -n "$vaultfiles" ]] || [[ -n "$passfiles" ]]; then
	icon="🔁"
fi

sketchybar --set "$NAME" icon="$icon$configError"
