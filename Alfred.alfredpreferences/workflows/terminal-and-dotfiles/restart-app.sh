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
while pgrep -xq "neovide"; do
	i=$((i + 1))
	sleep 0.1
	if [[ $i -gt 30 ]]; then
		osascript -e 'display notification "" with title "⚔️ Force killing nvim…"'
		killall -9 nvim neovide
		break
	fi
done

# Restart (config reopens last file if no arg)
open -a "Neovide"
