#!/usr/bin/env zsh

spell_config="$HOME/dotfiles/espanso/match/spelling.yml"
sublcli="/Applications/Sublime Text.app/Contents/SharedSupport/bin/subl"

wrong=$(echo "$*" | cut -d" " -f1)
correct=$(echo "$*" | cut -d" " -f2)

{ echo "  - trigger: $wrong" ;
  echo "    replace: $correct" ;
  echo "    word: true";        } >> "$spell_config"

lines=$(wc -l "$spell_config")

"$sublcli" "$spell_config:$lines"
