#!/usr/bin/env zsh
# shellcheck disable=2154
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# lowercase & kebab-case
entry_name=${*/ /-}
entry_name=${entry_name:l}

folder=${folder:1} # cut "*" which marked entry as folder

pass generate --clip --no-symbols "$folder/$entry_name" | tail -n1
