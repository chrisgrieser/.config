#!/usr/bin/env zsh

_export_github_token
#-------------------------------------------------------------------------------

response=$(curl --silent --location \
	-H "Accept: application/vnd.github+json" \
	-H "Authorization: Bearer $GITHUB_TOKEN" \
	-H "X-GitHub-Api-Version: 2022-11-28" \
	"https://api.github.com/notifications")

echo "$response" | jq --exit-status 'has("message")' &>/dev/null
has_error=$?

if [[ $has_error -eq 0 ]]; then
	echo "$response" | jq --raw-output '.message'
	exit 1
else
	count=$(echo "$response" | jq --raw-output '. | length')
	echo "$count"
	exit 0
fi
