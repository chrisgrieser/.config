#!/usr/bin/env zsh

today=$(date +%Y-%m-%d)

# `!` negates a sed match, q quits. 
# -> Effectivlely, this reads the file until the *last* occurrence of $today

# shellcheck disable=2154
sed "/$today/!q" "$log_location" | cut -d" " -f2-
