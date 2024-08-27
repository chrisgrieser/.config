#!/usr/bin/env zsh

# CONFIG
spell_config="$HOME/.config/espanso/match/spelling.yml"
#───────────────────────────────────────────────────────────────────────────────

wrong=$(echo "$*" | cut -d" " -f1)
correct=$(echo "$*" | cut -d" " -f2)
new_line="  - { trigger: $wrong, replace: $correct, propagate_case: true }"
echo "$new_line" >>"$spell_config"

# shellcheck disable=2154
[[ "$open" == "true" ]] && open "$spell_config"
