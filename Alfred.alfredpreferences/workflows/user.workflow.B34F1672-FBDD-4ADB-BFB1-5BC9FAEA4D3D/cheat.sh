#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#-------------------------------------------------------------------------------
# CONFIG

CONFIG=~/.config/alacritty/cheatsheet.yml
BG_COLOR=#303643
STYLE=paraiso-dark # https://cheat.sh/:styles-demo
STATUSLINE_COLOR=#8F9DB5

DEVICE_NAME="$(scutil --get ComputerName)"
if [[ "$DEVICE_NAME" =~ "Office" ]]; then
	X=200
	Y=40
	LINES=22
	FONT_SIZE=23
elif [[ "$DEVICE_NAME" =~ "Home" ]] ; then
	X=550
	Y=100
	LINES=28
	FONT_SIZE=24
fi

#-------------------------------------------------------------------------------

QUERY=$(echo "$*" | sed 's/ /\//' | tr " " "+") # first space → /, all other spaces "+" for url
CLEAN_QUERY=$(echo "$*" | tr "/" " ")
CACHE="/tmp/$CLEAN_QUERY"

if [[ ! -e "$CACHE" ]] ; then
	CHEAT_INFO=$(curl -s "https://cht.sh/$QUERY?style=$STYLE") # https://cht.sh/:help
	echo "$CHEAT_INFO" > "$CACHE"
fi
CHEAT_CODE_ONLY=$(curl -s "https://cht.sh/$QUERY?TQ")
[[ -z "$CHEAT_CODE_ONLY" ]] && CHEAT_CODE_ONLY=$(curl -s "https://cht.sh/$QUERY?T")
echo "$CHEAT_CODE_ONLY" | pbcopy

# title needs to be set for window manager
alacritty \
	--config-file="$CONFIG" \
	--title="cheatsheet: $QUERY" \
	--option="colors.primary.background='$BG_COLOR'" \
	--option="colors.primary.foreground='$STATUSLINE_COLOR'" \
	--option="window.position.x=$X" \
	--option="window.position.y=$Y" \
	--option="window.dimensions.lines=$LINES" \
	--option="font.size=$FONT_SIZE" \
	--command less -R \
		--long-prompt \
		--window=-3 \
		--incsearch \
		--ignore-case \
		--HILITE-UNREAD \
		--tilde \
		-- "$CACHE"
