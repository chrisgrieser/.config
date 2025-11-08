#!/usr/bin/env zsh
i=0
until ! pgrep -xq "neovide"; do
	sleep 0.05
	i=$((i + 1))
	[[ $i -gt 40 ]] && return 1
done
open -a "neovide"
