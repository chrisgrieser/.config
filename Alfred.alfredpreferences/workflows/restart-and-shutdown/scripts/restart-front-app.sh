#!/usr/bin/env zsh

front_app=$(osascript -e 'tell application "System Events" to return name of first process whose frontmost is true')

#───────────────────────────────────────────────────────────────────────────────
# NEOVIDE
if [[ "$front_app" == "neovide" ]]; then
	# kill
	nvim --server "/tmp/nvim_server.pipe" --remote-send "<cmd>wqall!<CR>"
	killall "emmylua_ls"

	# wait
	while pgrep -xq "nvim" || pgrep -xq "neovide"; do
		i=$((i + 1))
		sleep 0.1
		if [[ $i -gt 20 ]]; then
			echo -n "Could not quit nvim/neovide" # Alfred notification
			return 1
		fi
	done

	# restart
	sleep 0.1
	open -a "neovide"
	return 0
fi

#───────────────────────────────────────────────────────────────────────────────
# REGULAR APP

# kill
killall "$front_app"

# wait
i=0
while pgrep -xq "$front_app"; do
	i=$((i + 1))
	sleep 0.1
	if [[ $i -gt 20 ]]; then
		echo -n "Could not quit $front_app" # Alfred notification
		return 1
	fi
done
sleep 0.2

# restart
[[ "$front_app" == "wezterm-gui" ]] && front_app="WezTerm"
open -a "$front_app"
