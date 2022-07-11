#!/usr/bin/env zsh
export PATH=/usr/local/bin/:/opt/homebrew/bin/:$PATH

if [[ $(espanso status) = "espanso is running" ]]; then
	espanso stop
	MSG="OFF 🛑"
else
	opan -a "Espanso"
	sleep 0.5
	espanso start
	MSG="ON 🟢"
fi

echo "Espanso: $MSG"
