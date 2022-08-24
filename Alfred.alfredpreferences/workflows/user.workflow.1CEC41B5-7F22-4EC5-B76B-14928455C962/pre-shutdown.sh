#!/usr/bin/env zsh
cd ~/dotfiles/ || exit 1
filesChanged="$(git status --porcelain | wc -l | tr -d ' ')"
if [[ -n "$filesChanged" ]] ; then
	echo "📴 pre-shutdown-sync dotfiles" >> ~'/dotfiles/hammerspoon/logs/sync.log'
	zsh ~"/dotfiles/git-dotfile-sync.sh"
fi

cd ~"/Main Vault/" || exit 1
filesChanged="$(git status --porcelain | wc -l | tr -d ' ')"
if [[ -n "$filesChanged" ]] ; then
	echo "📴 pre-shutdown-sync vault" >> ~'/dotfiles/hammerspoon/logs/sync.log'
	zsh ~"/Main Vault/Meta/git-vault-sync.sh"
fi

#-------------------------------------------------------------------------------

