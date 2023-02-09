#!/usr/bin/env zsh
# shellcheck disable=2154
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# lowercase & kebab-case
entry_name=${*/ /-}
entry_name=${entry_name:l}

pass generate --clip --no-symbols "$folder/$entry_name" | tail -n1
[[ "$auto_push" == "1" ]] && pass git push &>/dev/null
