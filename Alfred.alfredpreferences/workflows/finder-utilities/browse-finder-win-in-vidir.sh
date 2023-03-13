#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
finderWin=$(osascript -e 'tell application "Finder" to return POSIX path of (target of window 1 as alias)')

alacritty --working-directory="$finderWin" --command vidir
