#!/usr/bin/env zsh

# CONFIG
list_name="Diss URLs"

#───────────────────────────────────────────────────────────────────────────────
set -e

# start Obsidian
open -a "Obsidian"
sleep 1

# Download
urls=$(reminders show "$list_name" --format=json | yq '.[].title' --input-format=json)
echo "$urls" | xargs -I {} open "obsidian://slurp?vault=phd-data-analysis&url={}"
echo "$urls" | pbcopy

# show inbox
open "$HOME/phd-data-analysis/Data/_ inbox"
open "$HOME/phd-data-analysis/Data/articles"

# complete
url_count=$(echo "$urls" | wc -l)

for ((i = 0; i <= ; i++)); do
   
done
