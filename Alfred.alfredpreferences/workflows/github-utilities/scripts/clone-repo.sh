#!/usr/bin/env zsh
# shellcheck disable=2154
# INFO LOCAL_REPOS defined in .zshenv
#───────────────────────────────────────────────────────────────────────────────

origin_repo=$(echo "$*" | cut -c20-)
reponame=$(echo "$*" | sed -E 's/.*\///')
url="git@github.com:$origin_repo.git" # use SSH instead of https

# CLONE
[[ ! -e "$LOCAL_REPOS" ]] && mkdir -p "$LOCAL_REPOS"
cd "$LOCAL_REPOS" || exit 1
# WARN depth=2 ensures that amending a shallow commit does not result in a
# new commit without parent, effectively destroying git history (!!)
git clone --depth=2 --filter="blob:none" "$url"

# Open in terminal via Alfred
echo -n "$LOCAL_REPOS/$reponame"

[[ "$publicRepo" != "true" ]] && return 0

#───────────────────────────────────────────────────────────────────────────────
# PREPARE PR

cd "$reponame" || return 1
gh repo fork --remote=false

# add my remote as SSH & set it to origin for `push.autoSetupRemote`
git remote rename origin upstream
git remote add origin "git@github.com:$github_username/$reponame.git"

gh repo set-default "$origin_repo" # where to send PRs
git checkout -b "dev" # send PR as branch so maintainer can edit it
