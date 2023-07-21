#!/usr/bin/env zsh


path_to_open="$*"
current_cwd=$(wezterm cli list --format json | grep "cwd" | cut -d'"' -f4 | sed 's/%20/ /g' | sed -E 's|/$||' | sed -E 's/^file:.*local//')

echo -n "$path_to_open"
