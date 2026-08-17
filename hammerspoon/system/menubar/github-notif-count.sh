#!/usr/bin/env zsh

_export_github_token

#-------------------------------------------------------------------------------

response=$(curl --silent --location \
	-H "Accept: application/vnd.github+json" \
	-H "Authorization: Bearer $GITHUB_TOKEN" \
	-H "X-GitHub-Api-Version: 2022-11-28" \
	"https://api.github.com/notifications")

error=$(echo "$response" | jq --raw-output '.message')
count=$(echo "$response" | jq --raw-output '. | length')

if [[ "$error" != "null" ]]; then
	echo "$error"
	exit 1
fi

echo "$count"
