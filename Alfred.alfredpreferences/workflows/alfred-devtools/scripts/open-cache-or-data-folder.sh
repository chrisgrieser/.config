#!/usr/bin/env zsh

mode="$1"
current_workflow_uid=$(sed -n "4p" "$HOME/Library/Application Support/Alfred/history.json" | cut -d'"' -f2)
current_workflow_bundleid=$(plutil -extract "bundleid" raw -o - "../$current_workflow_uid/info.plist")

# shellcheck disable=2154
if [[ "$mode" == "cache_folder" ]]; then
	cache_folder="$HOME/Library/Caches/com.runningwithcrayons.Alfred/Workflow Data"
	open "$cache_folder/$current_workflow_bundleid" || open "$cache_folder"
elif [[ "$mode" == "data_folder" ]]; then
	data_folder="$HOME/Library/Application Support/Alfred/Workflow Data"
	open "$data_folder/$current_workflow_bundleid" || open "$data_folder"
fi
