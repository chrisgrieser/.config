#!/usr/bin/env zsh
if [[ ! -x "$(command -v gh)" ]]; then print "\e[1;33mgh not installed.\e[0m" && return 1; fi
# set -e
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
github_username="chrisgrieser"
# repo_names="alfred|shimmering-obsidian|gitfred"
repo_names="nvim"
commit_msg="ci: remove stylua action & update PR template"

function actions_in_repo {
	[[ -e .github/workflows/stylua.yml ]] && rm .github/workflows/stylua.yml
	cp -f "$HOME/Desktop/pull_request_template.md" ./.github/PULL_REQUEST_TEMPLATE.md
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
declare -f actions_in_repo
echo
print "\e[1;34mProceed? (y/n)\e[0m"
read -rks pressed
if [[ "$pressed" != "y" ]]; then
	echo "Aborted."
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────
# clone each repo, do the replacements, and git add/commit/push
i=1
while read -r repo; do
	echo
	echo "──────────────────────────────────────────────────────────────"
	print "\e[1;34mUpdating $repo… ($i/$repo_count)\e[0m"
	git clone --depth=2 "git@github.com:$github_username/$repo"
	cd "$repo" || return 1

	actions_in_repo

	git add --all && git commit -m "$commit_msg" && git push
	cd ..
	rm -rf "$repo"
	((i++))
done <<< "$repos_to_update"
