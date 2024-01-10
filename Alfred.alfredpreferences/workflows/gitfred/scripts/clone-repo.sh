#!/usr/bin/env zsh
# shellcheck disable=2154
#───────────────────────────────────────────────────────────────────────────────

source_repo=$(echo "$*" | cut -c20-)
reponame=$(echo "$*" | sed -E 's|.*/||')
url="git@github.com:$source_repo.git" # use SSH instead of https

[[ ! -e "$local_repo_folder" ]] && mkdir -p "$local_repo_folder"
cd "$local_repo_folder" || return 1

# validate depth, minimum 2
# WARN depth=2 ensures that amending a shallow commit does not result in a
# new commit without parent, effectively destroying git history (!!)
[[ $clone_depth =~ ^[0-9]+$ && $clone_depth -ge 2 ]] || clone_depth=2
git clone --depth="$clone_depth" "$url" --no-single-branch --no-tags # get branches, but not tags

# Open in terminal via Alfred
echo -n "$local_repo_folder/$reponame"

#───────────────────────────────────────────────────────────────────────────────
# FORK ON CLONE (if owner)

if [[ "$ownerOfRepo" != "1" && "$fork_on_clone" == "1" ]]; then
	cd "$reponame" || return 1
	if [[ ! -x "$(command -v gh)" ]]; then print "\`gh\` not installed." && return 1; fi

	gh repo fork --remote=false

	# origin -> my fork repo
	# upstream -> the source repo
	git remote rename origin upstream
	git remote add origin "git@github.com:$github_username/$reponame.git"
	gh repo set-default "$source_repo" # where `gh` sends PRs to

	# switch to new branch
	git config push.autoSetupRemote true
	git checkout -b "dev"
fi
