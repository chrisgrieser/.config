#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH


# read from .zshenv, default value 45s
delay=${PASSWORD_STORE_CLIP_TIME-45}
pw="$*"

sleep "$delay"
# clear the clipboard only if it is currently in the clipboard
if [[ "$pw" == "$(pbpaste)" ]]; then
	pbcopy </dev/null
	osascript -e "beep"
fi
