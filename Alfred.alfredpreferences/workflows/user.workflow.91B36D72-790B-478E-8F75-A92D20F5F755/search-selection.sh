#!/bin/zsh

# IF SELECTION IS...
# file path: reveal it
# directory path: open it
# url: open in Browser
# email: send to that adress
# some other text: google it
# empty: do nothing

SEL="$*"
SEL="${SEL/#\~/$HOME}"

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
