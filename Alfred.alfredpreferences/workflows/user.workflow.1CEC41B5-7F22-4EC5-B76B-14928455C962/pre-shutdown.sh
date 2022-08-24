#!/usr/bin/env zsh
cd ~/dotfiles/ || exit 1
if [[ -n "$(git status --porcelain)" ]] ; then
	echo "📴 pre-shutdown-sync dotfiles" >> ~'/dotfiles/hammerspoon/logs/sync.log'
	zsh ~"/dotfiles/git-dotfile-sync.sh"

	if [[ -n "$(git status --porcelain)" ]] ; then
		echo "Dotfile-Repo not clean." # f
		exit 1
	fi
fi

cd ~"/Main Vault/" || exit 1
if [[ -n "$(git status --porcelain)" ]] ; then
	echo "📴 pre-shutdown-sync vault" >> ~'/dotfiles/hammerspoon/logs/sync.log'
	zsh ~"/Main Vault/Meta/git-vault-sync.sh"
	if [[ -n "$(git status --porcelain)" ]] ; then
		echo "Vault-Repo not clean."
		exit 1
	fi
fi

echo -n "success"

