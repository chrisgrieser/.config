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
git clone --depth=2 --no-single-branch "$url"

# Open in terminal via Alfred
echo -n "$LOCAL_REPOS/$reponame"

#───────────────────────────────────────────────────────────────────────────────
# PREPARE PR

if [[ "$publicRepo" == "true" ]] ; then
	cd "$reponame" || return 1
	gh repo fork --remote=false

	# add my remote as SSH & name it "origin" for `push.autoSetupRemote`
	git remote rename origin upstream
	git config push.autoSetupRemote true
	git remote add origin "git@github.com:$github_username/$reponame.git"

	gh repo set-default "$origin_repo" # where `gh` sends PRs to
	git checkout -b "dev" # as branch so maintainer can edit it
fi
