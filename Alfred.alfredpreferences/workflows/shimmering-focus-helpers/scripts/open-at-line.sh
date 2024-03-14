#!/usr/bin/env zsh

# INFO LOCAL_REPOS set in zshenv
sf_path="$LOCAL_REPOS/shimmering-focus/theme.css"

# workaround for https://github.com/neovide/neovide/issues/1604
lineNo="$*"
open "$sf_path" --env=LINE="$lineNo"
