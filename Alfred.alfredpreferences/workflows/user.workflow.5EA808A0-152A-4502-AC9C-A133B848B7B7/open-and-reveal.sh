#!/bin/zsh
cd "$*" || return
if [[ -f main.ts ]] ; then
	open -R main.ts
elif [[ -f README.md ]] ; then
	open -R README.md
else
	open .
fi

# enlarge window in Moom
osascript -e "tell application \"System Events\" to keystroke space using {option down}"
