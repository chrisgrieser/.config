#!/usr/bin/env zsh

# shellcheck disable=2154
if [[ "$mode" == "mark-as-read" ]]; then
	# DOCS https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#mark-a-thread-as-read
	thread_id="$1"
	curl -sL \
		-X PATCH \
		-H "Accept: application/vnd.github+json" \
		-H "Authorization: Bearer $GITHUB_TOKEN" \
		-H "X-GitHub-Api-Version: 2022-11-28" \
		"https://api.github.com/notifications/threads/$thread_id"
else
	api_url="$1"
	# DOCS https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#get-a-thread
	if [[ -z "$api_url" ]]; then
		# some notification types like ci-activity do not provide a thread
		github_url="https://github.com/notifications?query=is%3Aunread"
	else
		response=$(curl -sL -H "Accept: application/vnd.github+json" \
			-H "Authorization: Bearer $GITHUB_TOKEN" \
			-H "X-GitHub-Api-Version: 2022-11-28" \
			"$api_url")
		# using `grep` here avoids `jq` dependency
		github_url=$(echo "$response" | grep --max-count=1 '"html_url"' | cut -d '"' -f4)

		# VALIDATE
		if [[ -z "$github_url" ]]; then
			err_msg="ERROR: could not get url to open. Check debugging log"
			echo -n "$err_msg"                               # pass for Alfred notification
			print "$err_msg\nGithub response: $response" >&2 # pass to console
			return 1
		fi
	fi

	if [[ "$mode" == "open" ]]; then
		open "$github_url"
	elif [[ "$mode" == "copy" ]]; then
		echo -n "$github_url" | pbcopy
		echo -n "$github_url" # pass for Alfred notification
	fi
fi
