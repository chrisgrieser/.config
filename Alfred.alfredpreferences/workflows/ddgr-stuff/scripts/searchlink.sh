#!/usr/bin/env zsh
# shellcheck disable=2154,2086
# INFO this scripts basically replaces https://brettterpstra.com/projects/searchlink/

query="$*"
extra_args=$([[ "$noua" == "1" ]] && echo "--noua" || echo "")

# get URL

# using older version https://github.com/jarun/ddgr/blob/15f91df06079847143f5915e53fe6e7c588da80d/ddgr
# PENDING https://github.com/jarun/ddgr/issues/159
response=$(python3 ./binary/ddgr.py --unsafe $extra_args --num=1 --json --reg="$region" "$query")
url=$(echo "$response" | grep "url" | cut -d'"' -f4)
mdlink="[$query]($url)"

# paste via Alfred
echo -n "$mdlink"
