#!/usr/bin/env zsh
# INFO
# - Backup all PUBLIC NON-FORK repos owned by the specified github user as zip archive. 
# - For speed and disk space, only shallow clones are saved (depth 2).
# - Requires `yq` being installed. 
# - Due to github API restrictions, only a maximum of 100 repos are downloaded.

#───────────────────────────────────────────────────────────────────────────────

# CONFIG
github_username="chrisgrieser"
repo_to_ignore=".config" # excluded, since dotfiles are already existing locally
backup_location="$DATA_DIR/Backups/My Repos"

#───────────────────────────────────────────────────────────────────────────────

# prerequisites
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
if ! command -v yq &>/dev/null; then printf "\033[1;33myq not installed.\033[0m" && return 1; fi
mkdir -p "$backup_location/temp"
cd "$backup_location/temp" || return 1

# download repos
apiURL="https://api.github.com/users/${github_username}/repos?per_page=100"
curl -s "$apiURL" | 
	yq "filter(.fork == false) | filter(.archived == false) | filter(.name != \"$repo_to_ignore\") | map(.full_name)" --prettyPrint |
	cut -c3- |
	# WARN depth=2 ensures that amending a shallow commit does not result in a 
	# new commit without parent, effectively destroying git history (!!)
	xargs -I {} git clone --depth=2 'git@github.com:{}.git'

# archive them
date_stamp=$(date +%Y-%m-%d_%H-%M-%S)
repos_count=$(find . -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d " ")
if [[ repos_count -ge 100 ]]; then	
	print "\033[1;33mGitHub API only allows up to 100 repos to be downloaded.\033[0m"
fi
archive_name="${repos_count} Repos – ${date_stamp}.zip"
zip -r --quiet "../$archive_name" . || return 1

echo
print "\033[1;32mArchived $repos_count repos.\033[0m"
open -R "$backup_location/$archive_name"

# remove leftover folders
cd ..
rm -rf "$backup_location/temp"

