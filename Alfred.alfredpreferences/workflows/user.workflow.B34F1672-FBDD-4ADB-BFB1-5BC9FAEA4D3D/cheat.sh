#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#-------------------------------------------------------------------------------
# CONFIG

CONFIG=~/.config/alacritty/cheatsheet.yml
BG_COLOR=#303643
STYLE=paraiso-dark # https://cheat.sh/:styles-demo
DEVICE_NAME="$(scutil --get ComputerName)"
if [[ "$DEVICE_NAME" =~ "Mac mini" ]]; then
	X=200
	Y=40
	LINES=22
else
	X=600
	Y=100
	LINES=28
fi

#-------------------------------------------------------------------------------

QUERY=$(echo "$*" | sed 's/ /\//' | tr " " "+") # first space → /, all other spaces "+" for url
CHEAT_INFO=$(curl -s "https://cht.sh/$QUERY?style=$STYLE") # https://cht.sh/:help
CHEAT_CODE_ONLY=$(curl -s "https://cht.sh/$QUERY?TQ")

# if empty string, copy the full info instead
if [[ -z "$CHEAT_CODE_ONLY" ]]; then
	CHEAT_CODE_ONLY=$(curl -s "https://cht.sh/$QUERY?T")
fi
echo "$CHEAT_CODE_ONLY" | pbcopy

CLEAN_QUERY=$(echo "$*" | tr "/" " ")
CACHE="/tmp/$CLEAN_QUERY"
echo "$CHEAT_INFO" > "$CACHE"

# title needs to be set for window manager
alacritty \
	--config-file="$CONFIG" \
	--title="cheatsheet: $QUERY" \
	--option="colors.primary.background='$BG_COLOR'" \
	--option="window.position.x=$X" \
	--option="window.position.y=$Y" \
	--option="window.dimensions.lines=$LINES" \
	--command less -R \
		--window=-4 \
		--incsearch \
		--ignore-case \
		--HILITE-UNREAD \
		--tilde \
		-- "$CACHE"

