#!/usr/bin/env zsh

# shellcheck disable=2154
cd "$base_folder" || return 1

[[ -z "$(ls)" ]] && echo -n "empty"
