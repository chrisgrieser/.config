#!/usr/bin/env zsh

# not using `echo -n` due to #2
entry="$*"
pass show "$entry" | head -n1
