#!/usr/bin/env zsh

cache_folder="$HOME/Library/Caches/com.runningwithcrayons.Alfred/Workflow Data"
data_folder="$HOME/Library/Application Support/Alfred/Workflow Data"
current_workflow_uid=$(sed -n "4p" "$HOME/Library/Application Support/Alfred/history.json" | cut -d'"' -f2)
current_workflow_bundleid=$(grep -A1 "bundleid" "../$current_workflow_uid/info.plist" | tail -1 | cut -d">" -f2 | cut -d"<" -f1)

which_one="$*"

if [[ "$which_one" == "cache" ]]; then
	open "$cache_folder/$current_workflow_bundleid" || open "$cache_folder"
elif [[ "$which_one" == "data" ]]; then
	open "$data_folder/$current_workflow_bundleid" || open "$data_folder"
fi

