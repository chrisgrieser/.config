#!/usr/bin/env zsh
# shellcheck disable=2154,2034,2296
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────
# Based on
# https://medium.com/@gareth.stretton/obsidian-do-almost-anything-really-with-system-commands-b496ffd0679c
# https://medium.com/@gareth.stretton/obsidian-part-2-system-commands-cdc20836a2b8

# (z) parameter required for zsh to split the string into arguments
# https://stackoverflow.com/a/14099674
# https://zsh.sourceforge.io/Doc/Release/Expansion.html#Parameter-Expansion-Flags
#───────────────────────────────────────────────────────────────────────────────

pipe_cmd="$*"
result=$(cat <<EOF | ${(z)pipe_cmd}
${text}
EOF
)

# shellcheck disable=2181
if [[ $? == 0 ]] ; then
	# paste via clipboard
	echo -n "$result" | pbcopy
	sleep 0.1
	osascript -e 'tell application "System Events" to keystroke "v" using {command down}'
else
	echo -n "🛑 non-zero exit code"
fi

