#!/bin/zsh

INPUT="$*"
FOLDER=$(dirname "$INPUT")
FILE=$(basename "$INPUT")

if [[ -d "$INPUT" ]] ; then
	FOLDER="$INPUT"
	FILE=""
elif [[ -f "$INPUT" ]] ; then
	FOLDER=$(dirname "$INPUT")
	FILE=$(basename "$INPUT")
else
	exit 1 # no regular file selected
fi

cd "$FOLDER" || exit 1
[[ $(git rev-parse --git-dir) ]] || exit 1 # not a git directory
# shellcheck disable=SC2164
r=$(git rev-parse --git-dir) && r=$(cd "$r" && pwd)/ && ROOTF="${r%%/.git/*}"
BRANCH=$(git branch --show-current)
REMOTE_URL="$(git remote -v | grep git@github.com | grep fetch | head -n1 | cut -f2 | cut -d' ' -f1 | sed -e's/:/\//' -e 's/git@/https:\/\//' -e 's/\.git//')"

# shellcheck disable=SC2053
if [[ "$ROOTF" == "$FOLDER" ]] ; then
	if [[ -z "$FILE" ]] ; then
		URL="$REMOTE_URL"
	else
		URL="$REMOTE_URL/blob/$BRANCH/$FILE"
	fi
else
	ROOTF_LEN=$((${#ROOTF} + 2))
	# shellcheck disable=SC2086,SC2248
	SUBFOLDER=$(echo "$FOLDER" | cut -c $ROOTF_LEN-)
	if [[ -z "$FILE" ]] ; then
		URL="$REMOTE_URL/tree/$BRANCH/$SUBFOLDER"
	else
		# use "blob" instead of "commits" for file view
		URL="$REMOTE_URL/blob/$BRANCH/$SUBFOLDER/$FILE"
	fi
fi

# open pseudo-encoded url (to not require a dependency)
open "${URL/ /%20}"

