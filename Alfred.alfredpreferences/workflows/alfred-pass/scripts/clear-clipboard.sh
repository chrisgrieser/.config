#!/usr/bin/env zsh
# INFO password clearing is implemented via this script rather than using pass'
# built-in functionality because the built-in functionality requires using `pass
# --clip` which saves the password a non-transiently, meaning it is readable in
# Alfred's clipboard history. Not using `pass --clip` however means that the
# automatic password clearance after after PASSWORD_STORE_CLIP_TIME seconds does
# not take place and therefore needs to be implemented manually here.

#───────────────────────────────────────────────────────────────────────────────

password="$*"

delay=${PASSWORD_STORE_CLIP_TIME-45} # read from .zshenv, default value 45s
sleep "$delay"

# clear the clipboard only if it is currently in the clipboard, to not override
# other clipboard content
if [[ "$password" == "$(pbpaste)" ]]; then
	pbcopy < /dev/null
	echo -n "cleared" # triggers Alfred notification
fi
