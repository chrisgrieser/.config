#!/bin/zsh
# shellcheck disable=SC2016

# GIT BACKUPS
# ----------------------------------------------------
zsh ~"/Library/Mobile Documents/iCloud~md~obsidian/Documents/Main Vault/Meta/git vault backup.sh"
zsh ~"/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Dotfiles/git-dotfile-backup.sh"

# LOGGING
# ---------------------------------------------------
echo "15-min $(date '+%Y-%m-%d %H:%M')" >> '/Users/chrisgrieser/Library/Mobile Documents/com~apple~CloudDocs/Dotfolder/Dotfiles/Cron Jobs/frequent.log'
