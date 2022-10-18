# INFO: on every change of the Neovim.app, it needs to be granted Accessibility
# permissions again to be able to send keystrokes

#───────────────────────────────────────────────────────────────────────────────
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# workaround for: https://github.com/neovide/neovide/issues/1586
if pgrep "neovide" ; then
	prevClipboard="$(pbpaste)"
	echo "$1" | pbcopy
	osascript -e 'tell application "Neovide" to activate
		delay 0.07
		tell application "System Events"
			key code 53
			keystroke ":e "
			keystroke "v" using {command down}
			delay 0.05
			keystroke return
		end tell'
	echo "$prevClipboard" | pbcopy

# workaround for: https://github.com/neovide/neovide/issues/1604
else
	if [[ -z "$LINE" ]] ; then
		neovide "$1"
	else
		neovide "+$LINE" "$1"
	fi
fi
