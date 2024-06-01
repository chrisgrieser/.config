#!/usr/bin/env zsh
if [[ ! -x "$(command -v gh)" ]]; then print "\e[1;33mgh not installed.\e[0m" && return 1; fi
# set -e
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
github_username="chrisgrieser"
# repo_names="alfred|shimmering-obsidian|gitfred"
repo_names="nvim"
commit_msg="ci: allow \`improv\` as commit keyword"

function actions_in_repo {
	cp -f "$HOME/Desktop/semantic-pr-title.yml" ./.github/workflows/semantic-pr-title.yml
}

#───────────────────────────────────────────────────────────────────────────────

repos_to_update=$(gh repo list --limit=100 --no-archived --source --json="name" \
	--jq=".[].name | select(test(\"$repo_names\"))")
repo_count=$(echo "$repos_to_update" | wc -l | tr -d " ")

# confirmation that everything is correct
print "\e[1;34mCommit message:\e[0m"
echo "$commit_msg"
echo
print "\e[1;34mRepos to update ($repo_count):\e[0m"
echo "$repos_to_update"
echo
print "\e[1;34mActions:\e[0m"
declare -f actions_in_repo | bat --language=sh
echo
print "\e[1;34mProceed? (y/n)\e[0m"
read -rk pressed
if [[ "$pressed" != "y" ]]; then
	echo "Aborted."
	return 1
fi
echo && echo

#───────────────────────────────────────────────────────────────────────────────
# clone each repo, do the replacements, and git add/commit/push
i=1
while read -r repo; do
	echo "──────────────────────────────────────────────────────────────"
	print "\e[1;34mUpdating $repo… ($i/$repo_count)\e[0m"
	git clone --depth=2 "git@github.com:$github_username/$repo"
	cd "$repo" || return 1

	actions_in_repo

	git add --all && echo &&
		git commit -m "$commit_msg" && echo &&
		git push && echo

	cd ..
	rm -rf "$repo"
	((i++))
done <<< "$repos_to_update"
