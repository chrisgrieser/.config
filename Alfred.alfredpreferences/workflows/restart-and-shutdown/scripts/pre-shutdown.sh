#!/usr/bin/env zsh

# CONFIG
perma_repo_file="$HOME/.config/perma-repos.csv"

#-------------------------------------------------------------------------------

set -e
alfred_dir="$PWD" # stored, since cd'ing later
function notify() {
	"$alfred_dir/notificator" --title "Pre-shutdown sync" --message "$1"
}

#-------------------------------------------------------------------------------

# So Obsidian isn't re-opened on startup causing sync issues
pgrep -xq "Obsidian" && killall "Obsidian"

while read -r line; do
	repo_path=$(echo "$line" | cut -d, -f1 | sed "s|^~|$HOME|")
	icon=$(echo "$line" | cut -d, -f2)
	name=$(basename "$repo_path")
	cd "$repo_path"
	if [[ -n "$(git status --porcelain)" ]]; then
		notify "$name $icon"
		zsh ".sync-this-repo.sh" &> /dev/null
	fi
	if [[ -n "$(git status --porcelain)" ]]; then
		notify "⚠️$icon $name not synced."
		return 1
	fi
done < "$perma_repo_file"

#-------------------------------------------------------------------------------

echo -n "success" # trigger shutdown prompt in Alfred
notify "✅ All synced."
sketchybar --trigger sync_indicator # sketchybar sync icon
