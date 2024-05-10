#!/usr/bin/env zsh

export GIT_OPTIONAL_LOCKS=0    # prevent unnecessary lock files
cd "$(dirname "$0")" || exit 1 # go to location of this script, i.e. going into the git repo
#───────────────────────────────────────────────────────────────────────────────

files_changed="$(git status --porcelain | wc -l | tr -d ' ')"
[[ $files_changed -eq 0 ]] && exit 0
device_name=$(scutil --get ComputerName | cut -d" " -f2-)
commit_msg="$device_name ($files_changed)"

# loop git add-commit-pull-push, since when between add and push files have been
# changed, the push will fail
i=0
while true; do
	git add --all && git commit -m "$commit_msg" --author="🤖 automated<cron@job>" || exit 1
	sleep 0.5 # prevent "Cannot rebase on multiple branches"
	git pull && git push && exit 0
	sleep 1
	i=$((i + 1))
	[[ $i -gt 3 ]] && exit 1
done
