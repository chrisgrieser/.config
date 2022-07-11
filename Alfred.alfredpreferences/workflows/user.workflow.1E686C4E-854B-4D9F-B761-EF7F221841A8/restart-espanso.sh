#!/usr/bin/env zsh

if pgrep -x "espanso" > /dev/null; then
	killall "espanso" # needs to be lowercase
	sleep 1
fi

open -a "Espanso"
echo "🟨 Espanso restarted"
