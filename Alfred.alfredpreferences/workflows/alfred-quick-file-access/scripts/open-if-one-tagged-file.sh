#!/usr/bin/env zsh

# shellcheck disable=2154 # Alfred variable
tagged_files=$(mdfind "kMDItemUserTags == '$tag_to_search'")
count=$(echo "$tagged_files" | wc -l | tr -d " ")

[[ "$count" -eq 1 ]] && open "$tagged_files"
echo -n "$count" # for Alfred
