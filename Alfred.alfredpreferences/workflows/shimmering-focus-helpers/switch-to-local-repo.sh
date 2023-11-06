#!/usr/bin/env zsh

#───────────────────────────────────────────────────────────────────────────────

# CONFIG
theme_folder="$VAULT_PATH/.obsidian/themes/Shimmering Focus/"
remote_ssh="git@github.com:chrisgrieser/shimmering-focus.git"
# INFO LOCAL_REPOS and VAULT_PATH are set in .zshenv

#───────────────────────────────────────────────────────────────────────────────

[[ ! -d "$LOCAL_REPOS" ]] && mkdir -p "$LOCAL_REPOS"
cd "$LOCAL_REPOS" || return 1

# WARN depth=2 ensures that amending a shallow commit does not result in a
# new commit without parent, effectively destroying git history (!!)
git clone --depth=2 --filter="blob:none" "$remote_ssh"

# switch symlink
ln -sf "$LOCAL_REPOS/shimmering-focus/source.css" "$theme_folder/theme.css"

# loop back to open file
# (dependencies only needed later and therefore installed afterwards)
osascript -e '
	tell application id "com.runningwithcrayons.Alfred" to run trigger "loop" in workflow "de.chris-grieser.shimmering-focus"
'

#───────────────────────────────────────────────────────────────────────────────

# install only "production", since the dev-depdencies are on my machine globally
# installed and only listed in the package.json for documentation purposes
cd "./shimmering-focus/" || return 1
npm install --omit=dev
