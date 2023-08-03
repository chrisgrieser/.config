#!/usr/bin/env zsh

current_subreddit="$1"

# shellcheck disable=2154
next_subreddit=$(echo "$subreddits" |
	sed -n "/$current_subreddit/,+1p" |
	tail -n1)

# if already last subreddit, go back to first subreddit
if [[ "$next_subreddit" == "$current_subreddit" ]]; then
	next_subreddit=$(echo "$subreddits" | head -n1)
fi

# pass to Alfred-loop
echo -n "$next_subreddit"
