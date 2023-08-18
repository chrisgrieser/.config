#!/usr/bin/env zsh

if ! command -v pdftotext &>/dev/null; then printf "pdftotext (poppler) not installed." && return 1; fi

pdfpath="$1"
pdftotext "$pdfpath" - | pbcopy

# for notification
echo -n "$(basename "$pdfpath")"
