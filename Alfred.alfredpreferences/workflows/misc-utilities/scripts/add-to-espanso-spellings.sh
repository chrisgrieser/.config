#!/usr/bin/env zsh

# CONFIG
spell_config="$HOME/.config/espanso/match/spelling.yml"
#───────────────────────────────────────────────────────────────────────────────

wrong=$(echo "$*" | cut -d" " -f1)
correct=$(echo "$*" | cut -d" " -f2)
new_line="  - { replace: $correct, trigger: $wrong, propagate_case: true, word: true }"
echo "$new_line" >>"$spell_config"

# shellcheck disable=2154
[[ "$open" == "true" ]] && open "$spell_config"

# for Alfred notification
echo "$wrong → $correct"
