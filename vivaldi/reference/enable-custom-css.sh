#!/usr/bin/env zsh
# enable custom css in vivaldi
open -a "Vivaldi" "vivaldi://experiments"

# --- 
killall "Vivaldi"
while pgrep -q "Vivaldi" ; do
  sleep 0.1
done
open -a "Vivaldi" "vivaldi://settings/appearance/"
echo -n "$HOME/.config/vivaldi" | pbcopy
