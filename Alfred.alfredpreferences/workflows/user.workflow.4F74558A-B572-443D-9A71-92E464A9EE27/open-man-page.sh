#!/usr/bin/env zsh

# to import LESS settings like colorization
DOTFILE_FOLDER=~/dotfiles
source "$DOTFILE_FOLDER/zsh/docs_man.zsh"

# INPUT terms
ONE=$(echo "$*" | cut -d" " -f1)
[[ "$*" =~ " " ]] && TWO=$(echo "$*" | cut -d" " -f2)

if [[ -z "$TWO" ]] ; then
	alacritty \
		--option=window.decorations=full \
		--title="man $ONE" \
		--command man "$ONE" &
else
	alacritty \
		--option=window.decorations=full \
		--title="man $ONE" \
		--command man "$ONE" -P "/usr/bin/less -is --pattern=$TWO" &
fi
