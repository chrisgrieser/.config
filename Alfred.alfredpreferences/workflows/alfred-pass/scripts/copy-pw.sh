#!/usr/bin/env zsh

# DEBUG
gpgconf --kill gpg-agent

# ensure gpg key is unlocked, then passing the entry
entry="$*"
export GPG_TTY="" ; pass show "$entry" >/dev/null 2>&1

# shellcheck disable=2181
if [[ $? -eq 0 ]]; then
    echo "Password store is unlocked"
else
    echo "Password store is locked"
fi
