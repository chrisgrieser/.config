#!/usr/bin/env zsh
# shellcheck disable=2154
# INFO this scripts basically replaces https://brettterpstra.com/projects/searchlink/

query="$*"

# get URL
# HACK adding `--noua` seems to fix the `[ERROR] HTTP Error 202: Accepted`
# shellcheck disable=2086
response=$(ddgr $ddgr_args --num=1 --json --reg="$region" "$query")
url=$(echo "$response" | grep "url" | cut -d'"' -f4)
mdlink="[$query]($url)"

# paste via Alfred
echo -n "$mdlink"
