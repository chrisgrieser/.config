#!/usr/bin/env zsh
export GIT_OPTIONAL_LOCKS=0

perma_repos_path="$HOME/.config/perma-repos.csv"
all_changes=""

#-UNCOMMITTED CHANGES-----------------------------------------------------------
while read -r line; do
	letter=$(echo "$line" | cut -d, -f3)
	repo_path=$(echo "$line" | cut -d, -f1 | sed "s|^~|$HOME|")
	changes=$(git -C "$repo_path" status --porcelain)
	change_count=0 # to account for empty changes adding one blank line
	[[ -n "$changes" ]] && change_count=$(echo "$changes" | wc -l | tr -d " ")

	if [[ "$changes" =~ index\.lock ]]; then # blocked by lockfile
		all_changes="$all_changes $letter "
	elif [[ $change_count -ne 0 ]]; then
		all_changes="$all_changes$change_count$letter "
	fi
done < "$perma_repos_path"

#-COMMITS BEHIND----------------------------------------------------------------
while read -r line; do
	letter=$(echo "$line" | cut -d, -f4)
	repo_path=$(echo "$line" | cut -d, -f2 | sed "s|^~|$HOME|")

	git -C "$repo_path" fetch
	behind=$(git -C "$repo_path" branch --verbose |
		grep --only-matching "behind \d\+" |
		cut -d" " -f2)
	[[ -n $behind ]] && all_changes="$all_changes$behind󰶡$letter "
done < "$perma_repos_path"

#-SET---------------------------------------------------------------------------
if [[ -z "$all_changes" ]]; then
	sketchybar --set "$NAME" drawing=false
else
	sketchybar --set "$NAME" drawing=true label="$all_changes"
fi
