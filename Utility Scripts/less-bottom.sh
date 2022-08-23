#!/bin/zsh
# open .log files from Finder via this script, wrapped in the app `less-bottom`.

export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# less ignore-case is actually smart case
alacritty --command less -R \
	--long-prompt \
	+G \
	--window=-4 \
	--incsearch \
	--ignore-case \
	--tilde \
	-- "$1"
