#!/usr/bin/env zsh
export GIT_OPTIONAL_LOCKS=0      # prevent unnecessary lock files
cd "$(dirname "$0")" || return 1 # go to location of this script, i.e., the git root
#───────────────────────────────────────────────────────────────────────────────

change_count=$(git status --porcelain | wc -l | tr -d " ")

# if no changes, just pull
if [[ $change_count -eq 0 ]]; then
	git pull --no-progress
	return $?
fi

#───────────────────────────────────────────────────────────────────────────────

# determine commit message
changed_files="$(git status --porcelain | cut -c4- | sed 's|^|./|')"
common_parent=$(echo "$changed_files" | head -n1) # initialize
while read -r filepath; do                        # don't call it `path`, messes with `$PATH`
	while [[ ! "$filepath" =~ ^$common_parent ]]; do
		common_parent=$(dirname "$common_parent")
	done
done < <(echo "$changed_files")
common_parent=$(echo "$common_parent" | cut -c3-) # remove leading `./`

device_name=$(scutil --get ComputerName | cut -d" " -f2-)
if [[ -z "$common_parent" ]]; then
	commit_msg="$device_name ($change_count)"
else
	commit_msg="$device_name ($common_parent)"
fi

# add-commit-pull-push
git add --all
git commit --message="$commit_msg" --author="🤖 automated<cron@job>" || return 1 # fail with pre-commit check
git pull --no-progress && git push --no-progress
return $?
