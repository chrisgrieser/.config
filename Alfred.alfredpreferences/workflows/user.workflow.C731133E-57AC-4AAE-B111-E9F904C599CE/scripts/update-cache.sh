#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# check if cache is old
# shellcheck disable=2154
cache="${alfred_workflow_cache}/cache.json"
updating="${alfred_workflow_cache}/is-updating"

touch "$updating"
[[ -z "$(find "${cache}" -mtime -1)" ]] && osascript -l JavaScript "./scripts/build-brew-list.js" >"$cache"
rm -f "$updating"
