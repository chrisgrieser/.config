#!/usr/bin/env zsh

MAX_FILE_SIZE_MB=10
#───────────────────────────────────────────────────────────────────────────────

# ensure non-zero exit of script if anything fails, relevant for hammerspoon to
# be able to detect sync failure
set -e

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
i=0
while true; do
	git add -A && git commit -m "$msg" --author="🤖 automated<cron@job>"
	git pull && git push && break
	sleep 3
	i=$((i + 1))
	[[ $i -gt 10 ]] && break
done
