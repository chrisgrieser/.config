#!/usr/bin/env zsh

# How to generate the karabiner mod schema
#───────────────────────────────────────────────────────────────────────────────

if ! command -v quicktype &>/dev/null; then print "\033[1;33mquicktype not installed.\033[0m" && return 1; fi

# TODO manually: exclude Finder vim json and highlights vim mode
cat ./*.yaml >all.yaml
# TODO cleanup unneeded properties, e.g. top-level title-keys
yq --output-format=json 'explode(.)' "all.yaml" >"all.json"

quicktype all.json --all-properties-optional --lang=schema --out=../karabiner-mod.json
