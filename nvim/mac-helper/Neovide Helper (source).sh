#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#───────────────────────────────────────────────────────────────────────────────
# INFO
# - workaround for: https://github.com/neovide/neovide/issues/1586
# - this script, bundled as .app via Automator, ensures you can open a file from
#   anywhere in macOS and it will open in the currently existing Neovide instance
#───────────────────────────────────────────────────────────────────────────────

address="/tmp/nvim_server.pipe"

if pgrep -xq "neovide"; then
	# https://neovim.io/doc/user/remote.html
	nvim --server "$address" --remote "$@"

	# $LINE is set via `open --env=LINE=n` by the caller
	[[ -n "$LINE" ]] && nvim --server "$address" --remote-send "<cmd>$LINE<CR>"

	osascript -e 'tell application "Neovide" to activate'
else
	[[ -n "$LINE" ]] && LINE="+$LINE"

	# shellcheck disable=2086 # $LINE must be unquoted to prevent opening empty file
	nohup neovide --geometry=104x33 $LINE "$@" &

	disown # https://stackoverflow.com/a/20338584/22114136
fi
