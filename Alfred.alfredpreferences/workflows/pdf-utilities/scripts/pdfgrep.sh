#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
# shellcheck disable=2154

pdfpath=$(osascript "./scripts/get-pdf-path.applescript")
osascript -l JavaScript "./scripts/pdfgrep.js" "$*" "$pdfpath" 
