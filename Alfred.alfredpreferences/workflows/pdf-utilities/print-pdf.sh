#!/usr/bin/env zsh
lpr "$*"
find "$HOME/Library/Printers" -name "*.app" -exec open "{}" \;
