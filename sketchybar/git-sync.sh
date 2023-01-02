#!/usr/bin/env zsh

# shellcheck disable=2034
GIT_OPTIONAL_LOCKS=0

# INFO to prevent constantly calling `git status`, which prevents other git processes
# from running due to lock (happens sometimes even with optional locks)
# FROM_PATCHWATCHER gets set when called from hammerspoon
if [[ "$FROM_PATCHWATCHER" -eq 1 ]]; then
	sketchybar --set "$NAME" icon="🔁"
	osascript -e 'display notification "" with title "pathwatcher loop"'
	exit 0
fi

osascript -e 'display notification "" with title "regular trigger"'
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
