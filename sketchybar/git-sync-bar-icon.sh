#!/usr/bin/env zsh
export GIT_OPTIONAL_LOCKS=0
#───────────────────────────────────────────────────────────────────────────────

function commits_ahead {
	local letter="$1"
	local repo_path="$2"
	changes=$(git -C "$repo_path" status --porcelain | wc -l | tr -d " ")
	[[ $changes -ne 0 ]] && all_changes="$all_changes$changes$letter "
}

function commits_behind {
	local letter="$1"
	local repo_path="$2"

	git -C "$repo_path" fetch
	behind=$(git -C "$repo_path" branch --verbose | grep -o "behind \d\+" | cut -d" " -f2)
	[[ $behind -ne 0 ]] && all_changes="$all_changes$changes!$letter "
}

function set_sketchybar {
	all_changes="$1"
	icon=""
	[[ -n "$all_changes" ]] && icon=""
	sketchybar --set "$NAME" icon="$icon" label="$all_changes"
}

#───────────────────────────────────────────────────────────────────────────────

all_changes=""

commits_ahead "d" "$HOME/.config"
commits_ahead "v" "$VAULT_PATH"
commits_ahead "p" "$PASSWORD_STORE_DIR"
commits_ahead "a" "$PHD_DATA_VAULT"

# INFO set early, since `git fetch` requires time and the icons should update quicker
# If there are behinds, icons will appear a few seconds later which isn't a
# problem. But if there are no behinds, the outdated label will disappear quicker.
set_sketchybar "$all_changes"

commits_behind "d" "$HOME/.config"
commits_behind "v" "$VAULT_PATH"
commits_behind "p" "$PASSWORD_STORE_DIR"
commits_behind "a" "$PHD_DATA_VAULT"

set_sketchybar "$all_changes"
