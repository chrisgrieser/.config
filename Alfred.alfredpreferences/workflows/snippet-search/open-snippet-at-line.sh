#!/usr/bin/env zsh

snippet_file="$1"
snippet="$2"
line_number=$(grep --line-number --max-count=1 "\"$snippet\"" "$snippet_file" | cut -d: -f1)

# workaround for https://github.com/neovide/neovide/issues/1604
open "$snippet_file" --env=LINE="$line_number"
