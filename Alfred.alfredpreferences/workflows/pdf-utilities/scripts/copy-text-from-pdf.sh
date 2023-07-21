#!/usr/bin/env zsh

if ! command -v pdftotext &>/dev/null; then printf "\033[1;33mpdftotext (poppler) not installed.\033[0m" && return 1; fi

pdfpath="$1"
pdftotext "$pdfpath" - | pbcopy

# for notification
echo -n "$(basename "$pdfpath")"
