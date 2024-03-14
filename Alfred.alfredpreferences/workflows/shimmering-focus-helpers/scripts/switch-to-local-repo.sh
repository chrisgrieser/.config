#!/usr/bin/env zsh
# INFO
# get all folder that are Obsidian vaults from the list of perma-repos and
# switch to symlinks in that folder
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
remote_ssh="git@github.com:chrisgrieser/shimmering-focus"
theme_folders=$(grep --ignore-case "vault" "$HOME/.config/perma-repos.csv" |
	cut -d, -f2 |
	sed -e "s|^~|$HOME|" -e 's|$|/.obsidian/themes/Shimmering Focus/theme.css|')

#───────────────────────────────────────────────────────────────────────────────

[[ ! -d "$LOCAL_REPOS" ]] && mkdir -p "$LOCAL_REPOS"
cd "$LOCAL_REPOS" || return 1

# WARN depth=2 ensures that amending a shallow commit does not result in a
# new commit without parent, effectively destroying git history
git clone --depth=2 --filter="blob:none" "$remote_ssh"

# switch to symlink ($LOCAL_REPOS set in .zshenv)
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
