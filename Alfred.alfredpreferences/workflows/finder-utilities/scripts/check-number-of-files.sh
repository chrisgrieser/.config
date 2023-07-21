#!/usr/bin/env zsh

# shellcheck disable=1091
source "$HOME/.zshenv"
cd "$WD" || return 1

[[ -z "$(ls)" ]] && echo -n "empty"
