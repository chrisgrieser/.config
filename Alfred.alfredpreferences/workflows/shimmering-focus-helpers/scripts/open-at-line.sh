#!/usr/bin/env zsh

# shellcheck disable=2154 # Alfred var
sf_path="$local_repos/shimmering-focus/theme.css"
lineNo="$*"

# workaround for https://github.com/neovide/neovide/issues/1604
open "$sf_path"
sleep 0.8
open "$sf_path" --env=LINE="$lineNo" # FIX not open at correct line
