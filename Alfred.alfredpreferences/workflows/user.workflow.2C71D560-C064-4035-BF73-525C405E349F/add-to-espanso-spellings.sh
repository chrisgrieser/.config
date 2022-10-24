#!/usr/bin/env zsh

spell_config="$HOME/dotfiles/espanso/match/spelling.yml"

wrong=$(echo "$*" | cut -d" " -f1)
correct=$(echo "$*" | cut -d" " -f2)

{ echo "  - trigger: $wrong" ;
  echo "    replace: $correct" ;
  echo "    word: true";        } >> "$spell_config"

LINE_NO=$(wc -l "$spell_config")

# workaround for https://github.com/neovide/neovide/issues/1604
open "$spell_config" --env=LINE=$LINE_NO
