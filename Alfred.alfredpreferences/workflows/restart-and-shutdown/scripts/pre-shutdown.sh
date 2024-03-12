#!/usr/bin/env zsh
set -e
#───────────────────────────────────────────────────────────────────────────────

function ensure_sync {
	local repo_path="$1"
	local name="$2"

	cd "$repo_path"
	if [[ -n "$(git status --porcelain)" ]]; then
		osascript -e "display notification \"$name\" with title \"🔁 Syncing…\""
		zsh ".sync-this-repo.sh" &>/dev/null
	fi
	if [[ -n "$(git status --porcelain)" ]]; then
		echo "⚠️ $name not synced."
		return 1
	fi
}

#───────────────────────────────────────────────────────────────────────────────

ensure_sync "$HOME/.config" "🔵 Dotfiles"
ensure_sync "$VAULT_PATH" "🟪 Vault"
ensure_sync "$PASSWORD_STORE_DIR" "🔑 Password Store"
ensure_sync "$PHD_DATA_VAULT" "📗 PhD Data"

# for Alfred conditional to prompt shutdown
echo -n "success"
