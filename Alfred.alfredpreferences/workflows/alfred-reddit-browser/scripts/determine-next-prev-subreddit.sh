#!/usr/bin/env zsh
# shellcheck disable=2154

direction="$1"
cur_subreddit=$(cat "$alfred_workflow_cache/current_subreddit")

if [[ "$direction" == "next" ]]; then
	next_subreddit=$(echo "$subreddits" | grep -A1 "$cur_subreddit" | tail -n1)

	# if already last subreddit, go back to first subreddit
	if [[ "$next_subreddit" == "$cur_subreddit" && "$add_hackernews" == "0" ]]; then
		next_subreddit=$(echo "$subreddits" | head -n1)
	fi

elif [[ "$direction" == "prev" ]]; then
	next_subreddit=$(echo "$subreddits" | grep -B1 "$cur_subreddit" | head -n1)

	# if already first subreddit, go back to last subreddit
	if [[ "$next_subreddit" == "$cur_subreddit" && "$add_hackernews" == "0" ]]; then
		next_subreddit=$(echo "$subreddits" | tail -n1)
	fi
fi

if [[ "$next_subreddit" == "$cur_subreddit" && "$add_hackernews" == "1" ]]; then
	next_subreddit="hackernews"
fi

# save for Alfred-loop
echo -n "$next_subreddit" >"$alfred_workflow_cache/current_subreddit"
