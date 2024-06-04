#!/usr/bin/env zsh
# shellcheck disable=2154
#───────────────────────────────────────────────────────────────────────────────

source_repo=$(echo "$*" | cut -c20-)
reponame=$(echo "$*" | sed -E 's|.*/||')
url="git@github.com:$source_repo" # use SSH instead of https

[[ ! -e "$local_repo_folder" ]] && mkdir -p "$local_repo_folder"
cd "$local_repo_folder" || return 1

#───────────────────────────────────────────────────────────────────────────────
# CLONE

if [[ $clone_depth == "0" ]]; then
	git clone "$url" --no-single-branch --no-tags # get branches, but not tags
else
	# WARN depth=1 is dangerous, as amending such a commit does result in a
	# new commit without parent, effectively destroying git history (!!)
	[[ $clone_depth == "1" ]] && clone_depth=2

	git clone "$url" --depth="$clone_depth" --no-single-branch --no-tags
fi

# Open in terminal via Alfred
echo -n "$local_repo_folder/$reponame"

#───────────────────────────────────────────────────────────────────────────────
# RESTORE MTIME

cd "$reponame" || return 1

# https://stackoverflow.com/a/36243002/22114136
if [[ "$restore_mtime" == "1" ]]; then
	git ls-tree -r -t --full-name --name-only HEAD | while read -r file; do
		timestamp=$(git log --pretty=format:%cd --date=format:%Y%m%d%H%M.%S -1 HEAD -- "$file")
		touch -t "$timestamp" "$file"
	done
fi

#───────────────────────────────────────────────────────────────────────────────
# FORK ON CLONE (if not owner)

# INFO Alfred stores checkbox settings as `"1"` or `"0"`, and variables in stringified form.
if [[ "$ownerOfRepo" != "true" && "$fork_on_clone" == "1" ]]; then
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
