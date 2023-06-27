#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
# shellcheck disable=2154

cache="$alfred_workflow_cache/pdfpath"
if [[ -f "$cache" ]]; then
	
fi
pdfpath=$(osascript "./scripts/get-pdf-path.applescript")
[[ ! -d "$alfred_workflow_cache" ]] && mkdir -p "$alfred_workflow_cache"
echo -n "$pdfpath" > "$alfred_workflow_cache/pdfpath"

osascript -l JavaScript "./scripts/pdfgrep.js" "$*" "$(cat "$alfred_workflow_cache/pdfpath")" 
