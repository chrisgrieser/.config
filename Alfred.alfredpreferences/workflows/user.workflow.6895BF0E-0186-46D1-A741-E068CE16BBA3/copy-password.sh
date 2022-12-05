#!/usr/bin/env zsh
# shellcheck disable=2154
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

pass --clip "$*"
