#!/usr/bin/env zsh

sf_path="$local_repos/shimmering-focus/theme.css"

# workaround for https://github.com/neovide/neovide/issues/1604
lineNo="$*"
open "$sf_path" --env=LINE="$lineNo"
