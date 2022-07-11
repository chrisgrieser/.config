#!/bin/zsh

# go to script location (the script should be located in the git repository)
THIS_LOCATION="$(dirname "$0")"
cd "$THIS_LOCATION" || exit 1
#-------------------------------------------------------------------------------
device_name=$(scutil --get ComputerName | cut -d" " -f2-)
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
# no full date needed, since git shows it already
git commit -m "$(date +"%a, %H:%M"), $changeType, $device_name" -m "$details"

git pull
git push

#-------------------------------------------------------------------------------
# pull repos

git pull
cd "$THIS_LOCATION/Alfred.alfredpreferences/workflows/user.workflow.41B90DCD-A99E-4943-A19A-E91859557FB0/" || exit 1
git pull
cd "$THIS_LOCATION/Alfred.alfredpreferences/workflows/user.workflow.D02FCDA1-EA32-4486-B5A6-09B42C44677C/" || exit 1
git pull
cd "$THIS_LOCATION/Alfred.alfredpreferences/workflows/user.workflow.765354AA-49F0-4CB1-8DB0-EA4BE2DB09F8/" || exit 1
