#!/bin/zsh

# IF SELECTION IS…
# file path: reveal it in file explorer
# directory path: open it
# url: open in Browser
# email: send to that address
# some other text: google it & open first duckduckgo hit
# empty: do nothing

#───────────────────────────────────────────────────────────────────────────────

SEL="$*"
# when called via external trigger, will have no input, therefore copying
# selection then
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
SEL=$(echo -n "$SEL" | xargs) # trims whitespace
SEL="${SEL/#\~/$HOME}"			# resolve ~

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
	# shellcheck disable=2154
	URL_2="$search_site$URL_ENCODED_SEL"


#───────────────────────────────────────────────────────────────────────────────
	# INFO opening via `ddgr` because it loads quicker than opening search url with
	# `!ducky` appended
	# URL_1="https://duckduckgo.com/?q=$URL_ENCODED_SEL+!ducky"
	# open "$URL_1"
	ddgr --ducky --noua "$SEL"

#───────────────────────────────────────────────────────────────────────────────

	# OPEN SECOND URL IN BACKGROUND
	# Use AppleScript instead of JXA because the latter cannot create tabs at specific indexes
	# Call it via the shell because otherwise the code is complicated by "using terms from"
	# which requires a specific browser to be installed
	front_browser="$(osascript -e 'tell application "System Events" to return name of first process whose frontmost is true')"

	if [[ "${front_browser}" == 'Safari'* || "${front_browser}" == 'Webkit'* ]]; then
		osascript -e "
	tell application \"${front_browser}\" to tell front window
		set tabIndex to index of current tab
		make new tab at after tab tabIndex with properties {URL:\"${URL_2}\"}
	end tell" >/dev/null # Ignore stdout, otherwise tab info is printed
	elif [[ "${front_browser}" == 'Google Chrome'* || "${front_browser}" == 'Chromium'* || "${front_browser}" == 'Opera'* || "${front_browser}" == 'Vivaldi'* || "${front_browser}" == 'Brave Browser'* || "${front_browser}" == 'Microsoft Edge'* ]]; then
		osascript -e "
	tell application \"${front_browser}\" to tell front window
		set tabIndex to active tab index
		make new tab at after tab tabIndex with properties {URL:\"${URL_2}\"}
		set active tab index to tabIndex
	end tell"
	# As of Orion 0.99.124.1 and Arc 0.105.3, neither exposes tab indexes via AppleScript
	elif [[ "${front_browser}" == 'Orion' || "${front_browser}" == 'Arc' ]]; then
		osascript -e "
	tell application \"${front_browser}\" to tell front window
		make new tab with properties {URL:\"${URL_2}\"}
	end tell" >/dev/null # Ignore stdout, otherwise tab info is printed
	# Browser without AppleScript support, such as Firefox
	else
		open "${URL_2}"
	fi
fi
