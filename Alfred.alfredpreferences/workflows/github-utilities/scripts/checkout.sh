#!/usr/bin/env zsh

# depending on mode, is either hash or branch, but both work with the same
# checkout command here
hashOrBranch="$*"
git checkout "$hashOrBranch" 2>&1
