# INFO
# - workaround for: https://github.com/neovide/neovide/issues/1586
# - this script, bundled as .app via Automator, ensures you can open a file from
#   anywhere in macOS and it will open in the currently existing Neovide instance
#───────────────────────────────────────────────────────────────────────────────
# In case Automator is deprecated, a script can also be created by compiling JXA?
# https://github.com/vitorgalvao/notificator/blob/master/notificator
#───────────────────────────────────────────────────────────────────────────────
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

if pgrep -xq "neovide"; then
	nvim --server "/tmp/nvim_server.pipe" --remote "$@"
	# $LINE is set via `open --env=LINE=n` by the caller
	[[ -n "$LINE" ]] && nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>$LINE<CR>"

	osascript -e 'tell application "Neovide" to activate'
else
	[[ -z "$LINE" ]] && linearg="+$LINE"

	# FIX Neovide's `config.toml` not working, so adding these as options

	# shellcheck disable=2086
	neovide --title-hidden --no-tabs $linearg "$@" &
	disown
fi
