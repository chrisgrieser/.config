#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# shellcheck disable=1091
source "$HOME/.zshenv" # gets $WD

touch "$WD/scratch.txt"
open "$WD/scratch.txt"
