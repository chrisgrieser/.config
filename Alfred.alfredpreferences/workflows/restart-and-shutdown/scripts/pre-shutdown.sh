#!/usr/bin/env zsh
set -e
#───────────────────────────────────────────────────────────────────────────────

alfred_root="$PWD"

while read -r line; do
	name=$(echo "$line" | cut -d, -f1)
	repo_path=$(echo "$line" | cut -d, -f2 | sed "s|^~|$HOME|")
	icon=$(echo "$line" | cut -d, -f3)
	cd "$repo_path"
	if [[ -n "$(git status --porcelain)" ]]; then
		"$alfred_root/notificator" --title "Pre-Shutdown Sync…" --message "$name $icon"
		zsh ".sync-this-repo.sh" &>/dev/null
	fi
	if [[ -n "$(git status --porcelain)" ]]; then
		echo "⚠️ $icon $name not synced."
		return 1
	fi
done <"$HOME/.config/perma-repos.csv"

# for Alfred conditional to prompt shutdown
echo -n "success"
