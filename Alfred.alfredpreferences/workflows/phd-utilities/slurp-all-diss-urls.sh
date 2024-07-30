#!/usr/bin/env zsh
# shellcheck disable=2154 # Alfred vars
set -e
#───────────────────────────────────────────────────────────────────────────────

# start Obsidian (to ensure all URIs are accepted)
open "obsidian://vault=${slurp_vault}"
sleep 4

# Download
urls=$(
	reminders show "$slurp_list" |
		cut -d " " -f2- |
		xargs -I {} echo "obsidian://slurp?vault=${slurp_vault}&url={}"
)
echo "$urls" | xargs open
echo "$urls" | pbcopy

# show inbox
open "$HOME/phd-data-analysis/Data/articles"
open "$HOME/phd-data-analysis/Data/_ inbox"

# complete all (backwards, as indexes are shifted)
url_count=$(echo "$urls" | wc -l)
for ((i = url_count - 1; i >= 0; i--)); do
	reminders complete "$slurp_list" $i
done
