#!/usr/bin/env zsh

export GIT_OPTIONAL_LOCKS=0

# WARN running a git command on a path watcher trigger leads to an infinite loop
# since git commands create index lock files, which again trigger the path
# watcher. Therefore, not using any path watcher but regularly running this
# script plus trigger it after sync events via Hammerspoon

#───────────────────────────────────────────────────────────────────────────────
# CHANGES

cd "$HOME/.config" || configError="repo-path wrong"
dotChanges=$(git status --short | wc -l | tr -d " ")

cd "$VAULT_PATH" || configError="repo-path wrong"
vaultChanges=$(git status --porcelain | wc -l | tr -d " ")

cd "$PASSWORD_STORE_DIR" || configError="repo-path wrong"
passChanges=$(git status --porcelain | wc -l | tr -d " ")

[[ $dotChanges -ne 0 ]] && label="${dotChanges}d "
[[ $vaultChanges -ne 0 ]] && label="$label${vaultChanges}v "
[[ $passChanges -ne 0 ]] && label="$label${passChanges}p"

#───────────────────────────────────────────────────────────────────────────────

# INFO set early, since `git fetch` requires time and the icons should update quicker
# If there are behinds, icons will appear a few seconds later which isn't a
# problem. But if there are no behinds, the outdated label will disappear quicker.

if [[ -n "$label" ]] ; then
	sketchybar --set "$NAME" icon=" " label="$label$configError"
else
	sketchybar --remove "$NAME"
fi

#───────────────────────────────────────────────────────────────────────────────
# COMMITS BEHIND

cd "$HOME/.config" || configError="repo-path wrong"
git fetch # required to check for commits behind
dotBehind=$(git status --porcelain --branch | head -n1 | grep "behind" | grep -Eo "\d")

cd "$VAULT_PATH" || configError="repo-path wrong"
git fetch
vaultBehind=$(git status --porcelain --branch | head -n1 | grep "behind" | grep -Eo "\d")

cd "$PASSWORD_STORE_DIR" || configError="repo-path wrong"
git fetch
passBehind=$(git status --porcelain --branch | head -n1 | grep "behind" | grep -Eo "\d")

[[ -n "$dotBehind" ]] && label="$label${dotBehind}!d "
[[ -n "$vaultBehind" ]] && label="$label${vaultBehind}!v "
[[ -n "$passBehind" ]] && label="$label${passBehind}!p"

if [[ -n "$label" ]] ; then
	sketchybar --set "$NAME" icon=" " label="$label$configError"
else
	sketchybar --remove "$NAME"
fi
