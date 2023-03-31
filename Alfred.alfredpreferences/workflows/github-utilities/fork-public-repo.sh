#!/usr/bin/env zsh

# CONFIG
NAME_OF_NEW_PLUGIN="nvim-early-retirement"
TEMP_FOLDER="$ICLOUD/Repos"

#───────────────────────────────────────────────────────────────────────────────
# Preparatory
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
if ! command -v gh &>/dev/null; then echo "⚠️ gh not installed." && return 1; fi
if ! command -v deno &>/dev/null; then echo "⚠️ deno not installed." && return 1; fi
set -e # abort if any step fails

#───────────────────────────────────────────────────────────────────────────────
# NEOVIMCRAFT
cd "$TEMP_FOLDER"
gh repo fork "neurosnap/neovimcraft" --clone=false # using separate clone call to set depth
gh repo clone "chrisgrieser/neovimcraft" -- --depth=1

cd "neovimcraft"
make resource # INTERACT

git add .
git commit -m "Add $NAME_OF_NEW_PLUGIN"
git push
gh pr create --fill # --fill = use commit ino

#───────────────────────────────────────────────────────────────────────────────
# AWESOME NEOVIM


#───────────────────────────────────────────────────────────────────────────────
# THIS WEEK IN NEOVIM


#───────────────────────────────────────────────────────────────────────────────
# REDDIT
open "https://www.reddit.com/r/neovim/submit?title=Introducing%20$NAME_OF_NEW_PLUGIN"

