#!/usr/bin/env zsh
# shellcheck disable=2154
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

if ! command -v gh &>/dev/null; then
	echo "⚠️ gh not installed." # alfred notification
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────

set -e # abort if any step fails

original="$*"
reponame=$(echo "$original" | cut -d/ -f2)
fork="$username/$reponame"

cd "$local_repo_folder"
gh repo fork "$original" --clone=false

gh repo clone "$fork" -- --depth=1 || echo "❌ Error"

cd "$name"
ls -G # colorized inspection
