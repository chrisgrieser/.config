#!/bin/zsh

# get path of current Finder Selection/Window
FINDER_SEL=$(osascript -e 'tell application "Finder"
	if ((count windows) is 0) then return "no window"

	set sel to selection
	if ((count sel) > 1) then return POSIX path of ((item 1 of sel) as text)
	if ((count sel) = 1) then return POSIX path of (sel as text)
	if ((count sel) = 0) then return POSIX path of (target of window 1 as alias)
end tell')

[[ "$FINDER_SEL" == "no window" ]] && exit 1 # no finder window

FOLDER=$(dirname "$FINDER_SEL")
FILE=$(basename "$FINDER_SEL")

if [[ -d "$FINDER_SEL" ]] ; then
	FOLDER="$FINDER_SEL"
	FILE=""
elif [[ -f "$FINDER_SEL" ]] ; then
	FOLDER=$(dirname "$FINDER_SEL")
	FILE=$(basename "$FINDER_SEL")
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

