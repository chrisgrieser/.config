#!/usr/bin/env zsh

if ! command -v ddgr &>/dev/null; then echo -n "ddgr not installed." && return 1; fi

query="$*"

# shellcheck disable=2154
[[ "$include_unsafe" == "1" ]] && extra="--unsafe"

# `--noua` disables user agent & fetches faster (~10% faster according to hyperfine)
url=$(ddgr --num=1 --noua "$extra" --json "$query" | grep "url" | cut -d'"' -f4)
mdlink="[$query]($url)"

echo -n "$mdlink"
