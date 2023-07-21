#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# run separately, since dependencies not needed at once
cd "$LOCAL_REPOS/shimmering-focus/" || return 1
npm i
