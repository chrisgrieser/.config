#!/usr/bin/env zsh

# shellcheck disable=2034
GIT_OPTIONAL_LOCKS=0

# WARN running a git command on a path watcher trigger leads to an infinite loop
# since git commands create index lock files, which again trigger the path
# watcher. Therefore, not using any path watcher but regularly running this
# script plus trigger it after sync events via Hammerspoon

cd "$DOTFILE_FOLDER" || configError="repo-path wrong"
dotChanges=$(git status --short | wc -l | tr -d " ")
git status --short | grep -q " m " && submodulesChanges=1
echo "(log) dotChanges: $dotChanges"

cd "$VAULT_PATH" || configError="repo-path wrong"
vaultChanges=$(git status --porcelain | wc -l | tr -d " ")

passPath="$PASSWORD_STORE_DIR"
[[ -z "$passPath" ]] && passPath="$HOME/.password-store"
cd "$passPath" || configError="repo-path wrong"
passChanges=$(git status --porcelain --branch | grep -Eo "\d") # to check for ahead/behind instead of untracked, since pass auto add-commits, but does not auto-push

[[ "$dotChanges" != "0" ]] && label="${dotChanges}d " # INFO string comparison, so it also works with submodules
[[ $vaultChanges -ne 0 ]] && label="$label${vaultChanges}v "
[[ -n "$passChanges" ]] && label="$label${passChanges}p "
[[ -n "$label" ]] && icon="痢"
[[ $submodulesChanges -eq 1 ]] && icon=" "
sketchybar --set "$NAME" icon="$icon" label="$label$configError"
