#!/usr/bin/env zsh
# INFO get all folder that are Obsidian vaults from the list of perma-repos and
# switch to symlinks in that folder
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
remote_ssh="git@github.com:chrisgrieser/shimmering-focus"
theme_folders=$(grep --ignore-case "vault" "$HOME/.config/perma-repos.csv" |
	cut -d, -f2 |
	sed -e "s|^~|$HOME|" -e 's|$|/.obsidian/themes/Shimmering Focus/theme.css|')

#───────────────────────────────────────────────────────────────────────────────

# shellcheck disable=2154 # Alfred var
[[ ! -d "$local_repos" ]] && mkdir -p "$local_repos"
cd "$local_repos" || return 1

#───────────────────────────────────────────────────────────────────────────────
# CLONE

# WARN depth=2 ensures that amending a shallow commit does not result in a
# new commit without parent, effectively destroying git history
branch_to_use=${branch_to_use:-main} # default value: "main"
git clone --branch="$branch_to_use" --depth=2 --filter="blob:none" "$remote_ssh" >&2
clone_success=$?
if [[ $clone_success -ne 0 ]]; then
	echo -n "❌ Could not clone."
	return 1
fi

# switch to symlink for each vault (from perma-repos)
echo "$theme_folders" | while read -r theme_file; do
	ln -sf "$local_repos/shimmering-focus/theme.css" "$theme_file"
done

#───────────────────────────────────────────────────────────────────────────────

# Open file
open "$local_repos/shimmering-focus/theme.css"

# install dependencies in the background
cd "$local_repos/shimmering-focus/" && npm install >&2
