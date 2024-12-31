#!/usr/bin/env zsh
# shellcheck disable=2154
#───────────────────────────────────────────────────────────────────────────────

# VARIABLES
https_url="$1"
source_repo=$(echo "$https_url" | sed -E 's_.*github.com/([^/?]*/[^/?]*).*_\1_')
reponame=$(echo "$source_repo" | cut -d '/' -f2)
owner=$(echo "$source_repo" | cut -d '/' -f1)
ssh_url="git@github.com:$source_repo"

[[ ! -e "$local_repo_folder" ]] && mkdir -p "$local_repo_folder"
cd "$local_repo_folder" || return 1

#───────────────────────────────────────────────────────────────────────────────
# CLONE

# if multiple repos of same name, add owner to directory name of both the
# existing and the to-be-cloned repo (see https://github.com/chrisgrieser/gitfred/issues/5)
# (uses `__` as separator, since that string normally does not occur in reponames)
clone_dir="$reponame"
if [[ -d "$reponame" ]]; then
	clone_dir="${owner}__$reponame"
	# rename existing repo
	owner_of_existing_repo=$(git -C "$reponame" remote --verbose | tail -n1 | sed -Ee 's|.*:(.*)/.*|\1|')
	if [[ "$owner_of_existing_repo" == "$owner" ]]; then
		echo "ERROR: $source_repo already exists."
		return 1
	fi
	mv "$reponame" "${owner_of_existing_repo}__$reponame"
elif [[ -n $(find . -type directory -maxdepth 1 -name "*__$reponame") ]]; then
	clone_dir="${owner}__$reponame"
fi

# clone with depth
if [[ $clone_depth -eq 0 ]]; then
	msg=$(git clone "$ssh_url" --no-single-branch --no-tags "$clone_dir" 2>&1)
else
	# WARN depth=1 is dangerous, as amending such a commit does result in a
	# new commit without parent, effectively destroying git history (!!)
	[[ $clone_depth -eq 1 ]] && clone_depth=2
	msg=$(git clone "$ssh_url" --depth="$clone_depth" --no-single-branch --no-tags "$clone_dir" 2>&1)
fi

success=$?
if [[ $success -ne 0 ]]; then
	echo "ERROR: Clone failed. $msg"
	return 1
fi

# Open in terminal via Alfred
echo -n "$local_repo_folder/$clone_dir"

cd "$clone_dir" || return 1

#───────────────────────────────────────────────────────────────────────────────

# BRANCH ON CLONE
if [[ -n "$branch_on_clone" ]]; then
	# `git switch` fails silently if the branch does not exist
	git switch "$branch_on_clone" &> /dev/null
fi

# RESTORE MTIME
# PERF `partial` checks only files touched in the last x commits (with x being clone
# depth or 50), while `full` checks every single file. `partial` is magnitudes
# quicker, but does not restore the mtime for all files correctly, since only
# some commits are considered. If using shallow clones (`clone_depth` > 0), will
# automatically use `partial`, since there is not enough git history for correct
# mtime restoring, so `partial` and `full` have the same result, and using
# `partial` is then always preferable due to being quicker.
if [[ "$restore_mtime" == "quick-partial" || $clone_depth -ne 0 ]]; then
	how_far=$([[ $clone_depth -eq 0 ]] && echo 50 || echo $((clone_depth - 1)))

	# set date for all files to x+1 commits ago
	oldest_commit=$(git log -1 --format="%h" HEAD~"$how_far"^)
	old_timestamp=$(git log -1 --format="%cd" --date="format:%Y%m%d%H%M.%S" "$oldest_commit")
	git ls-tree -t -r --name-only HEAD | xargs touch -t "$old_timestamp"

	# set mtime for all files touched in last x commits
	# (reverse with `tail -r` so most recent commit comes last)
	last_commits=$(git log --format="%h" --max-count="$how_far" | tail -r)
	echo "$last_commits" | while read -r hash; do
		timestamp=$(git log -1 --format="%cd" --date="format:%Y%m%d%H%M.%S" "$hash")
		changed_files=$(git log -1 --name-only --format="" "$hash")
		echo "$changed_files" | while read -r file; do
			# check for file existence, since a file could have been deleted/moved
			[[ -f "$file" ]] && touch -t "$timestamp" "$file"
		done
	done
elif [[ "$restore_mtime" == "slow-full" ]]; then
	# https://stackoverflow.com/a/36243002/22114136
	git ls-tree -t -r --name-only HEAD | while read -r file; do
		timestamp=$(git log --format="%cd" --date="format:%Y%m%d%H%M.%S" -1 HEAD -- "$file")
		touch -t "$timestamp" "$file"
	done
fi

#───────────────────────────────────────────────────────────────────────────────
# FORKING

# INFO Alfred stores checkbox settings as `"1"` or `"0"`, and variables in stringified form.
if [[ "$ownerOfRepo" != "true" && "$fork_on_clone" == "1" ]]; then

	if [[ -x "$(command -v gh)" ]]; then
		gh repo fork --remote=false
	else
		echo "ERROR: Cannot fork, \`gh\` not installed."
	fi

	if [[ "$setup_remotes_on_fork" == "1" ]]; then
		git remote rename origin upstream
		git remote add origin "git@github.com:$github_username/$reponame.git"
	fi

	if [[ -n "$on_fork_branch" ]]; then
		git switch --create "$on_fork_branch" &> /dev/null
	fi
fi
