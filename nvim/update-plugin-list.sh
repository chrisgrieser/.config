#!/usr/bin/env zsh
# updates README.md with current list of installed plugins

# CONFIG
nvim_readme="./nvim/README.md"
last_line_before_plugins="## All installed plugins"
lazy_lock="./nvim/.lazy-lock.json"
lazy_specs_path="./nvim/lua/plugins"

#───────────────────────────────────────────────────────────────────────────────

# remove old lines
# sed -i '' -n "1,/$last_line_before_plugins/p" "$nvim_readme"

plugin_names=$(sed '1d;$d' "$lazy_lock" | cut -d'"' -f2)

echo "$lines" | while read -r line; do
	echo "$line"
done
	




