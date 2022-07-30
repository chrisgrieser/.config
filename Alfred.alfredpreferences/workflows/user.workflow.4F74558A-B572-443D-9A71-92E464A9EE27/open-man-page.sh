#!/usr/bin/env zsh
# shellcheck disable=SC1091

DOTFILE_FOLDER=~/dotfiles
source "$DOTFILE_FOLDER/zsh/docs_man.zsh"

ONE=$(echo "$*" | cut -d" " -f1)
[[ "$*" =~ " " ]] && TWO=$(echo "$*" | cut -d" " -f2)

man "$ONE" "$TWO"
