#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# shellcheck disable=2154
readonly cache="${alfred_workflow_cache}/cache.json"

# build cache on first run
if [[ ! -f "$cache" ]]; then
	osascript -l JavaScript "./build-brew-list.js" >"$cache"
	while [[ ! -f "$cache" ]]; do sleep 0.1; done
fi

# check if cache is old
[[ -n "$(find "${cache}" -mtime +15)" ]]
