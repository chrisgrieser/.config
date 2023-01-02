#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH
#───────────────────────────────────────────────────────────────────────────────

if ! command -v btop &>/dev/null; then
	osascript -e 'display notification "brew install btop" with title "⚠️ btop not installed"'
	exit 1
fi

# starting with smaller font be able to read all processes
alacritty --option="font.size=20" --option="colors.primary.background='#000000'" --title="btop" --command btop
