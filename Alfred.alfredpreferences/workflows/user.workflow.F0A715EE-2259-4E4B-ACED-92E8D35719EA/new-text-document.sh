#!/bin/zsh

targetLocation="$*"
targetLocation="${targetLocation/#\~/$HOME}" # resolve path
filename=$(date '+%H-%M-%S')
content=$(pbpaste)

# remove shebang if there is one
if [[ $(echo "$content" | head -n1 | cut -c-2) == '#!' ]] ; then
	content=$(echo "$content" | tail -n +2)
fi

# content & app based on file type
app="Sublime Text"
if [[ $ext == "js" ]] ; then
	content='#!/usr/bin/env osascript -l JavaScript\n'"$content"
fi
if [[ $ext == "sh" ]] ; then
	content='#!/bin/zsh\n'"$content"
fi
if [[ $ext == "applescript" ]] ; then
	content='#!/usr/bin/env osascript\n'"$content"
fi
if [[ $ext == "py" ]] ; then
	content='#!/bin/python\n'"$content"
fi
if [[ $ext == "se-applescript" ]] ; then
	content='#!/usr/bin/env osascript\n'"$content"
	ext="applescript"
	app="Script Editor"
fi
if [[ $ext == "rtf" ]] ; then
	app="TextEdit"
fi

filepath="$targetLocation"/$filename.$ext
echo "$content" >> "$filepath"
open -a "$app" "$filepath"

if [[ "$app" == "Script Editor" ]] ; then
	sleep 0.5
	osascript -e 'tell application "System Events" to keystroke "k" using {command down}'
fi

# echo to give permission as well
echo -n "$filepath"
