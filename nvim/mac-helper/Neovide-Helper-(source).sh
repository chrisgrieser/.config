#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#───────────────────────────────────────────────────────────────────────────────
# INFO
# - workaround for: https://github.com/neovide/neovide/issues/1586
# - this script, bundled as .app via Automator, ensures you can open a file from
#   anywhere in macOS and it will open in the currently existing Neovide instance
#───────────────────────────────────────────────────────────────────────────────

if pgrep -xq "neovide"; then
	nvim --server "/tmp/nvim_server.pipe" --remote "$@" # https://neovim.io/doc/user/remote.html

	# $LINE is set via `open --env=LINE=n` by the caller
	[[ -n "$LINE" ]] && nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>$LINE<CR>"

	osascript -e 'tell application "Neovide" to activate'
else
	if [[ -z "$LINE" ]]; then
		nohup neovide --geometry=104x33 --notabs "$@" &
		disown # https://stackoverflow.com/a/20338584/22114136
	else
		nohup neovide --geometry=104x33 --notabs "+$LINE" "$@" &
		disown
	fi
fi
