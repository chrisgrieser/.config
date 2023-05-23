#!/usr/bin/env zsh

# switch to the FALLBACK
theme_folder="$VAULT_PATH/.obsidian/themes/Shimmering Focus/"
ln -sf "$theme_folder/fallback.css" "$theme_folder/theme.css"

# delete local folder
# shellcheck disable=2154
rm -r "$local_repo_folder/shimmering-focus"
