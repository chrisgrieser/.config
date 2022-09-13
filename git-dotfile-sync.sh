#!/bin/zsh
# "--submodules" → also pull submodules

MAX_FILE_SIZE_MB=10
cd "$(dirname "$0")" || exit 1 # go to location of this script, i.e. cd'ing into the git repo
device_name=$(scutil --get ComputerName | cut -d" " -f2-)

filesChanged="$(git status --porcelain | wc -l | tr -d ' ')"
if [[ "$filesChanged" == 0 ]] ; then
	git pull
	[[ "$1" == "--submodules" ]] && git submodule update --remote --rebase # --rebase ensures that there is no detached head in the submodules
	exit 0
fi

# safeguard against accidental pushing of large files
# shellcheck disable=SC2248
NUMBER_LARGE_FILES=$(find . -not -path "**/.git/**" -size +${MAX_FILE_SIZE_MB}M | wc -l | xargs)
if [[ $NUMBER_LARGE_FILES -gt 0 ]]; then
	echo -n "$NUMBER_LARGE_FILES Large files detected, aborting automatic git sync."
	exit 1
fi

# git add-commit-pull-push sequence
msg="$device_name ($filesChanged)"
git add -A && git commit -m "$msg" --author="🤖 automated<cron@job>"
git pull
[[ "$1" == "--submodules" ]] && git submodule update --remote
git push

# check that everything worked (e.g. submodules are still dirty)
DIRTY=$(git status --porcelain)
if [[ -n "$DIRTY" ]]; then
	echo
	echo "\033[1;33mDotfile Repo still dirty."
	echo "$DIRTY"
	exit 1
fi
