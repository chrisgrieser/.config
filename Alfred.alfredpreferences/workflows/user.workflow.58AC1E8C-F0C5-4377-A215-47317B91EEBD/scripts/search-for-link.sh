#!/usr/bin/env zsh

query="$*"

# shellcheck disable=2154
[[ "$include_unsafe" == "1" ]] && unsafe="--unsafe"

# `--noua` disables user agent & fetches faster (~10% faster according to hyperfine)
url=$(python3 ./dependencies/ddgr.py --num=1 --noua "$unsafe" --json "$query" | grep "url" | cut -d'"' -f4)
mdlink="[$query]($url)"

echo -n "$mdlink"
