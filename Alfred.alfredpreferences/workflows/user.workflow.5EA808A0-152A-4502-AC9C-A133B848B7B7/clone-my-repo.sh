#!/usr/bin/env zsh

# use SSH instead of https
url="$(echo "$*" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git"

# shellcheck disable=2154
target="${local_repo_folder/#\~/$HOME}"
open "$target"

cd "$target" || exit 1
git clone --depth=1 "$url" || echo "Error"
