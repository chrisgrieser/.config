#!/usr/bin/env zsh

# not using `echo -n` due to #2
pass show "$*" | head -n1
