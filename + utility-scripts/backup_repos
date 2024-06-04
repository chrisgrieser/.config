#!/usr/bin/env zsh

# CONFIG
# ignores perma-repos since they are already locally backed up
backup_location="$DATA_DIR/Backups/My Repos"
max_number_of_bkps=4
ignore_repos=$(cut -d, -f2 "$HOME/.config/perma-repos.csv" | cut -c2- |
	tr "\n" "|" | sed -e "s/.$//") # construct regex pattern for `grep`

#───────────────────────────────────────────────────────────────────────────────

set -e

# get all repos
repos=$(gh repo list --limit=200 --no-archived --source --json="nameWithOwner" --jq=".[].nameWithOwner" |
	grep --extended-regexp --invert-match "$ignore_repos")
repos_count=$(echo "$repos" | wc -l | tr -d " ")
if [[ repos_count -ge 100 ]]; then
	print "\e[1;33mMore than 100 repos. Unclear whether GitHub API allows for so many listings, so need to manually check that all repos are included.\e[0m"
fi

# download repos
mkdir -p "$backup_location/temp"
cd "$backup_location/temp" || return 1
i=0
echo "$repos" | while read -r repo; do
	i=$((i + 1))
	print "\e[1;34m$repo ($i/$repos_count)\e[0m"
	git clone "git@github.com:$repo.git" # full clones, not shalow ones
	echo
done

# archive them
isodate=$(date +%Y-%m-%d)
archive_name="${repos_count} Repos – ${isodate}.zip"
zip -r --quiet "../$archive_name" . || return 1

#───────────────────────────────────────────────────────────────────────────────
# restrict number of backups
cd "$backup_location" || return 1
# shellcheck disable=2012
ls -t | tail -n +$((max_number_of_bkps + 1)) | tr '\n' '\0' | xargs -0 rm

# confirm and remove leftover folders
rm -rf "$backup_location/temp"
print "\e[1;32mArchived $repos_count repos.\e[0m"
open -R "$backup_location/$archive_name"
