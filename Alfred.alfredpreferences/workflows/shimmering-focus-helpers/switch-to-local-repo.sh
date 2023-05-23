#!/usr/bin/env zsh
# shellcheck disable=2154,2164

theme_folder="$VAULT_PATH/.obsidian/themes/Shimmering Focus/"
remote_ssh="git@github.com:chrisgrieser/shimmering-focus.git"

#───────────────────────────────────────────────────────────────────────────────

[[ ! -d "$target_path" ]] && mkdir -p "$target_path"
cd "$LOCAL_REPOS"
git clone --depth=1 "$remote_ssh"
npm i # install dependencies (clean-css-cli)

ln -sf "$LOCAL_REPOS/shimmering-focus/source.css" "$theme_folder/theme.css"
