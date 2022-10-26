#!/bin/zsh

open -g "obsidian://advanced-uri?commandid=workspace%253Acopy-path"
sleep 0.1

vault_path="${vault_path/#\~/$HOME}"
filepath="$vault_path/$(pbpaste)"

# upload to prose and open URL
scp "$filepath" prose.sh:/ 2>&1 | xargs open

