#!/usr/bin/env zsh
# INFO
# - Backup all PUBLIC NON-FORK repos owned by the specified github user as zip archive.
# - Requires `yq`.
# - Due to github API restrictions, only a maximum of 100 repos are downloaded.
#   (TODO use `gh` instead to work around restrictions & `yq` dependency?)
#───────────────────────────────────────────────────────────────────────────────

# CONFIG
github_username="chrisgrieser"
repo_to_ignore=".config" # excluded, since dotfiles are already existing locally
backup_location="$DATA_DIR/Backups/My Repos"
max_number_of_bkps=4

#───────────────────────────────────────────────────────────────────────────────

# GUARD prerequisites
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
if ! command -v yq &>/dev/null; then printf "\e[1;33myq not installed.\e[0m" && return 1; fi
mkdir -p "$backup_location/temp"
cd "$backup_location/temp" || return 1

#───────────────────────────────────────────────────────────────────────────────

# download repos
apiURL="https://api.github.com/users/${github_username}/repos?per_page=100"
repos=$(curl -s "$apiURL" |
	yq "filter(.fork == false) | filter(.archived == false) | filter(.name != \"$repo_to_ignore\") | map(.full_name)" --prettyPrint |
	cut -c3-)
repos_count=$(echo "$repos" | wc -l | tr -d " ")

i=0
echo "$repos" | while read -r repo; do
	i=$((i + 1))
	print "\e[1;34m$repo ($i/$repos_count)\e[0m"
	git clone "git@github.com:$repo.git" # full clones, not shalow ones
	echo
done

# archive them
isodate=$(date +%Y-%m-%d)
if [[ repos_count -ge 100 ]]; then
	print "\e[1;33mGitHub API only allows up to 100 repos to be downloaded, backup is therefore incomplete.\e[0m"
fi
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
