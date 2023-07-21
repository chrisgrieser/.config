#!/usr/bin/env zsh
# shellcheck disable=2154,2164

theme_folder="$VAULT_PATH/.obsidian/themes/Shimmering Focus/"
remote_ssh="git@github.com:chrisgrieser/shimmering-focus.git"

#───────────────────────────────────────────────────────────────────────────────

[[ ! -d "$LOCAL_REPOS" ]] && mkdir -p "$LOCAL_REPOS"
cd "$LOCAL_REPOS"
git clone --depth=1 --filter="blob:none" "$remote_ssh"
cd "shimmering-focus" || return 1
ln -sf "$LOCAL_REPOS/shimmering-focus/source.css" "$theme_folder/theme.css"

#───────────────────────────────────────────────────────────────────────────────

