#!/usr/bin/env zsh

_export_github_token

#-------------------------------------------------------------------------------

response=$(curl --silent --location \
	-H "Accept: application/vnd.github+json" \
	-H "Authorization: Bearer $GITHUB_TOKEN" \
	-H "X-GitHub-Api-Version: 2022-11-28" \
	"https://api.github.com/notifications")

echo "$response" | jq -r '. | length'
