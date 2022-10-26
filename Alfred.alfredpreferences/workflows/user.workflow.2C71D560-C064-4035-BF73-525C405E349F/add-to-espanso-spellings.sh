#!/usr/bin/env zsh

spell_config="$HOME/dotfiles/espanso/match/spelling.yml"
wc -l "$spell_config"

wrong=$(echo "$*" | cut -d" " -f1)
correct=$(echo "$*" | cut -d" " -f2)

{ echo "  - trigger: $wrong" ;
  echo "    replace: $correct" ;
  echo "    word: true";        } >> "$spell_config"

LINE_NO=$(wc -l "$spell_config" | tr -s " " | cut -d" " -f2)

# workaround for https://github.com/neovide/neovide/issues/1604
open "$spell_config" --env=LINE=$LINE_NO

