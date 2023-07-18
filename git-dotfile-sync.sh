#!/usr/bin/env zsh

set -e

# CONFIG
MAX_FILE_SIZE_MB=10

# shellcheck disable=2034
GIT_OPTIONAL_LOCKS=0

#───────────────────────────────────────────────────────────────────────────────

cd "$(dirname "$0")" || exit 1 # go to location of this script, i.e. cd'ing into the git repo
device_name=$(scutil --get ComputerName | cut -d" " -f2-)

filesChanged="$(git status --porcelain | wc -l | tr -d ' ')"
if [[ "$filesChanged" == 0 ]] ; then
	git pull
	return 0
fi

# safeguard against accidental pushing of large files
NUMBER_LARGE_FILES=$(find . -not -path "**/.git/**" -size +${MAX_FILE_SIZE_MB}M | wc -l | xargs)
if [[ $NUMBER_LARGE_FILES -gt 0 ]]; then
	echo -n "$NUMBER_LARGE_FILES Large files detected, aborting automatic git sync."
	return 1
fi

# git add-commit-pull-push
msg="$device_name ($filesChanged)"

# loop git add-commit-pull-push, since when between add and push files have been
# changed, the push will fail
i=0
while true; do
	git add -A && git commit -m "$msg" --author="🤖 automated<cron@job>"
	git pull && git push && break
	sleep 5
	i=$((i + 1))
	[[ $i -gt 20 ]] && break
done
