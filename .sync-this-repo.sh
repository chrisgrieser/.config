#!/usr/bin/env zsh

export GIT_OPTIONAL_LOCKS=0    # prevent unnecessary lock files
cd "$(dirname "$0")" || exit 1 # go to location of this script, i.e. going into the git repo
#───────────────────────────────────────────────────────────────────────────────

files_changed="$(git status --porcelain | wc -l | tr -d ' ')"
device_name=$(scutil --get ComputerName | cut -d" " -f2-)
commit_msg="$device_name ($files_changed)"

if [[ $files_changed -gt 0 ]]; then
	git add --all &&
		git commit -m "$commit_msg" --author="🤖 automated<cron@job>" ||
		exit 1
fi

# loop git add-commit-pull-push, since when between add and push files have been
# changed, the push will fail
i=0
while true; do
	sleep 0.5 # prevent "Cannot rebase on multiple branches"
	git pull && git push && exit 0
	sleep 1
	i=$((i + 1))
	[[ $i -gt 3 ]] && exit 1
done
