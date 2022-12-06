#!/usr/bin/env zsh
# shellcheck disable=2154
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

pass generate --clip --no-symbols "$folder/$*" | tail -n1
[[ "$auto_push" == "1" ]] && pass git push &>/dev/null
