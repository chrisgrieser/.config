#!/usr/bin/env zsh

# CONFIG
spell_config="$HOME/.config/espanso/match/spelling.yml"
#───────────────────────────────────────────────────────────────────────────────

wrong=$(echo "$*" | cut -d" " -f1)
correct=$(echo "$*" | cut -d" " -f2)
new_line="  - { trigger: $wrong, replace: $correct, propagate_case: true, word: true }"
echo "$new_line" >>"$spell_config"

# espanso restart # required if `auto_restart = false`

# shellcheck disable=2154
if [[ "$open" == "true" ]]; then
	line_no=$(wc -l "$spell_config" | tr -s " " | cut -d" " -f2)
	open "$spell_config" --env=LINE="$line_no"
fi
