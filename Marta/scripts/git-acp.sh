#!/usr/bin/env zsh
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

git add -A && git commit -m "$msg" --author="🤖📂<marta@file.explorer>"
git pull
git push
