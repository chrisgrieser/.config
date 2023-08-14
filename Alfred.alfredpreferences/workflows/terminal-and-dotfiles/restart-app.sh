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
nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>try|wqall|catch|qall|endtry<CR>"

# wait until dead
i=0
while pgrep -xq "neovide" || pgrep -xq "nvim"; do
	sleep 0.1
	i=$((i + 1))
	[[ $i -gt 30 ]] && return 1
done
rm -f "/tmp/nvim_server.pipe" # FIX server sometimes not shut down
sleep 0.1

# Restart (config reopens last file if no arg)
open -a "Neovide"

#───────────────────────────────────────────────────────────────────────────────
# CHECK IF SERVER IS RESPONSIVE

sleep 1 # wait for server

# HACK sleep for 1ms = effectively pinging nvim server
if ! nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>sleep 1m<CR>"; then
	osascript -e 'display notification "" with title "Server unresponsive."'
	killall -9 nvim neovide
	sleep 0.5
	open -a "Neovide"
fi
