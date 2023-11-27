#!/usr/bin/env zsh
# shellcheck disable=2154
# INFO this scripts basically replaces https://brettterpstra.com/projects/searchlink/

query="$*"

# get URL
response=$(ddgr --num=1 --unsafe --json --reg="$region" "$query")
url=$(echo "$response" | grep "url" | cut -d'"' -f4)
mdlink="[$query]($url)"

# paste via Alfred
echo -n "$mdlink"
