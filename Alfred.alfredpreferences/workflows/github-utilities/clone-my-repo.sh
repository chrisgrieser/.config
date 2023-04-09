#!/usr/bin/env zsh

# use SSH instead of https
url="$(echo "$*" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git"
reponame=$(echo "$*" | sed -E 's/.*\///')

# shellcheck disable=2154
target="${local_repo_folder/#\~/$HOME}"
[[ ! -e "$target" ]] && mkdir -p "$target"
repo_abs_path="$target/$reponame"


echo -n "$repo_abs_path"
cd "$target" || exit 1
git clone --depth=1 "$url" || return 1

# open in terminal via Alfred
echo -n "$repo_abs_path"

