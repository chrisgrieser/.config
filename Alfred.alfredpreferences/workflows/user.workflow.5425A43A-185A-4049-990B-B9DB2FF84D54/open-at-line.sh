#!/usr/bin/env zsh

# INFO vault path set in zshenv
sf_path="$VAULT_PATH/.obsidian/themes/Shimmering Focus/theme.css"
lineNo="$*"

# workaround for https://github.com/neovide/neovide/issues/1604
open "$sf_path/source.css" --env=LINE="$lineNo"
