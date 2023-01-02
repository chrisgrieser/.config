#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

# starting with smaller font be able to read all processes
alacritty --option="font.size=20" --title="btop" --command btop
