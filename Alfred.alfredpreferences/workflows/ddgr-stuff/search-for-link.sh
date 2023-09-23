#!/usr/bin/env zsh
# shellcheck disable=2154
query="$*"

# PERF `--noua` disables user agent & fetches faster (~10% faster according to hyperfine)
# but does not work all the time
response=$(ddgr --num=1 --noua --unsafe --json --reg="$region" "$query" 2>&1)
[[ "$response" =~ "HTTP Error 403" ]] && response=$(ddgr --num=1 --unsafe --json --reg="$region" "$query")

url=$(echo "$response" | grep "url" | cut -d'"' -f4)
mdlink="[$query]($url)"
echo -n "$mdlink"
