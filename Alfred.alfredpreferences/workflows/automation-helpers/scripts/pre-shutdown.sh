#!/usr/bin/env zsh
# shellcheck disable=SC2181

cd "$DOTFILE_FOLDER" || exit 1
if [[ -n "$(git status --porcelain)" ]] ; then
	zsh "$DOTFILE_FOLDER/git-dotfile-sync.sh" &> /dev/null
	if [[ $? -ne 0 ]] ; then
		echo "Dotfile-Repo not clean."
		exit 1
	fi
fi

cd "$VAULT_PATH" || exit 1
if [[ -n "$(git status --porcelain)" ]] ; then
	zsh "$VAULT_PATH/Meta/git-vault-sync.sh" &> /dev/null
	if [[ $? -ne 0 ]] ; then
		echo "Vault-Repo not clean."
		exit 1
	fi
fi

cd "$PASSWORD_STORE_DIR" || exit 1
if [[ -n "$(git status --porcelain)" ]] ; then
	zsh "$VAULT_PATH/pass-sync.sh" &> /dev/null
	if [[ $? -ne 0 ]] ; then
		echo "Pass-Store Repo not clean."
		exit 1
	fi
fi

sketchybar --trigger repo-files-update # update icon
echo -n "success"

