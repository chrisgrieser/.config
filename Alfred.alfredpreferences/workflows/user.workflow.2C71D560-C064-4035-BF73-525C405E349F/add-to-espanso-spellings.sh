#!/usr/bin/env zsh

spell_config="$HOME/dotfiles/espanso/match/spelling.yml"

wrong=$(echo "$*" | cut -d" " -f1)
correct=$(echo "$*" | cut -d" " -f2)

{ echo "  - trigger: $wrong" ;
  echo "    replace: $correct" ;
  echo "    word: true";        } >> "$spell_config"

lines=$(wc -l "$spell_config")

alacritty --command nvim +$LINE_NO "$spell_config"
