#!/usr/bin/env zsh

# CONFIG
theme_folders=$(grep --ignore-case "vault" "$HOME/.config/perma-repos.csv" |
	cut -d, -f2 |
	sed -e "s|^~|$HOME|" -e 's|$|/.obsidian/themes/Shimmering Focus/theme.css|')

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
echo "$theme_folders" | while read -r theme_file; do
	ln -sf "$LOCAL_REPOS/shimmering-focus/theme.css" "$theme_file"
done

# loop back to open file
# (dependencies only needed later and therefore installed afterwards)
osascript -e '
	tell application id "com.runningwithcrayons.Alfred" to run trigger "loop" in workflow "de.chris-grieser.shimmering-focus"
'

# install dependencies
cd "./shimmering-focus/" && npm install
