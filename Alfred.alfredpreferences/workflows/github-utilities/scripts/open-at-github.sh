#!/usr/bin/env zsh

# shellcheck disable=2034
GIT_OPTIONAL_LOCKS=0
file="$1"
cd "$(dirname "$file")" || exit 1
if ! git rev-parse --is-inside-work-tree &>/dev/null ; then echo "$file is not ins a git repository." && exit 1 ; fi

#───────────────────────────────────────────────────────────────────────────────

BRANCH=$(git branch --show-current)
ROOT_PATH=$(git rev-parse --show-toplevel)
ROOT_LEN=${#ROOT_PATH}
REMOTE_URL="$(git remote -v | head -n1 | cut -f2 | cut -d' ' -f1 | sed -e's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//')"
PATH_IN_REPO=${file:$ROOT_LEN}
PATH_IN_REPO=$(osascript -l JavaScript -e "encodeURIComponent('$PATH_IN_REPO')")

URL="$REMOTE_URL/blob/$BRANCH/$PATH_IN_REPO"

# shellcheck disable=2154
if [[ "$mode" == "open" ]]; then
	open "$URL"
else
	echo "$URL" | pbcopy
fi
