#!/usr/bin/env zsh

# shellcheck disable=2154
staged_file="$1"
cd "$repo" || return 1
git add "$staged_file"
echo "$staged_file"
