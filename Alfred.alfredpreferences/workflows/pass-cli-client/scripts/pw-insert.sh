#!/usr/bin/env zsh
# shellcheck disable=2154
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# lowercase & kebab-case
entry_name=${*/ /-}
entry_name=${entry_name:l}

folder=${folder:1} # cut "*" which marked entry as folder

pbpaste | pass insert --echo "$folder/$entry_name" # new password from clipboard

echo -n "Password saved for $entry_name"
