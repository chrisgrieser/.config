#!/usr/bin/env zsh

current_subreddit="$1"

# shellcheck disable=2154
next_subreddit=$(echo "$subreddits" |
	sed -n "/$current_subreddit/,+1p" |
	tail -n1)

# if already last subreddit, go back to first subreddit
if [[ "$next_subreddit" == "$current_subreddit" ]]; then
	# shellcheck disable=2154
	if [[ "$add_hackernews" == "1" ]]; then
		next_subreddit="hackernews"
	else
		next_subreddit=$(echo "$subreddits" | head -n1)
	fi
fi

# pass to Alfred-loop
# shellcheck disable=2154
echo -n "$next_subreddit" > "$alfred_workflow_cache/current_subreddit"
