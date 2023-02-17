#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# shellcheck disable=2154
mkdir -p "$alfred_workflow_cache"
cache="${alfred_workflow_cache}/cache.json"
updating="${alfred_workflow_cache}/is-updating"

# build cache on first run
[[ ! -f "$cache" ]] && osascript -l JavaScript "./scripts/build-brew-list.js" >"$cache"

# avoid cache corruption when running while currently updating
if [[ -e "$updating" ]]; then
	echo '{"items": [{"title": "Cache reloading, try again in a moment.", "valid": false}]}'
else
	cat "$cache"
fi
