#!/usr/bin/env zsh

# Backup all public non-fork repos owned by the specified 
# github user as zip archive. For speed and disk space reasons, only shallow 
# clones are saved. Requires `yq` being installed. Due to github API
# restrictions, only a maximum of 100 repos are downloaded.

#───────────────────────────────────────────────────────────────────────────────

github_username="chrisgrieser"
repo_to_ignore=".config" # excluded, since dotfiles are already existing locally
backup_location="$DATA_DIR/Backups/My Repos"

#───────────────────────────────────────────────────────────────────────────────

export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
if ! command -v yq &>/dev/null; then printf "\033[1;33myq not installed.\033[0m" && return 1; fi

cd "$backup_location" || return 1

apiURL="https://api.github.com/users/${github_username}/repos?per_page=100"
curl -s "$apiURL" | 
	yq "filter(.fork == false) | filter(.name != \"$repo_to_ignore\") | map(.full_name)" --prettyPrint |
	cut -c3- |
	xargs -I {} git clone --depth=1 'git@github.com:{}.git'

date_stamp=$(date +%Y-%m-%d_%H-%M-%S)
zip -r --quiet "my-repos_${date_stamp}.zip" .
find . -maxdepth 1 -type d -exec rm -rf {} \;
