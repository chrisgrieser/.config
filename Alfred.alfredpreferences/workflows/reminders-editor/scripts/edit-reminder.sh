#!/usr/bin/env zsh

export LANG="en_US.UTF-8"
export LC_ALL="$LANG"
export LC_CTYPE="$LANG"
#───────────────────────────────────────────────────────────────────────────────

title=$(echo "$*" | head -n1)
body=$(echo "$*" | tail -n +2)

# shellcheck disable=2154 # Alfred variables
msg=$(reminders edit "$reminder_list" "$id" "$title" --notes "$body")
if [[ -z "$msg" ]] ; then
	echo "$*" | pbcopy
	echo -n "⚠️ Not saved! Text copied to clipboard."
else
	echo -n "$title"
fi

