#!/usr/bin/env zsh
export GIT_OPTIONAL_LOCKS=0      # prevent unnecessary lock files
cd "$(dirname "$0")" || return 1 # go to location of this script, i.e., the git root
#───────────────────────────────────────────────────────────────────────────────

# ADD & COMMIT
device_name=$(scutil --get ComputerName | cut -d" " -f2-)
files_changed="$(git status --porcelain | wc -l | tr -d ' ')"
if [[ $files_changed -gt 0 ]]; then
	# do not exit when no changes, since there could still be changes to pull
	git add --all
	git commit --message="$device_name ($files_changed)" --author="🤖 automated<cron@job>" ||
		return 1
fi

# PULL & PUSH
git pull --no-progress && git push --no-progress && return 0
return 1
