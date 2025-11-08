#!/usr/bin/env zsh
i=0
sleep 0.05
	i=$((i + 1))
	[[ $i -gt 40 ]] && return 1
done
open -a "neovide"
