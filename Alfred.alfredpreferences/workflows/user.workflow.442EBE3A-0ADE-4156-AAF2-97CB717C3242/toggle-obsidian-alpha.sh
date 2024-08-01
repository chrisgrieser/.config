#!/usr/bin/env zsh

# toggle .asar file 
pref_path="$HOME/Library/Application Support/obsidian"
asar_file=$(find "$pref_path" -name "obsidian-*.*.*.asar")
bkp_file=$(find "$pref_path" -name "obsidian-*.*.*.asar.bkp")

if [[ -n "$bkp_file" ]]; then
	mv "$bkp_file" "${bkp_file%.bkp}"
	rm "$pref_path"/obsidian-*.*.*.asar # Obsidian creates new .asar for current version if there is none
	msg="disabled"
elif [[ -n "$asar_file" ]]; then
	mv "$asar_file" "$asar_file.bkp"
	msg="enabled"
else
	msg="Error: no asar file found, please download the alpha."
fi

# restart Obsidian
killall "Obsidian"
while pgrep -xq "Obsidian"; do sleep 0.1; done
open -a "Obsidian"

# notify on type of change
echo "$msg"
