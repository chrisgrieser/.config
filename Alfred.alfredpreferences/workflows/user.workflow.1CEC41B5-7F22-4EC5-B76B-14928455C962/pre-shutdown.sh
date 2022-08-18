#!/usr/bin/env zsh
cd ~/dotfiles/ || exit 1

filesChanged="$(git status --porcelain | wc -l | tr -d ' ')"
if [[ -n "$filesChanged" ]] ; then
	echo "📴 pre-shutdown-sync" >> ~"/dotfiles/Cron Jobs/sync.log"
	zsh ~/dotfiles/git-dotfile-sync.sh
	zsh ~"/Main Vault/Meta/git vault backup.sh"
fi
