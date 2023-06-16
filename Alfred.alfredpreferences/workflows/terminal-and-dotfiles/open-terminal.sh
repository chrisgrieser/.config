#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

FRONT_APP=$(osascript -e 'tell application "System Events" to set frontApp to (name of first process where it is frontmost)')
if [[ "$FRONT_APP" =~ "Finder" ]]; then
	dir_to_open=$(osascript -e '
		tell application "Finder"
			if (count windows) is not 0 then set pathToOpen to target of window 1 as alias
			return POSIX path of pathToOpen
		end tell
	')
elif [[ "$FRONT_APP" =~ "neovide" ]]; then
	# INFO requires vim.opt.titlestring='%{expand(\"%:p\")}'
	win_title=$(osascript -e 'tell application "System Events" to tell process "neovide" to return name of front window')
	dir_to_open=$(dirname "$win_title")
else
	dir_to_open="$WD" # defined in .zshenv
fi

#───────────────────────────────────────────────────────────────────────────────

# INFO Appname is `WezTerm`, processname is `wezterm-gui`
open -a "WezTerm" # launch/activate
while ! pgrep -xq "wezterm-gui"; do sleep 0.1; done
sleep 0.1
echo "cd '$dir_to_open'" | wezterm cli send-text --no-paste
