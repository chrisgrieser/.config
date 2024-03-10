#!/usr/bin/env zsh
if [[ ! -x "$(command -v gh)" ]]; then print "\e[1;33mgh not installed.\e[0m" && return 1; fi
set -e # safe mode
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
github_username="chrisgrieser"

repos_to_update=$(gh repo list --limit=100 --no-archived --source --json="name" --jq=".[].name" |
	grep -E "alfred|shimmering-obsidian")

commit_msg="build: improved release action"

function actions_in_repo {
	# update release action
	rm -v ./.github/workflows/alfred-workflow-release.yml
	cp -v "$WD/alfred-workflow-release.yml" ./.github/workflows
}

#───────────────────────────────────────────────────────────────────────────────
# confirmation that everything is correct
print "\e[1;34mCommit Message:\e[0m"
echo "$commit_msg"
echo
print "\e[1;34mRepos to Update:\e[0m"
echo "$repos_to_update"
echo
print "\e[1;34mAction:\e[0m"
declare -f actions_in_repo
echo
print "\e[1;34mProceed? (y/n)\e[0m"
if [[ "$(read -rks)" != "y" ]]; then
	echo "Aborted."
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────
# clone each repo, do the replacements, and git add/commit/push
while read -r repo; do
	echo
	echo "-----------------------------------------------------"
	print "\e[1;34mUpdating $repo…\e[0m"
	git clone --depth=2 "git@github.com:$github_username/$repo"
	cd "$repo" || return 1

	actions_in_repo

	git add --all && git commit -m "$commit_msg" && git push
	cd ..
	rm -rf "$repo"
done <<<"$repos_to_update"
