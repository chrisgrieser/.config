#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

url=$(echo "$*" | xargs) # remove trailing blankline
repo=$(echo "$url" | cut "")

# turn http url into github ssh remote address
giturl="$(echo "$url" | sed -E 's/https?:\/\/github.com\//git@github.com:/').git"
cd /tmp/ || exit 1
git clone --depth=1 --single-branch "$giturl"
cd ./"$repo" || exit 1



