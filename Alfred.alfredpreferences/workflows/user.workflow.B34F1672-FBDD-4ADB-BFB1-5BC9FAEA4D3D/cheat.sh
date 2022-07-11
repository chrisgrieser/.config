#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#-------------------------------------------------------------------------------
# CONFIG

PREVIEW_CONFIG=~/.config/alacritty/preview-window.yml
BG_COLOR=#303643
STATUSLINE_COLOR=#859DC5
STYLE=paraiso-dark # https://cheat.sh/:styles-demo
if [[ "$(scutil --get ComputerName)" =~ "Mac mini" ]]; then
	X=250
	Y=40
	LINES=22
else
	X=700
	Y=250
	LINES=27
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
CACHE="/tmp/$CLEAN_QUERY" # will be displayed in less prompt line at start
echo "$CHEAT_INFO" > "$CACHE"

alacritty \
	--config-file="$PREVIEW_CONFIG" \
	--option="colors.primary.background='$BG_COLOR'" \
	--option="colors.primary.foreground='$STATUSLINE_COLOR'" \
	--option="window.position.x=$X" \
	--option="window.position.y=$Y" \
	--option="window.dimensions.lines=$LINES" \
	--command less -R \
		--long-prompt \
		--window=-4 \
		--incsearch \
		--ignore-case \
		--HILITE-UNREAD \
		--tilde \
		-- "$CACHE"

