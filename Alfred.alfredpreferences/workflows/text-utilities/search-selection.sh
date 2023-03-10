#!/bin/zsh

# IF SELECTION IS…
# file path: reveal it in file explorer
# directory path: open it
# url: open in Browser
# email: send to that address
# some other text: google it & open first duckduckgo hit
# empty: do nothing

# if no input, copy selection
SEL="$*"
if [[ -z "$SEL" ]]; then
	PREV_CLIPBOARD=$(pbpaste)
	osascript -e 'tell application "System Events" to keystroke "c" using {command down}'
	sleep 0.1
	SEL=$(pbpaste)
	# restore clipboard
	[[ -n "$PREV_CLIPBOARD" ]] && echo "$PREV_CLIPBOARD" | pbcopy
	[[ -z "$SEL" ]] && return 1 # = no selection
fi

# clean up
SEL=$(echo -n "$SEL" | xargs echo -n) # trims whitespace
SEL="${SEL/#\~/$HOME}"                # resolve ~

# openers
if [[ -f "$SEL" ]]; then
	open -R "$SEL"
elif [[ -d "$SEL" ]]; then
	open "$SEL"
elif [[ "$SEL" =~ ^http.* ]]; then
	open "$SEL"
elif [[ "$SEL" =~ "@" ]]; then
	open "mailto:$SEL"
elif [[ -n "$SEL" ]]; then
	URL_ENCODED_SEL=$(osascript -l JavaScript -e "encodeURIComponent('$SEL')")
	open "https://duckduckgo.com/?q=$URL_ENCODED_SEL+!ducky"
	open "https://www.google.com/search?q=$URL_ENCODED_SEL"
	sleep 0.05
	# requires browser to cycle "in tab order", so the DDG lucky window is active
	osascript -e 'tell application "System Events" to keystroke tab using {control down, shift down}'
fi
