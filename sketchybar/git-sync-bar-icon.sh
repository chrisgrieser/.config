#!/usr/bin/env zsh

# shellcheck disable=2034
GIT_OPTIONAL_LOCKS=0

# WARN running a git command on a path watcher trigger leads to an infinite loop
# since git commands create index lock files, which again trigger the path
# watcher. Therefore, not using any path watcher but regularly running this
# script plus trigger it after sync events via Hammerspoon

#───────────────────────────────────────────────────────────────────────────────

cd "$DOTFILE_FOLDER" || configError="repo-path wrong"
dotChanges=$(git status --short | wc -l | tr -d " ")
git fetch # required to check for commits behind
dotBehind=$(git status --porcelain --branch | grep -Eo "\d") 

cd "$VAULT_PATH" || configError="repo-path wrong"
vaultChanges=$(git status --porcelain | wc -l | tr -d " ")
git fetch
vaultBehind=$(git status --porcelain --branch | grep -Eo "\d") 

cd "$VAULT_PATH" || configError="repo-path wrong"
git fetch
passChanges=$(git status --porcelain | wc -l | tr -d " ")
passBehind=$(git status --porcelain --branch | grep -Eo "\d") 

#───────────────────────────────────────────────────────────────────────────────

[[ $dotChanges -ne 0 ]] && label="${dotChanges}d " 
[[ $vaultChanges -ne 0 ]] && label="$label${vaultChanges}v "
[[ "$passChanges" -ne 0 ]] && label="$label${passChanges}p"

[[ -n "$dotBehind" ]] && label="$label${dotBehind}p"
[[ -n "$vaultBehind" ]] && label="$label${vaultBehind}p"
[[ -n "$passBehind" ]] && label="$label${passBehind}p"

[[ -n "$label" ]] && icon=" "

sketchybar --set "$NAME" icon="$icon" label="$label$configError"
