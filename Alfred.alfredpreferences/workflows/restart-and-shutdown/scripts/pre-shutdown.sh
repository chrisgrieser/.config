#!/usr/bin/env zsh

cd "$HOME/.config" || return 1
if [[ -n "$(git status --porcelain)" ]]; then
	osascript -e 'display notification "🔵 Dotfiles" with title "🔁 Syncing…"'
	zsh ".git-dotfile-sync.sh" &>/dev/null
fi
if [[ -n "$(git status --porcelain)" ]]; then
	echo "⚠️🔵 not synced."
	return 1
fi

cd "$VAULT_PATH" || return 1
if [[ -n "$(git status --porcelain)" ]]; then
	osascript -e 'display notification "🟪 Vault" with title "🔁 Syncing…"'
	zsh ".git-vault-sync.sh" &>/dev/null
fi
if [[ -n "$(git status --porcelain)" ]]; then
	echo "⚠️🟪 Vault not synced."
	return 1
fi

cd "$PASSWORD_STORE_DIR" || return 1
if [[ -n "$(git status --porcelain)" ]]; then
	osascript -e 'display notification "🔑 Password Store" with title "🔁 Syncing…"'
	zsh ".pass-sync.sh" &>/dev/null
fi
if [[ -n "$(git status --porcelain)" ]]; then
	echo "⚠️🔑 Password store not synced."
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────

# for Alfred conditional to prompt shutdown
echo -n "success" 
