#───────────────────────────────────────────────────────────────────────────────
# INFO
# - workaround for: https://github.com/neovide/neovide/issues/1586
# - this script, bundled as .app via Automator, ensures you can open a file from
#   anywhere in macOS and it will open in the currently existing Neovide instance
#───────────────────────────────────────────────────────────────────────────────
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

if pgrep -xq "neovide"; then
	# DOCS # https://neovim.io/doc/user/remote.html
	nvim --server "/tmp/nvim_server.pipe" --remote "$@"

	# $LINE is set via `open --env=LINE=n` by the caller
	[[ -n "$LINE" ]] && nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>$LINE<CR>"

	osascript -e 'tell application "Neovide" to activate'
else
	[[ -z "$LINE" ]] && linearg="+$LINE"
	# shellcheck disable=2086
	nohup neovide --no-tabs $linearg "$@" &
	disown # https://stackoverflow.com/a/20338584/22114136
fi
