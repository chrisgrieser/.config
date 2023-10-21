#!/usr/bin/env zsh
# INFO LOCAL_REPOS defined in .zshenv
#───────────────────────────────────────────────────────────────────────────────

# use SSH instead of https
full_repo=$(echo "$*" | cut -c20-)
url="git@github.com:$full_repo.git"
reponame=$(echo "$*" | sed -E 's/.*\///')

[[ ! -e "$LOCAL_REPOS" ]] && mkdir -p "$LOCAL_REPOS"
cd "$LOCAL_REPOS" || exit 1

if [[ -e "$reponame" ]]; then
	osascript -e 'display notification "" with title "⚠️ Repo already exists."'
fi

# WARN depth=2 ensures that amending a shallow commit does not result in a 
# new commit without parent, effectively destroying git history (!!)
git clone --depth=2 --filter="blob:none" "$url" || return 1

#───────────────────────────────────────────────────────────────────────────────

echo -n "$LOCAL_REPOS/$reponame" # Open in terminal via Alfred

# shellcheck disable=2154 # set via previous script
if [[ "$publicRepo" == "true" ]]; then
	cd "$reponame" || return 1
	gh repo fork --remote=false

	# add my remote as SSH
	git remote add upstream "git@github.com:$github_username/$reponame.git"

	gh repo set-default "$full_repo" # where to send PRs
	git checkout -b "feature" # send PR via branch for editing from maintainer
fi

