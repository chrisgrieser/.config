#!/usr/bin/env zsh

# run separately, since dependencies not needed at once
cd "$LOCAL_REPOS/shimmering-focus/" || return 1
npm i
