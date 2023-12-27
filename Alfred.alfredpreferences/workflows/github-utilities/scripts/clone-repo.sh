#!/usr/bin/env zsh
# shellcheck disable=2154
#───────────────────────────────────────────────────────────────────────────────

source_repo=$(echo "$*" | cut -c20-)
reponame=$(echo "$*" | sed -E 's|.*/||')
url="git@github.com:$source_repo.git" # use SSH instead of https

# INFO LOCAL_REPOS defined in .zshenv
[[ ! -e "$LOCAL_REPOS" ]] && mkdir -p "$LOCAL_REPOS"
cd "$LOCAL_REPOS" || return 1

# WARN depth=2 ensures that amending a shallow commit does not result in a
# new commit without parent, effectively destroying git history (!!)
git clone --depth=2 "$url" --no-single-branch --no-tags # get branches, but not tags

# Open in terminal via Alfred
echo -n "$LOCAL_REPOS/$reponame"


#───────────────────────────────────────────────────────────────────────────────
# PREPARE PR

if [[ "$publicRepo" == "true" ]] ; then
	cd "$reponame" || return 1
	gh repo fork --remote=false

	# origin -> my fork repo
	# upstream -> the source repo
	git remote rename origin upstream
	git remote add origin "git@github.com:$github_username/$reponame.git"
	gh repo set-default "$source_repo" # where `gh` sends PRs to

	# as branch so maintainer can edit it
	git config push.autoSetupRemote true
	git checkout -b "dev"
fi
