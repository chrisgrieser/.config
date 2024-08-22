#!/usr/bin/env zsh
# shellcheck disable=2154

direction="$1"
cur_subreddit=$(cat "$alfred_workflow_cache/current_subreddit")
list_of_subreddits=$(echo "$subreddits" |
	sed -E 's|^/?r/||') # can be r/ or /r/ https://www.alfredforum.com/topic/20813-reddit-browser/page/2/#comment-114645

#───────────────────────────────────────────────────────────────────────────────

if [[ "$direction" == "next" ]]; then
	next_subreddit=$(echo "$list_of_subreddits" |
		grep --after-context=1 --extended-regexp "^$cur_subreddit$" |
		tail -n1)

	# if already last subreddit, go back to first subreddit
	if [[ "$next_subreddit" == "$cur_subreddit" && "$add_hackernews" == "0" ]]; then
		next_subreddit=$(echo "$list_of_subreddits" | head -n1)
	fi

elif [[ "$direction" == "prev" ]]; then
	next_subreddit=$(echo "$list_of_subreddits" |
		grep --before-context=1 --extended-regexp "^$cur_subreddit$" |
		head -n1)

	# if already first subreddit, go back to last subreddit
	if [[ "$next_subreddit" == "$cur_subreddit" && "$add_hackernews" == "0" ]]; then
		next_subreddit=$(echo "$list_of_subreddits" | tail -n1)
	fi
fi

# in case user has only one subreddit & hackernews enabled
if [[ "$next_subreddit" == "$cur_subreddit" && "$add_hackernews" == "1" ]]; then
	next_subreddit="hackernews"
fi

#───────────────────────────────────────────────────────────────────────────────

# save for Alfred-loop
echo -n "$next_subreddit" > "$alfred_workflow_cache/current_subreddit"
