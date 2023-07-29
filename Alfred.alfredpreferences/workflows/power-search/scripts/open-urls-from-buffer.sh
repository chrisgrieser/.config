#!/usr/bin/env zsh

# shellcheck disable=2154
saved_urls="$alfred_workflow_cache/urlsToOpen.txt"

if [[ -f "$saved_urls" ]] ; then

content=$(cat "$file")
rm "$file"
echo -n "$content"
fi
