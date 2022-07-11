#!/bin/zsh

# go to script location (the script should be located in the git repository)
cd "$(dirname "$0")" || exit

device_name=$(hostname | cut -d"." -f1)
details="$(git status --porcelain)"
filesChanged="$(echo "$details" | wc -l | tr -d ' ')"

if [[ "$filesChanged" == 0 ]] ; then
	# abort if there haven't been changes
	exit 0
elif [[ "$filesChanged" == 1 ]] ; then
	changeType="$filesChanged file"
else
	changeType="$filesChanged files"
fi

git add -A
# no full date needed, since GitHub shows it
git commit -m "$(date +"%a, %H:%M"), $changeType, $device_name" -m "$details"

git pull
git push
