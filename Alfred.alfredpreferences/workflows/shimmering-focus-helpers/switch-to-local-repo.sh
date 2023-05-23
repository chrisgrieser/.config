#!/usr/bin/env zsh
# shellcheck disable=2154,2164

remote_ssh="git@github.com:chrisgrieser/shimmering-focus.git"
target_path="${local_repo_folder/#\~/$HOME}"

[[ ! -d "$target_path" ]] && mkdir -p "$target_path"
cd "$target_path"

git clone --depth=1 "$remote_ssh" || return 1
