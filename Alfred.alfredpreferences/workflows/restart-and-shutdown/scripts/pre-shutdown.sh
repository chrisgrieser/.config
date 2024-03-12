#!/usr/bin/env zsh
set -e
#───────────────────────────────────────────────────────────────────────────────

function ensure_sync {
	local repo_path="$1"
	local name="$2"
	local syncfile="$3"

	cd "$repo_path"
	if [[ -n "$(git status --porcelain)" ]]; then
		osascript -e "display notification \"$name\" with title \"🔁 Syncing…\""
		zsh "$syncfile" &>/dev/null
	fi
	if [[ -n "$(git status --porcelain)" ]]; then
		echo "⚠️ $name not synced."
		return 1
	fi
}

#───────────────────────────────────────────────────────────────────────────────

ensure_sync "$HOME/.config" "🔵 Dotfiles" ".git-dotfile-sync.sh"
ensure_sync "$VAULT_PATH" "🟪 Vault" ".git-vault-sync.sh"
ensure_sync "$PASSWORD_STORE_DIR" "🔑 Password Store" ".pass-sync.sh"
# ensure_sync "$PHD_DATA_VAULT" "📊 PhD Data" ".phd-data-sync.sh"

# for Alfred conditional to prompt shutdown
echo -n "success" 
