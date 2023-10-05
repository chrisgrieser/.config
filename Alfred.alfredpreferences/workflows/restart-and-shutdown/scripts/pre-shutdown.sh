#!/usr/bin/env zsh

cd "$HOME/.config" || return 1
if [[ -n "$(git status --porcelain)" ]]; then
	osascript -e 'display notification "" with title "🔁 Syncing Dotfiles…"'
	zsh "$HOME/.config/git-dotfile-sync.sh" &>/dev/null
fi

cd "$VAULT_PATH" || return 1
if [[ -n "$(git status --porcelain)" ]]; then
	osascript -e 'display notification "" with title "🔁 Syncing Vault…"'
	zsh "$VAULT_PATH/Meta/git-vault-sync.sh" &>/dev/null
fi

cd "$PASSWORD_STORE_DIR" || return 1
if [[ -n "$(git status --porcelain)" ]]; then
	osascript -e 'display notification "" with title "🔁 Syncing Password Store…"'
	zsh "$VAULT_PATH/pass-sync.sh" &>/dev/null
fi

sketchybar --trigger repo-files-update # update icon
echo -n "success"
