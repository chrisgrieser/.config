#!/usr/bin/env zsh
# shellcheck disable=2086
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#───────────────────────────────────────────────────────────────────────────────
# INFO
# - workaround for: https://github.com/neovide/neovide/issues/1586
# - this script, bundled as .app via Automator, ensures you can open a file from
#   anywhere in macOS and it will open in the currently existing Neovide instance
#───────────────────────────────────────────────────────────────────────────────

if pgrep -xq "neovide"; then
	# https://neovim.io/doc/user/remote.html
	nvim --server "/tmp/nvim_server.pipe" --remote "$@"

	# goto line $LINE is set via `open --env=LINE=num`
	[[ -n "$LINE" ]] && nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>$LINE<CR>"

	osascript -e 'tell application "Neovide" to activate'
else
	[[ -n "$LINE" ]] && LINE="+$LINE"

	# INFO LINE must be unquoted to prevent opening empty file
	nohup neovide --geometry=104x33 --notabs $LINE "$@" &
	disown # https://stackoverflow.com/a/20338584/22114136
fi
