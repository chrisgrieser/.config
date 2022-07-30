#!/bin/zsh

cd "$(dirname "$0")" || exit 1

device_name=$(scutil --get ComputerName | cut -d" " -f2-)
filesChanged="$(git status --porcelain | wc -l | tr -d ' ')"

if [[ "$filesChanged" == 0 ]] ; then
	exit 0
elif [[ "$filesChanged" == 1 ]] ; then
	changeType="$filesChanged file"
else
	changeType="$filesChanged files"
fi
msg="$changeType, $device_name"

git add -A && git commit -m "$msg"
git pull
git push

# Alfred Repos pullen
if [[ "$1" == "wake" ]] ; then
	cd "Alfred.alfredpreferences/workflows" || exit 1
	cd "./shimmering-obsidian" && git pull
	cd "../alfred-bibtex-citation-picker" && git pull
	cd "../pdf-annotation-extractor-alfred" && git pull
fi
