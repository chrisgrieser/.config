# INFO
# - Backup all PUBLIC NON-FORK repos owned by the specified github user as zip archive.
# - For speed and disk space, only shallow clones are saved (depth 2).
# - Requires `yq` being installed.
# - Due to github API restrictions, only a maximum of 100 repos are downloaded.

# CONFIG
github_username="chrisgrieser"
repo_to_ignore=".config" # excluded, since dotfiles are already existing locally
backup_location="$DATA_DIR/Backups/My Repos"

#───────────────────────────────────────────────────────────────────────────────

# GUARD prerequisites
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
if ! command -v yq &>/dev/null; then printf "\e[1;33myq not installed.\e[0m" && return 1; fi
mkdir -p "$backup_location/temp"
cd "$backup_location/temp" || return 1

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
date_stamp=$(date +%Y-%m-%d_%H-%M-%S)
if [[ repos_count -ge 100 ]]; then
	print "\e[1;33mGitHub API only allows up to 100 repos to be downloaded, backup is therefore incomplete\e[0m"
fi
archive_name="${repos_count} Repos – ${date_stamp}.zip"
zip -r --quiet "../$archive_name" . || return 1

# confirm and remove leftover folders
print "\e[1;32mArchived $repos_count repos.\e[0m"
open -R "$backup_location/$archive_name"
cd ..
rm -rf "$backup_location/temp"
