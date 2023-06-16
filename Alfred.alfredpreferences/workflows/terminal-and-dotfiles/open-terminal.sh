#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

FRONT_APP=$(osascript -e 'tell application "System Events" to set frontApp to (name of first process where it is frontmost)')
if [[ "$FRONT_APP" =~ "Finder" ]]; then
	dir_to_open=$(osascript -e 'tell application "Finder" to return POSIX path of (target of window 1 as alias)')
elif [[ "$FRONT_APP" =~ "neovide" ]]; then
	# INFO requires vim.opt.titlestring='%{expand(\"%:p\")}'
	win_title=$(osascript -e 'tell application "System Events" to tell process "neovide" to return name of front window')
	dir_to_open=$(dirname "$win_title")
fi

#───────────────────────────────────────────────────────────────────────────────

# INFO 
# - Appname is `WezTerm`, processname is `wezterm-gui`
# - not spawning via `wezterm start --cwd`, since that makes wezterm a
#   child-process of this Alfred script, blocking the next run of this script

open -a "WezTerm" # launch/activate
while ! pgrep -xq "wezterm-gui"; do sleep 0.1; done
sleep 0.2
[[ -n "$dir_to_open" ]] && echo "cd '$dir_to_open'" | wezterm cli send-text --no-paste
