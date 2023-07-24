#!/usr/bin/env zsh

# shellcheck disable=2154
cd "$base_folder" || return 1
files=$(find . -mindepth 1 -not -name ".DS_Store")
[[ -z "$files" ]] && echo -n "empty"
