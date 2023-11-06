#!/usr/bin/env zsh

# switch to the FALLBACK
cd "$VAULT_PATH/.obsidian/themes/Shimmering Focus/" || return 1
ln -sf "fallback.css" "theme.css"

# delete local folder
rm -rf "$LOCAL_REPOS/shimmering-focus"
