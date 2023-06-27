#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

cache="$alfred_workflow_cache/pdfpath"
pdfpath=$(osascript "./scripts/get-pdf-path.applescript")

# shellcheck disable=2154
[[ ! -d "$alfred_workflow_cache" ]] && mkdir -p "$alfred_workflow_cache"
echo -n "$pdfpath" > "$alfred_workflow_cache/pdfpath"

osascript -l JavaScript "./scripts/pdfgrep.js" "$*" "$(cat "$alfred_workflow_cache/pdfpath")" 
