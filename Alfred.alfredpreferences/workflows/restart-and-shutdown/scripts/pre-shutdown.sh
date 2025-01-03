#!/usr/bin/env zsh
set -e
#───────────────────────────────────────────────────────────────────────────────

alfred_dir="$PWD" # stored, since cd'ing later

# So Obsidian isn't re-opened on startup causing sync issues
if pgrep -xq "Obsidian"; then
	killall "Obsidian"
fi

function notify() {
	name=$1
	icon=$2
	"$alfred_dir/notificator" --title "Pre-Shutdown Sync…" --message "$name $icon"
}

while read -r line; do
	name=$(echo "$line" | cut -d, -f1)
	repo_path=$(echo "$line" | cut -d, -f2 | sed "s|^~|$HOME|")
	icon=$(echo "$line" | cut -d, -f3)
	cd "$repo_path"
	if [[ -n "$(git status --porcelain)" ]]; then
		notify "$name" "$icon"
		zsh ".sync-this-repo.sh" &> /dev/null
	fi
	if [[ -n "$(git status --porcelain)" ]]; then
		notify "⚠️ $icon $name not synced."
		return 1
	fi
done < "$HOME/.config/perma-repos.csv"

# for Alfred conditional to prompt shutdown
echo -n "success"
