#!/usr/bin/env zsh

#───────────────────────────────────────────────────────────────────────────────
# REGULAR RESTART

FRONT_APP=$(osascript -e 'tell application "System Events" to return name of first process whose frontmost is true')
if [[ "$FRONT_APP" != "neovide" ]]; then
	killall "$FRONT_APP"

	# wait for 2.0 secs
	i=0
	while pgrep -xq "$FRONT_APP"; do
		i=$((i + 1))
		sleep 0.1
		if [[ $i -gt 20 ]]; then
			echo -n "Could not quit $FRONT_APP" # Alfred notification
			return 1
		fi
	done
	sleep 0.2

	[[ "$FRONT_APP" == "wezterm-gui" ]] && FRONT_APP="WezTerm"
	open -a "$FRONT_APP"
	return
fi

#───────────────────────────────────────────────────────────────────────────────
# SPECIAL RESTART FOR NEOVIDE/NVIM

# kill
nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>try|wqall|endtry<CR>"

# wait until dead
i=0
while pgrep -xq "neovide" || pgrep -xq "nvim"; do
	sleep 0.1
	i=$((i + 1))
	if [[ $i -gt 15 ]]; then
		echo -n "Could not quit neovide." # Alfred notification
		return 1
	fi
done

# Restart (looped to ensure it becomes frontmost)
sleep 0.1
for i in {1..3}; do
	open -a "Neovide"
	sleep 0.25
done
