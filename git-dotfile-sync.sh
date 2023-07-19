#!/usr/bin/env zsh

MAX_FILE_SIZE_MB=10

# shellcheck disable=2034
GIT_OPTIONAL_LOCKS=0

#───────────────────────────────────────────────────────────────────────────────

cd "$(dirname "$0")" || return 1 # go to location of this script, i.e. going into the git repo

# safeguard against accidental pushing of large files
NUMBER_LARGE_FILES=$(find . -not -path "**/.git/**" -size +${MAX_FILE_SIZE_MB}M | wc -l | xargs)
if [[ $NUMBER_LARGE_FILES -gt 0 ]]; then
	echo -n "$NUMBER_LARGE_FILES Large files detected, aborting automatic git sync."
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────

# git add-commit-pull-push
filesChanged="$(git status --porcelain | wc -l | tr -d ' ')"
device_name=$(scutil --get ComputerName | cut -d" " -f2-)
msg="$device_name ($filesChanged)"

# loop git add-commit-pull-push, since when between add and push files have been
# changed, the push will fail
# exit 0 once push/pull is successful
# exit 1 after multiple failed attempts to push/pull
i=0
while true; do
	# "|| true" ensures that if the git add fails, the script will not abort due to set -e
	(git add -A && git commit -m "$msg" --author="🤖 automated<cron@job>") || true
	git pull && git push && return 0 
	sleep 3
	i=$((i + 1))
	[[ $i -gt 10 ]] && return 1
done


