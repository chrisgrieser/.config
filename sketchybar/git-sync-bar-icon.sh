#!/usr/bin/env zsh

# WARN running a git command on a path watcher trigger leads to an infinite loop
# since git commands create index lock files, which again trigger the path
# watcher. Therefore, not using any path watcher but regularly running this
# script plus trigger it after sync events via Hammerspoon

cd "$DOTFILE_FOLDER" || configError="repo-path wrong"
dotfiles=$(git --no-optional-locks status --short)
dotChanges=$(echo "$dotfiles" | wc -l | td -d " ")
[[ "$dotfiles" =~ " m " ]] && dotChanges="$dotChanges!" # changes in submodules

cd "$VAULT_PATH" || configError="repo-path wrong"
vaultfiles=$(git --no-optional-locks status --porcelain)
vaultChanges=$(echo "$vaultfiles" | wc -l | td -d " ")

passPath="$PASSWORD_STORE_DIR"
[[ -z "$passPath" ]] && passPath="$HOME/.password-store"
cd "$passPath" || configError="repo-path wrong"
passfiles=$(git --no-optional-locks status --porcelain --branch | grep -Eo "\d") # to check for ahead/behind instead of untracked, since pass auto add-commits, but does not auto-push

label="$dotChanges/$vaultChanges/$passfiles"
label=${label/#\//} ; label=${label/\/%/}
if [[ -n "$dotfiles" ]] || [[ -n "$vaultfiles" ]] || [[ -n "$passfiles" ]]; then
	icon="痢"
fi

sketchybar --set "$NAME" icon="$icon$configError" label="$label$configError"
