#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

pass rm "$*" | tail -n1
# shellcheck disable=2154
[[ "$auto_push" == "1" ]] && pass git push &> /dev/null
