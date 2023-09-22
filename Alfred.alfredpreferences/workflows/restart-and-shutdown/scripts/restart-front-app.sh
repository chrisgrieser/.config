#!/usr/bin/env zsh
export PATH=/usr/local/lib:/usr/local/bin:/opt/homebrew/bin/:$PATH

#───────────────────────────────────────────────────────────────────────────────
# REGULAR RESTART

FRONT_APP=$(osascript -e 'tell application "System Events" to return name of first process whose frontmost is true')
if [[ "$FRONT_APP" != "neovide" ]]; then
	killall "$FRONT_APP"

	# wait for 2.5 secs
	i=0
	while pgrep -xq "$FRONT_APP"; do
		i=$((i + 1))
		sleep 0.1
		if [[ $i -gt 25 ]]; then
			osascript -e "display notification \"\" with title \"Could not quit $FRONT_APP\""
			exit 1
		fi
	done

	[[ "$FRONT_APP" == "wezterm-gui" ]] && FRONT_APP="WezTerm"
	open -a "$FRONT_APP"
	return
fi

#───────────────────────────────────────────────────────────────────────────────
# SPECIAL RESTART FOR NEOVIDE/NVIM

# kill
server="/tmp/nvim_server.pipe"
nvim --server "$server" --remote-send "<cmd>try|wqall|catch|qall|endtry<CR>"

# wait until dead
i=0
while pgrep -xq "neovide" || pgrep -xq "nvim"; do
	sleep 0.1
	i=$((i + 1))
	if [[ $i -gt 25 ]]; then
		osascript -e 'display notification "⚔️ Force killing Neovide…" with title "Could not quit."'
		killall -9 neovide nvim || exit 1
	fi
done
sleep 0.1

# Restart
open -a "Neovide" # config reopens last file if no arg

# server responsive?
sleep 2 # wait for server
# HACK sleep for 1ms = effectively pinging nvim server
if ! nvim --server "$server" --remote-send "<cmd>sleep 1m<CR>"; then
	osascript -e 'display notification "" with title "Server unresponsive."'
fi

#───────────────────────────────────────────────────────────────────────────────
