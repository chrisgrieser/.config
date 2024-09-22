#!/usr/bin/env zsh
# shellcheck disable=2154
#───────────────────────────────────────────────────────────────────────────────

https_url="$1"
source_repo=$(echo "$https_url" | sed -E 's_.*github.com/([^/?]*/[^/?]*).*_\1_')
echo "🖨️ source_repo: $source_repo" >&2
reponame=$(echo "$source_repo" | cut -d '/' -f2)
echo "🖨️ reponame: $reponame" >&2
ssh_url="git@github.com:$source_repo"

[[ ! -e "$local_repo_folder" ]] && mkdir -p "$local_repo_folder"
cd "$local_repo_folder" || return 1

#───────────────────────────────────────────────────────────────────────────────
# CLONE

if [[ $clone_depth == "0" ]]; then
	msg=$(git clone "$ssh_url" --no-single-branch --no-tags 2>&1)
else
	# WARN depth=1 is dangerous, as amending such a commit does result in a
	# new commit without parent, effectively destroying git history (!!)
	[[ $clone_depth == "1" ]] && clone_depth=2
	msg=$(git clone "$ssh_url" --depth="$clone_depth" --no-single-branch --no-tags 2>&1)
fi

success=$?
if [[ $success -ne 0 ]]; then
	echo "ERROR: Clone failed. $msg"
	exit 1
fi

# Open in terminal via Alfred
echo -n "$local_repo_folder/$reponame"

cd "$reponame" || return 1

#───────────────────────────────────────────────────────────────────────────────

# SWITCH TO WORKING BRANCH
if [[ -n "$working_branch" ]]; then
	# `git switch` fails silently if the branch does not exist
	git switch "$working_branch" &> /dev/null
fi

# RESTORE MTIME
if [[ "$restore_mtime" == "1" ]]; then
	# https://stackoverflow.com/a/36243002/22114136
	git ls-tree -r -t --full-name --name-only HEAD | while read -r file; do
		timestamp=$(git log --pretty=format:%cd --date=format:%Y%m%d%H%M.%S -1 HEAD -- "$file")
		touch -t "$timestamp" "$file"
	done
fi

# FORK ON CLONE (if not owner)
# INFO Alfred stores checkbox settings as `"1"` or `"0"`, and variables in stringified form.
if [[ "$ownerOfRepo" != "true" && "$fork_on_clone" == "1" ]] ||
	[[ "$clonedViaHotkey" == "true" && "$fork_on_clone_via_hotkey" == "1" ]]; then
	if [[ ! -x "$(command -v gh)" ]]; then echo "ERROR: \`gh\` not installed." && return 1; fi

	gh repo fork --remote=false

	# origin -> my fork repo
	# upstream -> the source repo
	git remote rename origin upstream
	git remote add origin "git@github.com:$github_username/$reponame.git"
	gh repo set-default "$source_repo" # where `gh` sends PRs to

	# create default branch
	if [[ -n "$default_branch" ]]; then
		git config push.autoSetupRemote true
		git switch --create "$default_branch"
	fi
fi
