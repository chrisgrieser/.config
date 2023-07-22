#!/usr/bin/env zsh

# WD defined in .zshenv
# shellcheck disable=1091
touch "$WD/scratch.txt"
open "$WD/scratch.txt"
