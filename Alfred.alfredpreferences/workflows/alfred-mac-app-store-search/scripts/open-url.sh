#!/usr/bin/env zsh

url="$*"

# shellcheck disable=2154 # Alfred variable
if [[ "$openIn" == "browser" ]]; then
	open "$url"
else
	open -a "App Store" "$url"
fi
