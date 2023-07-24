#!/usr/bin/env zsh

today=$(date +%Y-%m-%d)
# shellcheck disable=2154
# `!` negates a sed match, q quits. Effectivlely, this reads the file until the first occurence of today
sed "/$today/!q" "$log_location" | cut -d" " -f2-
