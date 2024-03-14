#!/usr/bin/env zsh

# CONFIG
theme_folder_1="$VAULT_PATH/.obsidian/themes/Shimmering Focus/"
theme_folder_2="$PHD_DATA_VAULT/.obsidian/themes/Shimmering Focus/"
remote_ssh="git@github.com:chrisgrieser/shimmering-focus"

# INFO 
# $LOCAL_REPOS, $PHD_DATA_VAULT, and $VAULT_PATH are set in .zshenv

#───────────────────────────────────────────────────────────────────────────────

[[ ! -d "$LOCAL_REPOS" ]] && mkdir -p "$LOCAL_REPOS"
cd "$LOCAL_REPOS" || return 1

# WARN depth=2 ensures that amending a shallow commit does not result in a
# new commit without parent, effectively destroying git history
git clone --depth=2 --filter="blob:none" "$remote_ssh"

# switch to symlink
ln -sf "$LOCAL_REPOS/shimmering-focus/theme.css" "$theme_folder_1/theme.css"
ln -sf "$LOCAL_REPOS/shimmering-focus/theme.css" "$theme_folder_2/theme.css"

# loop back to open file
# (dependencies only needed later and therefore installed afterwards)
osascript -e '
	tell application id "com.runningwithcrayons.Alfred" to run trigger "loop" in workflow "de.chris-grieser.shimmering-focus"
'

# install dependencies
cd "./shimmering-focus/" && npm install
