#!/usr/bin/env zsh
# shellcheck disable=2154

lang="$*"
path_no_ext=${input_path%.*}
out_path="${path_no_ext}_ocr.pdf"

ocrmypdf --language="$lang" "$input_path" "$out_path"

#───────────────────────────────────────────────────────────────────────────────
# success sound & reveal file
open -R "$out_path"
afplay "/System/Library/Sounds/Blow.aiff" &
