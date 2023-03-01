#!/usr/bin/env zsh

snippet_file="$1"
snippet="$2"

grep --line-number --max-count=1 "\"$snippet\"" "$snippet_file"
