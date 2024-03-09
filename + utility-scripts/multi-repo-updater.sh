#!/usr/bin/env zsh
if [[ ! -x "$(command -v gh)" ]]; then print "\e[1;33mgh not installed.\e[0m" && return 1; fi
set -e # safe mode
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
github_username="chrisgrieser"

repos_to_update=$(gh repo list --limit=100 --no-archived --source --json="name" --jq=".[].name" |
	grep "alfred")

commit_msg="build: improved release action"

function replacements_todo {
	rm -v ./.github/workflows/build-and-release.yml
	cp -v "$WD/alfred-workflow-release.yml" ./.github/workflows
}

#───────────────────────────────────────────────────────────────────────────────
# clone each repo, do the replacements, and git add/commit/push
while read -r repo; do
	echo "-----------------------------------------------------"
	echo "Updating $repo…"
	git clone --depth=2 "git@github.com:$github_username/$repo"
	cd "$repo" || return 1

	replacements_todo

	git add --all && git commit -m "$commit_msg" && git push
	cd ..
	rm -rf "$repo"
	echo
done <<<"$repos_to_update"
