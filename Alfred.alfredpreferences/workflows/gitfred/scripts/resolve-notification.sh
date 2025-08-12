#!/usr/bin/env zsh
# shellcheck disable=2154

# MARK AS READ
if [[ "$mode" == "mark-as-read" ]]; then
	# DOCS https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#mark-a-thread-as-read
	thread_id="$1"
	curl -sL \
		-X PATCH \
		-H "Accept: application/vnd.github+json" \
		-H "Authorization: Bearer $GITHUB_TOKEN" \
		-H "X-GitHub-Api-Version: 2022-11-28" \
		"https://api.github.com/notifications/threads/$thread_id"
	return 0
fi

#───────────────────────────────────────────────────────────────────────────────

api_url="$1"
# DOCS https://docs.github.com/en/rest/activity/notifications?apiVersion=2022-11-28#get-a-thread
if [[ -z "$api_url" && "$mode" == "open" ]]; then
	# some notification types like ci-activity do not provide a thread
	github_url="https://github.com/notifications"
else
	# get token
	token=$github_token_from_alfred_prefs
	[[ -z "$token" && -n "$github_token_shell_cmd" ]] && token=$(zsh -c "$github_token_shell_cmd")
	[[ -z "$token" ]] && token=$GITHUB_TOKEN

	response=$(curl -sL -H "Accept: application/vnd.github+json" \
		-H "Authorization: Bearer $token" \
		-H "X-GitHub-Api-Version: 2022-11-28" \
		"$api_url")
	# using `grep` here avoids `jq` dependency
	github_url=$(echo "$response" | grep --max-count=1 '"html_url"' | cut -d '"' -f4)

	# VALIDATE
	if [[ -z "$github_url" && "$mode" == "open" ]]; then
		# some notification types like ci-activity do not provide a thread
		github_url="https://github.com/notifications"
	fi
fi

if [[ "$mode" == "open" ]]; then
	open "$github_url"
	if [[ "$github_url" == "https://github.com/notifications" ]]; then
		echo "Opening notification inbox at GitHub instead."
		return 1
	fi
elif [[ "$mode" == "copy" ]]; then
	if [[ -z "$github_url" ]]; then
		echo "Error: No URL found for notification."
		return 1
	fi
	echo -n "$github_url" | pbcopy
	echo -n "$github_url" # pass for Alfred notification
fi
