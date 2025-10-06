#!/usr/bin/env zsh
export GIT_OPTIONAL_LOCKS=0      # prevent unnecessary lock files
cd "$(dirname "$0")" || return 1 # go to location of this script, i.e., the git root
#───────────────────────────────────────────────────────────────────────────────

# if no changes, just pull & push
change_count=$(git status --porcelain | wc -l | tr -d " ")

if [[ $change_count -eq 0 ]]; then
	git pull --no-progress && git push --no-progress
	return $?
fi

#───────────────────────────────────────────────────────────────────────────────

# determine commit message
changed_files="$(git status --porcelain | cut -c4- |
	sed -Ee 's/^"|"$//g' -Ee 's|^|./|' -Ee 's|/$||')"
common=$(echo "$changed_files" | head -n1) # initialize

while read -r filepath; do # don't call it `path`, messes with `$PATH`
	while [[ ! "$filepath" =~ ^$common ]]; do
		common=$(dirname "$common")
	done
done < <(echo "$changed_files")
[[ -d "$common" ]] && common="$common/" # distinguish from files with trailing `/`
common=$(echo "$common" | cut -c3-)     # remove leading `./`
while [[ ${#common} -gt 60 ]]; do
	common=${common#*/} # remove first directory
	[[ "$common" != *"/"* && ${#common} -gt 60 ]] && common="${common:0:59}…" # shorten files with long names
done

device_name=$(scutil --get ComputerName | cut -d" " -f3-)
if [[ -z "$common" ]]; then
	commit_msg="$device_name ($change_count files)"
else
	commit_msg="$device_name ($common)"
fi

#───────────────────────────────────────────────────────────────────────────────

# add-commit-pull-push
git add --all
git commit --message="$commit_msg" --author="🤖 automated<cron@job>" || return 1 # fail with pre-commit check
git pull --no-progress && git push --no-progress
return $?
