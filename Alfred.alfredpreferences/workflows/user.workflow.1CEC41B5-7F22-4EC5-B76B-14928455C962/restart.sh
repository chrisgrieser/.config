#!/usr/bin/env zsh
FRONT_APP=$(osascript -e 'tell application "System Events" to return name of first process whose frontmost is true')

if [[ "$FRONT_APP" == "neovide" ]]; then
	# so cursor position and changes are saved properly
	echo "cmd[[qwall]]" >"/tmp/nvim-automation"
else
	killall "$FRONT_APP"
fi

while pgrep -q "$FRONT_APP"; do sleep 0.1; done
sleep 0.1

# for neovide, re-open last file
if [[ "$FRONT_APP" == "neovide" ]]; then
	temp=/tmp/oldfiles.txt
	[[ -e "$temp" ]] && rm "$temp"
	nvim -c "redir > $temp | echo v:oldfiles[0] | redir end | q" &>/dev/null
	sleep 0.1
	open "$(tr -d "\n" <"$temp")"
else
	open -a "$FRONT_APP"
fi
