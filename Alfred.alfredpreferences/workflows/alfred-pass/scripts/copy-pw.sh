#!/usr/bin/env zsh

# DEBUG
gpgconf --kill gpg-agent

# ensure gpg key is unlocked, then passing the entry
entry="$*"
pass show "$entry" &> /dev/null
echo -n "$entry"
