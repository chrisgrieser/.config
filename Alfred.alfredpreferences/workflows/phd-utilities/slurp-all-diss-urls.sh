#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred vars
set -e

#───────────────────────────────────────────────────────────────────────────────

# start Obsidian (to ensure all URIs are accepted)
if ! pgrep -xq "Obsidian"; then
	open -a "Obsidian"
	sleep 1
fi

# Download
urls=$(reminders show "$slurp_list" --format=json | yq '.[].title' --input-format=json)
echo "$urls" | xargs -I {} open "obsidian://slurp?vault=${slurp_vault}&url={}"
echo "$urls" | pbcopy

# show inbox
open "$HOME/phd-data-analysis/Data/articles"
open "$HOME/phd-data-analysis/Data/_ inbox"

# complete all (backwards, as indexes are shifted)
url_count=$(echo "$urls" | wc -l)
for ((i = url_count - 1; i >= 0; i--)); do
	reminders complete "$slurp_list" $i
done
