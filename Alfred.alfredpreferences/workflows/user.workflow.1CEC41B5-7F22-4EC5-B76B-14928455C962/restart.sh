#!/usr/bin/env zsh
FRONT_APP=$(osascript -e 'tell application "System Events" to return name of first process whose frontmost is true')


if [[ "$FRONT_APP" == "neovide" ]]; then
	# so cursor position and changes are saved properly
	echo "cmd[[wall | quitall]]" > "/tmp/nvim-automation"
else
	killall "$FRONT_APP"
fi


while pgrep -q "$FRONT_APP" ; do sleep 0.1; done


if [[ "$FRONT_APP" == "neovide" ]]; then
	# for neovide, re-open last file
	temp=/tmp/oldfiles.txt
	[[ -e "$temp" ]] && rm "$temp"
	nvim -c "redir > $temp | silent oldfiles | redir end | q"
	sed "2q" "$temp" | cut -d" " -f2 | xargs open
else
	open -a "$FRONT_APP"
fi

