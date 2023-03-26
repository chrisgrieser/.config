#!/usr/bin/env zsh
# shellcheck disable=2154
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# lowercase & kebab-case
entry_name=${*/ /-}
entry_name=${entry_name:l}

folder=${folder:1} # cut "*" which marked entry as folder

# new password from clipboard
pbpaste | pass insert --echo "$folder/$entry_name" &>/dev/null

echo -n "Password saved for $entry_name"
