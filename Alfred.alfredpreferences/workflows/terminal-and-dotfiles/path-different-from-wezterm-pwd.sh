#!/usr/bin/env zsh

path_to_open="$*"
if [[ -z "$path_to_open" ]] || ! pgrep -xq "wezterm-gui"; then
	echo -n "just activate terminal"
	return 0
fi

#───────────────────────────────────────────────────────────────────────────────
# This is the only terminal-specific part of this workflow, the rest works
# regardless of the terminal, as long as it is configured for Alfred at
# alfredpreferences://navigateto/features>terminal
current_cwd=$(wezterm cli list --format json | grep 'cwd' | cut -d'"' -f4 | sed 's/%20/ /g' | sed -E 's|/$||' | sed -E 's/^file:.*local//')

#───────────────────────────────────────────────────────────────────────────────

if [[ "$path_to_open" == "$current_cwd" ]] ; then
	echo -n "just activate terminal"
	return 0
fi

echo -n "$path_to_open"
