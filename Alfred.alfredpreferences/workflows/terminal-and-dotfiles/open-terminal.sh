#!/usr/bin/env zsh

if ! command -v wezterm-gui &>/dev/null; then
	osascript -e 'display notification "" with title "❌ wezterm-gui not found." sound name "Basso"'
	return 1
fi

#───────────────────────────────────────────────────────────────────────────────

FRONT_APP=$(osascript -e 'tell application "System Events" to set frontApp to (name of first process where it is frontmost)')
if [[ "$FRONT_APP" == "Finder" ]]; then
	dir_to_open=$(osascript -e 'tell application "Finder" to return POSIX path of (target of window 1 as alias)' | sed -E 's|/$||')
elif [[ "$FRONT_APP" == "neovide" ]]; then
	# INFO requires vim.opt.titlestring='%{expand(\"%:p\")}'
	win_title=$(osascript -e 'tell application "System Events" to tell process "neovide" to return name of front window')
	dir_to_open=$(dirname "$win_title")
elif [[ "$FRONT_APP" == "wezterm-gui" ]]; then
	osascript -e 'tell application "Neovide" to activate'
	return 0
fi

#───────────────────────────────────────────────────────────────────────────────

# INFO
# - Appname is `WezTerm`, processname is `wezterm-gui`
# - not spawning via `wezterm start --cwd`, since that makes wezterm a
#   child-process of this Alfred script, blocking the next run of this script

open -a "WezTerm" # launch/activate
while ! pgrep -xq "wezterm-gui"; do sleep 0.1; done
sleep 0.2 # ensure wezterm-gui is up

current_cwd=$(
	wezterm cli list --format json |
		grep "cwd" | cut -d'"' -f4 | # get value without jq dependency
		sed 's/%20/ /g' |            # simplified url-decode
		sed -E 's|/$||' |              # remove trailing /
		sed -E 's/^file:.*local//'  # file-url to filepath
)

# if directory given and not correct already, open it in wezterm
[[ -n "$dir_to_open" && "$current_cwd" != "$dir_to_open" ]] || return 0
echo "cd '$dir_to_open'" | wezterm cli send-text --no-paste
