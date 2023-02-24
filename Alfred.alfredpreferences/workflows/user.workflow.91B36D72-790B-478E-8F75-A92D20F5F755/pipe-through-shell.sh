#!/usr/bin/env zsh
# shellcheck disable=2154
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────
# Based on
# https://medium.com/@gareth.stretton/obsidian-do-almost-anything-really-with-system-commands-b496ffd0679c
# https://medium.com/@gareth.stretton/obsidian-part-2-system-commands-cdc20836a2b8
#───────────────────────────────────────────────────────────────────────────────

pipe_cmd="$*"
result=$(cat <<EOF | $pipe_cmd
${selection}
EOF
)

# paste via clipboard
echo -n "$result" | pbcopy
sleep 0.1
osascript -e 'tell application "System Events" to keystroke "v" using {command down}'
