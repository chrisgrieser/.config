#!/usr/bin/env zsh
# run in subshell to surpress output

# to import LESS settings
DOTFILE_FOLDER=~/dotfiles
source "$DOTFILE_FOLDER/zsh/docs_man.zsh"


if [[ -z "$2" ]] ; then
	(alacritty \
		--option=window.decorations=full \
		--title="man $1" \
		--command man "$1" &)
else
	(alacritty \
		--option=window.decorations=full \
		--title="man $1" \
		--command man "$1" -P "/usr/bin/less -is --pattern=$2" &)
fi
