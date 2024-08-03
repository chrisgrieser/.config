#!/usr/bin/env zsh
if [[ -f "$1" ]]  ; then
	open -R "$1"
elif [[ -d "$1" ]] ; then
	open "$1"
fi
