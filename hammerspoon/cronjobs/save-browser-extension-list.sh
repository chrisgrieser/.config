#!/usr/bin/env zsh
# shellcheck disable=2010

ls "$HOME/Library/Application Support/BraveSoftware/Brave-Browser/Default/Extensions/" |
	grep -v "Temp" |
	sed "s|^|https://chrome.google.com/webstore/detail/|" \
		> "$HOME/.config/.installed-apps-and-packages/browser-extensions.txt"
