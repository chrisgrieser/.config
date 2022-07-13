#!/bin/zsh

# go to script location (the script should be located in the git repository)
THIS_LOCATION="$(dirname "$0")"
cd "$THIS_LOCATION" || exit 1
device_name=$(scutil --get ComputerName | cut -d" " -f2-)

details="$(git status --porcelain)"
filesChanged="$(echo "$details" | wc -l | tr -d ' ')"
[[ -z "$filesChanged" ]] && exit 0
if [[ "$filesChanged" == 1 ]] ; then
	changeType="$filesChanged file"
else
	changeType="$filesChanged files"
fi

git add -A
git commit -m "$(date +"%a, %H:%M"), $changeType, $device_name" -m "$details"
git pull
git push

# Alfred Repos pullen
cd "Alfred.alfredpreferences/workflows" || exit 1
cd "./shimmering-obsidian" || exit 1
git pull
cd "../alfred-bibtex-citation-picker" || exit 1
git pull
cd "../pdf-annotation-extractor-alfred" || exit 1
git pull
