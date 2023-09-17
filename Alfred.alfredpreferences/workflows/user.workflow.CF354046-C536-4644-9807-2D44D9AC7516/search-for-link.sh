#!/usr/bin/env zsh

query="$*"

# PERF `--noua` disables user agent & fetches faster (~10% faster according to hyperfine)
url=$(ddgr --num=1 --noua --unsafe --json "$query" | grep "url" | cut -d'"' -f4)
mdlink="[$query]($url)"

echo -n "$mdlink"
