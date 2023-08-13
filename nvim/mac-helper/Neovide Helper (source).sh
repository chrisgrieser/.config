#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#───────────────────────────────────────────────────────────────────────────────
# INFO
# - workaround for: https://github.com/neovide/neovide/issues/1586
# - this script, bundled as .app via Automator, ensures you can open a file from
#   anywhere in macOS and it will open in the currently existing Neovide instance
#───────────────────────────────────────────────────────────────────────────────

# ensure neovide is open and active
if ! pgrep -xq "neovide"; then
	open -a "Neovide"
	while ! pgrep -xq "neovide"; do sleep 0.1; done
else
	osascript -e 'tell application "Neovide" to activate'
fi

# open file -- https://neovim.io/doc/user/remote.html
nvim --server "/tmp/nvim_server.pipe" --remote "$@"

# goto line -- $LINE is set via `open --env=LINE=n` by the caller
[[ -n "$LINE" ]] && nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>$LINE<CR>"

