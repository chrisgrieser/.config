#!/usr/bin/env zsh
# INFO LOCAL_REPOS defined in .zshenv
#───────────────────────────────────────────────────────────────────────────────

# use SSH instead of https
url="$(echo "$*" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git"
reponame=$(echo "$*" | sed -E 's/.*\///')

[[ ! -e "$LOCAL_REPOS" ]] && mkdir -p "$LOCAL_REPOS"
cd "$LOCAL_REPOS" || exit 1

if [[ -e "$reponame" ]]; then
	osascript -e 'display notification "" with title "⚠️ Repo already exists."'
else
	git clone --depth=1 --filter="blob:none" "$url" || return 1
fi

# Browse
echo -n "$LOCAL_REPOS/$reponame" # open in terminal via Alfred
open "$LOCAL_REPOS/$reponame"
