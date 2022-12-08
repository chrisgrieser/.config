#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

if [[ -z "$LINE" ]]; then # $LINE is set via `open --env=LINE=num`
	fileAndLn="$1"
else
	fileAndLn="+$LINE $1"
fi

if pgrep "neovide"; then
	# workaround for: https://github.com/neovide/neovide/issues/1586
	echo "cmd[[edit $fileAndLn]]" >"/tmp/nvim-automation"
else
	neovide "$fileAndLn"
fi
