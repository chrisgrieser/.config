#!/usr/bin/env zsh
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
	exitcode=$?

	if [[ $exitcode -ne 0 ]]; then
		osascript -e 'display notification "⚠️ nvim server unresponsive" with title "Neovide"'
		exit 1
	fi

	# $LINE is set via `open --env=LINE=n` by the caller
	[[ -n "$LINE" ]] && nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>$LINE<CR>"

	osascript -e 'tell application "Neovide" to activate'
else
	if [[ -z "$LINE" ]] ; then
		nohup neovide --geometry=104x33 "$@" &
		disown # has to come directly after
	else
		nohup neovide --geometry=104x33 "+$LINE" "$@" &
		disown # has to come directly after
	fi
fi
