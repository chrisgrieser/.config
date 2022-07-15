#!/bin/zsh

cd "$(dirname "$0")" || exit 1

device_name=$(scutil --get ComputerName | cut -d" " -f2-)
details=$(git status --porcelain)
filesChanged=$(echo -n "$details" | wc -l | tr -d ' ')

[[ -z "$filesChanged" ]] && exit 0
if [[ "$filesChanged" == 1 ]] ; then
	changeType="$filesChanged file"
else
	changeType="$filesChanged files"
fi
msg="$(date +"%a, %H:%M"), $changeType, $device_name"

git add -A \
&& git commit -m "$msg" -m "$details" \
&& git pull \
&& git push

# Alfred Repos pullen
if [[ "$1" == "wake" ]] ; then
	cd "Alfred.alfredpreferences/workflows" || exit 1
	cd "./shimmering-obsidian" && git pull
	cd "../alfred-bibtex-citation-picker" && git pull
	cd "../pdf-annotation-extractor-alfred" && git pull
fi
