#!/usr/bin/env zsh

entry="$*"
pass generate --in-place "$entry" > /dev/null
pass show "$entry" 2>&1 | head -n1
