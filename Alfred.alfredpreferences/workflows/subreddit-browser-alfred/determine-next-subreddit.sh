#!/usr/bin/env zsh

current_subreddit="$1"

# shellcheck disable=2154
next_subreddit=$(echo "$subreddits" | 
	sed -n "/$current_subreddit/,+1p" |
	tail -n1)

echo n "$next_subreddit"
