#!/usr/bin/env zsh
export GIT_OPTIONAL_LOCKS=0

function set_sketchybar {
	icon=""
	[[ -n "$all_changes" ]] && icon=""
	sketchybar --set "$NAME" icon="$icon" label="$all_changes"
}

#───────────────────────────────────────────────────────────────────────────────

all_changes=""
perma_repos_path="$HOME/.config/perma-repos.csv"

# commits ahead
while read -r line; do
	letter=$(echo "$line" | cut -d, -f4)
	repo_path=$(echo "$line" | cut -d, -f2 | sed "s|^~|$HOME|")
	changes=$(git -C "$repo_path" status --porcelain)
	change_count=$(echo "$changes" | wc -l | tr -d " ")

	if [[ "$changes" =~ index.lock ]] ; then # lockfile
		all_changes="$all_changes🔒$letter "
	elif [[ $changes -ne 0 ]] ; then
		all_changes="$all_changes$change_count$letter "
	fi
done <"$perma_repos_path"

# INFO set early, since `git fetch` requires time and the icons should update quicker
# If there are behinds, icons will appear a few seconds later which isn't a
# problem. But if there are no behinds, the outdated label will disappear quicker.
set_sketchybar

# commits behind
while read -r line; do
	letter=$(echo "$line" | cut -d, -f4)
	repo_path=$(echo "$line" | cut -d, -f2 | sed "s|^~|$HOME|")

	git -C "$repo_path" fetch
	behind=$(git -C "$repo_path" branch --verbose |
		grep --only-matching "behind \d\+" |
		cut -d" " -f2)
	[[ -n $behind ]] && all_changes="$all_changes$behind!$letter "
done <"$perma_repos_path"

set_sketchybar
