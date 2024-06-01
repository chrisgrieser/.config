#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
# INFO
# - Backup all PUBLIC NON-FORK repos owned by the specified github user as zip archive.
# - Requires `yq`.
# - Due to github API restrictions, only a maximum of 100 repos are downloaded.
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
backup_location="$DATA_DIR/Backups/My Repos"
max_number_of_bkps=4

#───────────────────────────────────────────────────────────────────────────────

# get all repos
repos=$(gh repo list --limit=200 --no-archived --source --json=" nameWithOwner" --jq=".[].nameWithOwner")
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
actual_number=$((max_number_of_bkps + 1))
# shellcheck disable=2012
ls -t | tail -n +$actual_number | tr '\n' '\0' | xargs -0 rm

# confirm and remove leftover folders
rm -rf "$backup_location/temp"
print "\e[1;32mArchived $repos_count repos.\e[0m"
open -R "$backup_location/$archive_name"
