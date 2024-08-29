#!/usr/bin/env zsh

entry="$*"
pass generate --in-place "$entry" > /dev/null
pass show "$entry" | head -n1
