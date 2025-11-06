#!/usr/bin/env zsh
i=0
while pgrep -xq "neovide"; do
	sleep 0.05
	i=$((i + 1))
	if [[ $i -gt 40 ]]; then return; fi
done
open -a "neovide"
