#!/usr/bin/env zsh
# shellcheck disable=2154,2164

theme_folder="$VAULT_PATH/.obsidian/themes/Shimmering Focus/"
remote_ssh="git@github.com:chrisgrieser/shimmering-focus.git"

#───────────────────────────────────────────────────────────────────────────────

[[ ! -d "$LOCAL_REPOS" ]] && mkdir -p "$LOCAL_REPOS" 
cd "$LOCAL_REPOS"

git clone --depth=1 --filter="blob:none" "$remote_ssh"
ln -sf "$LOCAL_REPOS/shimmering-focus/source.css" "$theme_folder/theme.css"

# run in background, since dependencies can be run in the background 
cd "$LOCAL_REPOS/shimmering-focus/" || return 1
npm install --production &

