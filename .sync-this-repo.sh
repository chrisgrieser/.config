#!/usr/bin/env zsh

export GIT_OPTIONAL_LOCKS=0    # prevent unnecessary lock files
cd "$(dirname "$0")" || exit 1 # go to location of this script, i.e. going into the git repo
#───────────────────────────────────────────────────────────────────────────────

# ADD & COMMIT
files_changed="$(git status --porcelain | wc -l | tr -d ' ')"
device_name=$(scutil --get ComputerName | cut -d" " -f2-)
commit_msg="$device_name ($files_changed)"

# GUARD
if [[ $files_changed -eq 0 && -z "$1" ]]; then
	echo "No changes."
	exit 0
fi

if [[ $files_changed -gt 0 ]]; then
	git add --all
	git commit --message="$commit_msg" --author="🤖 automated<cron@job>"
fi
if [[ -n "$1" ]]; then
	git commit --no-verify --allow-empty --message="💾 Manual Snapshot"
fi

#───────────────────────────────────────────────────────────────────────────────
# PULL & PUSH

# loop git add-commit-pull-push, since when between add and push files have been
# changed, the push will fail
i=0
sleep 2 # prevent "Cannot rebase on multiple branches"
while true; do
	git pull --no-progress && git push --no-progress && exit 0
	sleep 2
	i=$((i + 1))
	[[ $i -gt 3 ]] && exit 1
done
