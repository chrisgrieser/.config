#!/usr/bin/env zsh

# INFO $LOCAL_REPOS and $VAULT_PATH are set in .zshenv

# CONFIG
theme_folder="$VAULT_PATH/.obsidian/themes/Shimmering Focus/"
remote_ssh="git@github.com:chrisgrieser/shimmering-focus.git"

#───────────────────────────────────────────────────────────────────────────────

[[ ! -d "$LOCAL_REPOS" ]] && mkdir -p "$LOCAL_REPOS"
cd "$LOCAL_REPOS" || return 1

# WARN depth=2 ensures that amending a shallow commit does not result in a
# new commit without parent, effectively destroying git history (!!)
git clone --depth=2 --filter="blob:none" "$remote_ssh"

# switch symlink
ln -f "$LOCAL_REPOS/shimmering-focus/theme.css" "$theme_folder/theme.css"

# loop back to open file
# (dependencies only needed later and therefore installed afterwards)
osascript -e '
	tell application id "com.runningwithcrayons.Alfred" to run trigger "loop" in workflow "de.chris-grieser.shimmering-focus"
'

# install dependencies
cd "./shimmering-focus/" && npm install
