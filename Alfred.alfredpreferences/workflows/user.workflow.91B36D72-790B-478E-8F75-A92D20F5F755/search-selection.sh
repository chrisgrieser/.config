#!/bin/zsh

# IF SELECTION IS...
# file path: reveal it in file explorer
# directory path: open it
# url: open in Browser
# email: send to that adress
# some other text: google it
# empty: do nothing

# if no input, copy selection
SEL="$*"
if [[ -z "$SEL" ]] ; then
	PREV_CLIPBOARD=$(pbpaste)
	osascript -e 'tell application "System Events" to keystroke "c" using {command down}'
	sleep 0.1
	SEL=$(pbpaste)
fi

# clean up
SEL=$(echo "$SEL" | xargs echo -n) # trims whitespace
SEL="${SEL/#\~/$HOME}" # resolve ~

# openers
if [[ -f "$SEL" ]]; then
	open -R "$SEL"
elif [[ -d "$SEL" ]]; then
	open "$SEL"
elif [[ "$SEL" =~ ^http.* ]]; then
	URL=$(echo "$SEL" | tr -d " ")
	open "$URL"
elif [[ "$SEL" =~ "@" ]]; then
	open "mailto:$SEL"
elif [[ -n "$SEL" ]]; then
	open "https://www.google.com/search?q=$SEL"
fi

# restore clipboard
if [[ -n "$PREV_CLIPBOARD" ]] ; then
	echo "$PREV_CLIPBOARD" | pbcopy
fi
