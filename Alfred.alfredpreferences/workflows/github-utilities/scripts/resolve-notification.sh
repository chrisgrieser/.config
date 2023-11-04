#!/usr/bin/env zsh

url="$1"

# shellcheck disable=2154
if [[ "$mode" == "direct-open" ]]; then
	open "$url"
elif [[ "$mode" == "mark-as-read" ]]; then
	# DOCS https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#mark-a-thread-as-read
	thread_id="$1"
	curl -sL \
		-X PATCH \
		-H "Accept: application/vnd.github+json" \
		-H "Authorization: Bearer $GITHUB_TOKEN" \
		-H "X-GitHub-Api-Version: 2022-11-28" \
		"https://api.github.com/notifications/threads/$thread_id"
else
	# DOCS https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#get-a-thread
	url=$(
		curl -sL -H "Accept: application/vnd.github+json" \
			-H "Authorization: Bearer $GITHUB_TOKEN" \
			-H "X-GitHub-Api-Version: 2022-11-28" \
			"$thread_id" |
			grep "html_url.*" | head -n1 | cut -d '"' -f 4 # skip `jq` dependency
	)

	if [[ "$mode" == "open" ]]; then
		open "$url"
	elif [[ "$mode" == "copy" ]]; then
		echo "$url" | pbcopy
		echo "$url" # pass for Alfred notification
	fi
fi
