#!/usr/bin/env zsh

# INFO IF SELECTION IS…
# file path: reveal it in Finder.app
# directory path: open it in Finder.app
# url(s): open all urls in Browser
# email: send to that address
# some other text: google it
# empty: do nothing
#───────────────────────────────────────────────────────────────────────────────

sel="$*"
# when called via external trigger, will have no input, therefore copying
# selection then
if [[ -z "$sel" ]]; then
	prev_clipboard=$(pbpaste)
	osascript -e 'tell application "System Events" to keystroke "c" using {command down}'
	sleep 0.1
	sel=$(pbpaste)

	[[ -n "$prev_clipboard" ]] && echo "$prev_clipboard" | pbcopy
	[[ -z "$sel" ]] && return 1 # = no selection
fi

# clean up
sel=$(echo -n "$sel" | xargs) # trims whitespace
sel="${sel/#\~/$HOME}"                                # resolve ~

# openers
if [[ -f "$sel" ]]; then # file
	open -R "$sel"
elif [[ -d "$sel" ]]; then # directory
	open "$sel"
elif echo "$sel" | grep -Eq "https?://"; then # url(s) in selection
	echo "$sel" | grep -Eo "https?://[^> ]*" | xargs open
elif [[ "$sel" =~ "@" ]]; then # mail
	open "mailto:$sel"
elif [[ -n "$sel" ]]; then
	sel=${sel/\'/\\\'}
	url_encoded_sel=$(osascript -l JavaScript -e "encodeURIComponent('$sel')")
	url="https://www.google.com/search?q=$url_encoded_sel"
	open "$url"
fi
