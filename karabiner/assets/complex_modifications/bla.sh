#!/usr/bin/env zsh


selection=$(osascript -e 'tell application "Finder" to return POSIX path of (selection as alias)')
ext=${$selection##*.}
