#!/usr/bin/env zsh

cache_folder="$HOME/Library/Caches/com.runningwithcrayons.Alfred/Workflow Data"
data_folder="$HOME/Library/Application Support/Alfred/Workflow Data"
current_workflow=$(sed -n "4p" "$HOME/Library/Application Support/Alfred/history.json" | cut -d'"' -f2)

which_one="$*"

if [[ "$which_one" == "cache" ]]; then
	open "$cache_folder/$current_workflow" || open "$cache_folder"
elif [[ "$which_one" == "data" ]]; then
	open "$data_folder/$current_workflow" || open "$data_folder"
fi

