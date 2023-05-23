#!/usr/bin/env zsh

# use SSH instead of https
url="$(echo "$*" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git"
reponame=$(echo "$*" | sed -E 's/.*\///')

# shellcheck disable=2154
target="${local_repo_folder/#\~/$HOME}"
[[ ! -e "$target" ]] && mkdir -p "$target"

cd "$target" || exit 1
if [[ -e "$reponame" ]]; then
	osascript -e 'display notification "" with title "⚠️ Repo already exists."'
else
	git clone --depth=1 "$url" || return 1
fi

# open in terminal via Alfred
echo -n "$target/$reponame"
