#!/usr/bin/env zsh

# use SSH instead of https
url="$(echo "$*" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git"
reponame=$(echo "$*" | sed -E 's/.*\///')
# shellcheck disable=2154
target="${local_repo_folder/#\~/$HOME}"

cd "$target" || exit 1
git clone --depth=1 "$url" || echo "Error"
open "$target/$reponame"
