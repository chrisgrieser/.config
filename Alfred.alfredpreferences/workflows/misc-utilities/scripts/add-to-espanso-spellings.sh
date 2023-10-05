#!/usr/bin/env zsh

# CONFIG
spell_config="$HOME/.config/espanso/match/spelling.yml"

#───────────────────────────────────────────────────────────────────────────────

wrong=$(echo "$*" | cut -d" " -f1)
correct=$(echo "$*" | cut -d" " -f2)

{
	echo "  - trigger: $wrong"
	echo "    replace: $correct"
	echo "    propagate_casing: true"
	echo "    word: true"
} >>"$spell_config"

# shellcheck disable=2154
[[ "$open" == "false" ]] && return 0

#───────────────────────────────────────────────────────────────────────────────

LINE_NO=$(wc -l "$spell_config" | tr -s " " | cut -d" " -f2)
# workaround for https://github.com/neovide/neovide/issues/1604
# shellcheck disable=2086
open "$spell_config" --env=LINE=$LINE_NO
