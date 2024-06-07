#!/usr/bin/env zsh

export LANG="en_US.UTF-8"
export LC_ALL="$LANG"
export LC_CTYPE="$LANG"
#───────────────────────────────────────────────────────────────────────────────

title=$(echo "$*" | head -n1)
body=$(echo "$*" | tail -n +2)
echo "$*" | pbcopy # bkp copy

# shellcheck disable=2154 # Alfred variables
msg=$(reminders edit "$reminder_list" "$id" "$title" --notes="$body")
success=$?
echo "⭕ id: $id" >&2
echo "$msg" >&2 # log msg in Alfred console

if [[ "$success" -ne 0 ]]; then
	echo -n "⚠️ Not saved! Text copied to clipboard."
else
	echo -n "💾 $msg"
fi
