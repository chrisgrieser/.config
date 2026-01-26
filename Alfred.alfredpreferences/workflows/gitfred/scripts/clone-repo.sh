#!/usr/bin/env zsh
# shellcheck disable=2154
#───────────────────────────────────────────────────────────────────────────────

# VARIABLES
https_url="$1"
# Determine GitHub host (github.com or enterprise)
if [[ -n "$github_enterprise_url" ]]; then
	github_host="$github_enterprise_url"
	is_enterprise=true
else
	github_host="github.com"
	is_enterprise=false
fi
# Parse owner/repo from URL (handles both github.com and enterprise URLs)
# Escape dots for regex (. -> \.)
github_host_escaped="${github_host//./\\.}"
source_repo=$(echo "$https_url" | sed -E "s_.*${github_host_escaped}/([^/?]*/[^/?]*).*_\1_")
reponame=$(echo "$source_repo" | cut -d '/' -f2)
owner=$(echo "$source_repo" | cut -d '/' -f1)

# Determine clone URL (SSH for github.com, HTTPS with token for Enterprise)
if [[ "$is_enterprise" == true ]]; then
	# Get token for Enterprise authentication
	token="$github_token_from_alfred_prefs"
	[[ -z "$token" && -n "$github_token_shell_cmd" ]] && token=$(zsh -c "$github_token_shell_cmd")
	# shellcheck disable=1091
	[[ -z "$token" ]] && token=$(test -e "$HOME"/.zshenv && source "$HOME/.zshenv" && echo "$GITHUB_TOKEN")
	if [[ -z "$token" ]]; then
		echo "ERROR: Cannot clone from Enterprise, \`GITHUB_TOKEN\` not found."
		return 1
	fi
	clone_url="https://oauth2:${token}@${github_host}/${source_repo}.git"
else
	clone_url="git@${github_host}:$source_repo"
fi

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
	msg=$(git clone "$clone_url" --no-single-branch --no-tags "$clone_dir" 2>&1)
else
	# WARN depth=1 is dangerous, as amending such a commit does result in a
	# new commit without parent, effectively destroying git history (!!)
	[[ $clone_depth -eq 1 ]] && clone_depth=2
	msg=$(git clone "$clone_url" --depth="$clone_depth" --no-single-branch --no-tags "$clone_dir" 2>&1)
fi

success=$?
if [[ $success -ne 0 ]]; then
	echo "ERROR: Clone failed. $msg"
	return 1
fi

# Open in terminal via Alfred
abs_path="$local_repo_folder/$clone_dir"
echo -n "$abs_path"

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
	oldest_commit=$(git log -1 --format="%h" HEAD~"$how_far")
	old_timestamp=$(git log -1 --format="%cd" --date="format:%Y%m%d%H%M.%S" "$oldest_commit")
	git ls-tree -z -t -r --name-only HEAD | xargs -0 touch -t "$old_timestamp"

	# set mtime for all files touched in last x commits
	# (reverse with `tail -r` so most recent commit comes last)
	last_commits=$(git log --format="%h" --max-count="$((how_far - 1))" | tail -r)
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

# SETUP LOCAL BRANCHES
# useful to have them available as completion via e.g., for `git switch`
if [[ "$create_local_branches_on_clone" == "1" ]]; then # Alfred stores checkbox settings as `"1"` or `"0"` (stringified)
	remote_branches=$(git for-each-ref --format='%(refname:short)' refs/remotes/origin/ |
		grep --invert-match '^origin$')
	echo "$remote_branches" | while read -r ref; do
		local_branch="${ref#origin/}"
		git branch --track "$local_branch" "$ref" &> /dev/null
	done
fi

#───────────────────────────────────────────────────────────────────────────────
# FORKING

# Alfred stores checkbox settings as `"1"` or `"0"` (stringified)
if [[ "$github_username" != "$owner" && "$fork_on_clone" == "1" ]]; then

	if [[ ! -x "$(command -v gh)" ]]; then
		echo "ERROR: Cannot fork, \`gh\` not installed."
		return 1
	fi

	# get token
	token="$github_token_from_alfred_prefs"
	[[ -z "$token" ]] && token=$(zsh -c "$github_token_shell_cmd")
	# shellcheck disable=1091
	[[ -z "$token" ]] && token=$(test -e "$HOME"/.zshenv && source "$HOME/.zshenv" && echo "$GITHUB_TOKEN")
	if [[ -z "$token" ]]; then
		echo "ERROR: Cannot fork, \`GITHUB_TOKEN\` not found." >&2
		return 1
	fi
	export GITHUB_TOKEN="$token"

	setup_remotes=$([[ "$setup_remotes_on_fork" == "1" ]] && echo "true" || echo "false")
	gh repo fork --remote="$setup_remotes" &> /dev/null

	if [[ -n "$on_fork_branch" ]]; then
		git switch --create "$on_fork_branch" &> /dev/null
	fi
fi
