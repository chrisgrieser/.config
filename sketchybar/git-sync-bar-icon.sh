#!/usr/bin/env zsh
export GIT_OPTIONAL_LOCKS=0

# WARN running a git command on a path watcher trigger leads to an infinite loop
# since git commands create index lock files, which again trigger the path
# watcher. Therefore, not using any path watcher but regularly running this
# script plus trigger it after sync events via Hammerspoon

#───────────────────────────────────────────────────────────────────────────────
# CHANGES
dotChanges=$(git -C "$HOME/.config" status --short | wc -l | tr -d " ")
vaultChanges=$(git -C "$VAULT_PATH" status --porcelain | wc -l | tr -d " ")
passChanges=$(git -C "$PASSWORD_STORE_DIR" status --porcelain | wc -l | tr -d " ")
[[ $dotChanges -ne 0 ]] && label="${dotChanges}d "
[[ $vaultChanges -ne 0 ]] && label="$label${vaultChanges}v "
[[ $passChanges -ne 0 ]] && label="$label${passChanges}p"

# INFO set early, since `git fetch` requires time and the icons should update quicker
# If there are behinds, icons will appear a few seconds later which isn't a
# problem. But if there are no behinds, the outdated label will disappear quicker.

[[ -n "$label" ]] && icon=""
sketchybar --set "$NAME" icon="$icon" label="$label"

#───────────────────────────────────────────────────────────────────────────────
# COMMITS BEHIND

git "$HOME/.config" fetch # required to check for commits behind
git "$VAULT_PATH" fetch
git "$PASSWORD_STORE_DIR" fetch

dotBehind=$(git -C "$HOME/.config" -c "status.short=false" status --porcelain --branch | 
	head -n1 | grep "behind" | grep -Eo "\d")
vaultBehind=$(git -C "$VAULT_PATH" -c "status.short=false" status --porcelain --branch | 
	head -n1 | grep "behind" | grep -Eo "\d")
passBehind=$(git -C "$PASSWORD_STORE_DIR" -c "status.short=false" status --porcelain --branch | 
	head -n1 | grep "behind" | grep -Eo "\d")

[[ -n "$dotBehind" ]] && label="$label${dotBehind}!d "
[[ -n "$vaultBehind" ]] && label="$label${vaultBehind}!v "
[[ -n "$passBehind" ]] && label="$label${passBehind}!p"

icon=""
[[ -n "$label" ]] && icon=" "

sketchybar --set "$NAME" icon="$icon" label="$label"
