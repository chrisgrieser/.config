#!/usr/bin/env zsh

# KILL
FRONT_APP=$(osascript -e 'tell application "System Events" to return name of first process whose frontmost is true')
if [[ "$FRONT_APP" == "neovide" ]]; then
	# using wqall so changes are saved
	nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>wqall<CR>"
else
	killall "$FRONT_APP"
fi

# WAIT
i=0
while pgrep -xq "$FRONT_APP"; do
	i=$((i + 1))
	sleep 0.1
	if [[ $i -gt 20 ]]; then
		echo -n "Could not quit $FRONT_APP" # Alfred notification
		return 1
	fi
done

# RESTART
[[ "$FRONT_APP" == "wezterm-gui" ]] && FRONT_APP="WezTerm"
sleep 0.2
open -a "$FRONT_APP"
sleep 0.2
open -a "$FRONT_APP" # redundancy to fix sometimes not switching
