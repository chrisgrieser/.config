#!/usr/bin/env zsh

# shellcheck disable=2154 # Alfred variable
if [[ "$open_in" == "browser" ]]; then
	# gives ios page by default, even if previously searched for Mac, thus need to set mac manually
	url= "$*&platform=mac"
	open "$url"
elif [[ "$open_in" == "app" ]]; then
	open -a "App Store" "$*"
fi
