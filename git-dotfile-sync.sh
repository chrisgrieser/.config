#!/usr/bin/env zsh

export GIT_OPTIONAL_LOCKS=0      # prevent unnecessary lock files
cd "$(dirname "$0")" || return 1 # go to location of this script, i.e. going into the git repo
#───────────────────────────────────────────────────────────────────────────────

files_changed="$(git status --porcelain | wc -l | tr -d ' ')"
device_name=$(scutil --get ComputerName | cut -d" " -f2-)
commit_msg="$device_name ($files_changed)"

# loop git add-commit-pull-push, since when between add and push files have been
# changed, the push will fail
# 0: once push/pull is successful
# 1: after multiple failed attempts to push/pull
i=0
while true; do
	git add -A && git commit -m "$commit_msg" --author="🤖 automated<cron@job>"
	[[ $? -eq 2 ]] && return 2 # pre-commit failed
	sleep 0.5 # prevent "Cannot rebase on multiple branches"
	git pull && git push && return 0
	sleep 1
	i=$((i + 1))
	[[ $i -gt 3 ]] && return 1
done
