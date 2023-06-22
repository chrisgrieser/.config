#!/usr/bin/env zsh

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
git add -A && git commit -m "$msg" --author="🤖 automated<cron@job>"
git pull
git push

# check that everything worked (e.g. submodules are still dirty)
DIRTY=$(git status --porcelain)
if [[ -n "$DIRTY" ]]; then
	printf "\033[1;33mVault Repo still dirty.033[0m"
	echo "$DIRTY"
	return 1
fi
